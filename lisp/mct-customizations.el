(require 'mct)
(setq mct-live-completion t)
(setq mct-hide-completion-mode-line t)
(setq mct-show-completion-line-numbers nil)
(setq mct-apply-completion-stripes nil)
(setq mct-minimum-input 3)
(setq mct-live-update-delay 0.6)
(setq mct-completions-format 'one-column)
(mct-minibuffer-mode 1)
(setq completion-show-inline-help nil)
(setq completions-detailed t)
(setq resize-mini-windows t)

(add-hook 'completion-list-mode-hook (lambda () (setq-local global-hl-line-mode nil)))

(provide 'mct-customizations)
