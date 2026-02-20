(import_from_statement 
    module_name: (dotted_name 
      (identifier) @name
	  ) 
  (#set! "kind" "Module")) @symbol

(import_statement 
  name: (dotted_name 
      (identifier) @name
	  )
(#set! "kind" "Module")) @symbol
 

(function_definition
  name: (identifier) @name
  (#set! "kind" "Function")) @symbol

(class_definition
  name: (identifier) @name
  (#set! "kind" "Class")) @symbol

(assignment
  left: (identifier) @name
  (#match? @name "^[A-Z_][A-Z0-9_]*$")
  (#set! "kind" "Constant")) @symbol

(assignment
  left: (identifier) @name
  (#not-match? @name "^[A-Z_][A-Z0-9_]*$")
  (#set! "kind" "Variable")) @symbol

(expression_statement
  (call
    function: (_) @name)
  (#set! "kind" "FCall")) @symbol

(decorated_definition
  (decorator) @name
  (#set! "kind" "Event")) @symbol
