(setq viper-inhibit-startup-message 't)
(setq viper-expert-level '5)
(setq-default viper-ESC-moves-cursor-back t)
(setq-default viper-auto-indent t)

; Allow backspace past start of edit and beginning of line.
(setq-default viper-ex-style-editing nil)  

; Non-sluggish paren matching (using "%" key).
(viper-set-parsing-style-toggling-macro 'undefine)
