(function_declaration
  name: [
    (identifier)
    (dot_index_expression)
    (method_index_expression)
  ] @name
  (#set! "kind" "Function")) @symbol

(variable_declaration
  (assignment_statement
    (variable_list
      name: [
        (identifier)
        (dot_index_expression)
      ] @name)
    (expression_list
      value: (function_definition) @symbol))
  (#set! "kind" "Function")) @start

(assignment_statement
  (variable_list
    name: [
      (identifier)
      (dot_index_expression)
      (bracket_index_expression)
    ] @name)
  (expression_list
    value: (function_definition) @symbol)
  (#set! "kind" "Function")) @start

(field
  name: (identifier) @name
  value: (function_definition) @symbol
  (#set! "kind" "Function")) @start

(function_call
  name: (identifier) @method @name
  (#any-of? @method "describe" "it" "before_each" "after_each" "setup" "teardown")
  arguments: (arguments
    (string)? @name
    (function_definition) @symbol)
  (#set! "kind" "Function")) @start @selection

(function_call
  name: (dot_index_expression
    table: (identifier) @tbl
    (#match? @tbl "^a")
    field: (identifier) @method @name
    (#any-of? @method "describe" "it" "before_each" "after_each"))
  arguments: (arguments
    (string)? @name
    (function_definition) @symbol)
  (#set! "kind" "Function")) @start @selection

(variable_declaration
  (assignment_statement
    (variable_list
      name: (identifier) @name)
    (expression_list
      value: (table_constructor) @symbol))
  (#set! "kind" "Array")) @start @selection

(field
  name: (identifier) @name
  (#set! "kind" "Field")) @symbol

(field
  name: (string
    content: (string_content) @name)
  (#set! "kind" "Field")) @symbol

(variable_declaration
  (assignment_statement
    (variable_list
      name: (identifier) @name)
    (expression_list
      value: [
        (false)
        (true)
        (string)
        (number)
        (function_call)
        (identifier)
        (dot_index_expression)
        (binary_expression)
        (unary_expression)
        (nil)
      ] @symbol))
  (#set! "kind" "Variable")) @start @selection

(function_call
  name: [
    (identifier)
    (dot_index_expression)
  ] @name
  (#not-match? @name "^(describe|it|before_each|after_each|setup|teardown|require)$")
  (#not-has-parent? @symbol 
    "expression_list"     
    "binary_expression"   
    "unary_expression"    
    "if_statement"        
    "while_statement"     
    "repeat_statement"    
    "elseif_statement"    
    "arguments"           
    "table_constructor"   
  )
  (#set! "kind" "FCall")) @symbol
