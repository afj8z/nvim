;; extends

;;  Web Links
(inline_link
  "[" @conceal
  (link_text) @markup.link.label.web
  "]" @conceal
  "(" @conceal
  (link_destination) @markup.link.url.web
  ")" @conceal
  (#set! @conceal conceal "")
  (#set! @markup.link.url.web conceal "")
  (#match? @markup.link.url.web "^https?://"))

;; Local File Links
(inline_link
  "[" @conceal
  (link_text) @markup.link.label.local
  "]" @conceal
  "(" @conceal
  (link_destination) @markup.link.url.local
  ")" @conceal
  (#set! @conceal conceal "")
  (#set! @markup.link.url.local conceal "")
  (#not-match? @markup.link.url.local "^https?://"))
