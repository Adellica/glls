;;;; basic.scm

;;;; This is the second example found on the glls wiki page:
;;;; https://wiki.call-cc.org/eggref/4/glls

(module basic-shader-example *

(import chicken scheme)

(use glls (prefix glfw3 glfw:) (prefix opengl-glew gl:))

(define-pipeline foo 
  ((#:vertex input: ((vertex #:vec2) (color #:vec3))
                             uniform: ((mvp #:mat4))
                             output: ((c #:vec3)))
   (define (main) #:void
     (set! gl:position (* mvp (vec4 vertex 0.0 1.0)))
     (set! c color)))
  ((#:fragment input: ((c #:vec3))
               output: ((frag-color #:vec4)))
   (define (main) #:void
     (set! frag-color (vec4 c 1.0)))))

(define-shader bar (#:vertex input: ((vertex #:vec2) (color #:vec3))
                             uniform: ((mvp #:mat4))
                             output: ((c #:vec3)))
  (define (main) #:void
    (set! gl:position (* mvp (vec4 vertex 0.0 1.0)))
    (set! c color)))

(define-pipeline baz 
  (bar uniform: (mvp #:mat4))
  (cadr (pipeline-shaders foo)))

(glfw:with-window (640 480 "Example" resizable: #f)
   (gl:init)
   (compile-pipelines)
   (print foo)
   (print baz))
) ; end module
