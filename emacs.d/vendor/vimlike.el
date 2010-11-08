;-*-Emacs-Lisp-*-
; Extensions to Viper that make it more Vim-like
;
; If you are running vanilla GNU Emacs, you will need redo.el
; Aquamacs and Xemacs should be fine
; This has only been tested on Aquamacs
; http://www.wonderworks.com/download/redo.el
(require 'redo)

;;;;;;;;; NEW FEATURES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Point movement features, gg
; Scrolling features, zt zb zz
; Search for word features, * #
; Tags support, C-] and C-t
; Undo/redo, u C-r
; Window manipulation, C-wC-w, C-wo, C-wc
; Expand abbreviation, C-n
; Visual mode commands, v, o, O, d, y, c
; New Ex features:
;  - split, vsplit, bdelete, bn
;  
;;;;;;;;; TODO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Incremental search with / and ?
; highlight all search matches
; look at Vim's top tips
; Visual mode compat
; jump to last change '.
; move over SEXP
;;;;;;;;; BUGS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;
; 1) Sometimes :edit gets broken, and pressing SPACE simply aborts EX mode
; 2) Visual mode is pretty rough

; Viper setup
(viper-buffer-search-enable)
(setq viper-syntax-preference 'emacs)
(setq viper-auto-indent t) 

; make :n cycle through buffers on the current window
(setq ex-cycle-other-window nil) 

; Keymaps to make Viper more Vim-like
; Command mode keys
(define-key viper-vi-global-user-map "gf"   'find-file-at-point)
(define-key viper-vi-global-user-map "gg"   'viper-goto-first-line) 
(define-key viper-vi-global-user-map "zt"   'viper-line-to-top)
(define-key viper-vi-global-user-map "zb"   'viper-line-to-bottom)
(define-key viper-vi-global-user-map "zz"   'viper-line-to-middle)
(define-key viper-vi-global-user-map "*"    'viper-search-forward-for-word-at-point) 
(define-key viper-vi-global-user-map "#"    'viper-search-backward-for-word-at-point) 
(define-key viper-vi-global-user-map "\C-]" 'viper-jump-to-tag-at-point)
(define-key viper-vi-global-user-map "\C-t" 'pop-tag-mark)

; Map undo and redo from XEmacs' redo.el
(define-key viper-vi-global-user-map "u"    'undo)
(define-key viper-vi-global-user-map "\C-r" 'redo)

; Window manipulation
(define-key global-map "\C-w" (make-sparse-keymap))
(define-key global-map "\C-w\C-w" 'viper-cycle-windows)
(define-key global-map "\C-wo" 'delete-other-windows)
(define-key global-map "\C-wc" 'delete-window)

; Insert mode keys
; Vim-like completion key
(define-key viper-insert-global-user-map "\C-n" 'dabbrev-expand)

;;; Additional Ex mode features.
;;; ex-token-alist is defined as a constant, but it appears I can safely push values to it!
(defvar viper-extra-ex-commands '(
      ("sp" "split")
      ("split" (viper-split-window))
      ("b" "buffer")
      ("bd" "bdelete")
      ("bdelete" (viper-kill-current-buffer))
      ("bn" "next")
      ("gr" "grep")
      ("grep" (viper-grep))
      ("vs" "vsplit")   ; Emacs and Vim use inverted naming conventions for splits :)
      ("vsplit" (viper-split-window-horizontally))
))
(setq ex-token-alist (append viper-extra-ex-commands ex-token-alist))

(defun viper-grep (&optional grep-string)
  (unless grep-string
    (setq grep-string (concat "grep -nH -e " (read-string ":grep "))))
  (grep grep-string))

(defun viper-split-window (&optional file)
  (split-window)
  (ex-edit file))

(defun viper-split-window-horizontally (&optional file)
  (split-window-horizontally)
  (ex-edit file))

;;; Functions that the new key mappings use
(defun viper-jump-to-tag-at-point ()
  (interactive)
  (let ((tag (thing-at-point 'word)))
    (find-tag tag)))

(defun viper-goto-first-line ()
  "Send point to the start of the first line."
  (interactive)
  (viper-goto-line 1)) 

(defun viper-kill-current-buffer ()
  "Kill the current buffer."
  (interactive)
  (kill-buffer nil)) 

(defun viper-cycle-windows ()
  "Cycle point to another window."
  (interactive) 
  (select-window (next-window)))

(defun viper-search-for-word-at-point (forward)
  "Search forwards or bacward for the word under point."
  (let ((word (thing-at-point 'word)))
    (setq viper-s-string word)
    (setq viper-s-forward forward)
    (viper-search word forward 1))) 

(defun viper-search-forward-for-word-at-point ()
  (interactive)
  (viper-search-for-word-at-point t))

(defun viper-search-backward-for-word-at-point ()
  (interactive)
  (viper-search-for-word-at-point nil))

;;; Make some Emacs Lisp mode stuff more like Vim
;;; This hook function will run when lisp mode is invoked
(defun viper-mode-lisp-hook ()
; let "-" be part of words, so word commands will work properly
  (modify-syntax-entry ?- "word"))
  
; run the Lisp mode hook
(add-hook 'lisp-mode-hook 'viper-mode-lisp-hook)
(add-hook 'emacs-lisp-mode-hook 'viper-mode-lisp-hook) 

;;; Manipulation of Vipers functions by using the advice feature
;;; Many of the functions here rely as heavily on Viper's internals as Viper itself
(require 'advice)

; Function to make brace highlighting like Vim's
; Contributed by Alessandro Piras
(defadvice show-paren-function (around viper-shop-paren-function activate)
  (if viper-vi-basic-minor-mode
      (cond
       ((= (char-after (point)) ?\))
	(forward-char)
	ad-do-it
	(backward-char))
       ((= (char-after (- (point) 1)) ?\)) nil)
       (t ad-do-it))
    ad-do-it))

(viper-deflocalvar viper-visual-minor-mode nil)
(defvar viper-visual-map (make-sparse-keymap))
(defvar viper-visual-mode-linewise nil)

; TODO, make this work for older Emacs without emulation-mode-map-alists
(defadvice viper-normalize-minor-mode-map-alist (after viper-add-visual-maps activate)
  "This function modifies viper--key-maps to include the visual mode keymap"
  (if (boundp 'emulation-mode-map-alists)
      (push (cons 'viper-visual-minor-mode viper-visual-map) viper--key-maps)
    ;; else:  This is a bit of a hack
    (push (cons 'viper-visual-mode viper-visual-map) minor-mode-map-alist)))

(define-key viper-vi-global-user-map "v" 'viper-toggle-visual-mode)
(define-key viper-vi-global-user-map "V" 'viper-toggle-visual-line-mode)

; Visual mode key mappings
(define-key viper-visual-map "y" 'viper-visual-yank)
(define-key viper-visual-map "d" 'viper-visual-delete) 
(define-key viper-visual-map "D" 'viper-visual-delete) 
(define-key viper-visual-map "x" 'viper-visual-delete) 
(define-key viper-visual-map "X" 'viper-visual-delete)
(define-key viper-visual-map "o" 'exchange-point-and-mark) 
(define-key viper-visual-map "O" 'exchange-point-and-mark)
(define-key viper-visual-map "c" 'viper-visual-change)
(define-key viper-visual-map "C" 'viper-visual-change)
(define-key viper-visual-map "s" 'viper-visual-change)
(define-key viper-visual-map "S" 'viper-visual-change)
(define-key viper-visual-map "F" 'viper-visual-change)
(define-key viper-visual-map "i" 'viper-nil)
(define-key viper-visual-map "I" 'viper-nil)
(define-key viper-visual-map "a" 'viper-nil)
(define-key viper-visual-map "A" 'viper-nil)
(define-key viper-visual-map "u" 'viper-nil)
(define-key viper-visual-map "\C-r" 'viper-nil)

;(defadvice viper-ex (around viper-extended-ex-commands (arg &optional string) activate)
;  ad-do-it) 
;(defadvice viper-move-marker-locally (around viper-move-marker-locally-wrap activate)
;  (unless viper-visual-minor-mode
;    ad-do-it))

(defadvice viper-deactivate-mark (around viper-deactivate-mark-wrap activate)
  (unless viper-visual-minor-mode
    ad-do-it))

(defadvice viper-intercept-ESC-key (before viper-visual-intercept-ESC-key activate)
  (when viper-visual-minor-mode
    (viper-disable-visual-mode nil))) 

(defadvice undo (before viper-visual-undo activate)
  (setq viper-visual-minor-mode nil))

(defadvice redo (before viper-visual-redo activate)
  (setq viper-visual-minor-mode nil))

(defun viper-enable-visual-mode (arg)
  (interactive "P")
  (viper-set-mark-if-necessary)
  (setq viper-visual-minor-mode t))

(defun viper-disable-visual-mode (arg)
  (interactive "P")
  (when viper-visual-linewise
    (setq viper-visual-linewise nil)
    (remove-hook 'post-command-hook 'viper-visual-linewise-lock))
  (setq viper-visual-minor-mode nil)
  (viper-deactivate-mark))

(defun viper-toggle-visual-mode (arg)
  "Toggle visual mode on and off.  This assumes that transient-mark-mode is active. viper-visual-minor-mode is also toggled on and off, which will enable the visual mode keymap."
  (interactive "P")
  (if viper-visual-minor-mode 
      (viper-disable-visual-mode arg)
    (viper-enable-visual-mode arg))) 

(defun viper-toggle-visual-line-mode (arg)
  (interactive "P")
  (make-local-variable 'viper-visual-linewise)
  (setq viper-visual-linewise t)
  (add-hook 'post-command-hook 'viper-visual-linewise-lock)
  (viper-visual-linewise-lock)
  (viper-toggle-visual-mode arg))

(defun viper-visual-linewise-lock ()
  (beginning-of-line))

(defun viper-visual-yank (arg)
  (interactive "P")
  (viper-prefix-arg-com ?r 1 ?y)
  (viper-disable-visual-mode arg)) 

(defun viper-visual-delete (arg)
  (interactive "P")
  (viper-prefix-arg-com ?r 1 ?d)
  (viper-disable-visual-mode arg)) 

(defun viper-visual-change (arg)
  (interactive "P")
  (setq viper-visual-minor-mode nil)
  (viper-prefix-arg-com ?r 1 ?c)) 

;(setq edebug-trace t) 
;(setq edebug-all-forms t) 
;(require 'edebug) 

; A helper function that injects the basic Viper movement keys into the map
; If you want different basic movement keys, then you can respond to the 
; hook viper-modify-map-for-movement-hook
(defun viper-modify-map-for-movement (map)
  ; Vi like movement keys
  (define-key map "\C-d" 'viper-scroll-up)
  (define-key map "\C-u" 'viper-scroll-down)
  (define-key map "0" 'viper-beginning-of-line)
  (define-key map "$" 'viper-goto-eol)
  (define-key map "k" 'viper-previous-line) 
  (define-key map "j" 'viper-next-line)
  (define-key map "l" 'viper-forward-char)
  (define-key map "h" 'viper-backward-char)
  (define-key map "w" 'viper-forward-word)
  (define-key map "b" 'viper-backward-word)
  (run-hook-with-args 'viper-modify-map-for-movement-hook map))


