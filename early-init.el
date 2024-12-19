;; This file is loaded before the package system and GUI is initialized, so in
;; it you can customize variables that affect frame appearance as well as the
;; package initialization process, such as package-enable-at-startup,
;; package-load-list, and package-user-dir. Note that variables like
;; package-archives which only affect the installation of new packages, and not
;; the process of making already-installed packages available, may be customized
;; in the regular init file.

(defvar file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)
(setq site-run-file nil)
(setq read-process-output-max (* 4096 4096)) ;; 1mb
(setq
 warning-minimum-level :emergency
 auto-save-default nil
 make-backup-file nil
 load-prefer-newer t
 mode-line-format nil
 package-enable-at-startup nil
 package-native-compile t)

;; prevent package.el loading packages prior to their init-file loading
(setq package-enable-at-startup nil)

;; Prevent Custom from modifying this file.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror 'nomessage)

(server-start)

;; Change location of natively compiled cache
(when (and (fboundp 'startup-redirect-eln-cache)
           (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (startup-redirect-eln-cache
   (convert-standard-filename
	(expand-file-name  "var/eln-cache/" user-emacs-directory))))

(provide 'early-init)
