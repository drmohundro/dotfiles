;; -*- mode: dotspacemacs -*-
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

 ;; Enable lazy installation of missing features
 dotspacemacs-enable-lazy-installation 'all

 dotspacemacs-additional-packages '(editorconfig)
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

  ; use ctrl-p for search in project
  (define-key evil-normal-state-map "\C-p" 'helm-projectile-find-file)

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

  ; tabs
  (setq-default
   indent-tabs-mode nil
   tab-width 2
   js-indent-level 2
   js2-basic-offset 2)

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
 '(ahs-case-fold-search nil t)
 '(ahs-default-range (quote ahs-range-whole-buffer) t)
 '(ahs-idle-interval 0.25 t)
 '(ahs-idle-timer 0 t)
 '(ahs-inhibit-face-list nil t)
 '(custom-safe-themes
   (quote
    ("d677ef584c6dfc0697901a44b885cc18e206f05114c8a3b7fde674fce6180879" "b571f92c9bfaf4a28cb64ae4b4cdbda95241cd62cf07d942be44dc8f46c491f4" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "0f0087ed1f27aaa8bd4c7e1910a02256facf075182e303adb33db23d1611864b" default)))
 '(package-selected-packages
   (quote
    (pug-mode yapfify uuidgen toc-org tide typescript-mode py-isort pcre2el spinner org org-plus-contrib org-bullets livid-mode skewer-mode simple-httpd live-py-mode link-hint json-mode json-snatcher json-reformat parent-mode request haml-mode gitignore-mode github-search gh marshal logito pcache flycheck-mix flx grizzl eyebrowse evil-visual-mark-mode evil-unimpaired magit-popup evil-ediff anzu highlight dumb-jump diminish darkokai-theme web-completion-data dash-functional tern company-shell column-enforce-mode cargo inf-ruby bind-map bind-key yasnippet packed pythonic s dash pkg-info epl avy async popup zenburn-theme yaml-mode ws-butler web-mode toml-mode tao-theme swift-mode spacemacs-theme spaceline racer rust-mode projectile-rails rake persp-mode organic-green-theme open-junk-file omtose-phellack-theme neotree moe-theme material-theme leuven-theme js2-refactor js2-mode indent-guide help-fns+ helm-themes helm-pydoc helm-projectile helm-descbinds helm-ag gruvbox-theme grandshell-theme google-translate git-link evil-surround evil-search-highlight-persist evil-matchit evil-iedit-state emmet-mode editorconfig darktooth-theme color-theme-sanityinc-tomorrow badwolf-theme ample-theme alchemist ace-link ace-jump-helm-line anaconda-mode smartparens company projectile helm helm-core ht markdown-mode csharp-mode flycheck magit git-commit with-editor hydra f auto-complete package-build which-key evil monokai-theme zonokai-theme zen-and-art-theme window-numbering web-beautify volatile-highlights vi-tilde-fringe use-package undo-tree underwater-theme ujelly-theme twilight-theme twilight-bright-theme twilight-anti-bright-theme tss tronesque-theme toxi-theme tangotango-theme tango-plus-theme tango-2-theme tagedit sunny-day-theme sublime-themes subatomic256-theme subatomic-theme stekene-theme sql-indent spacegray-theme soothe-theme soft-stone-theme soft-morning-theme soft-charcoal-theme smyx-theme smooth-scrolling smeargle slim-mode seti-theme scss-mode sass-mode rvm ruby-tools ruby-test-mode ruby-end rubocop rspec-mode robe reverse-theme restart-emacs rbenv rainbow-delimiters railscasts-theme quelpa pyvenv pytest pyenv-mode py-yapf purple-haze-theme professional-theme powershell powerline popwin planet-theme pip-requirements phoenix-dark-pink-theme phoenix-dark-mono-theme pastels-on-dark-theme paradox page-break-lines orgit omnisharp oldlace-theme occidental-theme obsidian-theme noctilux-theme niflheim-theme naquadah-theme mustang-theme multiple-cursors move-text monochrome-theme molokai-theme mmm-mode minimal-theme markdown-toc majapahit-theme magit-gitflow magit-gh-pulls macrostep lush-theme lua-mode lorem-ipsum linum-relative light-soap-theme less-css-mode js-doc jbeans-theme jazz-theme jade-mode ir-black-theme inkpot-theme info+ inflections iedit ido-vertical-mode hy-mode hungry-delete hl-todo highlight-parentheses highlight-numbers highlight-indentation heroku-theme hemisu-theme helm-swoop helm-mode-manager helm-make helm-gitignore helm-flx helm-css-scss helm-company helm-c-yasnippet hc-zenburn-theme gruber-darker-theme goto-chg gotham-theme golden-ratio github-clone github-browse-file gitconfig-mode gitattributes-mode git-timemachine git-messenger gist gh-md gandalf-theme flx-ido flatui-theme flatland-theme fish-mode firebelly-theme fill-column-indicator feature-mode fasd farmhouse-theme fancy-battery expand-region exec-path-from-shell evil-visualstar evil-tutor evil-numbers evil-nerd-commenter evil-mc evil-magit evil-lisp-state evil-indent-plus evil-exchange evil-escape evil-args evil-anzu eval-sexp-fu espresso-theme emoji-cheat-sheet-plus elixir-mode elisp-slime-nav dracula-theme django-theme define-word darkmine-theme darkburn-theme dakrone-theme cython-mode cyberpunk-theme company-web company-tern company-statistics company-racer company-quickhelp company-emoji company-anaconda colorsarenice-theme color-theme-sanityinc-solarized coffee-mode clues-theme clean-aindent-mode chruby cherry-blossom-theme busybee-theme bundler buffer-move bubbleberry-theme bracketed-paste birds-of-paradise-plus-theme auto-yasnippet auto-highlight-symbol auto-compile apropospriate-theme anti-zenburn-theme ample-zen-theme alect-themes aggressive-indent afternoon-theme adaptive-wrap ace-window ac-ispell)))
 '(paradox-github-token t)
 '(ring-bell-function (quote ignore)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
