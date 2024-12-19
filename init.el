;; -*- lexical-binding: t -*-

;; Load config.org for init.el configuration
(org-babel-load-file (expand-file-name "config.org" user-emacs-directory))

(if (file-exists-p custom-file)
    (load custom-file))
