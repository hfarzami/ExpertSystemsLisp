; HOW answers "How did you deduce that FACT?" questions.
(defun how (fact)
	(let
		(success)
		
		; any fired rules with FACT in the then-part?
		(dolist (possibility *rulesused*)
		
			(setf x (caar possibility))
			(if (equal x 'ifall)
				(setf x 'ALL)
				(setf x 'SOME)		 
			)
			(when (and (then-p fact possibility) (equal x 'ALL))
				(format t "~%~a demonstrated by " fact)
				(setq success t)
				(format t " ALL of ~%")
				(dolist (possible (cdar possibility))
					(format t "~a~%" possible)
				)				
			)
			
			(when (and (then-p fact possibility) (equal x 'SOME))
				(format t "~%~a demonstrated by " fact)
				(setq success t)
				(format t " SOME of ~%")
				(dolist (possible (cdar possibility))
					(format t "~a~%" possible)
				)	
			)
		)
		; if not, perhaps FACT was given in original knowledge base, or is not known to be true
		(cond
			(success t)
			((recall fact) (format t "~a was given.~%" fact) t)
			(t (format t "~a is not established.~%" fact) nil)
		)
		(format t "~%")
	)
)


; WHY answers "Why did you deduce that FACT?" questions.
(defun why (fact)
	(let
		(success)
		(format t "~%~a needed to establish~%" fact)
		; any fired rules with FACT in the if-part?
		(dolist (possibility *rulesused*)
			(when (if-p fact possibility)
				(setq success t)
				; if so, list the then-parts
				
				(dolist (possible  (cdadr possibility))
					(format t "~a~%" possible)
				)
			)
		)

		; if not, perhaps FACT was a hypothesis to be proved, or is not known to be true
		(cond
			(success t)
			((recall fact) (format t "~a was hypothesis.~%" fact) t)
			(t (format t "~a is not established.~%" fact) nil)
		)
		(format t "~%")
	)
)

(defun then-p (fact rule)
	(let (then)
	; set then-part with a fact in then-part of the rule
	(setf then (cadadr rule))
	; if slot and value is matched, return the rule
	(if (and (equal (first fact) (first then)) (equal (second fact) (second then)) (equal (third fact) (third then)))
		T
		NIL
	)
	)
)

(defun if-p (fact rule)
(let (
	(if-parts (cdar rule))
	)
	; for each if-part
	(dolist (ifs if-parts)
		(cond
			((equal (second ifs) '=) ; the from (a = b)
				; if slot and value is matched, return the rule
				(if (and (equal (first fact) (first ifs)) (equal (second fact) (second ifs)) (equal (third fact) (third ifs)))
					(return-from if-p rule)
				)
			)
			((equal (second ifs) '>) ; the form (a > b)
				; if slot is matched and the values satisfy the relation, return the rule
				(if (and (equal (first fact) (first ifs)) (> (caddr fact) (caddr ifs)))
					(return-from if-p rule)
				)
			)
			(T                         ; the form (a < b)
				; if slot is matched and the values satisfy the relation, return the rule
				(if (and (equal (first fact) (first ifs)) (< (caddr fact) (caddr ifs)))
					(return-from if-p rule)
				)
			)
		)
	)
	; if no match, return NIL
	NIL
))
