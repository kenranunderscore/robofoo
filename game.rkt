#lang racket

(provide (struct-out robot-state)
         (struct-out robot)
         (struct-out position)
         (struct-out tick-event)
         (struct-out game-state)
         (struct-out robot-with-state)
         (struct-out color)
         advance)

(require threading)

(struct position (x y))
(struct color (r g b))

;; FIXME color -> robot-configuration
;; FIXME game configuration (field size, robot size, ...)

;; A robot consists of the the following:
;; - A function to create some self-managed state given its initial
;;   game-assigned robot-state. Signature: robot-state -> 'a.
;; - A function to react to a new game tick event. Signature:
;;   tick-event -> robot-state -> 'a -> ('a, action) (FIXME: no action yet).
;; - A color with which it is drawn.
(struct robot (make-initial-state on-tick color))

(struct robot-state (pos hp))
(struct robot-with-state (robot state internal-state))
(struct tick-event (tick))
(struct game-state (tick robots-with-state))

;; FIXME use match

(define (action->state-update action)
  (λ (rs)
     (define current-position (robot-state-pos rs))
     (define next-pos
       (case action
         ('up (struct-copy position
                            current-position
                            (y (+ (position-y current-position) 1))))
         ('down (struct-copy position
                              current-position
                              (y (- (position-y current-position) 1))))
         ('left (struct-copy position
                              current-position
                              (x (- (position-x current-position) 1))))
         ('right (struct-copy position
                               current-position
                               (x (+ (position-x current-position) 1))))
         ('stay current-position)))
     (struct-copy robot-state
                  rs
                  (pos next-pos))))

(define (do-tick current-tick)
  (λ (rws)
     (define r (robot-with-state-robot rws))
     (define rs (robot-with-state-state rws))
     (define robot-decision
       ((robot-on-tick r) (tick-event current-tick)
                          rs
                          (robot-with-state-internal-state rws)))
     (define next-internal-state (car robot-decision))
     (define action (cadr robot-decision))
     (struct-copy robot-with-state
                  rws
                  (internal-state next-internal-state)
                  (state ((action->state-update action) rs)))))

(define (advance current-game-state)
  (define current-tick (game-state-tick current-game-state))
  (define rwss (game-state-robots-with-state current-game-state))
  (define robots-with-final-states (~>> rwss
                                        (map (do-tick current-tick))))
  (struct-copy game-state
               current-game-state
               (tick (+ 1 current-tick))
               (robots-with-state robots-with-final-states)))
