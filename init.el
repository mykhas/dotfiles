;;; package -- General Emacs setup

;; MELPA
(require 'package)
(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
                    (not (gnutls-available-p))))
       (proto (if no-ssl "http" "https")))
  ;; Comment/uncomment these two lines to enable/disable MELPA and MELPA Stable as desired
  (add-to-list 'package-archives (cons "melpa" (concat proto "://melpa.org/packages/")) t)
  ;;(add-to-list 'package-archives (cons "melpa-stable" (concat proto "://stable.melpa.org/packages/")) t)
  (when (< emacs-major-version 24)
    ;; For important compatibility libraries like cl-lib
    (add-to-list 'package-archives '("gnu" . (concat proto "://elpa.gnu.org/packages/")))))
(package-initialize)

;; ORG MODE
(require 'org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
(add-hook 'org-mode-hook 'org-indent-mode)
(add-hook 'org-mode-hook 'auto-fill-mode)
(setq org-startup-truncated t)
(setq org-todo-keywords
  '((sequence "TODO"
      "MAYBE"
      "NEXT"
      "STARTED"
      "WAITING"
      "DELEGATED"
      "|"
      "DONE"
      "DEFERRED"
      "CANCELLED")))
(require 'org-trello)
(require 'org-journal)
(setq org-agenda-files '("~/Portknox/Org"))
(setq org-journal-enable-agenda-integration t)
(setq org-journal-dir "~/Portknox/Org/journal")
(setq org-journal-file-format "%Y%m%d.org")
(setq org-journal-carryover-items "TODO=\"TODO\"|TODO=\"STARTED\"|TODO=\"NEXT\"|TODO=\"MAYBE\"|TODO=\"WAITING\"")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-trello-current-prefix-keybinding "C-c o" nil (org-trello))
 '(org-trello-files
   (quote
    ("/home/mykhas/Documents/Dropbox/org/chgk/trivia.org")) nil (org-trello))
 '(package-selected-packages
   (quote
    (jscs use-package elfeed elfeed-org pdf-tools pamparam ess org-pomodoro tss mastodon org-trello nov multi-term tide ng2-mode typescript-mode web-mode flycheck xref-js2 js2-refactor js2-mode exec-path-from-shell flymake-json yafolding json-mode editorconfig)))
 '(send-mail-function (quote smtpmail-send-it)))

;; NOV
(add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))
(setq nov-text-width 50)

;; TERM
(require 'multi-term)
(setq multi-term-program "/bin/bash")

;; MASTODON
(setq mastodon-instance-url "https://wandering.shop")

;; RSS
(require 'use-package)
(use-package elfeed-org
  :ensure t
  :config
  (elfeed-org)
  (setq rmh-elfeed-org-files (list "~/Portknox/Org/rss.org")))
;;shortcut functions
(defun bjm/elfeed-show-all ()
  (interactive)
  (bookmark-maybe-load-default-file)
  (bookmark-jump "all"))
(defun bjm/elfeed-show-schdk ()
  (interactive)
  (bookmark-maybe-load-default-file)
  (bookmark-jump "schdk"))
(defun bjm/elfeed-show-news ()
  (interactive)
  (bookmark-maybe-load-default-file)
  (bookmark-jump "news"))

;;functions to support syncing .elfeed between machines
;;makes sure elfeed reads index from disk before launching
(defun bjm/elfeed-load-db-and-open ()
  "Wrapper to load the elfeed db from disk before opening"
  (interactive)
  (elfeed-db-load)
  (elfeed)
  (elfeed-search-update--force))

;;write to disk when quiting
(defun bjm/elfeed-save-db-and-bury ()
  "Wrapper to save the elfeed db to disk before burying buffer"
  (interactive)
  (elfeed-db-save)
  (quit-window))

(require 'use-package)
(use-package elfeed
  :ensure t
  :bind (:map elfeed-search-mode-map
              ("A" . bjm/elfeed-show-all)
              ("S" . bjm/elfeed-show-schdk)
              ("N" . bjm/elfeed-show-news)
              ("q" . bjm/elfeed-save-db-and-bury)))


;; BASIC THEME AND SETTINGS
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'zenburn t)
(set-frame-font "Fira Mono")
(set-face-attribute 'default nil :height 104)
(tool-bar-mode -1)
(menu-bar-mode -1)
(setq-default indent-tabs-mode nil)
(setq backup-directory-alist `(("." . "~/.emacs-saves")))
(defvar autosave-dir (concat "~/.emacs-saves" "/"))
(make-directory autosave-dir t)
(setq auto-save-file-name-transforms
      `(("\\(?:[^/]*/\\)*\\(.*\\)" ,(concat autosave-dir "\\1") t)))

;; MAIL
(require 'mu4e)
(setq mail-user-agent 'mu4e-user-agent)

;; default
(setq mu4e-maildir "~/Maildir")

(setq mu4e-maildir-shortcuts
      '( ("/Gmail_Offlineimap/INBOX"        . ?g)))

;; allow for updating mail using 'U' in the main view:
(setq mu4e-get-mail-command "offlineimap")

;; BASHRC
(exec-path-from-shell-initialize)

;; JS
(require 'flycheck)
(require 'js2-mode)
(require 'js2-refactor)
(require 'xref-js2)

(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-hook 'js2-mode-hook #'js2-imenu-extras-mode) ; better imenu
(add-hook 'js2-mode-hook #'js2-refactor-mode)
(js2r-add-keybindings-with-prefix "C-c C-r")
(define-key js2-mode-map (kbd "C-k") #'js2r-kill)

;; js-mode (which js2 is based on) binds "M-." which conflicts with xref, so
;; unbind it.
(define-key js-mode-map (kbd "M-.") nil)

(add-hook 'js2-mode-hook (lambda ()
                           (add-hook 'xref-backend-functions #'xref-js2-xref-backend nil t)))

;; use web-mode for .jsx files
(add-to-list 'auto-mode-alist '("\\.jsx$" . web-mode))

;; turn on flychecking globally
(add-hook 'after-init-hook #'global-flycheck-mode)

;; disable jshint since we prefer eslint checking
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
    '(javascript-jshint)))

;; use eslint with web-mode for jsx files
(flycheck-add-mode 'javascript-eslint 'web-mode)
(flycheck-add-mode 'javascript-eslint 'js2-mode)

;; customize flycheck temp file prefix
(setq-default flycheck-temp-prefix ".flycheck")

;; disable json-jsonlist checking for json files
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
    '(json-jsonlist)))

;; turn off missing semicolons warnings
(setq js2-strict-missing-semi-warning nil)

;; use local eslint from node_modules before global
;; http://emacs.stackexchange.com/questions/21205/flycheck-with-file-relative-eslint-executable
(defun my/use-eslint-from-node-modules ()
  (let* ((root (locate-dominating-file
                (or (buffer-file-name) default-directory)
                "node_modules"))
         (eslint (and root
                      (expand-file-name "node_modules/eslint/bin/eslint.js"
                                        root))))
    (when (and eslint (file-executable-p eslint))
      (setq-local flycheck-javascript-eslint-executable eslint))))
(add-hook 'flycheck-mode-hook #'my/use-eslint-from-node-modules)

;; TS
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (tide-hl-identifier-mode +1)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
;; (add-hook 'before-save-hook 'tide-format-before-save)

(add-hook 'typescript-mode-hook #'setup-tide-mode)

;; CUSTOM

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(variable-pitch ((t (:family "Fira Sans")))))
