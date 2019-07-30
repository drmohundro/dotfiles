;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

(setq
 doom-font (font-spec :family "Iosevka" :size 16)
 doom-theme 'leuven)

; doom-theme 'doom-molokai)

; ln -s /Users/david/Library/Mobile\ Documents/iCloud\~com\~appsonthemove\~beorg/Documents/org org
(setq org-agenda-files '("~/org"))

; log the time when something is marked done
(setq org-log-done 'time)

(map! (:map override
        "C-l" #'switch-to-buffer)

      ;; global keybindings
      :n "J" #'evil-scroll-page-down
      :n "K" #'evil-scroll-page-up

      :v "\\\\" #'evil-commentary-line)

;      :localleader
;      "s" #'whitespace-mode)

(setq
 mac-command-modifier 'meta
 mac-option-modifier 'super)

(setq doom-localleader-key ",")

