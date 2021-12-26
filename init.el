;;disable emacs from creating files on system
(setq make-backup-file nil)
(setq auto-save-default nil)
(abbrev-mode -1)

;; requirements to be loaded before config.org
(add-to-list 'load-path "~/.emacs.d/lisp")

(require 'space-chord)
(require 'google-c-style)
(require 'xah-fly-keys)
(require 'ctags-utils)
(require 'move-text)
;; (load "xah-fly-keys.elc") ;; recompile for any changes
;; (load "ctags-utils.elc")

(setq xah-fly-use-control-key nil)
(xah-fly-keys-set-layout "qwerty")
(xah-fly-keys 1)

;; Minor Mode Settings
(global-subword-mode 1) ;; Change all cursor movement/edit commands to stop in-between the “camelCase” words

(defvar startup/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(defun startup/revert-file-name-handler-alist ()
  (setq file-name-handler-alist startup/file-name-handler-alist))

(defun startup/reset-gc ()
  (setq gc-cons-threshold 100000000))

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
 '(acme-theme-black-fg nil)
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#262626" "#FF6666" "#A6E22E" "#FFFF66" "#6666FF" "#FD5FF0" "#99CCFF" "#F1EFEE"])
 '(awesome-tray-mode-line-active-color "#0031a9")
 '(awesome-tray-mode-line-inactive-color "#d7d7d7")
 '(custom-enabled-themes '(xresources))
 '(custom-safe-themes
   '("6dc02f2784b4a49dd5a0e0fd9910ffd28bb03cfebb127a64f9c575d8e3651440" "998975856274957564b0ab8f4219300bca12a0f553d41c1438bbca065f298a29" "acb636fb88d15c6dd4432e7f197600a67a48fd35b54e82ea435d7cd52620c96d" "e5dc5b39fecbeeb027c13e8bfbf57a865be6e0ed703ac1ffa96476b62d1fae84" default))
 '(exwm-floating-border-color "#888888")
 '(flymake-error-bitmap '(flymake-double-exclamation-mark modus-themes-fringe-red))
 '(flymake-note-bitmap '(exclamation-mark modus-themes-fringe-cyan))
 '(flymake-warning-bitmap '(exclamation-mark modus-themes-fringe-yellow))
 '(hl-todo-keyword-faces
   '(("HOLD" . "#70480f")
	 ("TODO" . "#721045")
	 ("NEXT" . "#5317ac")
	 ("THEM" . "#8f0075")
	 ("PROG" . "#00538b")
	 ("OKAY" . "#30517f")
	 ("DONT" . "#315b00")
	 ("FAIL" . "#a60000")
	 ("BUG" . "#a60000")
	 ("DONE" . "#005e00")
	 ("NOTE" . "#863927")
	 ("KLUDGE" . "#813e00")
	 ("HACK" . "#813e00")
	 ("TEMP" . "#5f0000")
	 ("FIXME" . "#a0132f")
	 ("XXX+" . "#972500")
	 ("REVIEW" . "#005a5f")
	 ("DEPRECATED" . "#201f55")))
 '(ibuffer-deletion-face 'modus-themes-mark-del)
 '(ibuffer-filter-group-name-face 'modus-themes-pseudo-header)
 '(ibuffer-marked-face 'modus-themes-mark-sel)
 '(ibuffer-title-face 'default)
 '(org-src-block-faces 'nil)
 '(org-startup-folded t)
 '(package-selected-packages
   '(ryo-modal modus-themes go-mode xah-elisp-mode spaceline command-log-mode dired-toggle-sudo xah-css-mode elisp-format crux xresources-theme acme-theme geiser-mit meghanada company-irony company-c-headers yasnippet-snippets yasnippet company magit treemacs-icons-dired treemacs-evil treemacs undo-tree page-break-lines async ido-vertical-mode switch-window avy beacon swiper dashboard diminish auto-package-update htmlize use-package))
 '(pdf-view-midnight-colors '("#000000" . "#f8f8f8"))
 '(read-buffer-completion-ignore-case t)
 '(read-file-name-completion-ignore-case t)
 '(transient-mark-mode t)
 '(vc-annotate-background nil)
 '(vc-annotate-background-mode nil)
 '(vc-annotate-color-map
   '((20 . "#a60000")
	 (40 . "#721045")
	 (60 . "#8f0075")
	 (80 . "#972500")
	 (100 . "#813e00")
	 (120 . "#70480f")
	 (140 . "#5d3026")
	 (160 . "#184034")
	 (180 . "#005e00")
	 (200 . "#315b00")
	 (220 . "#005a5f")
	 (240 . "#30517f")
	 (260 . "#00538b")
	 (280 . "#093060")
	 (300 . "#0031a9")
	 (320 . "#2544bb")
	 (340 . "#0000c0")
	 (360 . "#5317ac")))
 '(vc-annotate-very-old-color nil)
 '(xterm-color-names
   ["black" "#a60000" "#005e00" "#813e00" "#0031a9" "#721045" "#00538b" "gray65"])
 '(xterm-color-names-bright
   ["gray35" "#972500" "#315b00" "#70480f" "#2544bb" "#8f0075" "#30517f" "white"]))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :extend nil :stipple nil :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 98 :width normal :foundry "Alts" :family "ProFontIIx"))))
 '(cursor ((t (:background "white smoke" :foreground "white smoke"))))
 '(hl-line ((t (:extend t))))
 '(mode-line ((t nil)))
 '(mouse ((t (:background "white smoke")))))

; UTF-8 as default encoding
(set-language-environment "UTF-8")
(set-default-coding-systems 'utf-8-unix)
(put 'narrow-to-region 'disabled nil)
