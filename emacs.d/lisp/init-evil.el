;;; package --- Summary
;;; Commentary:
;;; Emacs entry point

;;; Code:

(global-evil-leader-mode)

(evil-leader/set-leader ",")
(setq evil-leader/in-all-states 1)
(evil-leader/set-key
  "r" 'helm-for-files
  "s" 'whitespace-mode)

(global-evil-jumper-mode)

(evil-mode 1)

(global-evil-surround-mode 1)

(global-evil-matchit-mode 1)

; page down
(define-key evil-normal-state-map "J" 'evil-scroll-page-down)
; page up
(define-key evil-normal-state-map "K" 'evil-scroll-page-up)

; I got used to C-q for visual block mode for some reason
(define-key evil-normal-state-map "\C-q" 'evil-visual-block)

; commenting/uncommenting lines
(define-key evil-visual-state-map "\\\\" 'evilnc-comment-or-uncomment-lines)
(define-key evil-normal-state-map "\\\\" 'evilnc-comment-or-uncomment-lines)

; show buffers
(define-key evil-normal-state-map "\C-l" 'helm-for-files)

; find files in project
(define-key evil-normal-state-map "\C-p" 'helm-projectile-find-file)

;;; OmniSharp
(define-key evil-normal-state-map "\C-b" 'omnisharp-go-to-definition)

(defun minibuffer-keyboard-quit ()
  "Abort recursive edit.
In Delete Selection mode, if the mark is active, just deactivate it;
then it takes a second \\[keyboard-quit] to abort the minibuffer."
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivate-mark  t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions*"))
    (abort-recursive-edit)))

; Make escape quit everything, whenever possible.
(define-key evil-normal-state-map [escape] 'keyboard-quit)
(define-key evil-visual-state-map [escape] 'keyboard-quit)
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)

(provide 'init-evil)
;;; init-evil.el ends here
