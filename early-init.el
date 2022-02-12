;; Emacs Color and Set Faces
(set-face-background 'cursor "white smoke")
(set-face-background 'mouse "white smoke")
(set-face-background 'region  "#666")
(setq read-file-name-completion-ignore-case t)
(setq frame-resize-pixelwise t)
;;  (set-frame-parameter (selected-frame) 'alpha '(active . inactive))
;;  (set-frame-parameter (selected-frame) 'alpha '(both))
;;  (set-frame-parameter (selected-frame) 'alpha '(100 . 100))
(add-to-list 'default-frame-alist '(alpha . (100)))

(defvar startup/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(defun startup/revert-file-name-handler-alist ()
  (setq file-name-handler-alist startup/file-name-handler-alist))

(defun startup/reset-gc ()
  (setq gc-cons-threshold 100000000))

(add-hook 'emacs-startup-hook 'startup/revert-file-name-handler-alist)
(add-hook 'emacs-startup-hook 'startup/reset-gc)

(setq comp-deferred-compilation t)

(provide 'early-init)
