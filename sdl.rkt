#lang racket

(provide with-init!
         with-image-init!
         with-window!
         with-renderer!
         poll-event!
         event-type
         event-keysym)

(require
 (prefix-in sdl2: sdl2/pretty)
 (prefix-in sdl2-image: sdl2/image/pretty)
 (prefix-in ffi: ffi/unsafe))

;; FIXME handle return values from SDL2 calls

(define-syntax-rule (with-named-resource! resource-id acquire release body ...)
  (let ((resource-id (acquire)))
    ;; Release the resource if anything happens
    (with-handlers (((const true)
                     (λ (exn)
                        (displayln "Encountered the following runtime error:")
                        (displayln exn)
                        (release resource-id))))
      body ...
      (release resource-id))))

(define-syntax-rule (with-resource! acquire release body ...)
  (with-named-resource! _ acquire release body ...))

(define-syntax-rule (with-init! flags body ...)
  (with-resource!
    (λ ()
       (displayln "Initializing SDL…")
       (sdl2:set-main-ready!)
       (sdl2:init! flags)
       (displayln "SDL initialized"))
    (λ (_)
       (displayln "Quitting SDL…")
       (sdl2:quit!))
    body ...))

(define-syntax-rule (with-image-init! flags body ...)
  (with-resource!
    (λ ()
       (displayln "Initializing SDL_Image…")
       (sdl2-image:init! flags)
       (displayln "SDL_Image initialized"))
    (λ (_)
       (displayln "Quitting SDL_Image…")
       (sdl2-image:quit!))
    body ...))

(define-syntax-rule (with-window! id title x y w h flags body ...)
  (with-named-resource! id
    (λ ()
       (displayln "Creating game window…")
       (sdl2:create-window! title x y w h flags))
    (λ (window)
       (displayln "Destroying window…")
       (sdl2:destroy-window! window))
    body ...))

(define-syntax-rule (with-renderer! renderer-id window body ...)
  (with-named-resource! renderer-id
    (λ ()
       (displayln "Creating renderer…")
       (sdl2:create-renderer! window -1 empty))
    (λ (renderer)
       (displayln "Destroying renderer…")
       (sdl2:destroy-renderer! renderer))
    body ...))

(define event-ptr (ffi:cast (ffi:malloc (ffi:ctype-sizeof sdl2:_event))
                            ffi:_pointer sdl2:_event*))

(define (poll-event!)
  (unless (zero? (sdl2:poll-event! event-ptr))
    (ffi:ptr-ref event-ptr sdl2:_event)))

(define (event-type event)
  (ffi:union-ref event 0))

(define (event-keysym event)
  (sdl2:keysym-sym
   (sdl2:keyboard-event-keysym
    (ffi:union-ref event 4))))
