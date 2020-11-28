;; ------------------------------ Setting up ------------------------------

;; don't save custom variables
(setq custom-file (make-temp-file ""))

(setq make-backup-files nil        ; don't create backup~ files
      auto-save-default nil        ; don't create #autosave# files
      inhibit-startup-message t    ; don't show welcome screen
      ring-bell-function 'ignore   ; don't make beep sounds
      )

(fset 'yes-or-no-p 'y-or-n-p)
(setq initial-scratch-message "")

(progn ;; UTF-8
    (set-charset-priority 'unicode)
    (prefer-coding-system 'utf-8)
    (setq locale-coding-system 'utf-8)
    (set-language-environment 'utf-8)
    (set-default-coding-systems 'utf-8)
    ;; it modifies the buffer
    ;; (set-buffer-file-coding-system 'utf-8)
    ;; it requires flusing
    ;; (set-terminal-coding-system 'utf-8)
    (set-clipboard-coding-system 'utf-8)
    (set-file-name-coding-system 'utf-8)
    (set-keyboard-coding-system 'utf-8)
    (set-selection-coding-system 'utf-8)
    (modify-coding-system-alist 'process "*" 'utf-8))

(progn ;; Hide some builtin UI
    (menu-bar-mode -1)
    ;; GUI
    (scroll-bar-mode -1)
    (tool-bar-mode -1)
    (blink-cursor-mode -1))

(progn ;; Show more
    ;; show line numbers
    (global-display-line-numbers-mode)

    ;; highlight current line
    (global-hl-line-mode t)

    ;; show trailing whitespaces
    (setq-default show-trailing-whitespace t)

    (progn ;; show matching parentheses
        (setq-default show-paren-delay 0)
        (show-paren-mode 1))

    ;; show `line:column` in the modeline
    (column-number-mode))

;; [GUI]
(set-cursor-color "#8fee96")
(set-fringe-mode 10)

;; Scroll like Vim
(setq scroll-preserve-screen-position t  ; keep the cursor position when scrolling
      scroll-conservatively 100          ; scroll by lines, not by a half page
      scroll-margin 3                    ; scroll keeping the margins
      )

;; ------------------------------ Boostrapping ------------------------------

(progn ;; Package configuration
    (setq package-user-dir (concat user-emacs-directory "elpa")
          package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                             ("melpa" . "https://melpa.org/packages/")
                             ("cselpa" . "https://elpa.thecybershadow.net/packages/")))

    (setq use-package-always-ensure t
          use-package-expand-minimally t
          use-package-compute-statistics t
          use-package-enable-imenu-support t))

(progn ;; Boostrap `use-package`
    ;; initialize packages (only once)
    (unless (bound-and-true-p package--initialized)
        (setq package-enable-at-startup nil) (package-initialize))

    ;; install `use-package` if needed
    (unless (package-installed-p 'use-package)
        (package-refresh-contents)
        (package-install 'use-package))

    (require 'use-package) ;; to gather statistics, I guess we need the runtime after all
    (require 'bind-key)
    (use-package diminish :defer t))

;; ------------------------------ View settings ------------------------------

;; Color scheme in use
(use-package darkokai-theme
    :config (load-theme 'darkokai t))

;; ------------------------------ Evil ------------------------------

(use-package evil
    :init
    ;; do not bind `C-z` to `evil-emacs-state`
    (setq evil-toggle-key "")
    ;; configure
    (setq evil-want-C-u-delete t     ; use C-u for deleting in insert mode
          evil-want-C-u-scroll t     ; use C-u for scrolling in normal mode
          evil-want-Y-yank-to-eol t  ; map `Y` to `y$`
          evil-move-cursor-back t    ; move cursor back when exiting insert mode (like Vim)
          evil-search-module 'evil-search  ; `evil-search` seem to highlight better
          )
    :config
    (evil-mode 1))

(progn ;; Interactive commands
    ;; use `:ed` to open `init.el`
    (evil-ex-define-cmd "ed" (lambda () (interactive) (evil-edit (concat user-emacs-directory "init.el"))))
    ;; use `:s` to edit `init.el`
    (evil-ex-define-cmd "s" (lambda () (interactive) (load-file (concat user-emacs-directory "init.el"))))
    ;; close buffer (without closing window). alternative: `C-x k RET`
    (evil-ex-define-cmd "Bd" #'kill-this-buffer)
    (evil-ex-define-cmd "BD" #'kill-this-buffer)
    ;; horizontal split
    (evil-ex-define-cmd "hs" #'evil-split-buffer))

;; Enable redo with evil
(use-package undo-tree
    :init
    (evil-set-undo-system 'undo-tree)
    (global-undo-tree-mode))

(use-package evil-surround
    :config (global-evil-surround-mode))

(use-package expand-region
    :config
    (evil-define-key 'visual 'global
        "v" #'er/expand-region
        "V" #'er/contract-region))

;; ------------------------------ Help ------------------------------

(use-package which-key
    :init
    ;; a) show hints immediately
    (setq which-key-idle-delay 0.01
          which-key-idle-secondary-delay 0.01)
    ;; b) always press `C-h` to trigger which-key
    ;; (setq which-key-show-early-on-C-h t
    ;;       which-key-idle-delay 10000
    ;;       which-key-idle-secondary-delay 0.05)

    :config
    (define-key help-map (kbd "M") 'which-key-show-major-mode)
    (which-key-mode))

;; Improve *Help*
(use-package helpful
    :bind
    ([remap describe-command] . helpful-command)
    ([remap describe-key] . helpful-key)
    :init
    ;; press `q` or `<escape>` to quit (kill) the buffer
    (evil-define-key 'normal helpful-mode-map "q" #'kill-this-buffer)
    ;; press `K` to see the help!
    (evil-define-key 'normal 'global "K" #'helpful-at-point)
    )
;; ------------------------------ Terminal ------------------------------

;; If on terminal
(when (not (display-graphic-p))
    ;; Two exclusive options:
    ;; 1. use left click to move cursor:
    (xterm-mouse-mode 1)
    ;; 2. use left click to select (and copy):
    ;; (xterm-mouse-mode -1)

    ;; use mouse wheel for scrolling
    (global-set-key (kbd "<mouse-4>") 'scroll-down-line)
    (global-set-key (kbd "<mouse-5>") 'scroll-up-line))

;; [Terminal] Add command to copy to clipboard
(use-package clipetty
    :after evil
    :config
    ;; copy to system clipboard with `:copy`
    (evil-ex-define-cmd "copy" #'clipetty-kill-ring-save))

;; ------------------------------ Programming ------------------------------

(progn ;; ELisp
    (setq-default lisp-body-indent 4    ; I need this
                  indent-tabs-mode nil  ; don't whitespaces with TAB (overwrite it for, e.g., Makefile)
                  tab-width 4           ; display tab with a width of 4
                  )


    (use-package aggressive-indent
        :hook ((emacs-lisp-mode scheme-mode) . aggressive-indent-mode))

    ;; enable folding (`zr` to open all, `zm` to fold all, `za` to toggle)
    (add-hook 'emacs-lisp-mode-hook 'hs-minor-mode)
    )

