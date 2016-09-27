
;; ... Built-in Emacs config

;; This is for config settings that don't need to be installed. In
;; these cases, I'm not worried about load times, etc that I'd benefit
;; from by wrapping it in the use-package framework.
;;
;; Melie called at: 8:19 PM

;; Make sure my "full" name appears how I want it in signatures
(setq user-full-name "Vincent A. Emanuele II")

;; Highlight paren that matches one at point
(show-paren-mode 1)

;; Display column numbers
(setq column-number-mode t)

;; Tab behavior
(setq tab-width 4)
(setq tab-stop-list nil)
(setq-default indent-tabs-mode nil)

;; Text Width setup
;; I got the text-width setting from the python people
;; https://www.python.org/dev/peps/pep-0008/#maximum-line-length
(setq-default fill-column 79)
(add-hook 'text-mode-hook 'turn-on-auto-fill)

;; Spell checking
(add-hook 'text-mode-hook 'turn-on-flyspell)
(setq ispell-personal-dictionary "~/org/aspell.personal.en.dictionary")

;; I should add some setup for abbrev-mode. It is useful.

;; ... use-package for managing 3rd party packages and their config
;; Got this slick snippet of code from:
;; http://cachestocaches.com/2015/8/getting-started-use-package/
(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/"))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))
(require 'diminish)
(require 'bind-key)

;; Do I want to add a location for local lisp files to be loaded?

(use-package solarized-theme
  :config
  (load-theme 'solarized-dark t)
  :ensure t)

;; Use-package initialization framework
(use-package helm
  :ensure t
  :diminish helm-mode
  :init

  ;; Changes the helm prefix key
  (global-set-key (kbd "C-c h") 'helm-command-prefix)
  (global-unset-key (kbd "C-x c"))

  ;; Supress warning
  (setq ad-redefinition-action 'accept)

  :config

  (require 'helm)
  (require 'helm-files)
  (require 'helm-config) ; Necessary for helm-mode
  
  ;; Key bindings
  (bind-key "<tab>" 'helm-execute-persistent-action helm-map)
  (bind-key "C-i" 'helm-execute-persistent-action helm-map)
  (bind-key "C-z" 'helm-select-action helm-map) ; list actions using C-z

  (setq helm-split-window-in-side-p           t
	helm-move-to-line-cycle-in-source     t
	helm-ff-search-library-in-sexp        t
	helm-scroll-amount                    8
	helm-M-x-fuzzy-match                  t
	helm-ff-file-name-history-use-recentf t)

  (if (string-equal system-type "darwin")
      ;; This requires the 'ggrep' command to be installed for OSX
      ;; Note, I have kept defaul name of "grep" using brew
      (setq helm-grep-default-command
	    "grep --color=always -d skip %e -n%cH -e %p %f"
	    helm-grep-default-recurse-command
	    "grep --color=always -d recurse %e -n%cH -e %p %f"))
  (if (string-equal system-type "gnu/linux")
      (setq helm-grep-default-command
	    "grep --color=always -d skip %e -n%cH -e %p %f"
	    helm-grep-default-recurse-command
	    "grep --color=always -d recurse %e -n%cH -e %p %f"))

  (helm-mode 1)
  
  ;; Disable use of helm mode when setting tags in org mode

  ;; Considerations for future: wrap in an eval-after-load. For now, This MUST
  ;; occur after (helm-mode 1) line above

  ;; ... Remove org-set-tags binding to helm-complete 
  (setq helm-completing-read-handlers-alist (delq (assoc 'org-set-tags helm-completing-read-handlers-alist) helm-completing-read-handlers-alist))
  ;; ... Set it to be vanilla emacs completion engine (better for headlines that have multiple tags)
  (add-to-list 'helm-completing-read-handlers-alist '(org-set-tags . nil))

  :bind (("C-x b" . helm-buffers-list)
	 ("C-x C-f" . helm-find-files)
	 ("M-x" . helm-M-x)
	 ("M-s o" . helm-occur)
	 )
  )

;; ... Org Mode
(use-package org
  :mode (("\\.org$'" . org-mode))
  :ensure org-plus-contrib
  :init
  ;; (add-hook 'org-mode-hook 'visual-line-mode)
  ;; (add-hook 'org-mode-hook 'org-indent-mode)
  ;; (add-hook 'org-mode-hook 'flyspell-mode)

  ;; ...,,, Set to the location of your Org files on your local system
  (setq org-directory "~/org")

  ;; ...,,, Set to the name of the file where new notes will be stored
  (setq org-mobile-inbox-for-pull "~/org/flagged.org")

  ;; ...,,, Set to <your Dropbox root directory>/MobileOrg.
  (setq org-mobile-directory "~/Personal Files/Dropbox/Apps/MobileOrg")

  ;; (add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))

  (setq org-todo-keywords
      '( (sequence "TODO(t)" "INPROGRESS(i)" "WAITING(w)" "|" "ANTITODO(a)" "DONE(d)" "DELEGATED(l)" "CANCELED(c)" )
	 ))

  (setq org-todo-keyword-faces
      '(
        ("TODO"  . (:foreground "firebrick2" :weight bold))
        ("INPROGRESS"  . (:foreground "blue" :weight bold))
        ("WAITING"  . (:foreground "orange" :weight bold))
        ("ANTITODO"  . (:foreground "forestgreen" :weight bold))
        ("DONE"  . (:foreground "forestgreen" :weight bold))
        ("DELEGATED"  . (:foreground "dimgrey" :weight bold))
        ("CANCELED"  . (:foreground "forestgreen" :weight bold))
        ))

  (setq org-agenda-files '("~/org"))

  ;; Updated 2016 agenda views based on new system
  (setq org-agenda-custom-commands
	'(("paw" tags-todo "+priority+@work+PRIORITY=\"A\"")
	  ("pah" tags-todo "+priority+@home+PRIORITY=\"A\"")
	  ("pw" tags-todo "+priority+@work")
	  ("ph" tags-todo "+priority+@home")
	  ("wc" tags-todo "-@home-@work-@errand-@laptop")
	  ("kt" todo "TODO")
	  ("ki" todo "INPROGRESS")
	  ("kw" todo "WAITING")
	  ("kl" todo "DELEGATED")
	  ("kd" todo "DONE")
	  ("kc" todo "CANCELED")
	  ))

  ;; org-capture setup
  ;; Basically using the setup from http://doc.norang.ca/org-mode.html#Capture
  
  ;; ... tasks, notes, appointments, phone calls, org-workflow.  I
  ;; removed the %a because the links to the original file were really
  ;; annoying me
  (setq org-capture-templates
        '(("t" "Todo" entry (file+headline "~/org/inbox.org" "Inbox")
           "* TODO %?\n%U\n  %i")
          ("n" "Wellcentive meeting note"
           entry (file+headline "~/org/wellcentive/wellcentive.org" "Meeting Notes") "* %? %U :note:\n  - Who: \n %i" :prepend t)
          ))
  
  ;; Refile settings
  ;; Targets include this file and any file contributing to the agenda - up to
  ;; 2 levels deep
  (setq org-refile-targets (quote ((nil :maxlevel . 7)
				   (org-agenda-files :maxlevel . 7))))
  (setq org-refile-use-outline-path t)

  ;; Change these two to nil if using IDO (?)
  (setq org-outline-path-complete-in-steps nil)

  ;; Separate drawers for clocking and logs
  (setq org-drawers (quote ("PROPERTIES" "LOGBOOK")))

  ;; More logging
  (setq org-log-done (quote time))
  (setq org-log-into-drawer t)

  :defer t
  :bind (("\C-c a" . org-agenda)
	 ("\C-c c" . org-capture)
	 ("\C-c l" . org-store-link)
	 ("\C-c c" . org-capture)
	 ("\C-c b" . org-iswitchb)

	 ;; (global-set-key "8" (quote org-capture))
	 ;; (global-set-key "9" (quote org-refile))
	 ;; (global-set-key "0" (quote org-agenda))
	 ;; (global-set-key "8" (quote org-capture))
	 ;; (global-set-key "9" (quote org-refile))
	 )
  :config
  ;; Agenda
  (setq org-agenda-window-setup 'current-window)
  ;;(setq org-agenda-files (quote ("~/org" "~/rrg/gjstein_notebook")))

  (define-key global-map "\C-cl" 'org-store-link)
  
  ; Run/highlight code using babel in org-mode
  (org-babel-do-load-languages
   'org-babel-load-languages
   '(
     (R . t)
     (python . t)
     (sh . t)
     (sql . t)
     (ditaa . t)
     (java . t)
     )
   )

  ;; Turn off default org-babel security
  (setq org-confirm-babel-evaluate nil)

  ;; Other customizations of org based on config variables
  (setq org-refile-use-cache t)
  (setq org-src-fontify-natively t)
  
  )

;; ... Auto-Completion
;; Note, I used to use auto-complete, now I'm trying out company. It
;; looks more modular and easier to maintain.
;;
;; Ref:
;; http://emacs.stackexchange.com/questions/712/what-are-the-differences-between-autocomplete-and-company-mode

(use-package company
  :init
  (setq company-idle-delay 0.35)
  (setq company-minimum-prefix-length 3)
  (setq company-dabbrev-downcase nil)
  (add-hook 'after-init-hook 'global-company-mode)
  :ensure t)

;; Of course, I want to check out the helm-way of interacting with
;; company mode. Note, I'm overwritting the default key binding C-s
;; for company-search-candidates. I'm assuming I'll always want to
;; filter candidates with helm mode.
;;
;; A fix I had to use to get the case right for helm-company:
;; https://github.com/yasuyk/helm-company/issues/8

(use-package helm-company
  :init
  (eval-after-load 'company
  '(progn
     (define-key company-mode-map (kbd "C-:") 'helm-company)
     (define-key company-active-map (kbd "C-s") 'helm-company)))
  :ensure t)

;; ... Emacs Desktop Mode
(use-package desktop
  :config
  (desktop-save-mode t)
  :ensure t)

