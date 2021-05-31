#lang racket

(require
 (prefix-in game: "../game.rkt"))

(provide bot)

(define bot
  (game:robot (const 0)
              (λ (_event _rs is)
                 (list (+ 2 is) 'right))
              (game:color 30 150 90)))
