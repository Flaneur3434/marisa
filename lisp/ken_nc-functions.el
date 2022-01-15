;; ken_nc functions______________________________________________________

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

;; Grep Mode Keybindings
(defun ken_nc/save-buffer-dwim ()
  (interactive)
  (cond
   ((string-equal major-mode "grep-mode") (wgrep-finish-edit))
   ((string-equal major-mode "occur-edit-mode") (occur-cease-edit))
   (t (save-buffer))))

;; Grep Mode Keybindings
(defun ken_nc/edit-grep-buffer-dwim ()
  (interactive)
  (cond
   ((string-equal major-mode "grep-mode") (wgrep-change-to-wgrep-mode))
   ((string-equal major-mode "occur-mode") (occur-edit-mode))
   (t nil)))

(defun ken_nc/grep-dwim (&optional set-invert search-pattern file-name)
  "Runs grep and grep-buffer in one command. Default (no prefix) runs regular grep with the arguments of grep --color -inHr --null -e.
If the prefix is 4 (the default number for prefix), it runs grep inverse. The arguments are grep --color -ivnHr --null -e.
If no file is specified, then run occur."
  (interactive "p")
  (set (make-local-variable 'search-pattern) (read-regexp "Search pattern (regex): "))
  (if (y-or-n-p "File")
	  (progn
		(set (make-local-variable 'directory-name) (read-directory-name "Which directory: "))
		(set (make-local-variable 'file-name) (read-string "Which file(s): "))
		(cond
		 ((= set-invert 4)
		  (set (make-local-variable 'command) (concat "grep --color -ivnHr --null -e" " " search-pattern " " directory-name file-name)))
		 (t (set (make-local-variable 'command) (concat "grep --color -inHr --null -e" " " search-pattern " " directory-name file-name))))
		(grep command))
	(occur search-pattern)))

(global-set-key (kbd "C-c 0") 'ken_nc/delete-surround-char)

(provide 'ken_nc-functions)
