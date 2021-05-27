#lang racket

(require
 (prefix-in sdl2: sdl2/pretty))
(require ffi/unsafe)
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

(define (handle-event event)
  (case (union-ref event 0)
    ((key-down)
     (case (sdl2:keysym-sym (sdl2:keyboard-event-keysym (union-ref event 4)))
       ((escape)
        (displayln "ESC pressed")
        true)
       (else false)))
    (else false)))

(define (game-loop renderer)
  (define event-ptr
    (cast (malloc (ctype-sizeof sdl2:_event))
          _pointer sdl2:_event*))
  ;; FIXME call/cc!?
  (letrec ((go (λ (current-state)
                 (sdl2:wait-event! event-ptr)
                 (define event (ptr-ref event-ptr sdl2:_event))
                 (unless (handle-event event)
                   (sdl2:set-render-draw-color! renderer 30 30 30 255)
                   (sdl2:render-clear! renderer)
                   (draw-game renderer current-state)
                   (sdl2:render-present! renderer)
                   (go current-state)))))
    (go initial-game-state)))

(define (main)
  (sdl:with-init!
   '(video)
   (sdl:with-window!
    window "abc" 0 0 1024 768 empty
    (sdl:with-renderer!
     renderer window
     (game-loop renderer)
     (sdl2:delay! 2000)
     (sdl2:destroy-renderer! renderer)))))

(main)
