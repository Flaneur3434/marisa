;; ken_nc functions______________________________________________________
(require 'cl-lib)


(defun ken_nc/dwim-open-line ()
  "Create a new line above or below the current line depending on position of cursor.
The first section uses narrowing to find the current-colum of the cusor relative
to the current line. The current-column is stored in my-point-pos.
The second section determines whither to open a new line bellow and above the current line.
It does this by checking if the middle of the line is before or after the 'my-point-pos'.
If the middle is before, it opens a new line above. If its after, the opposite happens."
  (interactive)
  (save-excursion
	(save-restriction
	  (let ((original-pos (point)))
		(goto-char (line-beginning-position))
		(skip-chars-forward "[[:space:]]*")
		(narrow-to-region (point) (line-end-position))
		(goto-char original-pos)
		(setq my-point-pos (current-column)))))
  (save-excursion
	(let ((line-length (float (- (line-end-position) (point)))))
	  (if (< (float my-point-pos) (float (/ line-length 2)))
		  (progn
			(goto-char (line-beginning-position))
			(open-line 1))
		(progn
		  (goto-char (line-end-position))
		  (open-line 1))))))

(defun ken_nc/forward-word (&optional arg)
  "Move point to the end of the next word or string of
non-word-constituent characters.

Do it ARG times if ARG is positive, or -ARG times in the opposite
direction if ARG is negative. ARG defaults to 1."
  (interactive "^p")
  (if (> arg 0)
      (dotimes (_ arg)
        ;; First, skip whitespace ahead of point
        (when (looking-at-p "[ \t\n]")
          (skip-chars-forward " \t\n"))
        (unless (= (point) (point-max))
          ;; Now, if we're at the beginning of a word, skip it
          (if (looking-at-p "\\sw")
              (skip-syntax-forward "w")
            ;; otherwise it means we're at the beginning of a string of
            ;; symbols. Then move forward to another whitespace char,
            ;; word-constituent char, or to the end of the buffer.
            (if (re-search-forward "\n\\|\\s-\\|\\sw" nil t)
                (backward-char)
              (goto-char (point-max))))))
    (dotimes (_ (- arg))
      (when (looking-back "[ \t\n]")
        (skip-chars-backward " \t\n"))
      (unless (= (point) (point-min))
        (if (looking-back "\\sw")
            (skip-syntax-backward "w")
          (if (re-search-backward "\n\\|\\s-\\|\\sw" nil t)
              (forward-char)
            (goto-char (point-min))))))))

(defun ken_nc/backward-word (&optional arg)
  "Move point to the beginning of the previous word or string of
non-word-constituent characters.

Do it ARG times if ARG is positive, or -ARG times in the opposite
direction if ARG is negative. ARG defaults to 1."
  (interactive "^p")
  (ken_nc/forward-word (- arg)))

(defun ken_nc/delete-word (&optional arg)
  "Delete characters forward until encountering the end of a word.
With argument ARG, do this that many times."
  (interactive "p")
  (kill-region (point) (progn (ken_nc/forward-word arg) (point))))

(defun ken_nc/backward-delete-word (arg)
  "Delete characters backward until encountering the beginning of a word.
With argument ARG, do this that many times."
  (interactive "p")
  (ken_nc/delete-word (- arg)))

(defun ken_nc/beginning-of-line-or-block ()
  "Move cursor to beginning of code or comment or line"
  (interactive)
  (cond ((equal (point) (line-beginning-position))
		 (re-search-backward "[^[:space:]\n]" nil 1))
		((and (mwim-code-beginning)
			  (<= (point) (mwim-code-beginning)))
		 (move-beginning-of-line 1))
		(t (mwim-beginning))))

(defun ken_nc/end-of-line-or-block ()
  "Move cursor to end of code or comment or line"
  (interactive)
  (cond ((equal (point) (line-end-position))
		 (re-search-forward "\n[\t\n ]*" nil 1))
		((and (mwim-line-comment-beginning)
			  (>= (point) (mwim-line-comment-beginning)))
		 (move-end-of-line 1))
		(t (mwim-end))))

;; NOTE 2022-01-05: this is a copy of crux-move-beginning-of-line
(defun ken_nc/smarter-move-beginning-of-line (arg)
  "Move point back to indentation of beginning of line.

  Move point to the first non-whitespace character on this line.
  If point is already there, move to the beginning of the line.
  Effectively toggle between the first non-whitespace character and
  the beginning of the line.

  If ARG is not nil or 1, move forward ARG - 1 lines first.  If
  point reaches the beginning or end of the buffer, stop there."
  (interactive "^p")
  (setq arg (or arg 1))

  ;; Move lines first
  (when (/= arg 1)
    (let ((line-move-visual nil))
      (forward-line (1- arg))))

  (let ((orig-point (point)))
    (back-to-indentation)
    (when (= orig-point (point))
      (move-beginning-of-line 1))))

(defun ken_nc/goto-match-paren ()
  "Go to the matching  if on (){}[], similar to vi style of % "
  (interactive)
  ;; first, check for "outside of bracket" positions expected by forward-sexp, etc
  (cond ((looking-at "[\[\(\{]") (forward-sexp))
        ((looking-back "[\]\)\}]" 1) (backward-sexp))
		((looking-at "[\"\'\<\>]")
		 (let (start end)
		   (skip-chars-forward "^<>\"'")
		   (setq start (point))
		   (skip-chars-backward "^<>\"'")
		   (setq end (point))
		   (set-mark start)))
        ;; now, try to succeed from inside of a bracket
        ((looking-at "[\]\)\}]") (forward-char) (backward-sexp))
        ((looking-back "[\[\(\{]" 1) (backward-char) (forward-sexp))
        (t nil)))

(defun ken_nc/jump-to-mark ()
  "Jump to mark without activating the region inbetween the marks.
In defualt emacs behavior, this would be C-u C-x C-x (which calls exchange-point-and-mark with a prefix argument)."
  (interactive)
  (goto-char (mark)))

;; Turn on Write Mode Keybindings
(defun ken_nc/save-buffer-dwim ()
  (interactive)
  (cond
   ((string-equal major-mode "grep-mode") (wgrep-finish-edit))
   ((string-equal major-mode "ag-mode") (wgrep-finish-edit))
   ((string-equal major-mode "occur-edit-mode") (occur-cease-edit))
   ((string-equal major-mode "wdired-mode") (wdired-finish-edit))
   (t (save-buffer))))

;; Save Mode Keybindings
(defun ken_nc/edit-buffer-dwim ()
  (interactive)
  (cond
   ((string-equal major-mode "grep-mode") (wgrep-change-to-wgrep-mode))
   ((string-equal major-mode "ag-mode") (wgrep-change-to-wgrep-mode))
   ((string-equal major-mode "occur-mode") (occur-edit-mode))
   ((string-equal major-mode "dired-mode") (dired-toggle-read-only))
   (t nil)))

(defun ken_nc/perm (list)
  "Generate all permutations of a list."
  (cond ((null list) nil)
        ((null (cdr list)) (list list))
        (t (apply #'append
                  (mapcar (lambda (element)
                            (mapcar (lambda (l) (cons element l))
                                    (ken_nc/perm (remove element list))))
                          list)))))

(cl-defun ken_nc/convert-to-orderless-regex (patterns &key (ag nil))
  "Generates a regular expression string with all permutations of the words."
  (let* ((pattern-list (split-string patterns))
		 (converted-words (mapcar (lambda (p) (if ag
												  (format "(?:%s)" p)
												(format "\\(?:%s\\)" p)))
								  pattern-list))
		 (permutations (ken_nc/perm converted-words))
		 (converted-perms (mapcar (lambda (p) (string-join p ".*")) permutations)))
	(string-join converted-perms "|")))

(defun ken_nc/grep-dwim (&optional set-invert search-pattern directory-name file-name)
  "Runs grep or ag (silver searcher) in one command. If ag is found on the
system, it uses that to grep. If ag is not found, it uses the system grep
command. If prefix is given, it uses grep with the --invert-match flag."
  (interactive "p")
  (let
	  ((search-pattern (read-regexp "Search pattern (regex): "))
	   (directory-name (read-directory-name "Which directory: "))
	   (file-name (read-string "Which file(s): ")))
	(cond
	 ((= set-invert 4)
	  (grep (concat "grep --invert-match " grep-template " " (ken_nc/convert-to-orderless-regex search-pattern) " " directory-name file-name)))
	 (t
	  (if (executable-find "ag")
		  (ag/search (ken_nc/convert-to-orderless-regex search-pattern :ag t) directory-name :regexp t :file-regex file-name)
		(let ((file-name (read-string "Which file(s): ")))
		  (grep (concat "grep " grep-template " " (ken_nc/convert-to-orderless-regex search-pattern) " " directory-name file-name))))))))

(defun ken_nc/consult-ripgrep (&optional set-invert)
  "Call `consult-ripgrep' in specific directory"
  (interactive "p")
  (when	(equal set-invert nil) (setq set-invert 0))
  (let* ((directory-name (read-directory-name "Which directory: "))
		 (invert-p (when (= set-invert 4)
					 "--invert"))
		 (consult-ripgrep-args (concat
								"rg "
								"--null "
								"--line-buffered "
								"--color=never "
								"--max-columns=1000 "
								"--path-separator / "
								"--smart-case "
								"--no-heading "
								"--with-filename "
								"--line-number "
								"--search-zip "
								"--hidden "
								invert-p)))
	(consult-ripgrep directory-name)))

(defun ken_nc/affe-find ()
  "Call `consult-ripgrep' in specific directory"
  (interactive)
  (let* ((directory-name (read-directory-name "Which directory: ")))
	(affe-find directory-name)))

(defun ken_nc/grep-symbol-at-point (&optional occur-or-grep)
  "Call 'grep' on symbol at point. Default (no prefix) runs occur.
If prefix is given, it runs grep with the default command template"
  (interactive "p")
  (push (if (region-active-p)
            (buffer-substring-no-properties
             (region-beginning)
             (region-end))
          (let ((sym (thing-at-point 'word)))
			(when (stringp sym)
              (regexp-quote sym))))
		regexp-history)
  (deactivate-mark)
  (if (= occur-or-grep 4)
	  (grep (concat "grep " grep-template " " (grep-read-regexp)))
	(call-interactively 'occur)))

(defun ken_nc/mozc-dwim ()
  "If mozc is active turn it off. If mozc is turned off, turn it on."
  (interactive)
  (if mozc-mode
	  (mozc-mode nil)
	(mozc-mode t)))

(defun ken_nc/quit-emacs-dwim (&optional kill-server)
  (interactive "p")
  (if (daemonp)
      (cond
       ((= kill-server 4) (progn
			    (save-some-buffers)
			    (kill-emacs)))
       (t (delete-frame)))
    (kill-emacs)))

(defun ken_nc/pop-local-mark-ring (&optional global-prefix)
  "Move cursor to last mark position of current buffer. If prefix is given
pop-global-mark is called instead of set-mark-command.  Call this repeatedly
will cycle all positions in `mark-ring'."
  (interactive "p")
  (cond
   ((= global-prefix 4) (pop-global-mark))
   (t (set-mark-command t))))

(defun ken_nc/go-to-char ()
  "Move cursor to the position of char. If called repeatedly, revert to
character by character mode. Default is to search by word. This method requires
the cutomized version of go-to-char.el I have in this git repo"
  (interactive)
  (if (eq last-command 'ken_nc/go-to-char)
	  (go-to-char-forward 1 (car ken_nc/goto-char-hist))
	(go-to-char-forward 1 (read-char "Go to char forward: "))))

(defun ken_nc/go-to-char-backwards ()
  "Move cursor to the position of char backwards. If called repeatedly, revert to
character by character mode. Default is to search by word. This method requires
the cutomized version of go-to-char.el I have in this git repo"
  (interactive)
  (if (eq last-command 'ken_nc/go-to-char-backwards)
	  (go-to-char-backward 1 (car ken_nc/goto-char-hist))
	(go-to-char-backward 1 (read-char "Go to char backward: "))))

(defun ken_nc/file-at-point ()
  "Make a file-at-point function that opens a file in other-window"
  ;; basically call ffap-file-at-point (or something else idk) and other-window
  )

(defadvice ffap-file-at-point (after ffap-file-at-point-after-advice ())
  (if (string= ad-return-value "/")
      (setq ad-return-value nil)))

(ad-activate 'ffap-file-at-point)
;; (ad-deactivate 'ffap-file-at-point)

(defun ken_nc/tear-off-window ()
  "Delete the selected window, and create a new frame displaying its buffer."
  (interactive)
  (let* ((window (selected-window))
		 (buf (window-buffer window))
		 (frame (make-frame)))
    (select-frame frame)
    (switch-to-buffer buf)
    (delete-window window)))

(bind-key "C-x C-X" #'ken_nc/tear-off-window)

;; Suspend emacs terminal
(defun ken_nc/suspend ()
  (interactive)
  (if (not (display-graphic-p))
	  (suspend-frame)))

(bind-key "C-z" #'ken_nc/suspend)


(defun my-jump-to-wrapper ()
  "call different jump-to-definition functions depending on what's current major mode."
  (interactive)
  (cond
   ((string-equal major-mode "go-mode") (godef-jump (point)))
   ((string-equal major-mode "geiser-mode") (geiser-edit-symbol-at-point (point)))
   (t (xref-find-definitions (thing-at-point 'symbol)))))

(defun my-jump-back-wrapper ()
  "call different jump-back-definition functions depending on what's current major mode."
  (interactive)
  (cond
   ((string-equal major-mode "geiser-mode") (geiser-pop-symbol-stack))
   ;; if nothing match, do nothing
   (t (xref-pop-marker-stack))))

(defun ken_nc/M-x ()
  (interactive)
  (unless (bound-and-true-p amx-mode) (amx-mode t))
  (command-execute
   'amx
   nil
   nil
   :special))

(defun ken_nc/iBuffer ()
  (interactive)
  (ibuffer t nil nil nil t nil nil))

(provide 'ken_nc-functions)
