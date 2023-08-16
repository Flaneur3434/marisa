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
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/tokyo-theme.el")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/nothing.el")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/almost-mono-themes")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/acme-emacs-theme")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/naysayer-theme.el")

(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'load-path "~/.emacs.d/lisp/prot-lisp")
(add-to-list 'load-path "~/.emacs.d/lisp/wrap-region")
(add-to-list 'load-path "~/.emacs.d/lisp/undo-hl")
(add-to-list 'load-path "~/.emacs.d/lisp/sky-color-clock")
(add-to-list 'load-path "~/.emacs.d/lisp/almost-mono-themes")
(add-to-list 'load-path "~/.emacs.d/lisp/mwim.el")

(require 'basic-edit-toolkit)
(require 'color)
(require 'ctags-utils)
(require 'darkroom)
(require 'deferred)
(require 'dired-sort)
(require 'google-c-style)
(require 'google-java-format)
(require 'go-to-char)
(require 'ken_nc-custom-colors)
(require 'ken_nc-eshell)
(require 'ken_nc-functions)
(require 'move-text)
(require 'mwim)
(require 'openbsd-knf-style)
(require 'package)
(require 'project)
(require 'prot-comment)
(require 'prot-common)
(require 'prot-diff)
(require 'prot-eshell)
(require 'prot-simple)
(require 'rect-extension)				; TODO 2022-02-09: Add keybinds and functions
(require 'sky-color-clock)
(require 'undo-hl)
(require 'unfill)
(require 'wc-mode)
(require 'xterm-cursor-changer)

;; Minor Mode Settings
(global-subword-mode 1) ;; Change all cursor movement/edit commands to stop in-between the camelCase words

;; Load config.org for init.el configuration
(org-babel-load-file (expand-file-name "~/.emacs.d/config.org"))

;; needs to be last due to it calling interactive functions from other files
(require 'xah-fly-keys)

(setq xah-fly-use-control-key nil)
(xah-fly-keys-set-layout "qwerty")
(xah-fly-keys 1)

(when (daemonp)
  (add-hook 'after-make-frame-functions
            (lambda (frame)
			  (load-theme 'naysayer t)
			  (select-frame frame)
			  (xah-fly-keys t)
			  (gcmh-mode -1))))

(when (not (display-graphic-p))
  (progn
	;; (add-hook 'after-make-frame-functions
	;; 		  (lambda (frame)
	;; 			(load-theme 'xresources t)))
	(xterm-mouse-mode t)
	(setq mouse-wheel-scroll-amount '(0.1)
		  mouse-wheel-progressive-speed nil
		  ring-bell-function 'ignore)))

(if (fboundp 'native-compile-async)
	(progn
      (native-compile-async "~/.emacs.d/lisp" 'recursively)
	  (native-compile-async "~/.emacs.d/init.el")
	  (native-compile-async "~/.emacs.d/early-init.el")))

(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)
