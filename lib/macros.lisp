(defmacro join (glue arr)
  (concat "(" (translate arr) ").join(" (translate glue) ")"))

(defmacro +   (&rest args)
  (concat "(" (join " + " (map args translate)) ")"))
(defmacro -   (&rest args)
  (concat "(" (join " - " (map args translate)) ")"))
(defmacro *   (&rest args)
  (concat "(" (join " * " (map args translate)) ")"))
(defmacro /   (&rest args)
  (concat "(" (join " / " (map args translate)) ")"))
(defmacro or  (&rest args)
  (concat "(" (join " || " (map args translate)) ")"))
(defmacro and (&rest args)
  (concat "(" (join " && " (map args translate)) ")"))
(defmacro >   (&rest args)
  (concat "(" (join " > " (map args translate)) ")"))
(defmacro <   (&rest args)
  (concat "(" (join " < " (map args translate)) ")"))
(defmacro <=  (&rest args)
  (concat "(" (join " <= " (map args translate)) ")"))
(defmacro >=  (&rest args)
  (concat "(" (join " >= " (map args translate)) ")"))
(defmacro =   (&rest args)
  (concat "(" (join " === " (map args translate)) ")"))
(defmacro !=  (&rest args)
  (concat "(" (join " !== " (map args translate)) ")"))

(defmacro mod (&rest args)
  (concat "(" (join " % " (map args translate)) ")"))

(defmacro pow (base exponent)
  (macros.call "Math.pow" base exponent))

(defmacro incr-by (item increment)
  (concat (translate item) " += " (translate increment)))

(defmacro incr (item)
  (concat "((" (translate item) ")++)"))

(defmacro decr (item)
  (concat "((" (translate item) ")--)"))

(defmacro get (arr i) (concat "(" (translate arr) ")[" (translate i) "]"))

(defmacro set (arr &rest kv-pairs)
  (join "\n" (bulk-map kv-pairs
		       (lambda (k v)
			 (concat "(" (translate arr) ")"
				 "[" (translate k) "] = " (translate v) ";")))))
				       
(defmacro send (object method &rest args)
  (concat (translate object) "." (translate method)
	  "(" (join ", " (map args translate)) ")"))

(defmacro new (fn)
  (concat "(new " (translate fn) ")"))

