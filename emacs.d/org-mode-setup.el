(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cb" 'org-iswitchb)

(setq org-log-done 'time)
(setq org-hide-leading-stars t)
(setq org-startup-indented t)
(setq org-M-RET-may-split-line nil)
