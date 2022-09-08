;;; https://www.emacswiki.org/emacs/EshellFunctions

;;; Inspire by http://blog.binchen.org/posts/use-ivy-mode-to-search-bash-history.html
(defun ken_nc/parse-bash-history ()
  "Parse the bash history."
  (interactive)
  (let (collection bash_history)
    (shell-command "history -r") ; reload history
    (setq collection
          (nreverse
           (split-string (with-temp-buffer (insert-file-contents (file-truename "~/.bash_history"))
                                           (buffer-string))
                         "\n"
                         t)))
    (when (and collection (> (length collection) 0)
               (setq bash_history collection))
      bash_history)))

(defun ken_nc/esh-history ()
  "Interactive search eshell history."
  (interactive)
  (require 'em-hist)
  (save-excursion
    (let* ((start-pos (eshell-beginning-of-input))
		   (input (eshell-get-old-input))
		   (esh-history (when (> (ring-size eshell-history-ring) 0)
						  (ring-elements eshell-history-ring)))
		   (all-shell-history (append esh-history (ken_nc/parse-bash-history))))
      (let* ((def (car all-shell-history))
			 (command (completing-read
					   (format "Choose from history [%s]: " def)
					   all-shell-history nil nil nil nil def nil)))
		(eshell-kill-input)
		(insert command))))
  ;; move cursor to eol
  (end-of-line))


(defun ken_nc/esh-clear-buffer ()
  "Clear terminal."
  (interactive)
  (require 'esh-mode)
  (let ((inhibit-read-only t))
    (erase-buffer)
    (eshell-send-input)))

(defun ken_nc/async-make (&rest args)
  "Use `compile' to do background makes."
  (if (eshell-interactive-output-p)
      (let ((compilation-process-setup-function
             (list 'lambda nil
                   (list 'setq 'process-environment
                         (list 'quote (eshell-copy-environment))))))
        (compile (eshell-flatten-and-stringify args))
        (pop-to-buffer compilation-last-buffer))
    (throw 'eshell-replace-command
           (let ((l (eshell-stringify-list (eshell-flatten-list args))))
             (eshell-parse-command (car l) (cdr l))))))
(put 'eshell/ec 'eshell-no-numeric-conversions t)

(defun eshell-load-bash-aliases ()
  "Read Bash aliases and add them to the list of eshell aliases."
  ;; Bash needs to be run - temporarily - interactively
  ;; in order to get the list of aliases.
  (with-temp-buffer
    (call-process "bash" nil '(t nil) nil "-ci" "alias")
    (goto-char (point-min))
    (while (re-search-forward "alias \\(.+\\)='\\(.+\\)'$" nil t)
      (eshell/alias (match-string 1) (match-string 2)))))


(use-package eshell
  :commands eshell
  :hook
  (eshell-mode . company-mode)
  :init
  (progn
	(setq
	 eshell-highlight-prompt nil
	 eshell-buffer-shorthand t
	 eshell-history-size 5000
	 ;; auto truncate after 12k lines
	 eshell-buffer-maximum-lines 12000
	 eshell-hist-ignoredups t
	 eshell-error-if-no-glob t
	 eshell-glob-case-insensitive t
	 eshell-scroll-to-bottom-on-input 'all
	 eshell-list-files-after-cd t
	 eshell-aliases-file (concat user-emacs-directory "eshell/alias")
	 eshell-banner-message "(´ー`)y-~~ (´ー`)y-~~ (´ー`)y-~~ (´ー`)y-~~\n\n")
	;; Visual commands
	(setq eshell-visual-commands '("vi" "screen" "top" "less" "more" "lynx"
								   "ncftp" "pine" "tin" "trn" "elm" "vim"
								   "nmtui" "alsamixer" "htop" "el" "elinks"))
	(setq eshell-visual-subcommands '(("git" "log" "diff" "show")))))

(add-hook 'eshell-mode-hook
		  (lambda () (progn
					   (define-key eshell-mode-map (kbd "C-l") 'ken_nc/esh-clear-buffer)
					   (define-key eshell-mode-map (kbd "C-r") 'ken_nc/esh-history)
					   (define-key eshell-mode-map (kbd "<mouse-3>") 'xah-open-file-at-cursor))))

;; We only want Bash aliases to be loaded when Eshell loads its own aliases,
;; rather than every time `eshell-mode' is enabled.
;; (add-hook 'eshell-alias-load-hook 'eshell-load-bash-aliases)

(message "loading init-eshell")
(provide 'ken_nc-eshell)
;;; init-eshell.el ends here
