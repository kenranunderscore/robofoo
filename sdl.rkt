#lang racket

(provide with-init!
         with-window!)

(require
 (prefix-in sdl2: sdl2/pretty))

;; FIXME handle return values from SDL2 calls

(define-syntax-rule (with-named-resource! resource-id acquire release body ...)
  (let ((resource-id (acquire)))
    ;; Release the resource if anything happens
    (with-handlers (((const true) (λ (exn) (release resource-id))))
      body ...
      (release resource-id))))

(define-syntax-rule (with-resource! acquire release body ...)
  (with-named-resource! _ acquire release body ...))

(define-syntax-rule (with-init! flags body ...)
  (with-resource!
    (λ ()
       (sdl2:set-main-ready!)
       (sdl2:init! flags))
    (const (sdl2:quit!))
    body ...))

(define-syntax-rule (with-window! id title x y w h flags body ...)
  (with-named-resource! id
    (λ ()
       (sdl2:create-window! title x y w h flags))
    sdl2:destroy-window!
    body ...))
