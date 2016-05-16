;; -*- mode: emacs-lisp -*-
;; This file is loaded by Spacemacs at startup.
;; It must be stored in your home directory.

;; Configuration Layers
;; --------------------

(setq-default
 ;; List of additional paths where to look for configuration layers. Paths must
 ;; have a trailing slash (ie. `~/.mycontribs/')
 dotspacemacs-configuration-layer-path '()
 ;; List of configuration layers to load.
 dotspacemacs-configuration-layers '(auto-completion
                                     csharp
                                     elixir
                                     emacs-lisp
                                     emoji
                                     fasd
                                     git
                                     github
                                     html
                                     javascript
                                     lua
                                     markdown
                                     python
                                     ruby
                                     ruby-on-rails
                                     rust
                                     shell-scripts
                                     sql
                                     swift
                                     themes-megapack
                                     typescript
                                     vinegar
                                     windows-scripts
                                     yaml)
 ;; A list of packages and/or extensions that will not be install and loaded.
 dotspacemacs-excluded-packages '()
)

;; Settings
;; --------

(setq-default
 ;; Default theme applied at startup
 dotspacemacs-default-theme 'solarized-light
 ;; The leader key
 dotspacemacs-leader-key "SPC"
 ;; The command key used for Evil commands (ex-commands) and
 ;; Emacs commands (M-x).
 ;; By default the command key is `:' so ex-commands are executed like in Vim
 ;; with `:' and Emacs commands are executed with `<leader> :'.
 dotspacemacs-command-key ":"
 ;; Guide-key delay in seconds. The Guide-key is the popup buffer listing
 ;; the commands bound to the current keystrokes.
 dotspacemacs-guide-key-delay 0.4
 ;; If non nil the frame is fullscreen when Emacs starts up (Emacs 24.4+ only).
 dotspacemacs-fullscreen-at-startup nil
 ;; If non nil the frame is maximized when Emacs starts up (Emacs 24.4+ only).
 ;; Takes effect only if `dotspacemacs-fullscreen-at-startup' is nil.
 dotspacemacs-maximized-at-startup nil
 ;; If non nil smooth scrolling (native-scrolling) is enabled. Smooth scrolling
 ;; overrides the default behavior of Emacs which recenters the point when
 ;; it reaches the top or bottom of the screen
 dotspacemacs-smooth-scrolling t
 ;; If non nil pressing 'jk' in insert state, ido or helm will activate the
 ;; evil leader.
 dotspacemacs-feature-toggle-leader-on-jk nil
 ;; If non-nil smartparens-strict-mode will be enabled in programming modes.
 dotspacemacs-smartparens-strict-mode nil
 ;; If non nil advises quit functions to keep server open when quitting.
 dotspacemacs-persistent-server nil
 ;; The default package repository used if no explicit repository has been
 ;; specified with an installed package.
 ;; Not used for now.
 dotspacemacs-default-package-repository nil

 ;; "Major mode leader key is a shortcut key which is the equivalent of
 ;; pressing `<leader> m`. Set it to `nil` to disable it."
 dotspacemacs-major-mode-leader-key nil
)

;; Initialization Hooks
;; --------------------

(defun dotspacemacs/init ()
  "User initialization for Spacemacs. This function is called at the very
 startup."

  (setq-default dotspacemacs-default-font '("Office Code Pro"
                                            :size 15
                                            :weight normal
                                            :width normal
                                            :powerline-scale 1.1))

  (setq-default dotspacemacs-themes '(monokai
                                      molokai
                                      sanityinc-solarized-dark
                                      leuven))
)

(defun dotspacemacs/user-config ()
  "This is were you can ultimately override default Spacemacs configuration.
This function is called at the very end of Spacemacs initialization."

  ; enable line numbers
  (global-linum-mode t)

  ; swap meta/super in OSX
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'super)

  ; use \\ to comment or uncomment lines
  (define-key evil-visual-state-map "\\\\" 'evilnc-comment-or-uncomment-lines)
  (define-key evil-normal-state-map "\\\\" 'evilnc-comment-or-uncomment-lines)

  ; Make evil-mode up/down operate in screen lines instead of logical lines
  (define-key evil-motion-state-map "j" 'evil-next-visual-line)
  (define-key evil-motion-state-map "k" 'evil-previous-visual-line)
  ; Also in visual mode
  (define-key evil-visual-state-map "j" 'evil-next-visual-line)
  (define-key evil-visual-state-map "k" 'evil-previous-visual-line)

  ; page down
  (define-key evil-normal-state-map "J" 'evil-scroll-page-down)
  ; page up
  (define-key evil-normal-state-map "K" 'evil-scroll-page-up)

  ; I got used to C-q for visual block mode for some reason
  (define-key evil-normal-state-map "\C-q" 'evil-visual-block)

  ; show buffers
  (define-key evil-normal-state-map "\C-l" 'helm-for-files)

  ; because Spacemacs uses "SPC" for leader, this is just the shortcut I like
  (define-key evil-normal-state-map ",s" 'whitespace-mode)
  (define-key evil-normal-state-map ",r" 'helm-for-files)

  ; stop highlighting matches (i.e. nohlsearch)
  (define-key evil-normal-state-map [escape] 'evil-search-highlight-persist-remove-all)

  ; make default system clipboard paste work in visual mode
  (fset 'evil-visual-update-x-selection 'ignore)

  ; frame/window shortcuts
  (global-set-key "\M-`" 'other-frame)
  (global-set-key "\M-w" 'delete-frame)
  (global-set-key "\M-n" 'new-frame)

  ; increase/decrease font size
  (define-key evil-normal-state-map "\M-," 'text-scale-decrease)
  (define-key evil-normal-state-map "\M-." 'text-scale-increase)

  (add-hook
   'rust-mode-hook
   'lambda ()
   (setenv "RUST_SRC_PATH" (substitute-in-file-name "$HOME/dev/rustc-1.6.0/src")))

  (setq-default rust-enable-racer t)
)

;; Custom variables
;; ----------------

;; Do not write anything in this section. This is where Emacs will
;; auto-generate custom variable definitions.


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ac-ispell-requires 4 t)
 '(ahs-case-fold-search nil)
 '(ahs-default-range (quote ahs-range-whole-buffer))
 '(ahs-idle-interval 0.25)
 '(ahs-idle-timer 0 t)
 '(ahs-inhibit-face-list nil)
 '(custom-safe-themes
   (quote
    ("d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" "b571f92c9bfaf4a28cb64ae4b4cdbda95241cd62cf07d942be44dc8f46c491f4" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "0f0087ed1f27aaa8bd4c7e1910a02256facf075182e303adb33db23d1611864b" default)))
 '(paradox-github-token t)
 '(ring-bell-function (quote ignore) t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-tooltip-common ((t (:inherit company-tooltip :weight bold :underline nil))))
 '(company-tooltip-common-selection ((t (:inherit company-tooltip-selection :weight bold :underline nil)))))
