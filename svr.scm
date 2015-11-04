#!/usr/bin/env gosh

;;; playground on heroku

(use gauche.parseopt)
(use text.html-lite)
(use makiki)

(define-http-handler "/"
  (^[req app]
    ($ respond/ok req
       '(sxml
		 (html
          (head
		   (title "The Gauche Playground")
		   (link (@ (rel "stylesheet")
					(href "/static/css/jquery.numberedtextarea.css")))
		   (script (@ (src "/static/js/jquery-1.11.3.min.js")) "")
		   (script (@ (src "/static/js/jquery.numberedtextarea.js")) "")
		   (script (@ (src "/static/js/index.js")) ""))
          (body
		   (p "The Gauche Playground")
		   (button "RUN")
		   (textarea (@ (style "margin-top:1rem;width:100%;height:50%;resize:vertical;")) "")
		   (pre (@ (style "margin:1.8rem 0;"))
				(p (@ (id "result")
					  (style "max-height:15rem;overflow-y:auto;"))))
		   (p (@ (id "status") (style "color:grey;")))
		   ))))))

(define-http-handler #/^\/static(\/.*)$/
  (file-handler :directory-index '()
				:path-trans (^[req] ((request-path-rxmatch req) 0))))


(define (eval-code code)
  (guard (e (else #`"ERROR: ,(ref e 'message)"))
	(with-string-io code
	  (^() (let1 env (make-module #f)
			 (until (read (current-input-port)) eof-object? => expr
					(eval expr env))
			 (when (global-variable-bound? env 'main)
			   ((global-variable-ref env 'main) '()))
			 )))))

(define-http-handler "/eval"
  (^[req app]
    (let ([code (request-param-ref req "code")])
	  ($ respond/ok req
		 `(json
		   ((result . ,(html-escape-string (eval-code code))))
		   )))))


(define (main args)
  (let-args (cdr args)
			((port "p|port=s"))
			(start-http-server :port port)
			0))

;; Local variables:
;; mode: scheme
;; end:
