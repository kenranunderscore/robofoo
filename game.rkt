#lang racket

(provide (struct-out robot-state)
         (struct-out robot)
         (struct-out position)
         (struct-out tick-event)
         (struct-out game-state)
         (struct-out robot-with-state)
         (struct-out color)
         advance)

(struct position (x y))
(struct color (r g b))
(struct robot (on-tick color))
(struct robot-state (pos hp))
(struct robot-with-state (robot state))
(struct tick-event (tick))
(struct game-state (tick robots-with-state))

(define (advance-position pos)
  (struct-copy position pos (x (+ 1 (position-x pos)))))

(define (advance-robot-with-state rws)
  (define s (robot-with-state-state rws))
  (define next-state (struct-copy robot-state
                                  s
                                  (pos (advance-position (robot-state-pos s)))))
  (struct-copy robot-with-state rws (state next-state)))

(define (advance current-game-state)
  (define current-tick (game-state-tick current-game-state))
  (define rwss (game-state-robots-with-state current-game-state))
  (struct-copy game-state
               current-game-state
               (tick (+ 1 current-tick))
               (robots-with-state (map advance-robot-with-state rwss))))
