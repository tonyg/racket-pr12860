#lang racket/base

(require racket/tcp)
(require racket/port)

(define (make-alarm-e)
  (alarm-evt (+ (current-inexact-milliseconds) 50)))

(define ((connection-handler in out with-alarm?))
  (let loop ((alarm-e (make-alarm-e))
	     (read-e (read-bytes-evt 16 in)))
    (sync (if with-alarm?
	      (wrap-evt alarm-e (lambda (_) (loop (make-alarm-e) read-e)))
	      never-evt)
	  (wrap-evt read-e
		    (lambda (bs)
		      (when (bytes? bs)
			(sleep 0.01)
			(write-bytes bs out)
			(flush-output out))
		      (loop alarm-e read-e)))
	  (wrap-evt (eof-evt in)
		    (lambda (_)
		      (close-input-port in)
		      (close-output-port out))))))

(define (main port with-alarm?)
  (define listener (tcp-listen port 4 #t))
  (let listen-loop ()
    (write `(Waiting and with-alarm = ,with-alarm?)) (newline) (flush-output)
    (define-values (in out) (tcp-accept listener))
    (thread (connection-handler in out with-alarm?))
    (listen-loop)))

(main 5999 (cond
	    [(equal? (current-command-line-arguments) '#("1")) #t]
	    [(equal? (current-command-line-arguments) '#("0")) #f]
	    [else (error 'main "Expected command-line argument either '1' or '0'.")]))
