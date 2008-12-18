(add-to-list 'load-path "~/.elisp")

(defun expand-load (filename)
  (when (stringp filename)
    (load-file (expand-file-name (format "~/.emacs.d/%s" filename)))))

(mapc 'expand-load
      `("look-and-feel.el"))