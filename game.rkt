#lang racket

(provide (struct-out robot-state)
         (struct-out robot)
         (struct-out position)
         (struct-out tick-event)
         (struct-out game-state)
         (struct-out robot-with-state)
         (struct-out color))

(struct position (x y))
(struct color (r g b))
(struct robot (on-tick color))
(struct robot-state (pos hp))
(struct robot-with-state (robot state))
(struct tick-event (tick))
(struct game-state (tick robots-with-state))
