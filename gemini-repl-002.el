;; Emacs configuration for gemini-repl-002
;; Generated on Wed Aug  6 10:41:32 EDT 2025

;; Project settings
(setq project-root "/home/dsp-dr/ghq/github.com/aygp-dr/gemini-repl-002")
(setq project-name "gemini-repl-002")

;; Load essential packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Install packages if not present
(unless (package-installed-p 'cider)
  (package-refresh-contents)
  (package-install 'cider))
(unless (package-installed-p 'clojure-mode)
  (package-install 'clojure-mode))
(unless (package-installed-p 'paredit)
  (package-install 'paredit))

;; Configure Clojure development
(require 'cider)
(require 'clojure-mode)
(require 'paredit)

;; Enable paredit for Clojure
(add-hook 'clojure-mode-hook #'paredit-mode)
(add-hook 'cider-repl-mode-hook #'paredit-mode)

;; CIDER configuration
(setq cider-repl-display-help-banner nil)
(setq cider-shadow-cljs-command "npx shadow-cljs")
(setq cider-default-cljs-repl 'shadow)
(setq cider-shadow-default-options "app")

;; Org-mode configuration for literate programming
(require 'org)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((clojure . t)))

;; Start in project directory
(cd project-root)
(message "Emacs configured for %s" project-name)
