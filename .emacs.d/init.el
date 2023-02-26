;; .emacs.d/init.el

;; ===================================
;; MELPA Package Support
;; ===================================
;; Enables basic packaging support
(require 'package)

;; Adds the Melpa archive to the list of available repositories
(setq package-archives '(("melpa"  . "https://melpa.org/packages/")
                         ("gnu"    . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

;; Initializes the package infrastructure
(package-initialize)

;; If there are no archived package contents, refresh them
(when (not package-archive-contents)
  (package-refresh-contents))

;; Installs packages
;;
;; myPackages contains a list of package names
(defvar myPackages
  '(
    flycheck                        ;; On the fly syntax checking
    magit                           ;; Git integration
    modus-themes                    ;; Theme
    )
  )

;; Scans the list in myPackages
;; If the package listed is not already installed, install it
(mapc #'(lambda (package)
          (unless (package-installed-p package)
            (package-install package)))
      myPackages)

;; ===================================
;; Basic Customization
;; ===================================
(setq byte-compile-warnings '(cl-functions))
(setq inhibit-startup-message t)    ;; Hide the startup message
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-hook 'window-setup-hook 'toggle-frame-fullscreen t) ;;or Fn-F11
(setq frame-title-format '("%b@" (:eval (or (file-remote-p default-directory 'host) system-name)) " — Emacs"))
(scroll-bar-mode -1)
(menu-bar-mode -1)
(show-paren-mode t)
(global-auto-revert-mode t)
(setq large-file-warning-threshold 100000000)
(global-set-key [f10] 'menu-bar-open)
(setq backup-directory-alist '(("." . "~/.emacs.d/backup")))
(setq auto-save-list-file-prefix "~/.emacs.d/autosave/")
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/autosave/" t)))
(setq explicit-shell-file-name "C:/cygwin64/bin/zsh") ;; create file .zshenv in same directory .zshrc file to define user variable when using zsh in emacs Ex: PATH=$PATH:$HOME/bin:$GOPATH/bin EDITOR=emacsclient
(setq shell-file-name "zsh") ;;You could invoke the Cygwin programs and utilities via the Windows' Command Prompt ("cmd.exe") instead of bash shell (provided the PATH is set properly)
(setq explicit-zsh-args '("--login" "--interactive"))
(defun zsh-shell-mode-setup ()
  (setq-local comint-process-echoes t))
(add-hook 'shell-mode-hook #'zsh-shell-mode-setup)
(defun my-shell-mode-hook ()
  (add-hook
   'comint-output-filter-functions
   'python-pdbtrack-comint-output-filter-function t))
(add-hook 'shell-mode-hook 'my-shell-mode-hook)
					;(setq custom-file "~/.emacs.d/custom.el")
					;(when (file-exists-p custom-file)
					;(load custom-file))
					;(setq package-check-signature nil)
(setq delete-by-moving-to-trash t)
(setq initial-scratch-message nil) 
(fset 'yes-or-no-p 'y-or-n-p)
(setf dired-kill-when-opening-new-dired-buffer t)
(setq package-gnupghome-dir "elpa/gnupg")
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
(add-to-list 'company-backends 'company-c-headers)

(require 'golden-ratio)
(golden-ratio-mode 1)
;;(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/") using for download custom themes
;;and M-x load-theme RET zenburn
;; or (load-theme 'zenburn t)
(require 'multiple-cursors)
(global-unset-key (kbd "M-<down-mouse-1>"))
(global-set-key (kbd "M-<mouse-1>") 'mc/add-cursor-on-click)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
;;Using GDB
;M-x gdb-many-windows
;Auto nicely aligned when all you do is type
(global-aggressive-indent-mode 1)
(add-to-list 'aggressive-indent-excluded-modes 'python-mode)
(add-to-list 'aggressive-indent-excluded-modes 'html-mode)
(add-to-list 'aggressive-indent-excluded-modes 'css-mode)
(add-to-list 'aggressive-indent-excluded-modes 'rjsx-mode)
(add-to-list 'aggressive-indent-excluded-modes 'c-mode)
(add-to-list
 'aggressive-indent-dont-indent-if
 '(and (derived-mode-p 'c++-mode)
       (null (string-match "\\([;{}]\\|\\b\\(if\\|for\\|while\\)\\b\\)"
                           (thing-at-point 'line)))))
;;===========================================
;;End of Basic config
;;==========================================
(defun attach-marked-files (buffer) ;; Attach multiple file when send mail , press <u> to mark the file 
      "Attach all marked files to BUFFER"
      (interactive "BAttach to buffer: ")
      (let ((files (dired-get-marked-files)))
        (with-current-buffer (get-buffer buffer)
          (dolist (file files)
            (if (file-regular-p file)
              (mml-attach-file file
                (mm-default-file-encoding file)
                nil "attachment")
              (message "skipping non-regular file %s" file)))))
      (switch-to-buffer buffer))
;;Or C-x 4-d ===> M-x turn-on-gnus-dired-mode ===> Mark the file by press <u> ===> C-c C-a to attach or may be C-c RET C-a
;;Customize dashboard==========================
(add-to-list 'load-path "~/.emacs.d/fontlock")
(add-to-list 'load-path "~/.emacs.d/all-the-icons-dired")
(require 'font-lock)
(require 'font-lock+)
(require 'all-the-icons)
(require 'all-the-icons-dired)
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)
(require 'dashboard)
(setq dashboard-banner-logo-title "Welcome to my home!!!")
(setq dashboard-startup-banner "~/.emacs.d/img/2.jpg")
(setq dashboard-set-heading-icons t)
(setq dashboard-set-file-icons t)
(setq dashboard-items '((recents  . 5)
			(bookmarks . 5)
			(agenda . 5)))
(dashboard-setup-startup-hook)
;;=============================================
(defun split-window-right-and-focus ()
  "Spawn a new window right of the current one and focus it."
  (interactive)
  (split-window-right)
  (windmove-right))

(defun split-window-below-and-focus ()
  "Spawn a new window below the current one and focus it."
  (interactive)
  (split-window-below)
  (windmove-down))

(defun kill-buffer-and-delete-window ()
  "Kill the current buffer and delete its window."
  (interactive)
  (progn
    (kill-this-buffer)
    (delete-window)))

(setq-default initial-scratch-message nil)
(setq undo-limit        100000000
      auto-save-default t)
(setq window-combination-resize t)
(setq user-full-name       "Khoi Nguyen Tinh Song"
      user-real-login-name "Khoi Nguyen Tinh Song"
      user-login-name      "duk"
      user-mail-address    "songkhoi123@gmail.com")
(require 'time)
(setq display-time-format "%Y-%m-%d %H:%M")
(display-time-mode 1) ; display time in modeline
;;set environment
(set-language-environment 'utf-8)
(setq locale-coding-system 'utf-8)                                                       
;; set the default encoding system                                                          
(prefer-coding-system 'utf-8)                                                               
(setq default-file-name-coding-system 'utf-8)                                               
(set-default-coding-systems 'utf-8)                                                         
(set-terminal-coding-system 'utf-8)                                                         
(set-keyboard-coding-system 'utf-8)                                                         
;; Treat clipboard input as UTF-8 string first; compound text next, etc.                    
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING)) 
;;Mode-line config
(require 'doom-modeline)
(doom-modeline-mode 1)
(nyan-mode)
(parrot-mode)
(setq nyan-cat-face-number 4)
(setq nyan-animate-nyancat t)
(setq nyan-wavy-trail t)
(setq nyan-bar-length 60)
(setq doom-modeline-support-imenu t)
(setq doom-modeline-height 10)
;; How wide the mode-line bar should be. It's only respected in GUI.
(setq doom-modeline-bar-width 4)
;; Whether to use hud instead of default bar. It's only respected in GUI.
;;(setq doom-modeline-hud nil)
;; The limit of the window width.
;; If `window-width' is smaller than the limit, some information won't be
;; displayed. It can be an integer or a float number. `nil' means no limit."
(setq doom-modeline-window-width-limit nil)
;; How to detect the project root.
;; nil means to use `default-directory'.
;; The project management packages have some issues on detecting project root.
;; e.g. `projectile' doesn't handle symlink folders well, while `project' is unable
;; to hanle sub-projects.
;; You can specify one if you encounter the issue.
(setq doom-modeline-project-detection 'auto)
;; If you are experiencing the laggy issue, especially while editing remote files
;; with tramp, please try `file-name' style.
;; Please refer to https://github.com/bbatsov/projectile/issues/657.
(setq doom-modeline-buffer-file-name-style 'auto)
;; Whether display icons in the mode-line.
;; While using the server mode in GUI, should set the value explicitly.
;;(setq doom-modeline-icon t)
;; Whether display the icon for `major-mode'. It respects `doom-modeline-icon'.
;;(setq doom-modeline-major-mode-icon t)
;; Whether display the colorful icon for `major-mode'.
;; It respects `all-the-icons-color-icons'.
;;(setq doom-modeline-major-mode-color-icon t)
;; Whether display the icon for the buffer state. It respects `doom-modeline-icon'.
;;(setq doom-modeline-buffer-state-icon t)
;; Whether display the modification icon for the buffer.
;; It respects `doom-modeline-icon' and `doom-modeline-buffer-state-icon'.
;;(setq doom-modeline-buffer-modification-icon t)
;; Whether display the time icon. It respects variable `doom-modeline-icon'.
;;(setq doom-modeline-time-icon t)
;; Whether to use unicode as a fallback (instead of ASCII) when not using icons.
;;(setq doom-modeline-unicode-fallback nil)
;; Whether display the buffer name.
(setq doom-modeline-buffer-name t)
;; Whether highlight the modified buffer name.
(setq doom-modeline-highlight-modified-buffer-name t)
;; Whether display the minor modes in the mode-line.
(setq doom-modeline-minor-modes nil)
;; If non-nil, a word count will be added to the selection-info modeline segment.
(setq doom-modeline-enable-word-count t)
;; Major modes in which to display word count continuously.
;; Also applies to any derived modes. Respects `doom-modeline-enable-word-count'.
;; If it brings the sluggish issue, disable `doom-modeline-enable-word-count' or
;; remove the modes from `doom-modeline-continuous-word-count-modes'.
(setq doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode))
;; Whether display the buffer encoding.
(setq doom-modeline-buffer-encoding t)
;; Whether display the indentation information.
(setq doom-modeline-indent-info nil)
;; If non-nil, only display one number for checker information if applicable.
(setq doom-modeline-checker-simple-format t)
;; The maximum number displayed for notifications.
(setq doom-modeline-number-limit 50)
;; The maximum displayed length of the branch name of version control.
(setq doom-modeline-vcs-max-length 10)
;; Whether display the workspace name. Non-nil to display in the mode-line.
(setq doom-modeline-workspace-name t)
;; Whether display the perspective name. Non-nil to display in the mode-line.
(setq doom-modeline-persp-name t)
;; If non nil the default perspective name is displayed in the mode-line.
(setq doom-modeline-display-default-persp-name nil)
;; If non nil the perspective name is displayed alongside a folder icon.
;;(setq doom-modeline-persp-icon t)
;; Whether display the `lsp' state. Non-nil to display in the mode-line.
;;(setq doom-modeline-lsp t)
;; Whether display the GitHub notifications. It requires `ghub' package.
;;(setq doom-modeline-github nil)
;; The interval of checking GitHub.
;;(setq doom-modeline-github-interval (* 30 60))
;; Whether display the modal state.
;; Including `evil', `overwrite', `god', `ryo' and `xah-fly-keys', etc.
;;(setq doom-modeline-modal t)
;; Whether display the modal state icon.
;; Including `evil', `overwrite', `god', `ryo' and `xah-fly-keys', etc.
;;(setq doom-modeline-modal-icon t)
;; Whether display the mu4e notifications. It requires `mu4e-alert' package.
;;(setq doom-modeline-mu4e nil)
;; also enable the start of mu4e-alert
;;(mu4e-alert-enable-mode-line-display)
;; Whether display the gnus notifications.
;;(setq doom-modeline-gnus t)
;; Whether gnus should automatically be updated and how often (set to 0 or smaller than 0 to disable)
;;(setq doom-modeline-gnus-timer 2)
;; Wheter groups should be excludede when gnus automatically being updated.
;;(setq doom-modeline-gnus-excluded-groups '("dummy.group"))
;; Whether display the IRC notifications. It requires `circe' or `erc' package.
;;(setq doom-modeline-irc t)
;; Function to stylize the irc buffer names.
;;(setq doom-modeline-irc-stylize 'identity)
;; Whether display the battery status. It respects `display-battery-mode'.
;;(setq doom-modeline-battery t)
;; Whether display the time. It respects `display-time-mode'.
(setq doom-modeline-time t)
;; Whether display the misc segment on all mode lines.
;; If nil, display only if the mode line is active.
;;(setq doom-modeline-display-misc-in-all-mode-lines t)
;; Whether display the environment version.
(setq doom-modeline-env-version t)
;; Or for individual languages
(setq doom-modeline-env-enable-python t)
;; Change the executables to use for the language version string
;;(setq doom-modeline-env-python-executable "python") ; or `python-shell-interpreter'
;; What to display as the version while a new one is being loaded
(setq doom-modeline-env-load-string "...")
;; By default, almost all segments are displayed only in the active window. To
;; display such segments in all windows, specify e.g.
;;(setq doom-modeline-always-visible-segments '(mu4e irc))
;; Hooks that run before/after the modeline version string is updated
(setq doom-modeline-before-update-env-hook nil)
(setq doom-modeline-after-update-env-hook nil)
;;; For the built-in themes which cannot use `require':
;; Add all your customizations prior to loading the themes
(setq modus-themes-mode-line '(accented borderless)
      modus-themes-bold-constructs t
      modus-themes-italic-constructs t
      modus-themes-fringes 'subtle
      modus-themes-tabs-accented t
      modus-themes-paren-match '(bold intense)
      modus-themes-prompts '(bold intense)
      modus-themes-org-blocks 'tinted-background
      modus-themes-scale-headings t
      modus-themes-region '(bg-only)
      modus-themes-headings
      '((1 . (rainbow overline background 1.4))
        (2 . (rainbow background 1.3))
        (3 . (rainbow bold 1.2))
        (t . (semilight 1.1))))
;; Load the dark theme by default
(load-theme 'modus-vivendi t)
(define-key global-map (kbd "<f5>") #'modus-themes-toggle)
;; ====================================
;;; For packaged versions which must use `require':
;;(require 'modus-themes)
;; Load the theme files before enabling a theme
;;(modus-themes-load-themes)
;; ====================================
;; Load the theme of your choice:
;;(modus-themes-load-vivendi) ;; OR (modus-themes-load-operandi)
;;(define-key global-map (kbd "<f5>") #'modus-themes-toggle)
(global-linum-mode t)               ;; Enable line numbers globally
;; ====================================
;; Development Setup
;; ====================================
;;====================================
(require 'erc-hl-nicks)
(require 'erc-image)
(require 's)
(require 'erc-join)
(require 'erc-services)
(add-to-list 'erc-modules 'hl-nicks)
(add-to-list 'erc-modules 'image)
(add-to-list 'erc-modules 'notifications)
;;(add-to-list 'load-path "C:/Users/THAY PHACH/AppData/Roaming/.emacs.d/ZNC.el")
(setq erc-nick "duk"     ; Our IRC nick
      erc-user-full-name "Khoi Nguyen Tinh Song"
      erc-hide-list '("JOIN" "PART" "QUIT" "NICK" "MODE")
      erc-track-exclude-types '("JOIN" "NICK" "QUIT" "MODE" "AWAY")
      erc-auto-query 'buffer
      erc-server-auto-reconnect t
      ;erc-fill-column 100
      erc-server-reconnect-timeout 5
      erc-server-reconnect-attempts 3
      erc-rename-buffers t
      erc-fill-function 'erc-fill-static
      erc-fill-static-center 20
      erc-track-exclude-server-buffer t
      erc-track-visibility nil
 ) ; Our /whois name
(add-hook 'erc-mode-hook 'emojify-mode-hook) ;; emojify-list-emojis to see list emoji
;; Define a function to connect to a server
(defun start-irc ()
  "Connect to IRC."
  (interactive)
  (erc :server "irc.libera.chat"
       :port 6667
       :nick private-irc-freenode-username
       :password private-irc-freenode-password))
;;(defun start-irc-tls ()
;;      "Connect to IRC using TLS."
;;     (interactive)
;;      (erc-tls :server "localhost"
;;	       :port 6667
;;	       :nick private-irc-freenode-username
;;	       :password private-irc-freenode-password
;;	       :client-certificate '("/Users/me/libera.key" "/Users/me/libera.crt")))

;;(require 'znc)
;;(setq znc-servers
;;    '(("irc.libera.chat" PORT# t
;;      ((NETWORK-SLUG "USERNAME" "PASSWORD")
;;       (NETWORK-SLUG "USERNAME" "PASSWORD"))
;;)))
;;=========================================================================

(defun connect-bitlbee()                   ;;Run bitlbee daemon before run command bitlbee -n -D -v -d ~/.bitlbee -c ~/.bitlbee/bitlbee.conf or bitlbee -D
  "Connect to IM networks using bitlbee."
  (interactive)
  (erc :server "localhost" :port 6667 :nick "duk"))
(defun bitlbee-identify ()
  "If we're on the bitlbee server, send the identify command to the 
 &bitlbee channel."
  (when (and (string= "localhost" erc-session-server)
             (string= "&bitlbee" (buffer-name)))
    (erc-message "PRIVMSG" (format "%s identify %s" 
                                   (erc-default-target) 
                                   bitlbee-password))))
(add-hook 'erc-join-hook 'bitlbee-identify)
(add-hook 'erc-insert-modify-hook 'maybe-wash-im-with-w3m)
(autoload 'w3m-region "w3m" "Render region using w3m")
(defun maybe-wash-im-with-w3m ()
    "Wash the current im with emacs-w3m."
    (save-restriction
      (with-current-buffer (current-buffer)
        (let ((case-fold-search t))
	  (goto-char (point-min))
	  (when (re-search-forward "<HTML>.*</HTML>" nil t)
	    (print (match-string 0))
	    (narrow-to-region (match-beginning 0) (match-end 0))
	    (let ((w3m-safe-url-regexp mm-w3m-safe-url-regexp)
		  w3m-force-redisplay)
	      (w3m-region (point-min) (point-max))
	      (goto-char (point-max))
	      (delete-char -2))
	    (when (and mm-inline-text-html-with-w3m-keymap
		       (boundp 'w3m-minor-mode-map)
		       w3m-minor-mode-map)
	      (add-text-properties
	       (point-min) (point-max)
	       (list 'keymap w3m-minor-mode-map
		     ;; Put the mark meaning this part was rendered by emacs-w3m.
		     'mm-inline-text-html-with-w3m t))))))))


(defun erc-cmd-ICQWHOIS (uin)
      "Queries icq-user with UIN `uin', and returns the result."
      (let* ((result (myerc-query-icq-user uin))
             (fname (cdr (assoc 'fname result)))
             (lname (cdr (assoc 'lname result)))
             (nick (cdr (assoc 'nick result))))
        (erc-display-message nil 'notice (current-buffer) (format "%s (%s %s)" nick fname lname))))
(defun myerc-query-icq-user (&optional uin)
	  "Queries UIN `uin' on people.icq.com, returns result table."
	  (with-timeout (3 (ignore))
	    (and uin
	         (with-current-buffer 
	             (url-retrieve-synchronously (format "http://people.icq.com/whitepages/about_me/1,,,00.html?to=%%25U&Uin=%s" uin))
	           (let* (;; some cleansing
	                  (result (buffer-string))
	                  (result (replace-regexp-in-string (format "&nbsp\\|\n\\|%c" 13) " " result))
	                  (result (replace-regexp-in-string "<.+?>\\|%c" "" result))
	                  (result (replace-regexp-in-string "\\s-+" " " result))
	                  (result (replace-regexp-in-string ".+;Personal Details" "" result))
	                  ;; now the parsing
	                  (fname (and (string-match "first ?name: ;\\(\\S-+\\)" result) (match-string 1 result)))
	                  (lname (and (string-match "last ?name: ;\\(\\S-+\\)" result) (match-string 1 result)))
	                  (nick (and (string-match "nickname: ;\\(\\S-+\\)" result) (match-string 1 result))))
	             `((fname . ,fname)
	               (lname . ,lname)
	               (nick . ,nick)))))))

(require 'notifications)
  ;; Association list, pairing buffer names with notification IDs.
(setq erc-notification-id-alist '())
  ;; Function for use by erc-new-message-notify.
(defun erc-notification-closed (id reason)
    "Callback function, for removing notification entry if user closed notification manually."
    (dolist (entry erc-notification-id-alist)
      (if (equal id (cdr entry))
          (setq erc-notification-id-alist
                (delq
                 (assoc (car entry) erc-notification-id-alist)
                 erc-notification-id-alist)))))
  
  ;; Create notification when ERC message received.
(defun erc-new-message-notify (message)
    "Notify user of new ERC message."
    (let ((this-buffer (buffer-name (current-buffer))))
      (if (not (string-match "^[#&]" this-buffer))
          (if (not (assoc this-buffer erc-notification-id-alist))
              (setq erc-notification-id-alist
                    (cons
                     `(,this-buffer ,@(notifications-notify :timeout 0 :on-close 'erc-notification-closed :title "New message in chat" :body (buffer-name (current-buffer))))
                     erc-notification-id-alist))))))
  
(add-hook 'erc-insert-pre-hook 'erc-new-message-notify)
  ;; On ERC buffer modification by user, clear notification message.
(defun erc-close-notification ()
    "Close ERC notification bubbles related to the current chat."
    (let ((this-buffer (buffer-name (current-buffer))))
      (if (assoc this-buffer erc-notification-id-alist)
        (progn
          (notifications-close-notification (cdr (assoc this-buffer erc-notification-id-alist)))
          (setq erc-notification-id-alist
                (delq
                 (assoc this-buffer erc-notification-id-alist)
                 erc-notification-id-alist))))))
  
(add-hook 'erc-send-post-hook 'erc-close-notification)
;========================================================================================
(setq ercn-notify-rules
          '((current-nick . all)
            (keyword . all)
            (query-buffer . all)))
(when (fboundp 'alert)
      (defun do-notify (nickname message)
        (interactive)
        ;; Alert not needed, Sauron handles this now
        ;; (alert (concat nickname ": "
        ;;                (s-trim (s-collapse-whitespace message)))
        ;;        :title (buffer-name))
        (message "[%s] %s: %s"
                 (buffer-name) nickname (s-trim (s-collapse-whitespace message))))
(add-hook 'ercn-notify-hook 'do-notify))
;; ====================================
;; Config org-mode
(require 'org)
(require 'ox-latex)
(require 'org-download)
(require 'org-protocol)
(require 'org-capture)
(require 'org-cliplink)
(require 'org-id)
(require 'ox)
;; Drag-and-drop to `dired`
(add-hook 'org-mode-hook 'org-download-enable)
(setq-default org-download-image-dir "~/.emacs.d/img")
(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
(setq org-directory "~/.emacs.d/.org/archive")
(setq org-agenda-files '("~/.emacs.d/.org/gtd")) ;; <=> (list org-agenda-directory)
(setq org-default-notes-file "~/.emacs.d/.org/gtd/notes.org")
(setq org-agenda-directory "~/.emacs.d/.org/gtd/")
(setq org-capture-templates
      `(("I" "Inbox" entry (file ,(concat org-agenda-directory "inbox.org"))
         "* TODO %?\n%U\n" :clock-in t :clock-resume t)
	("n" "Note" entry  (file "notes.org")
	 "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
	("m" "Meeting" entry (file ,(concat org-agenda-directory "meeting.org"))
         "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t)
        ("e" "Inbox [mu4e]" entry (file+headline ,(concat org-agenda-directory "emails.org") "Emails")
         "* TODO [#A] Reply: %a :@home:@school:" :immediate-finish t)
        ("l" "link" entry (file ,(concat org-agenda-directory "inbox.org"))
         "* TODO %(org-cliplink-capture)" :immediate-finish t)
        ("c" "org-protocol-capture" entry (file ,(concat org-agenda-directory "inbox.org"))
         "* TODO [[%:link][%:description]]\n\n %i" :immediate-finish t)
        ("b" "Blog post" entry (file ,(concat org-agenda-directory "blogs.org"))
	 "* %^{Title} %^g\n:PROPERTIES:\n:EXPORT_DATE: %^{EXPORT_DATE}U%^{EXPORT_FILE_NAME}p\n:END:" :prepend t :empty-lines 1
	 :immediate-finish t :jump-to-captured t)))
(setq org-todo-keywords                              ;;C-c C-t key 
      '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d)")
	(sequence "MEETING" "|" "DONE(d)")
        (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)")))
(setq org-todo-keyword-faces
      '(
        ("TODO" :foreground "#cd5c5c" :weight bold)
        ("TODO" :foreground "red" :weight bold)
        ("NEXT" :foreground "#00ffff" :weight bold)
        ("NEXT" :foreground "blue" :weight bold)
        ("WAITING" :foreground "orange" :weight bold)
        ("HOLD" :foreground "magenta" :weight bold)
        ("DONE" :foreground "forest green" :weight bold)
        ("MEETING" :foreground "forest green" :weight bold)
        ("CANCELLED" :foreground "forest green" :weight bold)))
(setq org-todo-state-tags-triggers
      '(("CANCELLED" ("CANCELLED" . t))
        ("WAITING" ("WAITING" . t))
        ("HOLD" ("WAITING") ("HOLD" . t))
        (done ("WAITING") ("HOLD"))
        ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
        ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
        ("DONE" ("WAITING") ("CANCELLED") ("HOLD"))))
(setq org-src-fontify-natively t)
(setq org-edit-src-content-indentation 0)
(setq org-src-tab-acts-natively t)
(setq org-startup-indented t)
(setq org-download-method 'attach)
(setq org-fontify-whole-heading-line t)
(setq org-adapt-indentation nil)
(setq org-imenu-depth 3)
(setq org-footnote-define-inline t)
(setq org-special-ctrl-k t)
(setq org-special-ctrl-a/e t)
(setq org-yank-adjusted-subtrees nil)
(setq org-catch-invisible-edits 'smart)
(setq org-src-strip-leading-and-trailing-blank-lines t)
(setq org-src-window-setup 'current-window)
(setq org-cycle-separator-lines 0)
(setq org-image-actual-width nil)
(setq org-checkbox-hierarchical-statistics t)
(setq org-return-follows-link t)
(setq org-remove-highlights-with-change nil)
(setq org-read-date-prefer-future nil)
(setq org-show-hierarchy-above t)
(setq org-show-siblings nil)
(setq org-show-following-heading t)
(setq org-insert-heading-respect-content nil)
(setq org-enforce-todo-dependencies t)
(setq org-hide-emphasis-markers nil ;;bug in org-mode, set to t => type more * become error
      org-fontify-done-headline t
      org-hide-leading-stars t
      org-pretty-entities t
      )
(setq org-list-demote-modify-bullet
      (quote (
	      ("+" . "-")
	      ("*" . "-")
	      ("1." . "-")
	      ("1)" . "-")
	      ("A)" . "-")
	      ("B)" . "-")
	      ("a)" . "-")
	      ("b)" . "-")
	      ("A." . "-")
	      ("B." . "-")
	      ("a." . "-")
	      ("b." . "-"))))
(setq org-agenda-hide-tags-regexp "." )
(setq org-use-fast-todo-selection t)
(setq org-log-done 'time
      org-log-into-drawer t
      org-log-state-notes-insert-after-drawers nil)
(define-key global-map (kbd "C-c L") 'org-capture-link)

(require 'org-screenshot) ;; comes from org-contrib
(customize-set-variable 'org-screenshot-image-directory "~/.emacs.d/img/")
(defun org-capture-link()
    "Captures a link, and stores it in inbox."
    (interactive)
    (org-capture nil "l"))
(defun joindirs (root &rest dirs)
  "Joins a series of directories together, like Python's os.path.join,
  (dotemacs-joindirs \"/tmp\" \"a\" \"b\" \"c\") => /tmp/a/b/c"
  ; via https://newbedev.com/what-is-the-correct-way-to-join-multiple-path-components-into-a-single-complete-path-in-emacs-lisp

  (if (not dirs)
      root
    (apply 'joindirs
           (expand-file-name (car dirs) root)
           (cdr dirs))))
(defun windows-screenshot ()
  "Take a screenshot into a time stamped unique-named file in a sub-directory of the org-buffer and insert a link to this file."
  ; via https://www.sastibe.de/2018/11/take-screenshots-straight-into-org-files-in-emacs-on-win10/
  (interactive)
  (setq filename
        (concat
         (make-temp-name
          (joindirs (file-name-directory buffer-file-name)
                       "screenshots"
                       (concat (file-name-nondirectory buffer-file-name)
                               "_"
                               (format-time-string "%Y%m%d_%H%M%S_")) )) ".png"))
  ;; (message "filename: " filename)
  (let ((dirname (file-name-directory filename)))
    (message (concat "dirname: " dirname))
    (unless (file-exists-p dirname)
      (make-directory dirname)))
  (shell-command "snippingtool /clip")
  (shell-command (concat "powershell -command \"Add-Type -AssemblyName System.Windows.Forms;if ($([System.Windows.Forms.Clipboard]::ContainsImage())) {$image = [System.Windows.Forms.Clipboard]::GetImage();[System.Drawing.Bitmap]$image.Save('" filename "',[System.Drawing.Imaging.ImageFormat]::Png); Write-Output 'clipboard content saved as file'} else {Write-Output 'clipboard does not contain image data'}\""))
  (insert (concat "[[file:" filename "]]"))
  (org-display-inline-images))
(setq org-tag-alist (quote (("@errand" . ?e)
                            ("@office" . ?o)
                            ("@home" . ?h)
                            ("@work" . ?w)
			    ("book" . ?b)
                            ("support" . ?s)
                            ("docs" . ?d)
			    ("tech" . ?t)
                            (:newline)
                            ("WAITING" . ?W)
                            ("HOLD" . ?H)
                            ("CANCELLED" . ?c)
			    ("NOTE" . ?n))))
(setq org-fast-tag-selection-single-key nil)

;; https://github.com/syl20bnr/spacemacs/issues/3094
(setq org-refile-use-outline-path t
      org-outline-path-complete-in-steps nil)
(setq org-refile-allow-creating-parent-nodes (quote confirm))
(setq org-refile-targets (quote ((nil :maxlevel . 9)
                                 (org-agenda-files :maxlevel . 9))))
(defvar org-agenda-bulk-process-key ?f
  "Default key for bulk processing inbox items.")

(defun org-process-inbox ()
  "Called in org-agenda-mode, processes all inbox items."
  (interactive)
  (org-agenda-bulk-mark-regexp "inbox:")
  (bulk-process-entries))

(setq org-global-properties
      (quote (("Effort_ALL" .
               "0:15 0:30 1:00 2:00 3:00 6:00 12:00 18:00 0:00"))))
(defvar org-current-effort "1:00"
  "Current effort for agenda items.")
;; change time by S-<up arrow> or S-<down arrow>
(setq org-clock-out-remove-zero-time-clocks t)
(defun my-org-agenda-set-effort (effort)
  "Set the effort property for the current headline."
  (interactive
   (list (read-string (format "Effort [%s]: " org-current-effort) nil nil org-current-effort)))
  (setq org-current-effort effort)
  (org-agenda-check-no-diary)
  (let* ((hdmarker (or (org-get-at-bol 'org-hd-marker)
                       (org-agenda-error)))
         (buffer (marker-buffer hdmarker))
         (pos (marker-position hdmarker))
         (inhibit-read-only t)
         newhead)
    (org-with-remote-undo buffer
      (with-current-buffer buffer
        (widen)
        (goto-char pos)
        (org-show-context 'agenda)
        (funcall-interactively 'org-set-effort nil org-current-effort)
        (end-of-line 1)
        (setq newhead (org-get-heading)))
      (org-agenda-change-all-lines newhead hdmarker))))
(defun org-agenda-process-inbox-item ()
  "Process a single item in the org-agenda."
  (org-with-wide-buffer
   (org-agenda-set-tags)
   (org-agenda-priority)
   (call-interactively 'my-org-agenda-set-effort)
   (org-agenda-refile nil nil t)))
(defun bulk-process-entries ()
  (if (not (null org-agenda-bulk-marked-entries))
      (let ((entries (reverse org-agenda-bulk-marked-entries))
            (processed 0)
            (skipped 0))
        (dolist (e entries)
          (let ((pos (text-property-any (point-min) (point-max) 'org-hd-marker e)))
            (if (not pos)
                (progn (message "Skipping removed entry at %s" e)
                       (cl-incf skipped))
              (goto-char pos)
              (let (org-loop-over-headlines-in-active-region) (funcall 'org-agenda-process-inbox-item))
              ;; `post-command-hook' is not run yet.  We make sure any
              ;; pending log note is processed.
              (when (or (memq 'org-add-log-note (default-value 'post-command-hook))
                        (memq 'org-add-log-note post-command-hook))
                (org-add-log-note))
              (cl-incf processed))))
        (org-agenda-redo)
        (unless org-agenda-persistent-marks (org-agenda-bulk-unmark-all))
        (message "Acted on %d entries%s%s"
                 processed
                 (if (= skipped 0)
                     ""
                   (format ", skipped %d (disappeared before their turn)"
                           skipped))
                 (if (not org-agenda-persistent-marks) "" " (kept marked)")))))

(defun org-inbox-capture ()
  (interactive)
  "Capture a task in agenda mode."
  (org-capture nil "i"))

(setq org-agenda-bulk-custom-functions `((,org-agenda-bulk-process-key org-agenda-process-inbox-item)))

(define-key org-agenda-mode-map "i" 'org-agenda-clock-in)
(define-key org-agenda-mode-map "r" 'org-process-inbox)
(define-key org-agenda-mode-map "R" 'org-agenda-refile)
(define-key org-agenda-mode-map "c" 'org-inbox-capture)

(defun set-todo-state-next ()
  "Visit each parent task and change NEXT states to TODO"
  (org-todo "NEXT"))

(add-hook 'org-clock-in-hook 'set-todo-state-next 'append)

(setq org-agenda-block-separator nil)
(setq org-agenda-start-with-log-mode t)

(setq org-agenda-todo-view
      `(" " "Agenda"
        ((agenda ""
                 ((org-agenda-span 'day)
                  (org-deadline-warning-days 365)))
         (todo "TODO"
               ((org-agenda-overriding-header "To Refile")
                (org-agenda-files '(,(concat org-agenda-directory "inbox.org")))))
         (todo "TODO"
               ((org-agenda-overriding-header "Emails")
                (org-agenda-files '(,(concat org-agenda-directory "emails.org")))))
         (todo "NEXT"
               ((org-agenda-overriding-header "In Progress")
                (org-agenda-files '(,(concat org-agenda-directory "someday.org")
                                    ,(concat org-agenda-directory "projects.org")
                                    ,(concat org-agenda-directory "next.org")))
                ))
         (todo "TODO"
               ((org-agenda-overriding-header "Projects")
                (org-agenda-files '(,(concat org-agenda-directory "projects.org")))
                ))
         (todo "TODO"
               ((org-agenda-overriding-header "One-off Tasks")
                (org-agenda-files '(,(concat org-agenda-directory "next.org")))
                (org-agenda-skip-function '(org-agenda-skip-entry-if 'deadline 'scheduled))))
         nil)))

(add-to-list 'org-agenda-custom-commands `,org-agenda-todo-view)

(setq org-columns-default-format "%40ITEM(Task) %Effort(EE){:} %CLOCKSUM(Time Spent) %SCHEDULED(Scheduled) %DEADLINE(Deadline)")
(setq appt-message-warning-time 15
      appt-display-interval 5)

(eval-after-load "org"
  (run-at-time "00:59" 3600 'org-save-all-org-buffers))
(setq org-id-link-to-org-use-id 'create-if-interactive-and-no-custom-id)

(defun org-custom-id-get (&optional pom create prefix)
    "Get the CUSTOM_ID property of the entry at point-or-marker POM.
   If POM is nil, refer to the entry at point. If the entry does
   not have an CUSTOM_ID, the function returns nil. However, when
   CREATE is non nil, create a CUSTOM_ID if none is present
   already. PREFIX will be passed through to `org-id-new'. In any
   case, the CUSTOM_ID of the entry is returned."
    (interactive)
    (org-with-point-at pom
      (let ((id (org-entry-get nil "CUSTOM_ID")))
        (cond
         ((and id (stringp id) (string-match "\\S-" id))
          id)
         (create
          (setq id (org-id-new (concat prefix "h")))
          (org-entry-put pom "CUSTOM_ID" id)
          (org-id-add-location id (buffer-file-name (buffer-base-buffer)))
          id)))))

(defun org-add-ids-to-headlines-in-file ()
    "Add CUSTOM_ID properties to all headlines in the current
   file which do not already have one. Only adds ids if the
   `auto-id' option is set to `t' in the file somewhere. ie,
   #+OPTIONS: auto-id:t"
    (interactive)
    (save-excursion
      (widen)
      (goto-char (point-min))
      (when (re-search-forward "^#\\+OPTIONS:.*auto-id:t" (point-max) t)
        (org-map-entries (lambda () (org-custom-id-get (point) 'create))))))

  ;; automatically add ids to saved org-mode headlines
(add-hook 'org-mode-hook
            (lambda ()
              (add-hook 'before-save-hook
                        (lambda ()
                          (when (and (eq major-mode 'org-mode)
                                     (eq buffer-read-only nil))
                            (org-add-ids-to-headlines-in-file))))))

(setq org-agenda-include-diary t)
(setq org-agenda-insert-diary-extract-time t)
(setq org-agenda-diary-file "~/.emacs.d/.org/diary")
(setq calendar-holidays
      (append holiday-general-holidays
              holiday-christian-holidays))
;;using EWW for wikipedia
(require 'eww)
(setq eww-search-prefix "https://startpage.com/search/?q=")
(eval-and-compile
  (defun eww-browse-wikipedia-en ()
    (interactive)
    (let ((search (read-from-minibuffer "Wikipedia (EN) search: ")))
      (eww-browse-url
       (concat "https://en.wikipedia.org/w/index.php?search=" search)))))

(eval-and-compile
  (defun eww-browser-english-dict ()
    (interactive)
    (let ((search (read-from-minibuffer "Dictionary (EN) search: ")))
      (eww-browse-url
       (concat "https://www.merriam-webster.com/dictionary/" search)))))


;;Deft M-x deft manage all org-mode archive
(require 'deft)
(setq deft-directory "~/.emacs.d/.org/archive")
(setq deft-extensions '("org")) ;; allow more extension 
(setq deft-default-extension "org")
(setq deft-text-mode 'org-mode)
(setq deft-use-filename-as-title t)
(setq deft-use-filter-string-for-filename t)
(setq deft-auto-save-interval 0)
;;advise deft to save window config
(defun bjm-deft-save-windows (orig-fun &rest args)
  (setq bjm-pre-deft-window-config (current-window-configuration))
  (apply orig-fun args)
)

(advice-add 'deft :around #'bjm-deft-save-windows)
;;function to quit a deft edit cleanly back to pre deft window
(defun bjm-quit-deft ()
  "Save buffer, kill buffer, kill deft buffer, and restore window config to the way it was before deft was invoked"
  (interactive)
  (save-buffer)
  (kill-this-buffer)
  (switch-to-buffer "*Deft*")
  (kill-this-buffer)
  (when (window-configuration-p bjm-pre-deft-window-config)
    (set-window-configuration bjm-pre-deft-window-config)
    )
)
(global-set-key (kbd "C-c q") 'bjm-quit-deft) ;;Use this if you use deft before
;;======================================================================
(add-to-list 'load-path "C:/cygwin64/home/THAY PHACH/muttrc-mode-el")
 (autoload 'muttrc-mode "muttrc-mode"
        "Major mode to edit muttrc files" t)
(add-to-list 'auto-mode-alist '("\\Muttrc\\'" . muttrc-mode))
(add-to-list 'auto-mode-alist '("\\neomuttrc\\'" . muttrc-mode))


;;Set up mail box( mu4e and offlineimap)
;(add-to-list 'load-path "C:/msys64/usr/local/share/emacs/site-lisp/mu4e") ;;=====> wait mu4e support maildir file with !
;; I installed mu4e from the 0.9.18 tarball

;(require 'mu4e)
;(setq mu4e-mu-binary "C:/msys64/usr/bin/mu.exe")
;(setq mail-user-agent 'mu4e-user-agent)
;;;(setq debug-on-error t) ;;replace for --debug-init
;(setq mu4e-debug t)
;(setq mu4e-compose-format-flowed t)
;; every new email composition gets its own frame! (window)
;(setq mu4e-compose-in-new-frame t)
;; give me ISO(ish) format date-time stamps in the header list;
;(setq mu4e-headers-date-format "%Y-%m-%d %H:%M")
;; show full addresses in view message (instead of just names)
;; toggle per name with M-RET
;(setq mu4e-view-show-addresses t)
;(setq mu4e-view-scroll-to-next nil)
;(setq mu4e-headers-fields
;      '((:human-date . 16)
;;        (:flags . 4)
;        (:mailing-list . 10)
;        (:from-or-to . 22)
;        (:thread-subject)))
;; path to our Maildir directory
;(setq mu4e-maildir "C:/cygwin64/home/THAY PHACH/.mbsync")
;; the next are relative to `mu4e-maildir'
;; instead of strings, they can be functions too, see
;; their docstring or the chapter 'Dynamic folders'

;(setq mu4e-drafts-folder "/Drafts")
;(setq mu4e-sent-folder   "/SentMail")

;; the maildirs you use frequently; access them with 'j' ('jump')
;(setq   mu4e-maildir-shortcuts
;	'(("/INBOX" . ?i)
;	  ("/SentMail" . ?s)
;	  ("/Drafts" . ?d)))
;(add-hook 'mu4e-compose-mode-hook 
;	  ( lambda () 
;	    ( save-excursion 
;	      (message-add-header (concat   "Bcc: " user-mail-address "\n" )))))
;(setq mu4e-sent-messages-behavior 'sent)

;(setq message-citation-line-format "%f @ %Y-%m-%d %T %Z:\n"
;      message-citation-line-function 'message-insert-formatted-citation-line)
;; the headers to show in the headers list -- a pair of a field
;; and its width, with `nil' meaning 'unlimited'
;; (better only use that for the last field.
;; These are the defaults:
;(setq mu4e-get-mail-command (concat "bash --login -c 'mbsync -a'"))

;; not using smtp-async yet
;; some of these variables will get overridden by the contexts
;;============================================================
;;Send mail config
;;============================================================
;; This is needed to allow msmtp to do its magic:
(setq message-sendmail-f-is-evil 't)
;;need to tell msmtp which account we're using
(setq sendmail-program "C:/cygwin64/usr/local/bin/msmtp.exe")
(setq message-sendmail-extra-arguments '())
(setq mail-envelope-from 'header
      mail-specify-envelope-from t
      message-sendmail-envelope-from 'header)
(setq
 message-send-mail-function 'message-send-mail-with-sendmail
 mail-host-address "gmail.com"
 smtpmail-debug-info t
 )

;; don't keep message buffers around
(setq message-kill-buffer-on-exit t)
;; here come the contexts
;; I have about 5 of these, chopped down to 2 for demonstration purposes
;; each context can set any number of variables (see :vars)
;; for example below here I'm using two different SMTP servers depending on identity

;; start with the first (default) context; 
					;(setq mu4e-context-policy 'pick-first)

;; compose with the current context if no context matches;
					;(setq mu4e-compose-context-policy nil)
					;(setq mu4e-modeline-max-width 60)
;;(setq mu4e-user-mailing-lists '(("debian-user.lists.debian.org" . "DebUsr")
;;                                ("debian-security-announce.lists.debian.org" . "DebSecAnn"))) ==>alias for mail user receiver
;; these are the standard mu4e search bookmarks
;; I've only added the fourth one to pull up flagged emails in my inbox
;; I sometimes use this to shortlist emails I need to get around to ASAP
;;--------------

(require 'org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
(setq org-ellipsis "⤵")
(font-lock-add-keywords 'org-mode
 '(("^ *\\([-]\\) "
 (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
(font-lock-add-keywords 'org-mode
 '(("^ *\\([+]\\) "
    (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "◦"))))))

(setq-default prettify-symbols-alist '(("#+BEGIN_SRC" . "†")
 ("#+END_SRC" . "†")
 ("#+begin_src" . "†")
 ("#+end_src" . "†")
 (">=" . "≥")
 ("=>" . "⇨")
 ("lambda" . "λ")
 ("->" . "→")
 ("<-" . "←")
 ("[ ]" . "☐")
 ("[X]" . "☑")
 ("[-]" . "❍")
 ("!=" . "≠")
 ))

(setq prettify-symbols-unprettify-at-point 'right-edge)
(add-hook 'org-mode-hook 'prettify-symbols-mode)

(setq org-src-preserve-indentation t
      org-src-fontify-natively t
      org-export-latex-listings t
      org-latex-prefer-user-labels t
      org-confirm-babel-evaluate nil
      org-babel-python-command "python")
(add-hook 'org-mode-hook
 (lambda ()
 (variable-pitch-mode 1)
 visual-line-mode))

(org-babel-do-load-languages
    'org-babel-load-languages
    '((python . t)
      (latex . t)))

(defun org-fold-outer ()
  (interactive)
  (org-beginning-of-line)
  (if (string-match "^*+" (thing-at-point 'line t))
      (outline-up-heading 1))
  (outline-hide-subtree)
  )

(defun do-org-confirm-babel-evaluations (lang body)
  (not
  (or
     (string= lang "python")
     (string= lang "calc")
     (string= lang "latex"))))

(setq org-confirm-babel-evaluate 'do-org-confirm-babel-evaluations)
(setq org-latex-create-formula-image-program 'dvipng) ;;put your cursor in the equation content and hit C-c C-x C-l
; increase the size
(setq org-format-latex-options (plist-put org-format-latex-options :scale 2.0))
; highlight latex code in org-mode
(setq org-highlight-latex-and-related '(native))
;;Automate the Preview Generation: #+STARTUP: latexpreview <> #+STARTUP: nolatexpreview

(defconst org-timestamp-and-title
  "\\(\\([0-9]\\{4\\}\\)-\\([0-9]\\{2\\}\\)-\\([0-9]\\{2\\}\\) +\\([^]+0-9>
    -]+\\)?\\( +\\([0-9]\\{1,2\\}:[0-9]\\{2\\}\\)\\)?\\)] \\(.*\\)")

(defun split-datetime+title (str)
  (list :timestamp (match-string 1 str)
        :year (match-string 2 str)
        :month (match-string 3 str)
        ;; :day (match-string 4 str)
        ;; :weekday (match-string 5 str)
        :time (match-string 7 str)
        :title (match-string 8 str)))

(defun timestamp-and-title (str)
  """ on a bare string return current time + string """
  (let ((time) (current-time))
    (if (string-match org-timestamp-and-title str)
        (split-datetime+title str)
      ;; else date of export
      (list
      :timestamp (format-time-string "[%Y-%m-%d %a %H:%M]" time)
          :year  (format-time-string "%Y" time)
          :month (format-time-string "%m" time)
          :time  (format-time-string "%H:%M" time)
          :title str))))

(defun org-html-title-only (str)
  (if (string-match org-timestamp-and-title str)
      (split-datetime+title str)
    (str)))
;; ====================================
;; Config Org-mode for Latex
;; ====================================

(with-eval-after-load 'ox
  (require 'ox-pandoc))
(setq org-pandoc-menu-entry
      '(
	(?x "to docx and open." org-pandoc-export-to-docx-and-open)
	(?X "to docx." org-pandoc-export-to-docx)
	(?r "to revealjs and open." org-pandoc-export-to-revealjs-and-open)
	(?R "as revealjs." org-pandoc-export-as-revealjs)
	(?o "to odt and open." org-pandoc-export-to-odt-and-open)
	(?O "to odt." org-pandoc-export-to-odt)
	(?8 "to opendocument and open." org-pandoc-export-to-opendocument-and-open)
	(?8 "to opendocument." org-pandoc-export-to-opendocument)
	;;(?( "as opendocument." org-pandoc-export-as-opendocument)
	;;(?0 "to jats." org-pandoc-export-to-jats)
	;;(?0 "to jats and open." org-pandoc-export-to-jats-and-open)
	;;(?  "as jats." org-pandoc-export-as-jats)
	;;(?2 "to tei." org-pandoc-export-to-tei)
	;;(?2 "to tei and open." org-pandoc-export-to-tei-and-open)
	;;(?" "as tei." org-pandoc-export-as-tei)
	(?l "to latex-pdf and open." org-pandoc-export-to-latex-pdf-and-open)
	(?L "to latex-pdf." org-pandoc-export-to-latex-pdf)
	;;(?k "to markdown." org-pandoc-export-to-markdown)
	(?k "to markdown and open." org-pandoc-export-to-markdown-and-open)
	(?K "as markdown." org-pandoc-export-as-markdown)
	;;(?3 "to markdown_mmd." org-pandoc-export-to-markdown_mmd)
	(?m "to markdown_mmd and open." org-pandoc-export-to-markdown_mmd-and-open)
	(?M "as markdown_mmd. (reddit|Wiki.js)" org-pandoc-export-as-markdown_mmd)
	(?s "to markdown_strict & open" org-pandoc-export-to-markdown_strict-and-open)
	(?S "as markdown_strict." org-pandoc-export-as-markdown_strict)
	;;(?: "to rst." org-pandoc-export-to-rst)
	(?1 "to rst and open." org-pandoc-export-to-rst-and-open)
	(?2 "as rst." org-pandoc-export-as-rst)
	;;(?p "to plain." org-pandoc-export-to-plain)
	(?p "to plain and open." org-pandoc-export-to-plain-and-open)
	(?P "as plain." org-pandoc-export-as-plain)
	;;(?4 "to html5." org-pandoc-export-to-html5)
	(?h "to html5 and open." org-pandoc-export-to-html5-and-open)
	(?H "as html5." org-pandoc-export-as-html5)
	(?3 "to html5-pdf and open." org-pandoc-export-to-html5-pdf-and-open)
	(?4 "to html5-pdf." org-pandoc-export-to-html5-pdf)
	;;(?6 "to markdown_phpextra." org-pandoc-export-to-markdown_phpextra)
	;;(?6 "to markdown_phpextra and open." org-pandoc-export-to-markdown_phpextra-and-open)
	;;(?& "as markdown_phpextra." org-pandoc-export-as-markdown_phpextra)
	;;(?7 "to markdown_strict." org-pandoc-export-to-markdown_strict)
	;;(?9 "to opml." org-pandoc-export-to-opml)
	;;(?9 "to opml and open." org-pandoc-export-to-opml-and-open)
	;;(?\) "as opml." org-pandoc-export-as-opml)
	;;(?< "to slideous." org-pandoc-export-to-slideous)
	;;(?< "to slideous and open." org-pandoc-export-to-slideous-and-open)
	;;(?, "as slideous." org-pandoc-export-as-slideous)
	(?= "to ms-pdf and open." org-pandoc-export-to-ms-pdf-and-open)
	(?- "to ms-pdf." org-pandoc-export-to-ms-pdf)
	;;(?> "to textile." org-pandoc-export-to-textile)
	(?t "to textile and open." org-pandoc-export-to-textile-and-open)
	(?T "as textile." org-pandoc-export-as-textile)
	;;(?a "to asciidoc." org-pandoc-export-to-asciidoc)
	(?a "to asciidoc and open." org-pandoc-export-to-asciidoc-and-open)
	(?A "as asciidoc." org-pandoc-export-as-asciidoc)
	(?b "to beamer-pdf and open." org-pandoc-export-to-beamer-pdf-and-open)
	(?B "to beamer-pdf." org-pandoc-export-to-beamer-pdf)
	;;(?c "to context-pdf and open." org-pandoc-export-to-context-pdf-and-open)
	;;(?C "to context-pdf." org-pandoc-export-to-context-pdf)
	;;(?d "to docbook5." org-pandoc-export-to-docbook5)
	(?d "to docbook5 and open." org-pandoc-export-to-docbook5-and-open)
	(?D "as docbook5." org-pandoc-export-as-docbook5)
	(?e "to epub3 and open." org-pandoc-export-to-epub3-and-open)
	(?E "to epub3." org-pandoc-export-to-epub3)
	;;(?f "to fb2." org-pandoc-export-to-fb2)
	;;(?f "to fb2 and open." org-pandoc-export-to-fb2-and-open)
	;;(?F "as fb2." org-pandoc-export-as-fb2)
	;;(?g "to gfm." org-pandoc-export-to-gfm)
	;;(?g "to gfm and open." org-pandoc-export-to-gfm-and-open)
	;;(?G "as gfm." org-pandoc-export-as-gfm)
	;;(?h "to html4." org-pandoc-export-to-html4)
	(?h "to html4 and open." org-pandoc-export-to-html4-and-open)
	(?H "as html4." org-pandoc-export-as-html4)
	;;(?i "to icml." org-pandoc-export-to-icml)
	;;(?i "to icml and open." org-pandoc-export-to-icml-and-open)
	;;(?I "as icml." org-pandoc-export-as-icml)
	;;(?j "to json." org-pandoc-export-to-json)
	(?j "to json and open." org-pandoc-export-to-json-and-open)
	(?J "as json." org-pandoc-export-as-json)
	;;(?m "to man." org-pandoc-export-to-man)
	;;(?m "to man and open." org-pandoc-export-to-man-and-open)
	;;(?M "as man." org-pandoc-export-as-man)
	;;(?n "to native." org-pandoc-export-to-native)
	;;(?n "to native and open." org-pandoc-export-to-native-and-open)
	;;(?N "as native." org-pandoc-export-as-native)
	;;(?q "to commonmark." org-pandoc-export-to-commonmark)
	;;(?q "to commonmark and open." org-pandoc-export-to-commonmark-and-open)
	;;(?Q "as commonmark." org-pandoc-export-as-commonmark)
	;;(?r "to rtf." org-pandoc-export-to-rtf)
	(?f "to rtf and open." org-pandoc-export-to-rtf-and-open)
	(?F "as rtf." org-pandoc-export-as-rtf)
	;;(?s "to s5." org-pandoc-export-to-s5)
	;;(?s "to s5 and open." org-pandoc-export-to-s5-and-open)
	;;(?S "as s5." org-pandoc-export-as-s5)
	;;(?t "to texinfo." org-pandoc-export-to-texinfo)
	;;(?t "to texinfo and open." org-pandoc-export-to-texinfo-and-open)
	;;(?T "as texinfo." org-pandoc-export-as-texinfo)
	;;(?u "to dokuwiki." org-pandoc-export-to-dokuwiki)
	(?u "to dokuwiki and open." org-pandoc-export-to-dokuwiki-and-open)
	(?U "as dokuwiki." org-pandoc-export-as-dokuwiki)
	;;(?v "to revealjs." org-pandoc-export-to-revealjs)
	;;(?w "to mediawiki." org-pandoc-export-to-mediawiki)
	(?5 "to mediawiki and open." org-pandoc-export-to-mediawiki-and-open)
	(?6 "as mediawiki." org-pandoc-export-as-mediawiki)
	;;(?y "to slidy." org-pandoc-export-to-slidy)
	;;(?y "to slidy and open." org-pandoc-export-to-slidy-and-open)
	;;(?Y "as slidy." org-pandoc-export-as-slidy)
	;;(?z "to dzslides." org-pandoc-export-to-dzslides)
	;;(?z "to dzslides and open." org-pandoc-export-to-dzslides-and-open)
	;;(?Z "as dzslides." org-pandoc-export-as-dzslides)
	;;(?{ "to muse." org-pandoc-export-to-muse)
	;;(?{ "to muse and open." org-pandoc-export-to-muse-and-open)
	;;(?[ "as muse." org-pandoc-export-as-muse)
	;;(?} "to zimwiki." org-pandoc-export-to-zimwiki)
	;;(?} "to zimwiki and open." org-pandoc-export-to-zimwiki-and-open)
	;;(?] "as zimwiki." org-pandoc-export-as-zimwiki)
	;;(?~ "to haddock." org-pandoc-export-to-haddock)
	;;(?~ "to haddock and open." org-pandoc-export-to-haddock-and-open)
	;;(?^ "as haddock." org-pandoc-export-as-haddock)
	(?7 "to epub2 and open." org-pandoc-export-to-epub2-and-open)
	(?8 "to epub2." org-pandoc-export-to-epub2)
	(?9 "Slack (clipboard)" org-slack-export-to-clipboard-as-slack)
	(?0 "as Slack" org-slack-export-as-slack)
	)
      )

(setq org-reveal-root "file:///c:/Users/THAY PHACH/AppData/Roaming/.emacs.d/contrib/reveal.js-master/reveal.js-master/js/reveal.js")
(setq org-reveal-hlevel 2)
(setq org-reveal-postamble "<p> Created by Duk. </p>")
(setq org-reveal-center nil)
(setq org-reveal-progress t)
(setq org-reveal-history nil)
(setq org-reveal-control t)
(setq org-reveal-keyboard t)
(setq org-reveal-overview nil)
(setq org-reveal-transition "default")
(setq org-reveal-theme "night")
;;(setq org-reveal-extra-css "")
;;type “M-x load-library”, then type “ox-reveal”. ==> export this manual into Reveal.js presentation by typing “C-c C-e R R”.
;;more in https://github.com/yjwen/org-reveal
;;============================================
(eval-after-load 'ox '(require 'ox-koma-letter))
(eval-after-load 'ox-koma-letter
  '(progn
     (add-to-list 'org-latex-classes
                  '("my-letter"
                    "\\documentclass\{scrlttr2\}
     \\usepackage[english]{babel}
     \\setkomavar{frombank}{(1234)\\,567\\,890}
"))

     (setq org-koma-letter-default-class "my-letter")))
;;============================================
(setq org-latex-compiler "xelatex")
(setq org-latex-pdf-process
      (list (concat "latexmk -"
                    org-latex-compiler 
                    "-shell-escape -recorder -synctex=1 -bibtex-cond %b")))

(setq  org-latex-listings 'minted)
(setq org-latex-minted-options
      '(("frame" "leftline") ("linenos" "true") ("breaklines" "true") ("bgcolor" "bg")))

(setq org-latex-default-packages-alist
      '(("" "graphicx" t)
        ("" "grffile" t)
        ("normalem" "ulem" t)
        ("" "amsmath" t)
        ("" "textcomp" t)
        ("" "amssymb" t)
	("AUTO" "babel" t)))
(setq org-latex-classes
      '(("article"
	 "\\RequirePackage{fix-cm}
\\PassOptionsToPackage{svgnames}{xcolor}
\\documentclass[11pt]{article}
\\usepackage{fontspec}
\\setmainfont{Linux Libertine O}
\\setsansfont[Scale=MatchLowercase]{Raleway}
\\setmonofont[Scale=MatchLowercase]{Luxi Mono}
\\usepackage{sectsty}
\\allsectionsfont{\\sffamily}
\\usepackage{enumitem}
\\usepackage{minted}
\\setlist[description]{style=unboxed,font=\\sffamily\\bfseries}
\\usepackage{xcolor}
\\definecolor{bg}{HTML}{959595}
\\newcommand\\basicdefault[1]{\\scriptsize\\color{Black}\\ttfamily#1}
\\usepackage[a4paper,margin=1in,left=1.5in]{geometry}
\\makeatletter
\\renewcommand{\\maketitle}{%
\\begingroup\\parindent0pt
\\sffamily
\\Huge{\\bfseries\\@title}\\par\\bigskip
\\LARGE{\\bfseries\\@author}\\par\\medskip
\\normalsize\\@date\\par\\bigskip
\\endgroup}
\\makeatother
\\usepackage{longtable}
\\usepackage{wrapfig}
\\usepackage{rotating}
\\usepackage{capt-of}
\\usepackage{hyperref}
\\hypersetup{linkcolor=Blue,urlcolor=DarkBlue,
  citecolor=DarkRed,colorlinks=true}
\\AtBeginDocument{\\renewcommand{\\UrlFont}{\\ttfamily}}
"
	 ("\\section{%s}" . "\\section*{%s}")
	 ("\\subsection{%s}" . "\\subsection*{%s}")
	 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
	 ("\\paragraph{%s}" . "\\paragraph*{%s}")
	 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))

	("report"
	 "\\RequirePackage{fix-cm}
\\PassOptionsToPackage{svgnames}{xcolor}
\\documentclass[11pt]{report}
\\usepackage{fontspec}
\\setmainfont{ETBembo RomanOSF}
\\setsansfont[Scale=MatchLowercase]{Raleway}
\\setmonofont[Scale=MatchLowercase]{Operator Mono SSm}
\\usepackage{sectsty}
\\allsectionsfont{\\sffamily}
\\usepackage{enumitem}
\\usepackage{minted}
\\setlist[description]{style=unboxed,font=\\sffamily\\bfseries}
\\usepackage{xcolor}
\\definecolor{bg}{HTML}{959595}
\\newcommand\\basicdefault[1]{\\scriptsize\\color{Black}\\ttfamily#1}
\\usepackage[a4paper,margin=1in,left=1.5in]{geometry}
\\usepackage{parskip}
\\makeatletter
\\renewcommand{\\maketitle}{%
\\begingroup\\parindent0pt
\\sffamily
\\Huge{\\bfseries\\@title}\\par\\bigskip
\\LARGE{\\bfseries\\@author}\\par\\medskip
\\normalsize\\@date\\par\\bigskip
\\endgroup\\@afterindentfalse\\@afterheading}
\\makeatother
\\hypersetup{linkcolor=Blue,urlcolor=DarkBlue,
  citecolor=DarkRed,colorlinks=true}
\\AtBeginDocument{\\renewcommand{\\UrlFont}{\\ttfamily}}
"   
	 ("\\part{%s}" . "\\part*{%s}")
	 ("\\chapter{%s}" . "\\chapter*{%s}")
	 ("\\section{%s}" . "\\section*{%s}")
	 ("\\subsection{%s}" . "\\subsection*{%s}")
	 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
	 ("\\paragraph{%s}" . "\\paragraph*{%s}")
	 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")
	 )

	("book" "\\documentclass[11pt]{book}"
	 ("\\part{%s}" . "\\part*{%s}")
	 ("\\chapter{%s}" . "\\chapter*{%s}")
	 ("\\section{%s}" . "\\section*{%s}")
	 ("\\subsection{%s}" . "\\subsection*{%s}")
	 ("\\subsubsection{%s}" . "\\subsubsection*{%s}"))

	("modern-presentation"
	 "\\documentclass[11pt]{beamer}
\\usetheme{metropolis}
\\usepackage{appendixnumberbeamer}
\\usepackage{booktabs}
\\usepackage[scale=2]{ccicons}
\\usepackage{pgfplots}
\\usepackage{minted}
\\usepgfplotslibrary{dateplot}
\\usepackage{xspace}
\\newcommand{\\themename}{\\textbf{\\textsc{metropolis}}\\xspace}
\\date{\\today}
\\author{Khoi Nguyen}
\\institute{UTH}
%%\\titlegraphic{\\hfill\\includegraphics[height=1.5cm]{logo.pdf}}"
	 ("\\section{%s}" . "\\section*{%s}")
	 ("\\begin{frame}[fragile]\\frametitle{%s}"
	  "\\end{frame}"
	  "\\begin{frame}[fragile]\\frametitle{%s}"
	  "\\end{frame}"))

	("basic-presentation"
	 "\\documentclass[aspectratio=169,xcolor=dvipsnames]{beamer}
\\usetheme{SimpleDarkBlue}
\\usepackage{hyperref}
\\usepackage{graphicx}
\\usepackage{booktabs} 
\\author[Song Khoi] {Khoi Nguyen Tinh Song}
\\institute[UTH]
{
    Department of Computer Science \\
    University of Transport Ho Chi Minh City
    \\vskip 3pt
}
\\date{\\today}
%%\\titlegraphic{\\hfill\\includegraphics[height=1.5cm]{logo.pdf}}
\\makeatletter
\\renewcommand{\\itemize}[1][]{%
	\\beamer@ifempty{#1}{}{\\def\\beamer@defaultospec{#1}}%
	\\ifnum \\@itemdepth >2\\relax\\@toodeep\\else
	\\advance\\@itemdepth\\@ne
	\\beamer@computepref\\@itemdepth% sets \\beameritemnestingprefix
	\\usebeamerfont{itemize/enumerate \\beameritemnestingprefix body}%
	\\usebeamercolor[fg]{itemize/enumerate \\beameritemnestingprefix body}%
	\\usebeamertemplate{itemize/enumerate \\beameritemnestingprefix body begin}%
	\\list
	{\\usebeamertemplate{itemize \\beameritemnestingprefix item}}
	{\\def\\makelabel##1{%
			{%
				\\hss\\llap{{%
						\\usebeamerfont*{itemize \\beameritemnestingprefix item}%
						\\usebeamercolor[fg]{itemize \\beameritemnestingprefix item}##1}}%
			}%
		}%
	}
	\\fi%
	\\setlength\\itemsep{\\fill}
	\\ifnum \\@itemdepth >1
	\\vfill
	\\fi%  
	\\beamer@cramped%
	\\raggedright%
	\\beamer@firstlineitemizeunskip%
}
\\def\\enditemize{\\ifhmode\\unskip\\fi\\endlist%
	\\usebeamertemplate{itemize/enumerate \\beameritemnestingprefix body end}
	\\ifnum \\@itemdepth >1
	\\vfil
	\\fi%  
}
\\makeatother

\\makeatletter
\\def\\enumerate{%
	\\ifnum\\@enumdepth>2\\relax\\@toodeep
	\\else%
	\\advance\\@enumdepth\\@ne%
	\\edef\\@enumctr{enum\\romannumeral\\the\\@enumdepth}%
	\\advance\\@itemdepth\\@ne%
	\\fi%
	\\beamer@computepref\\@enumdepth% sets \\beameritemnestingprefix
	\\edef\\beamer@enumtempl{enumerate \\beameritemnestingprefix item}%
	\\@ifnextchar[{\\beamer@@enum@}{\\beamer@enum@}}
\\def\\beamer@@enum@[{\\@ifnextchar<{\\beamer@enumdefault[}{\\beamer@@@enum@[}}
\\def\\beamer@enumdefault[#1]{\\def\\beamer@defaultospec{#1}%
	\\@ifnextchar[{\\beamer@@@enum@}{\\beamer@enum@}}
\\def\\beamer@@@enum@[#1]{% partly copied from enumerate.sty
	\\@enLab{}\\let\\@enThe\\@enQmark
	\\@enloop#1\\@enum@
	\\ifx\\@enThe\\@enQmark\\@warning{The counter will not be printed.%
		^^J\\space\\@spaces\\@spaces\\@spaces The label is: \\the\\@enLab}\\fi
	\\def\\insertenumlabel{\\the\\@enLab}
	\\def\\beamer@enumtempl{enumerate mini template}%
	\\expandafter\\let\\csname the\\@enumctr\\endcsname\\@enThe
	\\csname c@\\@enumctr\\endcsname7
	\\expandafter\\settowidth
	\\csname leftmargin\\romannumeral\\@enumdepth\\endcsname
	{\\the\\@enLab\\hspace{\\labelsep}}%
	\\beamer@enum@}
\\def\\beamer@enum@{%
	\\beamer@computepref\\@itemdepth% sets \\beameritemnestingprefix
	\\usebeamerfont{itemize/enumerate \\beameritemnestingprefix body}%
	\\usebeamercolor[fg]{itemize/enumerate \\beameritemnestingprefix body}%
	\\usebeamertemplate{itemize/enumerate \\beameritemnestingprefix body begin}%
	\\expandafter
	\\list
	{\\usebeamertemplate{\\beamer@enumtempl}}
	{\\usecounter\\@enumctr%
		\\def\\makelabel##1{{\\hss\\llap{{%
						\\usebeamerfont*{enumerate \\beameritemnestingprefix item}%
						\\usebeamercolor[fg]{enumerate \\beameritemnestingprefix item}##1}}}}}%
	\\setlength\\itemsep{\\fill}
	\\ifnum \\@itemdepth >1
	\\vfill
	\\fi%  
	\\beamer@cramped%
	\\raggedright%
	\\beamer@firstlineitemizeunskip%
}
\\def\\endenumerate{\\ifhmode\\unskip\\fi\\endlist%
	\\usebeamertemplate{itemize/enumerate \\beameritemnestingprefix body end}
	\\ifnum \\@itemdepth >1
	\\vfil
	\\fi%  
}
\\makeatother
\\setbeamerfont{itemize/enumerate body}{size=\\Large}
\\setbeamerfont{itemize/enumerate subbody}{size=\\large}
\\setbeamerfont{itemize/enumerate subsubbody}{size=\\normalsize}
\\usepackage{etoolbox}
\\BeforeBeginEnvironment{equation*}{\\begingroup\\LARGE}
\\AfterEndEnvironment{equation*}{\\endgroup}
\\BeforeBeginEnvironment{align*}{\\begingroup\\LARGE}
\\AfterEndEnvironment{align*}{\\endgroup}"
	 ("\\section{%s}" . "\\section*{%s}")
	 ("\\begin{frame}[fragile]\\frametitle{%s}"
	  "\\end{frame}"
	  "\\begin{frame}[fragile]\\frametitle{%s}"
	  "\\end{frame}"))

	("white-black"
	 "\\documentclass[presentation,9pt]{beamer}
\\usepackage{arev}
\\usepackage[backend=bibtex,style=numeric-comp,citestyle=numeric-comp,autocite=plain]{biblatex}
\\addbibresource{/home/chl/Documents/notes/references.bib}
\\usecolortheme[named=black]{structure}
\\setbeamertemplate{navigation symbols}{}
\\makeatletter
\\setbeamertemplate{title page}[default][left,colsep=-4bp]
\\makeatother
\\usepackage{tcolorbox}
\\usepackage{textcomp}
\\usepackage{ragged2e}
\\usepackage{listings}
\\definecolor{SlateGrey}{HTML}{708090}
\\definecolor{CornflowerBlue}{HTML}{6495ed}
\\definecolor{SandyBrown}{HTML}{f4a460}
\\definecolor{White}{HTML}{ffffff}
\\usepackage[font={color=SlateGrey,small}]{caption}
\\setbeamercolor{frametitle}{bg=SlateGrey,fg=White}
\\setbeamercolor{alerted text}{fg=SlateGrey}
\\setbeamertemplate{itemize items}{\\scalebox{1.4}{\\raisebox{-.25ex}{\\text{\\textbullet}}}}
\\addtobeamertemplate{block begin}{}{\\justifying\\small\\sffamily}
\\captionsetup[figure]{labelformat=empty}
\\captionsetup[table]{labelformat=empty}
\\captionsetup[lstlisting]{labelformat=empty}
\\renewcommand{\\textbf}{\\alert}
\\definecolor{low}{named}{SandyBrown}
\\definecolor{high}{named}{CornflowerBlue}
\\newtcbox{\\texthigh}{nobeforeafter,colframe=high!15!white,colback=high!5!white,boxrule=0.5pt,arc=4pt,
boxsep=0pt,left=2pt,right=2pt,top=2pt,bottom=2pt,tcbox raise base}
\\newtcbox{\\textlow}{nobeforeafter,colframe=low!15!white,colback=low!5!white,boxrule=0.5pt,arc=4pt,
boxsep=0pt,left=2pt,right=2pt,top=2pt,bottom=2pt,tcbox raise base}
\\newcommand{\\mathhigh}[1]{\\textcolor{high}{#1}}
\\newcommand{\\mathlow}[1]{\\textcolor{low}{#1}}
\\newcommand{\\goto}[2]{\\quad\\hyperlink{#1}{\\beamerbutton{#2}}}
\\renewcommand{\\footnoterule}{%
\\kern -3pt
{\\color{SlateGrey}\\hrule width \\textwidth height .25pt}
\\kern 2.5pt
}
\\renewcommand{\\footnotesize}{\\scriptsize}
\\author{\\url{https://aliquote.org}\\\\ \\url{mailto:chl@aliquote.org}}
\\lstset{
basicstyle=\\small\\ttfamily,
commentstyle=\\color{SlateGrey}\\textit,
numbers=left,
stepnumber=1,
numbersep=8pt,
numberfirstline=true,
firstnumber=1,
numberstyle=\\color{SlateGrey}\\footnotesize{},
captionpos=t,
abovecaptionskip=3ex,
aboveskip=20pt,
identifierstyle=\\ttfamily,
keywordstyle=\\ttfamily,
escapeinside={(*@}{@*)}
}
[NO-DEFAULT-PACKAGES]
[PACKAGES]
[EXTRA]"
	 ("\\section{%s}" . "\\section*{%s}")
	 ("\\subsection{%s}" . "\\subsection*{%s}")
	 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
	 ("\\paragraph{%s}" . "\\paragraph*{%s}")
	 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))

	("html"
	 "\\documentclass{article}
\\usepackage[utf8]{inputenc}
\\usepackage[T1]{fontenc}
\\usepackage{graphicx}
\\usepackage{longtable}
\\usepackage{hyperref}
\\usepackage{natbib}
\\usepackage{amssymb}
\\usepackage{amsmath}
\\usepackage{geometry}
\\geometry{a4paper,left=2.5cm,top=2cm,right=2.5cm,bottom=2cm,marginparsep=7pt, marginparwidth=.6in}"
	 ("\\section{%s}" . "\\section*{%s}")
	 ("\\subsection{%s}" . "\\subsection*{%s}")
	 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
	 ("\\paragraph{%s}" . "\\paragraph*{%s}")
	 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))

	("tuftehandout"
	 "\\documentclass{tufte-handout}
\\addbibresource{/Users/chl/org/references.bib}
\\usepackage[style=authoryear-comp,autocite=footnote]{biblatex}           
\\usepackage{color}   
\\usepackage{amssymb}
\\usepackage{amsmath}
\\usepackage{gensymb}
\\usepackage{nicefrac}
\\usepackage{units}"                 
	 ("\\section{%s}" . "\\section*{%s}")   ;; \footnote 
	 ("\\subsection{%s}" . "\\subsection*{%s}")
	 ("\\paragraph{%s}" . "\\paragraph*{%s}")
	 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))

	))
;; ====================================
;;replace neotree with speedtree
;;Config Ivy=============================
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(setq ivy-count-format "(%d/%d) ")
(setq enable-recursive-minibuffers t)
(global-set-key (kbd "C-s") 'swiper-isearch)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "M-y") 'counsel-yank-pop)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "<f2> j") 'counsel-set-variable)
(global-set-key (kbd "C-x b") 'ivy-switch-buffer)
(global-set-key (kbd "C-c v") 'ivy-push-view)
(global-set-key (kbd "C-c V") 'ivy-pop-view)
(global-set-key (kbd "C-x l") 'counsel-locate)
(global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
(define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)
;;Switch between windows==============================
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <down>")  'windmove-down)
;;==================================================
;;==================================================

(add-to-list 'load-path "~/.emacs.d/emacs-application-framework/")
(require 'eaf) ;;M-x eaf-open... to active mode
(require 'eaf-browser)
;;(require 'eaf-file-browser);;M-x eaf-file-browser-qrcode
;;(require 'eaf-file-sender);;M-x eaf-file-sender-qrcode or eaf-file-sender-qrcode-in-dired
(require 'eaf-image-viewer);;
(require 'eaf-music-player);;M-x eaf-open-music-player

;;M-x open path/to/file
(require 'eaf-pdf-viewer);;
(require 'eaf-rss-reader)
(require 'eaf-video-player)
;;===================================================
;; ====================================
;; ====================================
;;Web developer config
;; ====================================
;;Reactjs-mode (rjsx-mode and flycheck eslint)
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-hook 'js-mode-hook 'js2-minor-mode)
(add-to-list 'auto-mode-alist '("\\.jsx?\\'" . js2-minor-mode))
(add-to-list 'interpreter-mode-alist '("node" . js2-mode))

;; http://www.flycheck.org/manual/latest/index.html
(require 'flycheck)
(require 'emmet-mode)

;; disable jshint since we prefer eslint checking
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
    '(javascript-jshint)))

;; use eslint with rjsx-mode for js files
(flycheck-add-mode 'javascript-eslint 'js2-mode)

;; customize flycheck temp file prefix
(setq-default flycheck-temp-prefix ".flycheck")

;; disable json-jsonlist checking for json files
(setq-default flycheck-disabled-checkers
  (append flycheck-disabled-checkers
	  '(json-jsonlist)))
(setq flycheck-highlighting-mode 'lines)
;;===========================================================
;;Refacting for js mode
(require 'js2-refactor)
(add-hook 'js2-mode-hook #'js2-refactor-mode)
(require 'js-comint)
(setq js-comint-program-command "C:/Program Files/nodejs/node.exe") ;;M-x run-js
(defun inferior-js-mode-hook-setup ()
  (add-hook 'comint-output-filter-functions 'js-comint-process-output))
(add-hook 'inferior-js-mode-hook 'inferior-js-mode-hook-setup t)
(add-hook 'js2-mode-hook
          (lambda ()
            (local-set-key (kbd "C-x C-e") 'js-send-last-sexp)
            (local-set-key (kbd "C-c b") 'js-send-buffer)))
;;Emmet mode
(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
(add-hook 'css-mode-hook  'emmet-mode) ;; enable Emmet's css abbreviation
(add-hook 'js2-mode-hook 'emmet-mode)
(add-hook 'js2-minor-mode-hook 'emmet-mode)
(setq emmet-move-cursor-between-quotes t)
(add-to-list 'emmet-jsx-major-modes 'js2-minor-mode)

;;Web-mode
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.js\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.api\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.twig\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.dtl\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tmpl\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.njk\\'" . web-mode))
(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
)
(add-hook 'web-mode-hook  'my-web-mode-hook)
;;==========================================
;;C++ config ===============================
;;==========================================
(require 'yasnippet)
(setq path-to-ctags "C:/cygwin64/usr/local/bin/ctags")
(defun create-tags (dir-name)                          ;; run ctags mannual
  "Create tags file."
  (interactive "DDirectory: ")
  (shell-command
   (format "%s -f TAGS -e -R %s" path-to-ctags (directory-file-name dir-name)))
  )

(add-to-list 'auto-mode-alist '("\\.c\\'"  . c-mode))
(add-to-list 'auto-mode-alist '("\\.C\\'"  . c++-mode))
(add-to-list 'auto-mode-alist '("\\.h\\'"  . c++-mode))
(add-to-list 'auto-mode-alist '("\\.hpp\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cpp\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.hh\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cc\\'" . c++-mode))

(require 'ggtags)
(add-hook 'c-mode-common-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
              (ggtags-mode 1))))
(define-key ggtags-mode-map (kbd "C-c g s") 'ggtags-find-other-symbol)
(define-key ggtags-mode-map (kbd "C-c g h") 'ggtags-view-tag-history)
(define-key ggtags-mode-map (kbd "C-c g r") 'ggtags-find-reference)
(define-key ggtags-mode-map (kbd "C-c g f") 'ggtags-find-file)
(define-key ggtags-mode-map (kbd "C-c g c") 'ggtags-create-tags)
(define-key ggtags-mode-map (kbd "C-c g u") 'ggtags-update-tags)
(define-key ggtags-mode-map (kbd "M-,") 'pop-tag-mark)

(add-hook 'c-mode-hook 'lsp)
(add-hook 'c++-mode-hook (lambda ()
                           (require 'lsp-clangd)
                           (lsp)))
(add-hook 'c++-mode-hook 'company-mode)
(add-hook 'c++-mode-hook 'yas-minor-mode)

(add-hook 'c++-mode-hook
          (lambda () (setq flycheck-clang-language-standard "c++17")))

(add-hook 'c++-mode-hook #'modern-c++-font-lock-mode)

;;set company-clang-arguments in this file, specifying the project header files' location, namly the include path.
;;((nil . ((company-clang-arguments . ("-I/home/<user>/project_root/include1/"
;;"-I/home/<user>/project_root/include2/")))))
;;other: ggtags-query-replace	ggtags-visit-project-root	ggtags-find-tag-regexp	

;;Flycheck and autopep8 python
;;Pyenv + Poetry or asdf + poetry  or venv + pip to use virtualenv in python
(require 'lsp-mode)
(require 'highlight-symbol)
(add-hook 'python-mode-hook 'flycheck-mode)
(setq python-indent-guess-indent-offset-verbose nil)
(setq python-indent-offset 4)
(setq lsp-workspace-folders-remove t)
(setq lsp-keep-workspace-alive nil)
(setq lsp-pyright-multi-root nil)
(setq lsp-eldoc-render-all t)
(setq lsp-enable-symbol-highlighting nil
      lsp-lens-enable nil
      lsp-prefer-flymake nil
      lsp-headerline-breadcrumb-enable t
      lsp-modeline-code-actions-enable nil
      lsp-diagnostics-provider :none
      lsp-modeline-diagnostics-enable nil
      lsp-completion-show-detail nil
      lsp-completion-show-kind nil
      lsp-restart 'auto-restart
      lsp-enable-file-watchers nil
      )
(add-hook 'python-mode-hook (lambda ()
                              (require 'lsp-pyright)
                              (lsp)))
(add-hook 'python-mode-hook 'highlight-symbol-mode)
(add-hook 'lsp-mode 'lsp-enable-which-key-integration)
(add-hook 'lsp-mode 'company-mode-hook)
;;				 python-shell-virtualenv-root (call-process "poetry" nil t nil "env" "info" "--no-ansi" "--path")


(setq python-shell-interpreter "python")
(setq flycheck-python-flake8-executable "python"
      flycheck-python-pycompile-executable "python"
      flycheck-python-pylint-executable "pylint"
      lsp-pyright-python-executable-cmd "python") ;python-shell-interpreter-args "--simple-prompt") when using ipython3
;;M-x compile ==> poetry run python ...  ==> to run python file in current buffer

;;===========================================================
;;Smartparens
(require 'smartparens-config)
(add-hook 'js-mode-hook #'smartparens-mode)
(add-hook 'c++-mode-hook #'smartparens-mode)
(add-hook 'c-mode-hook #'smartparens-mode)

;;Write-mode
;;enable with M-x writeroom-mode ==> distraction-free writing 
;;Rest-client to testing web

;;Google Translate
(require 'google-translate)
(require 'google-translate-default-ui)
(setq google-translate-default-target-language "vi")
(global-set-key "\C-ct" 'google-translate-at-point)
(global-set-key "\C-cT" 'google-translate-query-translate)

;;Youtube
;;M-x ytel
(require 'ytel)
(defvar invidious-instances-url
  "https://api.invidious.io/instances.json?pretty=1&sort_by=health")

(defun ytel-instances-fetch-json ()
  "Fetch list of invidious instances as json, sorted by health."
  (let
      ((url-request-method "GET")
       (url-request-extra-headers
	'(("Accept" . "application/json"))))
    (with-current-buffer
	(url-retrieve-synchronously invidious-instances-url)
      (goto-char (point-min))
      (re-search-forward "^$")
      (let* ((json-object-type 'alist)
	     (json-array-type 'list)
	     (json-key-type 'string))
	(json-read)))))

(defun ytel-instances-alist-from-json ()
  "Make the json of invidious instances into an alist."
  (let ((jsonlist (ytel-instances-fetch-json))
	(inst ()))
    (while jsonlist
      (push (concat "https://" (caar jsonlist)) inst)
      (setq jsonlist (cdr jsonlist)))
    (nreverse inst)))

(defun ytel-choose-instance ()
  "Prompt user to choose an invidious instance to use."
  (interactive)
  (setq ytel-invidious-api-url
	(or (condition-case nil
		(completing-read "Using instance: "
				 (subseq (ytel-instances-alist-from-json) 0 11) nil "confirm" "https://") ; "healthiest" 12 instances; no require match
	      (error nil))
	    "https://invidious.tube"))) ; fallback

;; default fallback "https://invidious.synopyta.org"
(defun ytel-watch ()
  "Stream video at point in mpv."
  (interactive)
  (let* ((video (ytel-get-current-video))
     	 (id    (ytel-video-id video)))
    (start-process "ytel mpv" nil
		   "mpv"
		   (concat "https://www.youtube.com/watch?v=" id))
    "--ytdl-format=bestvideo[height<=?720]+bestaudio/best")
  (message "Starting streaming..."))
(define-key ytel-mode-map "y" #'ytel-watch)

;;<==> mpv https://www.youtube.com/watch?v=nN_0YlcN-i8 --ytdl-format="bestvideo[height<=?720]+bestaudio/best"

;;===================================
;;HYDRA
;;==================================
(require 'hydra)
(require 'dired)
(require 'magit)

(defhydra hydra-buffer-menu (:color pink
				    :hint nil)
  "
^Mark^             ^Unmark^           ^Actions^          ^Search
^^^^^^^^-----------------------------------------------------------------                        (__)
_m_: mark          _u_: unmark        _x_: execute       _R_: re-isearch                         (oo)
_s_: save          _U_: unmark up     _b_: bury          _I_: isearch                      /------\\/
_d_: delete        ^ ^                _g_: refresh       _O_: multi-occur                 / |    ||
_D_: delete up     ^ ^                _T_: files only: % -28`Buffer-menu-files-only^^    *  /\\---/\\
_~_: modified      ^ ^                ^ ^                ^^                                 ~~   ~~
"
  ("m" Buffer-menu-mark)
  ("u" Buffer-menu-unmark)
  ("U" Buffer-menu-backup-unmark)
  ("d" Buffer-menu-delete)
  ("D" Buffer-menu-delete-backwards)
  ("s" Buffer-menu-save)
  ("~" Buffer-menu-not-modified)
  ("x" Buffer-menu-execute)
  ("b" Buffer-menu-bury)
  ("g" revert-buffer)
  ("T" Buffer-menu-toggle-files-only)
  ("O" Buffer-menu-multi-occur :color blue)
  ("I" Buffer-menu-isearch-buffers :color blue)
  ("R" Buffer-menu-isearch-buffers-regexp :color blue)
  ("c" nil "cancel")
  ("v" Buffer-menu-select "select" :color blue)
  ("o" Buffer-menu-other-window "other-window" :color blue)
  ("q" quit-window "quit" :color blue))
;; Recommended binding:
(define-key Buffer-menu-mode-map ";" 'hydra-buffer-menu/body)


(defhydra hydra-dired (:hint nil :color pink)
  "
_+_ mkdir          _v_iew           _m_ark             _(_ details        _i_nsert-subdir    wdired
_C_opy             _O_ view other   _U_nmark all       _)_ omit-mode      _$_ hide-subdir    C-x C-q : edit
_D_elete           _o_pen other     _u_nmark           _l_ redisplay      _w_ kill-subdir    C-c C-c : commit
_R_ename           _M_ chmod        _t_oggle           _g_ revert buf     _e_ ediff          C-c ESC : abort
_Y_ rel symlink    _G_ chgrp        _E_xtension mark   _s_ort             _=_ pdiff
_S_ymlink          ^ ^              _F_ind marked      _._ toggle hydra   \\ flyspell
_r_sync            ^ ^              ^ ^                ^ ^                _?_ summary
_z_ compress-file  _A_ find regexp
_Z_ compress       _Q_ repl regexp

T - tag prefix
"
  ("\\" dired-do-ispell)
  ("(" dired-hide-details-mode)
  (")" dired-omit-mode)
  ("+" dired-create-directory)
  ("=" diredp-ediff)         ;; smart diff
  ("?" dired-summary)
  ("$" diredp-hide-subdir-nomove)
  ("A" dired-do-find-regexp)
  ("C" dired-do-copy)        ;; Copy all marked files
  ("D" dired-do-delete)
  ("E" dired-mark-extension)
  ("e" dired-ediff-files)
  ("F" dired-do-find-marked-files)
  ("G" dired-do-chgrp)
  ("g" revert-buffer)        ;; read all directories again (refresh)
  ("i" dired-maybe-insert-subdir)
  ("l" dired-do-redisplay)   ;; relist the marked or singel directory
  ("M" dired-do-chmod)
  ("m" dired-mark)
  ("O" dired-display-file)
  ("o" dired-find-file-other-window)
  ("Q" dired-do-find-regexp-and-replace)
  ("R" dired-do-rename)
  ("r" dired-do-rsynch)
  ("S" dired-do-symlink)
  ("s" dired-sort-toggle-or-edit)
  ("t" dired-toggle-marks)
  ("U" dired-unmark-all-marks)
  ("u" dired-unmark)
  ("v" dired-view-file)      ;; q to exit, s to search, = gets line #
  ("w" dired-kill-subdir)
  ("Y" dired-do-relsymlink)
  ("z" diredp-compress-this-file)
  ("Z" dired-do-compress)
  ("q" nil)
  ("." nil :color blue))
(define-key dired-mode-map ";" 'hydra-dired/body)

;; Hydra for org agenda (graciously taken from Spacemacs)
(defhydra hydra-org-agenda (:pre (setq which-key-inhibit t)
				 :post (setq which-key-inhibit nil)
				 :hint none)
  "
Org agenda (_q_uit)

^Clock^      ^Visit entry^              ^Date^             ^Other^
^-----^----  ^-----------^------------  ^----^-----------  ^-----^---------
_ci_ in      _SPC_ in other window      _ds_ schedule      _gr_ reload
_co_ out     _TAB_ & go to location     _dd_ set deadline  _._  go to today
_cq_ cancel  _RET_ & del other windows  _dt_ timestamp     _gd_ go to date
_cj_ jump    _o_   link                 _+_  do later      ^^
^^           ^^                         _-_  do earlier    ^^
^^           ^^                         ^^                 ^^
^View^          ^Filter^                 ^Headline^         ^Toggle mode^
^----^--------  ^------^---------------  ^--------^-------  ^-----------^----
_vd_ day        _ft_ by tag              _ht_ set status    _tf_ follow
_vw_ week       _fr_ refine by tag       _hk_ kill          _tl_ log
_vt_ fortnight  _fc_ by category         _hr_ refile        _ta_ archive trees
_vm_ month      _fh_ by top headline     _hA_ archive       _tA_ archive files
_vy_ year       _fx_ by regexp           _h:_ set tags      _tr_ clock report
_vn_ next span  _fd_ delete all filters  _hp_ set priority  _td_ diaries
_vp_ prev span  ^^                       ^^                 ^^
_vr_ reset      ^^                       ^^                 ^^
^^              ^^                       ^^                 ^^
"
  ;; Entry
  ("hA" org-agenda-archive-default)
  ("hk" org-agenda-kill)
  ("hp" org-agenda-priority)
  ("hr" org-agenda-refile)
  ("h:" org-agenda-set-tags)
  ("ht" org-agenda-todo)
  ;; Visit entry
  ("o"   link-hint-open-link :exit t)
  ("<tab>" org-agenda-goto :exit t)
  ("TAB" org-agenda-goto :exit t)
  ("SPC" org-agenda-show-and-scroll-up)
  ("RET" org-agenda-switch-to :exit t)
  ;; Date
  ("dt" org-agenda-date-prompt)
  ("dd" org-agenda-deadline)
  ("+" org-agenda-do-date-later)
  ("-" org-agenda-do-date-earlier)
  ("ds" org-agenda-schedule)
  ;; View
  ("vd" org-agenda-day-view)
  ("vw" org-agenda-week-view)
  ("vt" org-agenda-fortnight-view)
  ("vm" org-agenda-month-view)
  ("vy" org-agenda-year-view)
  ("vn" org-agenda-later)
  ("vp" org-agenda-earlier)
  ("vr" org-agenda-reset-view)
  ;; Toggle mode
  ("ta" org-agenda-archives-mode)
  ("tA" (org-agenda-archives-mode 'files))
  ("tr" org-agenda-clockreport-mode)
  ("tf" org-agenda-follow-mode)
  ("tl" org-agenda-log-mode)
  ("td" org-agenda-toggle-diary)
  ;; Filter
  ("fc" org-agenda-filter-by-category)
  ("fx" org-agenda-filter-by-regexp)
  ("ft" org-agenda-filter-by-tag)
  ("fr" org-agenda-filter-by-tag-refine)
  ("fh" org-agenda-filter-by-top-headline)
  ("fd" org-agenda-filter-remove-all)
  ;; Clock
  ("cq" org-agenda-clock-cancel)
  ("cj" org-agenda-clock-goto :exit t)
  ("ci" org-agenda-clock-in :exit t)
  ("co" org-agenda-clock-out)
  ;; Other
  ("q" nil :exit t)
  ("gd" org-agenda-goto-date)
  ("." org-agenda-goto-today)
  ("gr" org-agenda-redo))
(define-key org-agenda-mode-map ";" 'hydra-org-agenda/body)

(defhydra hydra-smartparens (:hint nil)
  "
 Moving^^^^                       Slurp & Barf^^   Wrapping^^            Sexp juggling^^^^               Destructive
------------------------------------------------------------------------------------------------------------------------
 [_a_] beginning  [_n_] down      [_h_] bw slurp   [_R_]   rewrap        [_S_] split   [_t_] transpose   [_c_] change inner  [_w_] copy
 [_e_] end        [_N_] bw down   [_H_] bw barf    [_u_]   unwrap        [_s_] splice  [_A_] absorb      [_C_] change outer
 [_f_] forward    [_p_] up        [_l_] slurp      [_U_]   bw unwrap     [_r_] raise   [_E_] emit        [_k_] kill          [_g_] quit
 [_b_] backward   [_P_] bw up     [_L_] barf       [_(__{__[_] wrap (){}[]   [_j_] join    [_o_] convolute   [_K_] bw kill       [_q_] quit"
  ;; Moving
  ("a" sp-beginning-of-sexp)
  ("e" sp-end-of-sexp)
  ("f" sp-forward-sexp)
  ("b" sp-backward-sexp)
  ("n" sp-down-sexp)
  ("N" sp-backward-down-sexp)
  ("p" sp-up-sexp)
  ("P" sp-backward-up-sexp)
  
  ;; Slurping & barfing
  ("h" sp-backward-slurp-sexp)
  ("H" sp-backward-barf-sexp)
  ("l" sp-forward-slurp-sexp)
  ("L" sp-forward-barf-sexp)
  
  ;; Wrapping
  ("R" sp-rewrap-sexp)
  ("u" sp-unwrap-sexp)
  ("U" sp-backward-unwrap-sexp)
  ("(" sp-wrap-round)
  ("{" sp-wrap-curly)
  ("[" sp-wrap-square)
  
  ;; Sexp juggling
  ("S" sp-split-sexp)
  ("s" sp-splice-sexp)
  ("r" sp-raise-sexp)
  ("j" sp-join-sexp)
  ("t" sp-transpose-sexp)
  ("A" sp-absorb-sexp)
  ("E" sp-emit-sexp)
  ("o" sp-convolute-sexp)
  
  ;; Destructive editing
  ("c" sp-change-inner :exit t)
  ("C" sp-change-enclosing :exit t)
  ("k" sp-kill-sexp)
  ("K" sp-backward-kill-sexp)
  ("w" sp-copy-sexp)

  ("q" nil)
  ("g" nil))
(define-key smartparens-mode-map ";" 'hydra-smartparens/body)

(defhydra hydra-multiple-cursors (:hint nil)
  "
 Up^^             Down^^           Miscellaneous           % 2(mc/num-cursors) cursor%s(if (> (mc/num-cursors) 1) \"s\" \"\")
------------------------------------------------------------------
 [_p_]   Next     [_n_]   Next     [_l_] Edit lines  [_0_] Insert numbers
 [_P_]   Skip     [_N_]   Skip     [_a_] Mark all    [_A_] Insert letters
 [_M-p_] Unmark   [_M-n_] Unmark   [_s_] Search      [_q_] Quit
 [_|_] Align with input CHAR       [Click] Cursor at point"
  ("l" mc/edit-lines :exit t)
  ("a" mc/mark-all-like-this :exit t)
  ("n" mc/mark-next-like-this)
  ("N" mc/skip-to-next-like-this)
  ("M-n" mc/unmark-next-like-this)
  ("p" mc/mark-previous-like-this)
  ("P" mc/skip-to-previous-like-this)
  ("M-p" mc/unmark-previous-like-this)
  ("|" mc/vertical-align)
  ("s" mc/mark-all-in-region-regexp :exit t)
  ("0" mc/insert-numbers :exit t)
  ("A" mc/insert-letters :exit t)
  ("<mouse-1>" mc/add-cursor-on-click)
  ;; Help with click recognition in this hydra
  ("<down-mouse-1>" ignore)
  ("<drag-mouse-1>" ignore)
  ("q" nil))
(global-set-key [f9] 'hydra-multiple-cursors/body)


(defhydra hydra-lsp (:exit t :hint nil)
  "
 Buffer^^               Server^^                   Symbol
-------------------------------------------------------------------------------------
 [_f_] format           [_M-r_] restart            [_d_] declaration  [_i_] implementation  [_o_] documentation
 [_m_] imenu            [_S_]   shutdown           [_D_] definition   [_t_] type            [_r_] rename
 [_x_] execute action   [_M-s_] describe session   [_R_] references   [_s_] signature"
  ("d" lsp-find-declaration)
  ("D" lsp-ui-peek-find-definitions)
  ("R" lsp-ui-peek-find-references)
  ("i" lsp-ui-peek-find-implementation)
  ("t" lsp-find-type-definition)
  ("s" lsp-signature-help)
  ("o" lsp-describe-thing-at-point)
  ("r" lsp-rename)

  ("f" lsp-format-buffer)
  ("m" lsp-ui-imenu)
  ("x" lsp-execute-code-action)

  ("M-s" lsp-describe-session)
  ("M-r" lsp-restart-workspace)
  ("S" lsp-shutdown-workspace))
(define-key lsp-mode-map ";" 'hydra-lsp/body)


(defhydra hydra-git (:color blue)
  "
  ^^View                 ^^                  ^^
  ^^─────────────────────^^──────────────────^^────────────────
  _s_tatus    my-map g   ^^                  ^^
  _t_ime-machine         ^^                  ^^
  magit-_l_og-buffer-file^^                  ^^
  ^^                     ^^                  ^^
  ^^                     ^^                  ^^
  ^^─────────────────────^^──────────────────^^────────────────
  ^^                     ^^                  ^^
  ^^                     ^^                  ^^
  ^^                     ^^                  ^^
  ^^                     ^^                  ^^
  "
  ("q" nil "quit")

  ("s" magit-status nil)
  ("t" git-timemachine-toggle nil)
  ("l" magit-log-buffer-file nil)

  )
(with-eval-after-load 'magit
  (define-key global-map [(shift f2)] 'hydra-git/body)
  ;;(global-set-key [f9] 'hydra-git/body)
  )

(defhydra hydra-python (:color blue)

  "
  ^View^                 ^Navigation^        ^^                 
  ^^─────────────────────^^──────────────────^^────────────────  
                         _p_ ← error    F5   ^^
                         _n_   error →  F6   ^^
  ^^                     _<_ ← symbol        ^^
  ^^                     _>_   symbol →      ^^
  ^^                     _d_ definition      ^^
  ^^                     _r_ references      ^^
  ^^                     ^^                  ^^
  ^Edit^                 ^Help^              ^^
  ^^─────────────────────^^──────────────────^^────────────────
  ^^                     ^^                  ^^
  ^^                     ^^                  ^^
  ^^                     ^^                  ^^
  "
  ("q" nil "quit")

  ("p" flymake-goto-prev-error nil :color red)
  ("n" flymake-goto-next-error nil :color red)
  ("<" highlight-symbol-prev nil)
  (">" highlight-symbol-next nil)

  ("d" lsp-find-definition nil)
  ("r" lsp-find-references nil)
					;  (""  nil)
  )

(with-eval-after-load 'python
  (define-key python-mode-map ";" 'hydra-python/body)
  )


(defhydra hydra-org (:color blue)
  "
  ^^Go to                          ^^Inserting                        ^^Org-timer              ^^Properties                          ^^Tables
  ^────────^───────────────────────^──────^───────────────────────────^^───────────────────────^─────────^───────────────────────────^^────────────────────────────────────
                                   _u_rl clipboard → Org link         Start  C-c C-x _0_                                            S-RET  fill from cell above
                                   _T_ags include inherited            Insert C-c C-x _._                                             C-u C-u C-c =  edit cell formular
                                                                       Pause  C-c C-x _,_                                            C-c ?  info on cell + reference
  org-_a_ttach-reveal              add _n_ote to logbook               Stop   C-c C-x ___       ^^                                    C-c {  debug formula mode
  ^^                                                                  ^^                       ^^                                    C-c }  toggle row/column overlay
  ^^                                                                  ^^                       ^^                                    C-c '  edit formulas (S-<arrows> for changing references)
  ^^                                                                  ^^                       ^^
  ^^                                                                  ^^                       ^^
  ^^C-c C-a  attachment menu       indent-_r_igidly   C-x TAB         ^^                       ^^
  ^^                               org-_A_ttach-set-directory         ^^                       ^^
  ^^                               my-org-attach-_I_nsert             ^^                       ^^
  ^^                               ^^                                 ^^                       ^^                                    ^^M-0 C-x e  kmacro-end-and-call-macro → do macro until end of buffer
  ^^Filter                         ^^Export                         ^^MISC                                             
  ^────────^───────────────────────^──────^─────────────────────────^─────────^───────────────────────────────────────────────────
  _f_ocus agenda (prio A; sched .)                                  _x_  redacted-mode              
  _F_ocus disabled for agenda           
  ^^                               ^^                               _W_eather Ho Chi Minh City      
  ^^                               ^^                               _!_ save-buffers-kill-terminal  
  "

  ("f" (lambda ()
         (interactive)
         (org-agenda-filter-apply '("+.*\\[#A\\].*") 'regexp)
	 ) nil)
  ("F" (lambda ()
         (interactive)
         (org-agenda-filter-show-all-re)
	 ) nil)

  ("u" my-insert-orgmode-url-from-clipboard nil)
  ("T" my-set-tags-including-inherited nil)


  ("W" (lambda () (interactive) (wttrin-query "Ho Chi Minh")) nil)
  ("n" org-add-note nil)
  ("i" my-id-get-or-generate nil)

  ("0" org-timer-start nil)
  ("." org-timer nil)
  ("," org-timer-pause-or-continue nil)
  ("_" org-timer-stop nil)

  ("!" save-buffers-kill-terminal nil)

  ("r" indent-rigidly nil)
  ("A" org-attach-set-directory nil)
  ("a" org-attach-reveal nil)
  ("I" my-org-attach-insert nil)

  ("x" redacted-mode nil)

  ("q" nil "quit")

  )
(defun straight-string (s)
  "Spliting the string and then concatenating it back."
  (mapconcat #'(lambda (x) x) (split-string s) " "))
(defun my-cliplink-format-and-trim-title (title)
  (let (;; Table of replacements which make this title usable for
        ;; org-link. Can be extended.
        (replace-table '(("\\[" . "{")
                         ("\\]" . "}")
                         ("&#8217;" . "’")
                         ("&amp;" . "&") ("&#039;" . "'") ("&#8211;" . "–") ("&#8212;" . "—")
                         (" •     " . "")  ("  | heise online • " . " - heise online") (" | heise online • " . " - heise online")
                         ("&nbsp;" . " ") ("&ensp;" . " ") ("&emsp;" . " ") ("&thinsp;" . " ")
                         ("&rlm;" . "‏") ("&lrm;" . "‎") ("&zwj;" . "‍") ("&zwnj;" . "‌")
                         ("&iexcl;" . "¡") ("&cent;" . "¢") ("&pound;" . "£") ("&curren;" . "¤") ("&yen;" . "¥") ("&brvbar;" . "¦") ("&sect;" . "§")
                         ("&uml;" . "¨") ("&copy;" . "©") ("&ordf;" . "ª") ("&laquo;" . "«") ("&not;" . "¬") ("&shy;" . "­") ("&reg;" . "®")
                         ("&macr;" . "¯") ("&deg;" . "°") ("&plusmn;" . "±") ("&sup2;" . "²") ("&sup3;" . "³") ("&acute;" . "´") ("&micro;" . "µ")
                         ("&para;" . "¶") ("&middot;" . "·") ("&cedil;" . "¸") ("&sup1;" . "¹") ("&ordm;" . "º") ("&raquo;" . "»") ("&frac14;" . "¼")
                         ("&frac12;" . "½") ("&frac34;" . "¾") ("&iquest;" . "¿") ("&Agrave;" . "À") ("&Aacute;" . "Á") ("&Acirc;" . "Â")
                         ("&Atilde;" . "Ã") ("&Auml;" . "Ä") ("&Aring;" . "Å") ("&AElig;" . "Æ") ("&Ccedil;" . "Ç") ("&Egrave;" . "È") ("&Eacute;" . "É")
                         ("&Ecirc;" . "Ê") ("&Euml;" . "Ë") ("&Igrave;" . "Ì") ("&Iacute;" . "Í") ("&Icirc;" . "Î") ("&Iuml;" . "Ï") ("&ETH;" . "Ð")
                         ("&Ntilde;" . "Ñ") ("&Ograve;" . "Ò") ("&Oacute;" . "Ó") ("&Ocirc;" . "Ô") ("&Otilde;" . "Õ") ("&Ouml;" . "Ö") ("&times;" . "×")
                         ("&Oslash;" . "Ø") ("&Ugrave;" . "Ù") ("&Uacute;" . "Ú") ("&Ucirc;" . "Û") ("&Uuml;" . "Ü") ("&Yacute;" . "Ý") ("&THORN;" . "Þ")
                         ("&szlig;" . "ß") ("&agrave;" . "à") ("&aacute;" . "á") ("&acirc;" . "â") ("&atilde;" . "ã") ("&auml;" . "ä") ("&aring;" . "å")
                         ("&aelig;" . "æ") ("&ccedil;" . "ç") ("&egrave;" . "è") ("&eacute;" . "é") ("&ecirc;" . "ê") ("&euml;" . "ë") ("&igrave;" . "ì")
                         ("&iacute;" . "í") ("&icirc;" . "î") ("&iuml;" . "ï") ("&eth;" . "ð") ("&ntilde;" . "ñ") ("&ograve;" . "ò") ("&oacute;" . "ó")
                         ("&ocirc;" . "ô") ("&otilde;" . "õ") ("&ouml;" . "ö") ("&divide;" . "÷") ("&oslash;" . "ø") ("&ugrave;" . "ù") ("&uacute;" . "ú")
                         ("&ucirc;" . "û") ("&uuml;" . "ü") ("&yacute;" . "ý") ("&thorn;" . "þ") ("&yuml;" . "ÿ") ("&fnof;" . "ƒ") ("&Alpha;" . "Α")
                         ("&Beta;" . "Β") ("&Gamma;" . "Γ") ("&Delta;" . "Δ") ("&Epsilon;" . "Ε") ("&Zeta;" . "Ζ") ("&Eta;" . "Η") ("&Theta;" . "Θ")
                         ("&Iota;" . "Ι") ("&Kappa;" . "Κ") ("&Lambda;" . "Λ") ("&Mu;" . "Μ") ("&Nu;" . "Ν") ("&Xi;" . "Ξ") ("&Omicron;" . "Ο") ("&Pi;" . "Π")
                         ("&Rho;" . "Ρ") ("&Sigma;" . "Σ") ("&Tau;" . "Τ") ("&Upsilon;" . "Υ") ("&Phi;" . "Φ") ("&Chi;" . "Χ") ("&Psi;" . "Ψ")
                         ("&Omega;" . "Ω") ("&alpha;" . "α") ("&beta;" . "β") ("&gamma;" . "γ") ("&delta;" . "δ") ("&epsilon;" . "ε") ("&zeta;" . "ζ")
                         ("&eta;" . "η") ("&theta;" . "θ") ("&iota;" . "ι") ("&kappa;" . "κ") ("&lambda;" . "λ") ("&mu;" . "μ") ("&nu;" . "ν") ("&xi;" . "ξ")
                         ("&omicron;" . "ο") ("&pi;" . "π") ("&rho;" . "ρ") ("&sigmaf;" . "ς") ("&sigma;" . "σ") ("&tau;" . "τ") ("&upsilon;" . "υ")
                         ("&phi;" . "φ") ("&chi;" . "χ") ("&psi;" . "ψ") ("&omega;" . "ω") ("&thetasym;" . "ϑ") ("&upsih;" . "ϒ") ("&piv;" . "ϖ")
                         ("&bull;" . "•") ("&hellip;" . "…") ("&prime;" . "′") ("&Prime;" . "″") ("&oline;" . "‾") ("&frasl;" . "⁄") ("&weierp;" . "℘")
                         ("&image;" . "ℑ") ("&real;" . "ℜ") ("&trade;" . "™") ("&alefsym;" . "ℵ") ("&larr;" . "←") ("&uarr;" . "↑") ("&rarr;" . "→")
                         ("&darr;" . "↓") ("&harr;" . "↔") ("&crarr;" . "↵") ("&lArr;" . "⇐") ("&uArr;" . "⇑") ("&rArr;" . "⇒") ("&dArr;" . "⇓") ("&hArr;" . "⇔")
                         ("&forall;" . "∀") ("&part;" . "∂") ("&exist;" . "∃") ("&empty;" . "∅") ("&nabla;" . "∇") ("&isin;" . "∈") ("&notin;" . "∉")
                         ("&ni;" . "∋") ("&prod;" . "∏") ("&sum;" . "∑") ("&minus;" . "−") ("&lowast;" . "∗") ("&radic;" . "√") ("&prop;" . "∝")
                         ("&infin;" . "∞") ("&ang;" . "∠") ("&and;" . "∧") ("&or;" . "∨") ("&cap;" . "∩") ("&cup;" . "∪") ("&int;" . "∫") ("&there4;" . "∴")
                         ("&sim;" . "∼") ("&cong;" . "≅") ("&asymp;" . "≈") ("&ne;" . "≠") ("&equiv;" . "≡") ("&le;" . "≤") ("&ge;" . "≥") ("&sub;" . "⊂")
                         ("&sup;" . "⊃") ("&nsub;" . "⊄") ("&sube;" . "⊆") ("&supe;" . "⊇") ("&oplus;" . "⊕") ("&otimes;" . "⊗") ("&perp;" . "⊥")
                         ("&sdot;" . "⋅") ("&lceil;" . "⌈") ("&rceil;" . "⌉") ("&lfloor;" . "⌊") ("&rfloor;" . "⌋") ("&lang;" . "〈") ("&rang;" . "〉")
                         ("&loz;" . "◊") ("&spades;" . "♠") ("&clubs;" . "♣") ("&hearts;" . "♥") ("&diams;" . "♦") ("&quot;" . "\"") ("&OElig;" . "Œ")
                         ("&oelig;" . "œ") ("&Scaron;" . "Š") ("&scaron;" . "š") ("&Yuml;" . "Ÿ") ("&circ;" . "ˆ") ("&tilde;" . "˜") ("&ndash;" . "–")
                         ("&mdash;" . "—") ("&lsquo;" . "‘") ("&rsquo;" . "’") ("&sbquo;" . "‚") ("&ldquo;" . "“") ("&rdquo;" . "”") ("&bdquo;" . "„")
                         ("&dagger;" . "†") ("&Dagger;" . "‡") ("&permil;" . "‰") ("&lsaquo;" . "‹") ("&rsaquo;" . "›") ("&euro;" . "€")
                         ))
        ;; Maximum length of the title.
        (max-length 100)
        ;; Removing redundant whitespaces from the title.
        (result (straight-string title)))
    ;; Applying every element of the replace-table.
    (dolist (x replace-table)
      (setq result (replace-regexp-in-string (car x) (cdr x) result t t)))
    ;; Cutting off the title according to its maximum length.
    (when (> (length result) max-length)
      (setq result (concat (substring result 0 max-length) "…")))
    ;; Returning result.
    result))
(defun extract-title-from-html (html)
  (let (;; Start index of the title.
        (start (string-match "<title>" html))
        ;; End index of the title.
        (end (string-match "</title>" html))
        ;; Amount of characters to skip the openning title tag.
        (chars-to-skip (length "<title>")))
    ;; If title is found ...
    (if (and start end (< start end))
        ;; ... extract it and return.
        (substring html (+ start chars-to-skip) end)
      nil)))
(defun cliplink-decode-content-and-return-orgmode-link-of-title (buffer url content)
  (let* (;; Decoding the content from UTF-8.
         (decoded-content (decode-coding-string content 'utf-8))
         ;; Extrating and preparing the title.
         (title (my-cliplink-format-and-trim-title
                 (extract-title-from-html decoded-content))))
    ;; Inserting org-link.
    (with-current-buffer buffer
      (insert (format "[[%s][%s]]" url title)))))
(defun my-insert-orgmode-url-from-clipboard ()
  "It inserts the URL which is taken from the system clipboard in Org-mode"
  ;; Of course, this function is interactive. :)
  (interactive)
  (let (;; Remembering the current buffer, 'cause it is a destination
        ;; buffer we are inserting the org-link to.
        (dest-buffer (current-buffer))
        ;; Getting URL from the clipboard. Since it may contain
        ;; some text properties we are using substring-no-properties
        ;; function.
        (url (substring-no-properties (current-kill 0))))
    ;; Retrieving content by URL.
    (url-retrieve
     url
     ;; Performing an action on the retrieved content.
     `(lambda (s)
        (cliplink-decode-content-and-return-orgmode-link-of-title ,dest-buffer ,url
								  (buffer-string))))))
(define-key org-mode-map "u" 'my-insert-orgmode-url-from-clipboard)


(defun my-set-tags-including-inherited ()
  (interactive)
  (let (
        (alltags (org-get-tags-at)))
    (org-set-tags alltags))
  )
(defun my-org-attach-insert (&optional in-emacs)
  "Insert attachment from list."
  (interactive "P")
  (let ((attach-dir (org-attach-dir)))
    (if attach-dir
	(let* ((file (pcase (org-attach-file-list attach-dir)
		       (`(,file) file)
		       (files (completing-read "Insert attachment: "
					       (mapcar #'list files) nil t))))
               (path (expand-file-name file attach-dir))
               (desc (file-name-nondirectory path)))
          (let ((initial-input
		 (cond
		  ((not org-link-make-description-function) desc)
		  (t (condition-case nil
			 (funcall org-link-make-description-function link desc)
		       (error
			(message "Can't get link description from %S"
				 (symbol-name org-link-make-description-function))
			(sit-for 2)
			nil))))))
            (setq desc (if (called-interactively-p 'any)
			   (read-string "Description: " initial-input)
			 initial-input))
            (org-insert-link nil path (concat "attachment:" desc))))
      (error "No attachment directory exist"))))
(define-key org-mode-map ";" 'hydra-org/body)
(define-key ivy-minibuffer-map ";" 'hydra-ivy/body)

(setq wttrin-default-cities '("Ho Chi Minh" "Ninh Thuan"))
(setq wttrin-default-accept-language '("Accept-Language" . "vi-VN"))

(defhydra hydra-compilation (:columns 4)
  "
Command: %(duk/compilation-command-string)
%(duk/compilation-scroll-output-string) + %(duk/compilation-skip-threshold-string)
"
  ("c" compile "Compile")
  ("C" compile-from-buffer-folder "Compile from buffer folder")
  ("r" recompile "Recompile")
  ("k" duk/kill-compilation "Stop")
  ("n" next-error "Next error")
  ("N" next-error-skip-warnings "Next error, skip warnings")
  ("p" previous-error "Previous error")
  ("f" first-error "First error")
  ("l" duk/compilation-last-error "Last error")
  ("s" duk/compilation-toggle-scroll "Toggle scroll")
  ("t" duk/compilation-toggle-threshold "Toggle threshold")
  ("q" nil "Cancel" :color blue))

(setq compilation-window-height 30
      compilation-scroll-output 'first-error
      compilation-skip-threshold 2          
      compilation-always-kill t)
(setq old-split-height-threshold nil)
(add-hook 'compilation-mode-hook
          (lambda ()
            (setq old-split-height-threshold split-height-threshold
                  split-height-threshold --global-fill-column)
            process-adaptive-read-buffering nil))
(add-hook 'compilation-finish-functions
          (lambda (buffer string)
            (setq split-height-threshold old-split-height-threshold
                  old-split-height-threshold nil
                  process-adaptive-read-buffering t)))
(defun next-error-skip-warnings ()
  (interactive)
  (let ((compilation-skip-threshold 2))
    (next-error)))
(defun compile-from-buffer-folder (cmd)
  (interactive
   (list
    (read-shell-command "Compile command (pwd): ")))
  (compile
   (format "cd `dirname '%s'` && %s" (buffer-file-name) cmd)))
(defun duk/compilation-last-error ()
  (interactive)
  (condition-case err
      (while t
        (next-error))
    (user-error nil)))
(defun duk/compilation-toggle-scroll ()
  "Toggle between not scrolling and scrolling until first error
in compilation mode."
  (interactive)
  (if (not compilation-scroll-output)
      (setq compilation-scroll-output 'first-error)
    (setq compilation-scroll-output nil)))
(defun duk/compilation-scroll-output-string ()
  (interactive)
  (if (not compilation-scroll-output)
      "No scroll"
    "Scroll until match"))
(defun duk/compilation-skip-threshold-string ()
  (interactive)
  (cond
   ((= compilation-skip-threshold 2)
    "Skip anything less than error")
   ((= compilation-skip-threshold 1)
    "Skip anything less than warning")
   ((<= compilation-skip-threshold 0)
    "Don't skip anything")))
(defun duk/compilation-toggle-threshold ()
  (interactive)
  (progn
    (setq compilation-skip-threshold (- compilation-skip-threshold 1))
    (when (< compilation-skip-threshold 0)
      (setq compilation-skip-threshold 2))))
(defun duk/compilation-command-string ()
  (interactive)
  (if (not compile-command)
      "None"
    compile-command))
(defun duk/kill-compilation ()
  "Sometimes `kill-compilation' doesn't work because it finds the
wrong buffer. Here `compilation-find-buffer' uses non-nil
`AVOID-CURRENT' to only use current as a last resort."
  (interactive)
  (interrupt-process (get-buffer-process (compilation-find-buffer t))))
(add-hook 'prog-mode-hook
          (lambda ()
            ;; Using local-set-key because defining the bindings in prog-mode-map will get
            ;; overridden by c++-mode bindings, for instance. This shadows them instead.
            (when (member major-mode '(c++-mode c-mode))
              (local-set-key (kbd "C-c C-c") 'hydra-compilation/body))))
(global-set-key [(f7)] 'hydra-compilation/body)


(require 'rst)
(setq auto-mode-alist
      (append '(("\\.rst$" . rst-mode)
                ("\\.rest$" . rst-mode)) auto-mode-alist))


(require 'restclient) ;;M-x restclient-mode -> use rest-client and start write queries
;;C-c C-c: runs the query under the cursor, tries to pretty-print the response (if possible)
;;C-c C-r: same, but doesn't do anything with the response, just shows the buffer
;;C-c C-v: same as C-c C-c, but doesn't switch focus to other window
;;C-c C-p: jump to the previous query
;;C-c C-n: jump to the next query
;;C-c C-.: mark the query under the cursor
;;C-c C-u: copy query under the cursor as a curl command
;;C-c C-g: start a helm session with sources for variables and requests (if helm is available, of course)
;;C-c n n: narrow to region of current request (including headers)
;;TAB: hide/show current request body, only if
;;C-c C-a: show all collapsed regions
;;C-c C-i: show information on resclient variables at point



;; ====================================
;; User-Defined init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-c-headers-path-system
   '("C:/cygwin64/usr/include" "C:/cygwin64/usr/include/c++/v1" "C:/cygwin64/lib/gcc/x86_64-pc-cygwin/11/include"))
 '(display-time-mode t)
 '(org-bullets-bullet-list '("◎" "◉" "○" "●" "◈" "◇" "◆" "◦"))
 '(package-selected-packages
   '(lsp-pyright ox-reveal ox-pandoc git-timemachine highlight-symbol wttrin redacted hydra ytel google-translate writeroom-mode smartparens modern-cpp-font-lock js-comint aggressive-indent company-c-headers lsp-mode multiple-cursors ggtags golden-ratio sr-speedbar company org-contrib org-cliplink emojify ercn erc-image erc-hl-nicks gnu-elpa-keyring-update erc deft org-download all-the-icons dashboard counsel doom-modeline restclient web-mode emmet-mode js2-refactor js2-mode org modus-themes material-theme magit flycheck))
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Iosevka Extended" :foundry "outline" :slant normal :weight normal :height 120 :width normal))))
 '(fixed-pitch ((t (:family "Iosevka Medium Extended"))))
 '(menu ((t (:inherit modus-themes-intense-neutral :background "#323232" :foreground "#ffffff"))))
 '(modus-themes-intense-neutral ((t (:background "#323232" :foreground "#ffffff"))) t)
 '(org-block ((t (:inherit fixed-pitch))))
 '(org-code ((t (:inherit (shadow fixed-pitch)))))
 '(org-document-info ((t (:foreground "dark orange"))))
 '(org-document-info-keyword ((t (:inherit (shadow fixed-pitch)))))
 '(org-indent ((t (:inherit (org-hide fixed-pitch)))))
 '(org-level-1 ((t (:inherit fixed-pitch :foreground "#BF9D7A" :height 1.2))))
 '(org-level-2 ((t (:inherit fixed-pitch :foreground "goldenrod"))))
 '(org-level-3 ((t (:inherit fixed-pitch :foreground "chartreuse3"))))
 '(org-level-4 ((t (:inherit fixed-pitch :foreground "sienna"))))
 '(org-level-5 ((t (:inherit fixed-pitch))))
 '(org-level-6 ((t (:inherit fixed-pitch))))
 '(org-level-7 ((t (:inherit fixed-pitch))))
 '(org-level-8 ((t (:inherit fixed-pitch))))
 '(org-link ((t (:foreground "royal blue" :underline t))))
 '(org-meta-line ((t (:inherit (font-lock-comment-face fixed-pitch)))))
 '(org-property-value ((t (:inherit fixed-pitch))) t)
 '(org-special-keyword ((t (:inherit (font-lock-comment-face fixed-pitch)))))
 '(org-table ((t (:inherit fixed-pitch :foreground "#83a598"))))
 '(org-tag ((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
 '(org-verbatim ((t (:inherit (shadow fixed-pitch)))))
 '(preview-reference-face ((t (:background "#ebdbb2" :foreground "black")))))
(put 'upcase-region 'disabled nil)
