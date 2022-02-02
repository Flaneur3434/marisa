;;disable emacs from creating files on system
(setq make-backup-file nil)
(setq auto-save-default nil)
(abbrev-mode -1)

;; requirements to be loaded before config.org
(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'load-path "~/.emacs.d/lisp/mct")
(add-to-list 'load-path "~/.emacs.d/lisp/prot-lisp")
(add-to-list 'load-path "~/.emacs.d/lisp/wgrep")
(add-to-list 'load-path "~/.emacs.d/lisp/fzf")
(add-to-list 'load-path "~/.emacs.d/lisp/corfu")
(add-to-list 'load-path "~/.emacs.d/lisp/auto-complete")
(add-to-list 'load-path "~/.emacs.d/lisp/auto-complete-c-headers")
(add-to-list 'load-path "~/.emacs.d/lisp/cape")
(add-to-list 'load-path "~/.emacs.d/lisp/iedit")
(add-to-list 'load-path "~/.emacs.d/lisp/popup-el")

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/xresources-theme")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/zenburn-emacs")

(require 'google-c-style)
(require 'ctags-utils)
(require 'move-text)
(require 'color)  ;; for org mode codeblock background color
(require 'mct-customizations)
(require 'prot-comment)
(require 'prot-common)
(require 'prot-diff)
(require 'prot-simple)
(require 'prot-eshell)
(require 'wc-mode)
(require 'corfu)
(require 'cape)
(require 'ken_nc-functions)
(require 'ken_nc-custom-colors)
(require 'darkroom)
(require 'wgrep)
(require 'fzf)
(require 'smart-tab)
(require 'auto-complete)
(require 'auto-complete-c-headers)
(require 'iedit)
(require 'iedit-rect)
(require 'xah-fly-keys)

(setq xah-fly-use-control-key nil)
(xah-fly-keys-set-layout "qwerty")
(xah-fly-keys 1)

;; Minor Mode Settings
(global-subword-mode 1) ;; Change all cursor movement/edit commands to stop in-between the camelCase words

;; Initialize melpa repo
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
			 '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; Initialize use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Load config.org for init.el configuration
(org-babel-load-file (expand-file-name "~/.emacs.d/config.org"))

(put 'narrow-to-region 'disabled nil)

(custom-set-variables
 '(display-line-numbers-widen t)
 '(package-selected-packages
   '(orderless corfu meghanada irony compnay mozc highlight auto-compplete expand-region which-key use-package undo-tree powerline pfuture page-break-lines magit ido-vertical-mode hydra htmlize ht goto-chg go-mode geiser-mit elisp-format dired-toggle-sudo diminish dashboard crux cfrs beacon auto-package-update async)))
