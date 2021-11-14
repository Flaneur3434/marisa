(setq path-to-ctags "/usr/bin/ctags")

(defun my-create-tags (dir-name)
  "Create tags file."
  (interactive "DDirectory: ")
  (shell-command
   (format "%s -f TAGS -e -R --languages=%s *" path-to-ctags (read-string "Lang: ")))
)

(provide 'ctags-utils)
