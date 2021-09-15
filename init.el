;; Make emacs startup faster
(setq gc-cons-threshold 402653184
      gc-cons-percentage 0.6)

;;disable emacs from creating files on system
(setq make-backup-file nil)
(setq auto-save-default nil)

;; requirements to be loaded before config.org

(add-to-list 'load-path "~/.emacs.d/lisp/")
(require 'space-chord)
(require 'xah-fly-keys)

(setq xah-fly-use-control-key nil)
(xah-fly-keys-set-layout "qwerty")
(xah-fly-keys 1)

;; Minor Mode Settings
(load "~/.emacs.d/my-abbrev.el") ;; dictionary for my abbreviations
(global-subword-mode 1) ;; Change all cursor movement/edit commands to stop in-between the “camelCase” words

(defvar startup/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(defun startup/revert-file-name-handler-alist ()
  (setq file-name-handler-alist startup/file-name-handler-alist))

(defun startup/reset-gc ()
  (setq gc-cons-threshold 16777216
    gc-cons-percentage 0.1))

(add-hook 'emacs-startup-hook 'startup/revert-file-name-handler-alist)
(add-hook 'emacs-startup-hook 'startup/reset-gc)
;;

;; Initialize melpa repo
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
        '("melpa" . "https://melpa.org/packages/"))(package-initialize)

;; Initialize use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Load config.org for init.el configuration
(org-babel-load-file (expand-file-name "~/.emacs.d/config.org"))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#262626" "#FF6666" "#A6E22E" "#FFFF66" "#6666FF" "#FD5FF0" "#99CCFF" "#F1EFEE"])
 '(custom-enabled-themes '(xresources))
 '(custom-safe-themes
   '("acb636fb88d15c6dd4432e7f197600a67a48fd35b54e82ea435d7cd52620c96d" "e5dc5b39fecbeeb027c13e8bfbf57a865be6e0ed703ac1ffa96476b62d1fae84" default))
 '(package-selected-packages
   '(xah-css-mode elisp-format crux xresources-theme acme-theme geiser-mit meghanada company-irony company-c-headers yasnippet-snippets yasnippet company magit treemacs-icons-dired treemacs-evil treemacs undo-tree page-break-lines async ido-vertical-mode switch-window avy beacon swiper dashboard spaceline diminish auto-package-update htmlize use-package))
 '(read-buffer-completion-ignore-case t)
 '(read-file-name-completion-ignore-case t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :background "#010202" :foreground "#aba7a3" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 98 :width normal :foundry "ADBO" :family "ProFontIIx"))))
 '(cursor ((t (:background "white smoke" :foreground "white smoke"))))
 '(mouse ((t (:background "white smoke")))))

; UTF-8 as default encoding
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8-unix)
(put 'narrow-to-region 'disabled nil)
