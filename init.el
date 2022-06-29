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

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/xresources-theme")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/zenburn-emacs")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/monochrome-theme")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/emacs-flatland-black-theme")

(use-package aggressive-indent
  :ensure t)

(use-package dash
  :ensure t)

(use-package dired-toggle-sudo
  :ensure t)

(use-package exec-path-from-shell
  :ensure t)

(use-package expand-region
  :ensure t)

(use-package ido-vertical-mode
  :ensure t)

(use-package iedit
  :ensure t)

(use-package mct
  :ensure t)

(use-package pcmpl-args
  :ensure t)

(use-package page-break-lines
  :ensure t)

(use-package popwin
  :ensure t)

(use-package queue
  :ensure t)

(use-package s
  :ensure t)

(use-package undo-tree
  :ensure t)

(use-package undohist
  :ensure t)

(use-package which-key
  :ensure t)


(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'load-path "~/.emacs.d/lisp/prot-lisp")
(add-to-list 'load-path "~/.emacs.d/lisp/wgrep")

(require 'ag)
(require 'aggressive-indent)
(require 'basic-edit-toolkit)
(require 'color)
(require 'ctags-utils)
(require 'darkroom)
(require 'deferred)
(require 'dired-sort)
(require 'exec-path-from-shell)
(require 'google-c-style)
(require 'google-java-format)
(require 'go-to-char)
(require 'iedit)
(require 'iedit-rect)
(require 'inertial-scroll)
(require 'ken_nc-custom-colors)
(require 'ken_nc-eshell)
(require 'ken_nc-functions)
(require 'mct-customizations)
(require 'move-text)
(require 'openbsd-knf-style)
(require 'package)
(require 'pcmpl-args)
(require 'popwin)
(require 'project)
(require 'prot-comment)
(require 'prot-common)
(require 'prot-diff)
(require 'prot-eshell)
(require 'prot-simple)
(require 'rect-extension)				; TODO 2022-02-09: Add keybinds and functions
(require 'undohist)
(require 'unfill)
(require 'wc-mode)
(require 'wgrep)
(require 'wgrep-ag)

;; needs to be last due to it calling interactive functions from other files
(require 'xah-fly-keys)

(setq xah-fly-use-control-key nil)
(xah-fly-keys-set-layout "qwerty")
(xah-fly-keys 1)

;; Minor Mode Settings
(global-subword-mode 1) ;; Change all cursor movement/edit commands to stop in-between the camelCase words


;; Load config.org for init.el configuration
(org-babel-load-file (expand-file-name "~/.emacs.d/config.org"))

(if (fboundp 'native-compile-async)
	(progn
      (native-compile-async "~/.emacs.d/lisp" 'recursively)
	  (native-compile-async "~/.emacs.d/init.el")
	  (native-compile-async "~/.emacs.d/early-init.el")))
;; 	  (native-compile-async "~/.emacs.d/config.el")))

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)
