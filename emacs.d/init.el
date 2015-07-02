;;; package --- Summary
;;; Commentary:
;;; Emacs entry point

;;; Code:

(require 'cask "~/.cask/cask.el")
(cask-initialize)

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
(add-to-list 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))
(add-to-list 'exec-path "/usr/local/bin")

(require 'init-evil)
(require 'init-linum)

(defvar backup-dir "~/.emacs.d/backups/")
(setq backup-directory-alist (list (cons "." backup-dir)))
(setq make-backup-files nil)

; Use spaces instead of tabs
(setq indent-tabs-mode nil)

; Use Helm all the time.
(setq helm-buffers-fuzzy-matching t)
(helm-mode 1)

; Use projectile everywhere
(projectile-global-mode)
(helm-projectile-on)

; Enable flycheck mode
(add-hook 'after-init-hook #'global-flycheck-mode)

; Faster projectile indexing on Windows
(when (eq system-type 'windows-nt)
  (setq projectile-indexing-method 'alien))

;;; GUI

; Font settings
(if (eq system-type 'windows-nt)
  (progn
    (set-face-attribute 'default nil
                        :family "Office Code Pro"
                        :height 120
                        :weight 'normal
                        :width 'normal))
  (progn
    (set-face-attribute 'default nil
                        :family "Office Code Pro"
                        :height 140
                        :weight 'normal
                        :width 'normal)))

; Hide startup screen
(setq inhibit-startup-screen +1)

; Hide tool-bar
(when (window-system)
  (tool-bar-mode -1)
  (scroll-bar-mode -1))

; Current theme
(load-theme 'monokai t)

; Powerline theme
(powerline-default-theme)

(provide 'init)
;;; init.el ends here
