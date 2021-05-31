#lang racket

(require
 (prefix-in game: "../game.rkt"))

(provide bot)

(define (make-test-bot robot-state)
  empty)

(define my-color (game:color 0 100 200))

(define (react-to-tick event _robot-state internal-state)
  (define current-tick (game:tick-event-tick event))
  (list internal-state
        (case (modulo current-tick 3)
          ('0 'up)
          ('1 'down)
          ('2 'up))))

(define bot
  (game:robot make-test-bot
              react-to-tick
              my-color))
