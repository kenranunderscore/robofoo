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

(define (do-tick current-tick)
  (λ (rws)
     (define r (robot-with-state-robot rws))
     (define next-internal-state
       ((robot-on-tick r) (tick-event current-tick)
                          (robot-with-state-state rws)
                          (robot-with-state-internal-state rws)))
     (struct-copy robot-with-state
                  rws
                  (internal-state next-internal-state))))

(define (advance current-game-state)
  (define current-tick (game-state-tick current-game-state))
  (define rwss (game-state-robots-with-state current-game-state))
  (define robots-with-final-states (~>> rwss
                                        (map (do-tick current-tick))))
  (struct-copy game-state
               current-game-state
               (tick (+ 1 current-tick))
               (robots-with-state robots-with-final-states)))
