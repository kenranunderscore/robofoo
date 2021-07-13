#lang racket

(require
 (prefix-in sdl2: sdl2/pretty)
 (prefix-in game: "game.rkt")
 (prefix-in sdl: "sdl.rkt"))

(define (load-robot-from-file path)
  (dynamic-require path 'bot))

(define robot-1 (load-robot-from-file "example-robots/robot-1.rkt"))
(define robot-2 (load-robot-from-file "example-robots/robot-2.rkt"))

(define robot-state-1
  (game:robot-state (game:position 10 10) 100))

(define robot-state-2
  (game:robot-state (game:position 100 190) 100))

(define robots-with-state
  (list (game:robot-with-state robot-1
                               robot-state-1
                               ((game:robot-make-initial-state robot-1) robot-state-1))
        (game:robot-with-state robot-2
                               robot-state-2
                               ((game:robot-make-initial-state robot-2) robot-state-2))))

(define initial-game-state (game:game-state 0 robots-with-state))

(define (draw-robot renderer rws)
  (let* ((p (game:robot-state-pos (game:robot-with-state-state rws)))
         (color (game:robot-color (game:robot-with-state-robot rws)))
         (rect (sdl2:make-rect (game:position-x p) (game:position-y p) 40 40)))
    (sdl2:set-render-draw-color! renderer
                                 (game:color-r color)
                                 (game:color-g color)
                                 (game:color-b color)
                                 255)
    (sdl2:render-fill-rect! renderer rect)))

(define (draw-game renderer gs)
  (map (λ (rws) (draw-robot renderer rws))
       (game:game-state-robots-with-state gs)))

(define (handle-event event)
  (case (sdl:event-type event)
    ((key-down)
     (case (sdl:event-keysym event)
       ((escape)
        (displayln "ESC pressed")
        true)
       (else false)))
    (else false)))

(define (game-loop renderer)
  ;; FIXME call/cc!?
  (letrec ((go (λ (current-state)
                 (define event (sdl:poll-event!))
                 (unless (handle-event event)
                   (sdl2:delay! 20)
                   (sdl2:set-render-draw-color! renderer 30 30 30 255)
                   (sdl2:render-clear! renderer)
                   (draw-game renderer current-state)
                   (sdl2:render-present! renderer)
                   ;; Alternatively: current-game-step and advance only a single one?
                   (go (game:advance current-state))))))
    (go initial-game-state)))

(define (main)
  (sdl:with-init!
   '(video)
   (sdl:with-image-init!
    '(png)
    (sdl:with-window!
     window "abc" 0 0 1024 768 empty
     (sdl:with-renderer!
      renderer window
      (game-loop renderer)
      (sdl2:destroy-renderer! renderer))))))

(main)
