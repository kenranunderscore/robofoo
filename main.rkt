#lang racket

(require
 (prefix-in sdl2: sdl2/pretty))
(require
 (prefix-in game: "game.rkt"))

(define robot-1
  (game:robot (λ (event _)
                 (print "foo")
                 (print event))
              (game:color 30 150 90)))

(define robot-2
  (game:robot (λ (event _)
                 (print "foo")
                 (print event))
              (game:color 0 100 200)))

(define robot-state-1
  (game:robot-state (game:position 10 10) 100))

(define robot-state-2
  (game:robot-state (game:position 100 190) 100))

(define robots-with-state
  (list (game:robot-with-state robot-1 robot-state-1)
        (game:robot-with-state robot-2 robot-state-2)))

(define initial-game-state (game:game-state 0 robots-with-state))

(define (draw-robot renderer rws)
  (let* ((p (game:robot-state-pos (game:robot-with-state-state rws)))
         (color (game:robot-color (game:robot-with-state-robot rws)))
         (rect (sdl2:make-rect (game:position-x p) (game:position-y p) 20 20)))
    (sdl2:set-render-draw-color! renderer
                                 (game:color-r color)
                                 (game:color-g color)
                                 (game:color-b color)
                                 255)
    (sdl2:render-fill-rect! renderer rect)))

(define (draw-game renderer gs)
  (map (λ (rws) (draw-robot renderer rws))
       (game:game-state-robots-with-state gs)))

;; FIXME handle exceptions
(define (cleanup! renderer window)
  (sdl2:destroy-renderer! renderer)
  (sdl2:destroy-window! window)
  (sdl2:quit!))

(define (main)
  (sdl2:set-main-ready!)
  (sdl2:init! '(video))
  (let* ((window (sdl2:create-window! "Hello world" 0 0 600 400 '()))
         (renderer (sdl2:create-renderer! window -1 '())))
    (define (game-loop gs)
      (sdl2:set-render-draw-color! renderer 30 30 30 255)
      (sdl2:render-clear! renderer)
      (draw-game renderer gs)
      (sdl2:render-present! renderer))
    (game-loop initial-game-state)
    (sdl2:delay! 2000)
    (cleanup! renderer window)))

(main)