(defmacro regex (string &optional glim)
  ((get macros 'new) (macros.call "RegExp" string (or glim "undefined"))))

(defmacro timestamp ()
  (concat "\"" (send (new (-date)) to-string) "\""))

(defmacro comment (&rest contents)
  (map contents
       (lambda (item)
	 (join "\n" (map (send (translate item) split "\n")
			 (lambda (line) (concat "// " line)))))))

(defmacro meta (body)
  (eval (translate body)))

(defmacro apply (fn arglist)
  (macros.send fn 'apply 'undefined arglist))

(defmacro zero? (item)
  ((get macros "=") (translate item) 0))

(defmacro empty? (arr)
  (concat "((" (translate arr) ").length === 0)"))

(defmacro odd? (number)
  ((get macros "!=") 0
   (macros.mod (translate number) 2)))

(defmacro even? (number)
  ((get macros "=") 0
   (macros.mod (translate number) 2)))


(defmacro function? (thing)
  (concat "typeof(" (translate thing) ") === 'function'"))

(defmacro undefined? (thing)
  (concat "typeof(" (translate thing) ") === 'undefined'"))

(defmacro defined? (thing)
  (concat "typeof(" (translate thing) ") !== 'undefined'"))

(defmacro number? (thing)
  (concat "typeof(" (translate thing) ") === 'number'"))

(defmacro first (arr) (macros.get arr 0))
(defmacro second (arr) (macros.get arr 1))
(defmacro third (arr) (macros.get arr 2))
(defmacro fourth (arr) (macros.get arr 3))
(defmacro fifth (arr) (macros.get arr 4))
(defmacro sixth (arr) (macros.get arr 5))
(defmacro seventh (arr) (macros.get arr 6))
(defmacro eighth (arr) (macros.get arr 7))
(defmacro ninth (arr) (macros.get arr 8))

(defmacro rest (arr)
  (macros.send arr 'slice 1))

(defmacro length (arr)
  (macros.get arr "\"length\""))

(defmacro last (arr)
  (macros.get (macros.send arr 'slice -1) 0))

(defmacro if (arg truebody falsebody)
  (concat
   "(function() {"
   (indent (concat
	    "if (" (translate arg) ") {"
	    (indent (macros.progn truebody))
	    "} else {"
	    (indent (macros.progn falsebody))
	    "};"))
   "})()"))


(defmacro defvar (&rest pairs)
  (concat "var "
	  (join ",\n    "
		(bulk-map pairs
			  (lambda (name value)
			    (concat (translate name) " = "
				    (translate value)))))
	  ";"))

(defmacro string? (thing)
  (concat "typeof(" (translate thing) ") === \"string\""))

(defmacro array? (thing)
  (defvar translated (concat "(" (translate thing) ")"))
  (concat translated " && "
	  translated ".constructor.name === \"Array\""))


(defmacro when (arg &rest body)
  (concat
   "(function() {"
   (indent (concat
	    "if (" (translate arg) ") {"
	    (indent (apply macros.progn body))
	    "};"))
   "})()"))



(defmacro not (exp)
  (concat "(!" (translate exp) ")"))

(defmacro slice (arr start &optional end)
  (macros.send (translate arr) "slice" start end))

(defmacro inspect (&rest args)
  (join " + \"\\n\" + "
   (map args
	(lambda (arg)
	  (concat "\"" arg ":\" + " (translate arg))))))

(defmacro each (item array &rest body)
  (body.unshift item)
  (macros.send (translate array) 'for-each
	(apply macros.lambda body)))


(defmacro setf (&rest args)
  (join "\n"
	(bulk-map args (lambda (name value)
			 (concat (translate name) " = "
				 (translate value) ";")))))

(defmacro list (&rest args)
  (concat "[ " (join ", " (map args translate)) " ]"))

(defmacro macro-list ()
  (concat "["
	  (indent (join ",\n"
			(map (-object.keys macros)
			     macros.quote)))
	  "]"))

(defmacro macroexpand (name)
  (defvar macro (get macros (translate name)))
  (if macro
      (concat "// macro: " name "\n" (send macro to-string))
    "undefined"))

(defmacro throw (&rest string)
  (concat "throw new Error (" (join " " (map string translate)) ")"))

(defmacro as-boolean (expr)
  (concat "(!!(" (translate expr) "))"))

(defmacro force-semi () (concat ";\n"))

(defmacro chain (object &rest calls)
  (concat (translate object) " // chain"
	  (indent (join "\n"
		(map calls
		     (lambda (call, index)
		       (defvar method (first call))
		       (defvar args (rest call))
		       (concat "." (translate method)
			       "(" (join ", " (map args translate)) ")")))))))

(defmacro try (tryblock catchblock)
  (concat
   "(function() {"
   (indent (concat
	    "try {"
	    (indent (macros.progn tryblock))
	    "} catch (e) {"
	    (indent (macros.progn catchblock))
	    "}"))
   "})()"))


(defmacro while (condition &rest block)
  (macros.scoped
   (macros.defvar '**return-value**)
   (concat "while (" (translate condition) ") {"
           (indent (macros.setf '**return-value**
                                (apply macros.scoped block))))
   "}"
   '**return-value**))

(defmacro until (condition &rest block)
  (defvar condition (list 'not condition))
  (send block unshift condition)
  (apply (get macros 'while) block))


(defmacro thunk (&rest args)
  (args.unshift (list))
  (apply macros.lambda args))

(defmacro keys (obj)
  (macros.call "Object.keys" (translate obj)))

(defmacro delete (&rest objects)
  (join "\n" (map objects (lambda (obj)
                            (concat "delete " (translate obj) ";")))))

(defmacro delmacro (macro-name)
  (delete (get macros (translate macro-name))) "")

(defmacro defhash (name &rest pairs)
  (macros.defvar name (apply macros.hash pairs)))

(defmacro arguments ()
  "(Array.prototype.slice.apply(arguments))")

(defmacro scoped (&rest body)
  (macros.call (apply macros.thunk body)))

(defmacro each-key (as obj &rest body)
  (concat "(function() {"
	  (indent
	   (concat "for (var " (translate as) " in " (translate obj) ") "
		   (apply macros.scoped body)
		   ";"))
	  "})();"))

(defmacro match? (regexp string)
  (macros.send string 'match regexp))

(defmacro switch (obj &rest cases)

  ;; the complexity of this macro indicates there's a problem
  ;; I'm not quite sure where to fix this, but it has to do with quoting.
  (defvar lines (list (concat "switch(" (translate obj) ") {")))
  (each (case-def) cases
	(defvar case-name (case-def.shift))
	(when (and (array? case-name)
		   (= (first case-name) 'quote))
	  (defvar second (second case-name))
	  (setf case-name (if (array? second)
			      (map second macros.quote)
			    (macros.quote second))))
	
	(defvar case-string
	  (if (array? case-name)
	      (join "\n" (map case-name (lambda (c)
					  (concat "case " (translate c) ":"))))
	    (if (= 'default case-name) "default:"
	      (concat "case " (translate case-name) ":"))))
	
	(lines.push (concat case-string
			    (indent (apply macros.progn case-def)))))

  ; the following two lines are to get the whitespace right
  ; this is necessary because switches are indented weird
  (set lines (- lines.length 1)
       (chain (get lines (- lines.length 1)) (concat "}")))

  (concat "(function() {" (apply indent lines) "})()"))
