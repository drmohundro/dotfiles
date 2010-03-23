(setq viper-inhibit-startup-message 't)
(setq viper-expert-level '5)
(setq-default viper-ESC-moves-cursor-back t)
(setq-default viper-auto-indent t) 

(setq viper-mode t)                                 ; enable Viper at load time
(setq viper-ex-style-editing nil)                   ; can backspace past start of insert / line

(require 'viper)                                    ; load Viper
(require 'vimpulse)                                 ; load Vimpulse
(setq woman-use-own-frame nil)                      ; don't create new frame for manpages
(setq woman-use-topic-at-point t)                   ; don't prompt upon K key (manpage display)
(require 'redo)
(require 'rect-mark)                                ; for block visual mode

(load-library "vimlike")

(defvar viper-visual-mode-map (make-sparse-keymap)
  "Viper Visual mode keymap. This keymap is active when viper is in VISUAL mode")

(define-key viper-vi-global-user-map "J" 'View-scroll-half-page-forward)
(define-key viper-vi-global-user-map "K" 'View-scroll-half-page-backward)
(define-key viper-vi-global-user-map [(delete)] 'delete-char)
(define-key viper-vi-global-user-map "/" 'isearch-forward-regexp)
(define-key viper-vi-global-user-map "?" 'isearch-backward-regexp)
(define-key viper-vi-global-user-map "\C-wh" 'windmove-left)
(define-key viper-vi-global-user-map "\C-wj" 'windmove-down)
(define-key viper-vi-global-user-map "\C-wk" 'windmove-up)
(define-key viper-vi-global-user-map "\C-wl" 'windmove-right)
(define-key viper-vi-global-user-map "\C-wv" '(lambda () (interactive)
                                                (split-window-horizontally)
                                                (other-window 1)
                                                (switch-to-buffer (other-buffer))))

(define-key viper-visual-mode-map "F" 'viper-find-char-backward)
(define-key viper-visual-mode-map "t" 'viper-goto-char-forward)
(define-key viper-visual-mode-map "T" 'viper-goto-char-backward)
(define-key viper-visual-mode-map "e" '(lambda ()
                                         (interactive)
                                         (viper-end-of-word 1)
                                         (viper-forward-char 1)))

(push '("only" (delete-other-windows)) ex-token-alist)
(push '("close" (delete-window)) ex-token-alist)
