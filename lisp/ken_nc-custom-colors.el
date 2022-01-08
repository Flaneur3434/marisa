;; To find the face at point, use M-x describe-char
;;
;; To list about all available faces from the loaded packages on the
;; system, use M-x list-faces-display

(face-remap-add-relative 'font-lock-comment-delimiter-face 'eww-valid-certificate)

;; The problem with what I just showed is that we cannot undo the
;; remapping with the code we used.
;;
;; The `face-remap-add-relative' returns what is known as a "cookie".
;; To revert the changes we need to know the cookie.  So we must store
;; that cookie in a variable.

(defvar-local ken_nc/comment-remap-cookie nil
  "Cookie of the last `face-remap-add-relative'.")

(setq my-comment-remap-cookie (face-remap-add-relative 'font-lock-comment-face 'eww-valid-certificate))

;; Now use `face-remap-remove-relative' on the cookie.

(face-remap-remove-relative my-comment-remap-cookie)

;; Let's now write our own face instead of relying on existing ones
;; (those may change and/or they may not suit our particular
;; requirements).

(defface ken_nc/comment-remap-style
  '((default :inherit bold)
    (((class color) (background light))
     :foreground "ForestGreen")

    (((class color) (background dark))
     :foreground "#af875f")
    (t :foreground "ForestGreen"))
  "Green text with bold font (italics).")

(defface ken_nc/comment-delimiter-remap-style
  '((default :inherit bold)
    (((class color) (background light))
     :foreground "ForestGreen")

    (((class color) (background dark))
     :foreground "#af875f")
    (t :foreground "ForestGreen"))
  "Green text with bold font (italics).")

;; Time to put our functionality in a minor-mode so we can activate it
;; whenever we want with M-x.

(define-minor-mode my-comment-remap-mode
  "Remap the face of comments."
  :local t
  :init-value nil
  (if my-comment-remap-mode
	  (progn
		(setq my-comment-remap-cookie
			  (face-remap-add-relative 'font-lock-comment-face 'ken_nc/comment-remap-style))
		(setq my-comment-delimiter-remap-cookie
			  (face-remap-add-relative 'font-lock-comment-delimiter-face 'ken_nc/comment-delimiter-remap-style)))
	(progn
	  (face-remap-remove-relative my-comment-remap-cookie)
	  (face-remap-remove-relative my-comment-delimiter-remap-cookie))))

;; Or you can use a hook (this one targets the mode of the *scratch*
;; buffer):
(add-hook 'emacs-lisp-mode-hook #'my-comment-remap-mode)
(add-hook 'go-mode-hook #'my-comment-remap-mode)

(provide 'ken_nc-custom-colors)
