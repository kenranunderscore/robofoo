#lang racket

(require
 (prefix-in sdl2: sdl2/pretty))
(require
 (prefix-in game: "game.rkt"))
(require
 (prefix-in sdl: "sdl.rkt"))

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

(define (main)
  (sdl:with-init!
   '(video)
   (sdl:with-window!
    window "abc" 0 0 1024 768 empty
    (sdl:with-renderer!
     renderer window
     (define (game-loop gs)
       (sdl2:set-render-draw-color! renderer 30 30 30 255)
       (sdl2:render-clear! renderer)
       (draw-game renderer gs)
       (sdl2:render-present! renderer))
     (game-loop initial-game-state)
     (sdl2:delay! 2000)
     (sdl2:destroy-renderer! renderer)))))

(main)
