;;;; simple.scm

;;;; This is a glls version of the example found on the opengl-glew wiki page:
;;;; https://wiki.call-cc.org/eggref/4/opengl-glew
;;;;
;;;; NOTE:
;;;; This uses glls-render, so if this file is compiled it must be linked with OpenGL
;;;; E.g.:
;;;; csc -lGL simple.scm

(module simple-glls-example *

(import chicken scheme)
(use glls-render (prefix glfw3 glfw:) (prefix opengl-glew gl:) gl-math gl-utils)

;;; VAO data
(define vertex-data (f32vector -1 -1 1 0 0
                               1 -1 0 1 0
                               1 1 0 0 1
                               -1 1 1 0 1))

(define index-data (u16vector 0 1 2
                              0 2 3))

(define vao (make-parameter #f))

;;; Matrices
(define projection-matrix
  (perspective 640 480 0.1 100 70))

(define view-matrix
  (look-at (make-point 1 0 3)
           (make-point 0 0 0)
           (make-point 0 1 0)))

(define model-matrix (mat4-identity))

(define mvp (m* projection-matrix
                (m* view-matrix model-matrix)
                #t ; Matrix should be in a non-GC'd area
                ))


;;; Pipeline definition
(define-pipeline simple-shader
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

(define renderable (make-parameter #f))

;;; Initialization and main loop
(glfw:with-window (640 480 "Example" resizable: #f)
  (gl:init)
  (compile-pipelines)
  (let ([vao (make-vao vertex-data index-data
                       `((,(pipeline-attribute 'vertex simple-shader) float: 2)
                         (,(pipeline-attribute 'color simple-shader) float: 3)))])
    (renderable (make-simple-shader-renderable
                 n-elements: (u16vector-length index-data)
                 element-type: (type->gl-type ushort:)
                 vao: vao
                 mvp: mvp)))
  (let loop ()
     (glfw:swap-buffers (glfw:window))
     (gl:clear (bitwise-ior gl:+color-buffer-bit+ gl:+depth-buffer-bit+))
     (render-simple-shader (renderable))
     (check-error)
     (glfw:poll-events)
     (unless (glfw:window-should-close (glfw:window))
       (loop))))

) ; end module
