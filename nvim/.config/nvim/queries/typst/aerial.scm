(section
  (heading
    (text) @name)
  (#set! "kind" "Heading")) @symbol

(for
  pattern: (_) @name
  (#set! "kind" "Method")) @symbol

(while
  condition: (_) @name
  (#set! "kind" "Method")) @symbol

(let
  pattern: (call
    item: (ident) @name)
  (#set! "kind" "Function")) @symbol


(let 
  pattern: (ident) @name 
  value: (string) 
  (#set! "kind" "String")) @symbol

(let 
  pattern: (ident) @name 
  value: (group) 
  (#set! "kind" "Array")) @symbol

(let 
  pattern: (ident) @name 
  value: [(ident) (call) (number) (bool)] 
  (#set! "kind" "Variable")) @symbol

(set
  (call
    item: (ident) @name)
  (#set! "kind" "Property")) @symbol

(import
  import: (string) @name
  (#set! "kind" "Package")) @symbol

(call
  item: (ident) @name
  (#not-match? @name "^(str|float|int|range|rgb|upper|type|strong|upper)$")
  (#not-has-parent? @symbol let)
  (#not-has-parent? @symbol set)
  (#set! "kind" "FCall")) @symbol
