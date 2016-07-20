;;; packages.el --- zilongshanren Layer packages File for Spacemacs
;;
;; Copyright (c) 2014-2016 zilongshanren
;;
;; Author: zilongshanren <guanghui8827@gmail.com>
;; URL: https://github.com/zilongshanren/spacemacs-private
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;; List of all packages to install and/or initialize. Built-in packages
;; which require an initialization must be listed explicitly in the list.

(setq zilongshanren-programming-packages
      '(
        css-mode
        lispy
        company
        cmake-font-lock
        cmake-mode
        flycheck
        markdown-mode
        impatient-mode
        swiper
        magit
        git-messenger
        nodejs-repl
        js2-mode
        js2-refactor
        visual-regexp
        visual-regexp-steroids
        json-mode
        racket-mode
        yasnippet
        find-file-in-project
        projectile
        web-mode
        (occur-mode :location built-in)
        (dired-mode :location built-in)
        js-doc
        (whitespace :location built-in)
        smartparens
        peep-dired
        (profiler :location built-in)
        flyspell-correct
        gist
        ))



(defun zilongshanren-programming/init-ag ()
  (use-package ag
    :init))

(defun zilongshanren-programming/post-init-flyspell-correct ()
  (progn
    (with-eval-after-load 'flyspell
      (define-key flyspell-mode-map (kbd "C-;") 'flyspell-correct-word-generic))
    (setq flyspell-correct-interface 'flyspell-correct-ivy)))

(defun zilongshanren-programming/init-profiler ()
  (use-package profiler
    :init
    (evilified-state-evilify profiler-report-mode profiler-report-mode-map)))

(defun zilongshanren-programming/post-init-gist ()
  (use-package gist
    :defer t
    :init
    (setq gist-list-format
      '((files "File" 30 nil "%s")
        (id "Id" 10 nil identity)
        (created "Created" 20 nil "%D %R")
        (visibility "Visibility" 10 nil
                    (lambda
                      (public)
                      (or
                       (and public "public")
                       "private")))
        (description "Description" 0 nil identity)))
    :config
    (progn
      (spacemacs|define-transient-state gist-list-mode
        :title "Gist-mode Transient State"
        :bindings
        ("k" gist-kill-current "delete gist")
        ("e" gist-edit-current-description "edit gist title")
        ("+" gist-add-buffer "add a file")
        ("-" gist-remove-file "delete a file")
        ("y" gist-print-current-url "print url")
        ("b" gist-browse-current-url "browse gist in browser")
        ("*" gist-star "star gist")
        ("^" gist-unstar "unstar gist")
        ("f" gist-fork "fork gist")
        ("q" nil "quit" :exit t)
        ("<escape>" nil nil :exit t))
      (spacemacs/set-leader-keys-for-major-mode 'gist-list-mode
        "." 'spacemacs/gist-list-mode-transient-state/body))
    ))


(defun zilongshanren-programming/init-peep-dired ()
  ;;preview files in dired
  (use-package peep-dired
    :defer t
    :commands (peep-dired-next-file
               peep-dired-prev-file)
    :bind (:map dired-mode-map
                ("P" . peep-dired))))

(defun zilongshanren-programming/post-init-smartparens ()
  (progn
    (defun wrap-sexp-with-new-round-parens ()
      (interactive)
      (insert "()")
      (backward-char)
      (sp-forward-slurp-sexp))

    (global-set-key (kbd "C-(") 'wrap-sexp-with-new-round-parens)

    (with-eval-after-load 'smartparens
      (evil-define-key 'normal sp-keymap
        (kbd ")>") 'sp-forward-slurp-sexp
        (kbd ")<") 'sp-forward-barf-sexp
        (kbd "(>") 'sp-backward-barf-sexp
        (kbd "(<") 'sp-backward-slurp-sexp))

    ))

(defun zilongshanren-programming/post-init-erc ()
  (progn
    (defun my-erc-hook (match-type nick message)
      "Shows a growl notification, when user's nick was mentioned. If the buffer is currently not visible, makes it sticky."
      (unless (posix-string-match "^\\** *Users on #" message)
        (zilongshanren/growl-notification
         (concat "ERC: : " (buffer-name (current-buffer)))
         message
         t
         )))

    (add-hook 'erc-text-matched-hook 'my-erc-hook)
    (spaceline-toggle-erc-track-off)))

(defun zilongshanren-programming/post-init-whitespace ()
  (progn
    ;; ;; http://emacsredux.com/blog/2013/05/31/highlight-lines-that-exceed-a-certain-length-limit/
    (setq whitespace-line-column fill-column) ;; limit line length
    ;;https://www.reddit.com/r/emacs/comments/2keh6u/show_tabs_and_trailing_whitespaces_only/
    (setq whitespace-display-mappings
          ;; all numbers are Unicode codepoint in decimal. try (insert-char 182 ) to see it
          '(
            (space-mark 32 [183] [46])           ; 32 SPACE, 183 MIDDLE DOT 「·」, 46 FULL STOP 「.」
            (newline-mark 10 [182 10])           ; 10 LINE FEED
            (tab-mark 9 [187 9] [9655 9] [92 9]) ; 9 TAB, 9655 WHITE RIGHT-POINTING TRIANGLE 「▷」
            ))
    (setq whitespace-style '(face tabs trailing tab-mark ))
    ;; (setq whitespace-style '(face lines-tail))
    ;; show tab;  use untabify to convert tab to whitespace
    (setq spacemacs-show-trailing-whitespace nil)

    (setq-default tab-width 4)
    ;; set-buffer-file-coding-system -> utf8 to convert dos to utf8
    ;; (setq inhibit-eol-conversion t)
    ;; (add-hook 'prog-mode-hook 'whitespace-mode)

    ;; (global-whitespace-mode +1)

    (with-eval-after-load 'whitespace
      (progn
        (set-face-attribute 'whitespace-tab nil
                            :background "#Adff2f"
                            :foreground "#00a8a8"
                            :weight 'bold)
        (set-face-attribute 'whitespace-trailing nil
                            :background "#e4eeff"
                            :foreground "#183bc8"
                            :weight 'normal)))

    (diminish 'whitespace-mode)))

(defun zilongshanren-programming/post-init-js-doc ()
  (setq js-doc-mail-address "guanghui8827@gmail.com"
        js-doc-author (format "Guanghui Qu <%s>" js-doc-mail-address)
        js-doc-url "http://www.zilongshanren.com"
        js-doc-license "MIT")

 (defun my-js-doc-insert-function-doc-snippet ()
    "Insert JsDoc style comment of the function with yasnippet."
    (interactive)

    (with-eval-after-load 'yasnippet
      (js-doc--beginning-of-defun)

      (let ((metadata (js-doc--function-doc-metadata))
            (field-count 1))
        (yas-expand-snippet
         (concat
          js-doc-top-line
          " * ${1:Function description.}\n"
          (format "* @method %s\n" (nth-value 1 (split-string (which-function) "\\.")))
          (mapconcat (lambda (param)
                       (format
                        " * @param {${%d:Type of %s}} %s - ${%d:Parameter description.}\n"
                        (incf field-count)
                        param
                        param
                        (incf field-count)))
                     (cdr (assoc 'params metadata))
                     "")
          (when (assoc 'returns metadata)
            (format
             " * @returns {${%d:Return Type}} ${%d:Return description.}\n"
             (incf field-count)
             (incf field-count)))
          (when (assoc 'throws metadata)
            (format
             " * @throws {${%d:Exception Type}} ${%d:Exception description.}\n"
             (incf field-count)
             (incf field-count)))
          js-doc-bottom-line)))))

          (add-hook 'js2-mode-hook
                  #'(lambda ()
                      (define-key js2-mode-map "\C-ci" 'my-js-doc-insert-function-doc-snippet)
                      (define-key js2-mode-map "@" 'js-doc-insert-tag))))

(defun zilongshanren-programming/init-dired-mode ()
  (use-package dired-mode
    :init
    (progn
      (require 'dired-x)
      (require 'dired-aux)
      (setq dired-listing-switches "-alh")
      (setq dired-guess-shell-alist-user
            '(("\\.pdf\\'" "open")
              ("\\.docx\\'" "open")
              ("\\.\\(?:djvu\\|eps\\)\\'" "open")
              ("\\.\\(?:jpg\\|jpeg\\|png\\|gif\\|xpm\\)\\'" "open")
              ("\\.\\(?:xcf\\)\\'" "open")
              ("\\.csv\\'" "open")
              ("\\.tex\\'" "open")
              ("\\.\\(?:mp4\\|mkv\\|avi\\|flv\\|ogv\\)\\(?:\\.part\\)?\\'"
               "open")
              ("\\.\\(?:mp3\\|flac\\)\\'" "open")
              ("\\.html?\\'" "open")
              ("\\.md\\'" "open")))

      ;; always delete and copy recursively
      (setq dired-recursive-deletes 'always)
      (setq dired-recursive-copies 'always)

      (defvar dired-filelist-cmd
        '(("vlc" "-L")))

      (defun dired-get-size ()
        (interactive)
        (let ((files (dired-get-marked-files)))
          (with-temp-buffer
            (apply 'call-process "/usr/bin/du" nil t nil "-sch" files)
            (message
             "Size of all marked files: %s"
             (progn
               (re-search-backward "\\(^[ 0-9.,]+[A-Za-z]+\\).*total$")
               (match-string 1))))))

      (defun dired-start-process (cmd &optional file-list)
        (interactive
         (let ((files (dired-get-marked-files
                       t current-prefix-arg)))
           (list
            (dired-read-shell-command "& on %s: "
                                      current-prefix-arg files)
            files)))
        (let (list-switch)
          (start-process
           cmd nil shell-file-name
           shell-command-switch
           (format
            "nohup 1>/dev/null 2>/dev/null %s \"%s\""
            (if (and (> (length file-list) 1)
                     (setq list-switch
                           (cadr (assoc cmd dired-filelist-cmd))))
                (format "%s %s" cmd list-switch)
              cmd)
            (mapconcat #'expand-file-name file-list "\" \"")))))

      (defun dired-open-term ()
        "Open an `ansi-term' that corresponds to current directory."
        (interactive)
        (let* ((current-dir (dired-current-directory))
               (buffer (if (get-buffer "*zshell*")
                           (switch-to-buffer "*zshell*")
                         (ansi-term "/bin/zsh" "zshell")))
               (proc (get-buffer-process buffer)))
          (term-send-string
           proc
           (if (file-remote-p current-dir)
               (let ((v (tramp-dissect-file-name current-dir t)))
                 (format "ssh %s@%s\n"
                         (aref v 1) (aref v 2)))
             (format "cd '%s'\n" current-dir)))))

      (defun dired-copy-file-here (file)
        (interactive "fCopy file: ")
        (copy-file file default-directory))

      ;;dired find alternate file in other buffer
      (defun my-dired-find-file ()
        "Open buffer in another window"
        (interactive)
        (let ((filename (dired-get-filename nil t)))
          (if (car (file-attributes filename))
              (dired-find-alternate-file)
            (dired-find-file-other-window))))

      ;; do command on all marked file in dired mode
      (defun zilongshanren/dired-do-command (command)
        "Run COMMAND on marked files. Any files not already open will be opened.
After this command has been run, any buffers it's modified will remain
open and unsaved."
        (interactive "CRun on marked files M-x ")
        (save-window-excursion
          (mapc (lambda (filename)
                  (find-file filename)
                  (call-interactively command))
                (dired-get-marked-files))))

      (defun zilongshanren/dired-up-directory()
        "goto up directory and resue buffer"
        (interactive)
        (find-alternate-file ".."))

      (evilified-state-evilify-map dired-mode-map
        :mode dired-mode
        :bindings
        (kbd "C-k") 'zilongshanren/dired-up-directory
        "<RET>" 'dired-find-alternate-file
        "E" 'dired-toggle-read-only
        "C" 'dired-do-copy
        "<mouse-2>" 'my-dired-find-file
        "`" 'dired-open-term
        "p" 'peep-dired-prev-file
        "n" 'peep-dired-next-file
        "z" 'dired-get-size
        "c" 'dired-copy-file-here
        ")" 'dired-omit-mode)
      )
    :defer t
    )
  )

(defun zilongshanren-programming/init-occur-mode ()
  (defun occur-non-ascii ()
    "Find any non-ascii characters in the current buffer."
    (interactive)
    (occur "[^[:ascii:]]"))

  (defun occur-dwim ()
    "Call `occur' with a sane default."
    (interactive)
    (push (if (region-active-p)
              (buffer-substring-no-properties
               (region-beginning)
               (region-end))
            (let ((sym (thing-at-point 'symbol)))
              (when (stringp sym)
                (regexp-quote sym))))
          regexp-history)
    (deactivate-mark)
    (call-interactively 'occur))
  (bind-key* "M-s o" 'occur-dwim)
  (spacemacs/set-leader-keys "od" 'occur-dwim)
  (evilified-state-evilify occur-mode occur-mode-map
    "RET" 'occur-mode-goto-occurrence))

(defun zilongshanren-programming/init-beacon ()
  (use-package beacon
    :init
    (progn
      (spacemacs|add-toggle beacon
        :status beacon-mode
        :on (beacon-mode)
        :off (beacon-mode -1)
        :documentation "Enable point highlighting after scrolling"
        :evil-leader "otb")

      (spacemacs/toggle-beacon-on))
    :config (spacemacs|hide-lighter beacon-mode)))

(defun zilongshanren-programming/init-evil-vimish-fold ()
  (use-package evil-vimish-fold
    :init
    (vimish-fold-global-mode 1)
    :config
    (progn
      (define-key evil-normal-state-map (kbd "zf") 'vimish-fold)
      (define-key evil-visual-state-map (kbd "zf") 'vimish-fold)
      (define-key evil-normal-state-map (kbd "zd") 'vimish-fold-delete)
      (define-key evil-normal-state-map (kbd "za") 'vimish-fold-toggle))))

(defun zilongshanren-programming/init-ctags-update ()
  (use-package ctags-update
    :init
    (progn
      ;; (add-hook 'js2-mode-hook 'turn-on-ctags-auto-update-mode)
      )
    :defer t
    :config
    (spacemacs|hide-lighter ctags-auto-update-mode)))

;; nodejs-repl is much better now.
;; (defun zilongshanren-programming/init-js-comint ()
;;   (use-package js-comint
;;     :init
;;     (progn
;;       ;; http://stackoverflow.com/questions/13862471/using-node-js-with-js-comint-in-emacs
;;       (setq inferior-js-mode-hook
;;             (lambda ()
;;               ;; We like nice colors
;;               (ansi-color-for-comint-mode-on)
;;               ;; Deal with some prompt nonsense
;;               (add-to-list
;;                'comint-preoutput-filter-functions
;;                (lambda (output)
;;                  (replace-regexp-in-string "\033\\[[0-9]+[GKJ]" "" output)))))
;;       (setq inferior-js-program-command "node"))))

(defun zilongshanren-programming/post-init-web-mode ()
  (setq company-backends-web-mode '((company-dabbrev-code
                                     company-keywords
                                     company-etags)
                                    company-files company-dabbrev)))



(defun zilongshanren-programming/init-wrap-region ()
  (use-package wrap-region
    :init
    (progn
      (wrap-region-global-mode t)
      (wrap-region-add-wrappers
       '(("$" "$")
         ("{-" "-}" "#")
         ("/" "/" nil ruby-mode)
         ("/* " " */" "#" (java-mode javascript-mode css-mode js2-mode))
         ("`" "`" nil (markdown-mode ruby-mode))))
      (add-to-list 'wrap-region-except-modes 'dired-mode)
      (add-to-list 'wrap-region-except-modes 'web-mode)
      )
    :defer t
    :config
    (spacemacs|hide-lighter wrap-region-mode)))

(defun zilongshanren-programming/post-init-projectile ()
  (with-eval-after-load 'projectile
    (progn
      (setq projectile-completion-system 'ivy)
      (add-to-list 'projectile-other-file-alist '("html" "js")) ;; switch from html -> js
      (add-to-list 'projectile-other-file-alist '("js" "html")) ;; switch from js -> html
      )))

;; spacemacs distribution disabled this package, because it has overlay bug.
;; I hack the implementation here. on default, the hl-highlight-mode is disabled.
(defun zilongshanren-programming/post-init-hl-anything ()
  (progn
    (hl-highlight-mode -1)
    (spacemacs|add-toggle toggle-hl-anything
      :status hl-highlight-mode
      :on (hl-highlight-mode)
      :off (hl-highlight-mode -1)
      :documentation "Toggle highlight anything mode."
      :evil-leader "ths")))

(defun zilongshanren-programming/init-find-file-in-project ()
  (use-package find-file-in-project
    :defer t
    :init))


(defun zilongshanren-programming/post-init-yasnippet ()
  (progn
    (set-face-background 'secondary-selection "gray")
    (setq-default yas-prompt-functions '(yas-ido-prompt yas-dropdown-prompt))
    (mapc #'(lambda (hook) (remove-hook hook 'spacemacs/load-yasnippet)) '(prog-mode-hook
                                                                      org-mode-hook
                                                                      markdown-mode-hook))
    (defun zilongshanren/load-yasnippet ()
      (interactive)
      (unless yas-global-mode
        (progn
          (yas-global-mode 1)
          (setq my-snippet-dir (expand-file-name "~/.spacemacs.d/snippets"))
          (setq yas-snippet-dirs  my-snippet-dir)
          (yas-load-directory my-snippet-dir)
          (setq yas-wrap-around-region t)))
      (yas-minor-mode 1))

    (spacemacs/add-to-hooks 'zilongshanren/load-yasnippet '(prog-mode-hook
                                                            markdown-mode-hook
                                                            org-mode-hook))
    ))

(defun zilongshanren-programming/post-init-racket-mode ()
  (progn
    (eval-after-load 'racket-repl-mode
      '(progn
         (define-key racket-repl-mode-map (kbd "]") nil)
         (define-key racket-repl-mode-map (kbd "[") nil)))

    (add-hook 'racket-mode-hook (lambda () (lispy-mode 1)))
    (add-hook 'racket-repl-mode-hook #'(lambda () (lispy-mode t)))
    (add-hook 'racket-repl-mode-hook #'(lambda () (smartparens-mode t)))
    ))

(defun zilongshanren-programming/post-init-json-mode ()
  (add-to-list 'auto-mode-alist '("\\.tern-project\\'" . json-mode)))



(defun zilongshanren-programming/init-visual-regexp-steroids ()
  (use-package visual-regexp-steroids
    :commands (vr/select-replace vr/select-query-replace)))

(defun zilongshanren-programming/init-visual-regexp ()
  (use-package visual-regexp
    :commands (vr/replace vr/query-replace)))

(defun zilongshanren-programming/init-nodejs-repl ()
  (use-package nodejs-repl
    :init
    :defer t))

(defun zilongshanren-programming/init-flycheck-package ()
  (use-package flycheck-package))

(defun zilongshanren-programming/init-lispy ()
  "Initialize lispy"
  (use-package lispy
    :defer t
    :diminish (lispy-mode)
    :init
    (progn
      (add-hook 'emacs-lisp-mode-hook (lambda () (lispy-mode 1)))
      (add-hook 'ielm-mode-hook (lambda () (lispy-mode 1)))
      (add-hook 'inferior-emacs-lisp-mode-hook (lambda () (lispy-mode 1)))
      ;; (add-hook 'spacemacs-mode-hook (lambda () (lispy-mode 1)))
      (add-hook 'clojure-mode-hook (lambda () (lispy-mode 1)))
      (add-hook 'scheme-mode-hook (lambda () (lispy-mode 1)))
      (add-hook 'cider-repl-mode-hook (lambda () (lispy-mode 1))))))


(defun zilongshanren-programming/post-init-company ()
  (progn
    (setq company-minimum-prefix-length 1
          company-idle-delay 0.08)

    (when (configuration-layer/package-usedp 'company)
      (spacemacs|add-company-hook shell-script-mode)
      (spacemacs|add-company-hook makefile-bsdmake-mode)
      (spacemacs|add-company-hook sh-mode)
      (spacemacs|add-company-hook lua-mode)
      (spacemacs|add-company-hook nxml-mode)
      (spacemacs|add-company-hook conf-unix-mode)
      )
    ))

(defun zilongshanren-programming/init-cmake-font-lock ()
  (use-package cmake-font-lock
    :defer t))

(defun zilongshanren-programming/init-google-c-style ()
  (use-package google-c-style
    :init (add-hook 'c-mode-common-hook 'google-set-c-style)))

(defun zilongshanren-programming/post-init-cmake-mode ()
  (progn
    (spacemacs/declare-prefix-for-mode 'cmake-mode
                                       "mh" "docs")
    (spacemacs/set-leader-keys-for-major-mode 'cmake-mode
      "hd" 'cmake-help)
    (defun cmake-rename-buffer ()
      "Renames a CMakeLists.txt buffer to cmake-<directory name>."
      (interactive)
      (when (and (buffer-file-name)
                 (string-match "CMakeLists.txt" (buffer-name)))
        (setq parent-dir (file-name-nondirectory
                          (directory-file-name
                           (file-name-directory (buffer-file-name)))))
        (setq new-buffer-name (concat "cmake-" parent-dir))
        (rename-buffer new-buffer-name t)))

    (add-hook 'cmake-mode-hook (function cmake-rename-buffer))))


(defun zilongshanren-programming/post-init-flycheck ()
  (with-eval-after-load 'flycheck
    (progn
      ;; (setq flycheck-display-errors-function 'flycheck-display-error-messages)
      (setq flycheck-display-errors-delay 0.2)
      ;; (remove-hook 'c-mode-hook 'flycheck-mode)
      ;; (remove-hook 'c++-mode-hook 'flycheck-mode)
      )))

;; configs for writing
(defun zilongshanren-programming/post-init-markdown-mode ()
  (progn
    (add-to-list 'auto-mode-alist '("\\.mdown\\'" . markdown-mode))

    (with-eval-after-load 'markdown-mode
      (progn
        ;; (when (configuration-layer/package-usedp 'company)
        ;;   (spacemacs|add-company-hook markdown-mode))

        (defun zilongshanren/markdown-to-html ()
          (interactive)
          (start-process "grip" "*gfm-to-html*" "grip" (buffer-file-name) "5000")
          (browse-url (format "http://localhost:5000/%s.%s" (file-name-base) (file-name-extension (buffer-file-name)))))

        (spacemacs/set-leader-keys-for-major-mode 'gfm-mode-map
          "p" 'zilongshanren/markdown-to-html)
        (spacemacs/set-leader-keys-for-major-mode 'markdown-mode
          "p" 'zilongshanren/markdown-to-html)

        (evil-define-key 'normal markdown-mode-map (kbd "TAB") 'markdown-cycle)
        ))
    ))

(defun zilongshanren-programming/init-impatient-mode ()
  "Initialize impatient mode"
  (use-package impatient-mode
    :init
    (progn

      (defun zilongshanren-mode-hook ()
        "my web mode hook for HTML REPL"
        (interactive)
        (impatient-mode)
        (spacemacs|hide-lighter impatient-mode)
        (httpd-start))

      (add-hook 'web-mode-hook 'zilongshanren-mode-hook)
      (spacemacs/set-leader-keys-for-major-mode 'web-mode
        "p" 'imp-visit-buffer)
      )))


(defun zilongshanren-programming/init-keyfreq ()
  (use-package keyfreq
    :init
    (progn
      (keyfreq-mode t)
      (keyfreq-autosave-mode 1))))

(defun zilongshanren-programming/post-init-swiper ()
  "Initialize my package"
  (progn
    (defun my-swiper-search (p)
      (interactive "P")
      (let ((current-prefix-arg nil))
        (call-interactively
         (if p #'spacemacs/swiper-region-or-symbol
           #'swiper))))

    (setq ivy-use-virtual-buffers t)
    (setq ivy-display-style 'fancy)
    (use-package recentf
      :config
      (setq recentf-exclude
            '("COMMIT_MSG" "COMMIT_EDITMSG" "github.*txt$"
              ".*png$"))
      (setq recentf-max-saved-items 60))
    (evilified-state-evilify ivy-occur-mode ivy-occur-mode-map)

    (use-package ivy
      :defer t
      :config
      (progn
        (spacemacs|hide-lighter ivy-mode)

        (defun ivy-insert-action (x)
          (with-ivy-window
            (insert x)))

        (defun ivy-ff-checksum ()
          (interactive)
          "Calculate the checksum of FILE. The checksum is copied to kill-ring."
          (let ((file (expand-file-name ivy--current ivy--directory))
                (algo (intern (ivy-read
                               "Algorithm: "
                               '(md5 sha1 sha224 sha256 sha384 sha512)))))
            (kill-new (with-temp-buffer
                        (insert-file-contents-literally file)
                        (secure-hash algo (current-buffer))))
            (message "Checksum copied to kill-ring.")))

        (ivy-set-actions
         t
         '(("I" ivy-insert-action "insert")))

        ;; http://blog.binchen.org/posts/use-ivy-to-open-recent-directories.html
        (defun counsel-goto-recent-directory ()
          "Recent directories"
          (interactive)
          (unless recentf-mode (recentf-mode 1))
          (let ((collection
                 (delete-dups
                  (append (mapcar 'file-name-directory recentf-list)
                          ;; fasd history
                          (if (executable-find "fasd")
                              (split-string (shell-command-to-string "fasd -ld") "\n" t))))))
            (ivy-read "directories:" collection
                      :action 'dired
                      :caller 'counsel-goto-recent-directory)))
        (spacemacs/set-leader-keys "fad" 'counsel-goto-recent-directory)

        (setq ivy-initial-inputs-alist nil)

        (when (not (configuration-layer/layer-usedp 'helm))
          (spacemacs/set-leader-keys "sp" 'counsel-git-grep)
          (spacemacs/set-leader-keys "sP" 'spacemacs/counsel-git-grep-region-or-symbol))
        (define-key ivy-minibuffer-map (kbd "C-c o") 'ivy-occur)
        (define-key ivy-minibuffer-map (kbd "TAB") 'ivy-call)
        (define-key ivy-minibuffer-map (kbd "C-s-m") 'ivy-partial-or-done)
        (define-key ivy-minibuffer-map (kbd "C-c s") 'ivy-ff-checksum)
        (define-key ivy-minibuffer-map (kbd "s-o") 'ivy-dispatching-done)
        (define-key ivy-minibuffer-map (kbd "C-c C-e") 'counsel-git-grep-query-replace)
        (define-key ivy-minibuffer-map (kbd "<f3>") 'ivy-occur)
        (define-key ivy-minibuffer-map (kbd "C-s-j") 'ivy-immediate-done)
        (define-key ivy-minibuffer-map (kbd "C-j") 'ivy-next-line)
        (define-key ivy-minibuffer-map (kbd "C-k") 'ivy-previous-line)))

    (define-key global-map (kbd "C-s") 'my-swiper-search)
    ))


(defun zilongshanren-programming/post-init-magit ()
  (progn
    (with-eval-after-load 'magit
      (progn
        (add-to-list 'magit-no-confirm 'stage-all-changes)
        (define-key magit-log-mode-map (kbd "W") 'magit-copy-section-value)
        (define-key magit-status-mode-map (kbd "s-1") 'magit-jump-to-unstaged)
        (define-key magit-status-mode-map (kbd "s-2") 'magit-jump-to-untracked)
        (define-key magit-status-mode-map (kbd "s-3") 'magit-jump-to-staged)
        (define-key magit-status-mode-map (kbd "s-4") 'magit-jump-to-stashes)
        (setq magit-completing-read-function 'magit-builtin-completing-read)

        ;; http://emacs.stackexchange.com/questions/6021/change-a-branchs-upstream-with-magit/6023#6023
        (magit-define-popup-switch 'magit-push-popup ?u
          "Set upstream" "--set-upstream")
        ;; (define-key magit-status-mode-map (kbd "q") 'magit-quit-session)
        ;; (add-hook 'magit-section-set-visibility-hook '(lambda (section) (let ((section-type (magit-section-type section)))
        ;;                                                              (if (or (eq 'untracked section-type)
        ;;                                                                      (eq 'stashes section-type))
        ;;                                                                  'hide))))
        ))

    ;; Githu PR settings
    ;; "http://endlessparentheses.com/create-github-prs-from-emacs-with-magit.html"
    (setq magit-repository-directories '("~/cocos2d-x/"))
    (setq magit-push-always-verify nil)


    (defun zilongshanren/magit-visit-pull-request ()
      "Visit the current branch's PR on GitHub."
      (interactive)
      (let ((remote-branch (magit-get-current-branch)))
        (cond
         ((null remote-branch)
          (message "No remote branch"))
         (t
          (browse-url
           (format "https://github.com/%s/pull/new/%s"
                   (replace-regexp-in-string
                    "\\`.+github\\.com:\\(.+\\)\\.git\\'" "\\1"
                    (magit-get "remote"
                               (magit-get-remote)
                               "url"))
                   remote-branch))))))

    (eval-after-load 'magit
      '(define-key magit-mode-map (kbd "C-c g")
         #'zilongshanren/magit-visit-pull-request))

    (setq magit-process-popup-time 10)))

(defun zilongshanren-programming/post-init-git-messenger ()
  (use-package git-messenger
    :defer t
    :config
    (progn
      (defun zilong/github-browse-commit ()
        "Show the GitHub page for the current commit."
        (interactive)
        (use-package github-browse-file
          :commands (github-browse-file--relative-url))

        (let* ((commit git-messenger:last-commit-id)
               (url (concat "https://github.com/"
                            (github-browse-file--relative-url)
                            "/commit/"
                            commit)))
          (github-browse--save-and-view url)
          (git-messenger:popup-close)))

      (define-key git-messenger-map (kbd "f") 'zilong/github-browse-commit))))


(defun zilongshanren-programming/post-init-js2-refactor ()
  (progn
    (spacemacs/set-leader-keys-for-major-mode 'js2-mode
      "r>" 'js2r-forward-slurp
      "r<" 'js2r-forward-barf)))

(defun zilongshanren-programming/post-init-js2-mode ()
  (progn
    ;; http://blog.binchen.org/posts/use-which-func-mode-with-js2-mode.html
    (defun my-which-function ()
      ;; clean the imenu cache
      ;; @see http://stackoverflow.com/questions/13426564/how-to-force-a-rescan-in-imenu-by-a-function
      (setq imenu--index-alist nil)
      (which-function))

    (add-hook 'js2-mode-hook 'which-function-mode)

    (spacemacs/declare-prefix-for-mode 'js2-mode "ms" "repl")



    (with-eval-after-load 'js2-mode
      (progn
        ;; these mode related variables must be in eval-after-load
        ;; https://github.com/magnars/.emacs.d/blob/master/settings/setup-js2-mode.el
        (setq-default js2-allow-rhino-new-expr-initializer nil)
        (setq-default js2-auto-indent-p nil)
        (setq-default js2-enter-indents-newline nil)
        (setq-default js2-global-externs '("module" "require" "buster" "sinon" "assert" "refute" "setTimeout" "clearTimeout" "setInterval" "clearInterval" "location" "__dirname" "console" "JSON"))
        (setq-default js2-idle-timer-delay 0.2)
        (setq-default js2-mirror-mode nil)
        (setq-default js2-strict-inconsistent-return-warning nil)
        (setq-default js2-include-rhino-externs nil)
        (setq-default js2-include-gears-externs nil)
        (setq-default js2-concat-multiline-strings 'eol)
        (setq-default js2-rebind-eol-bol-keys nil)
        (setq-default js2-auto-indent-p t)

        (setq-default js2-bounce-indent nil)
        (setq-default js-indent-level 4)
        (setq-default js2-basic-offset 4)
        (setq-default js2-indent-switch-body t)
        ;; Let flycheck handle parse errors
        ;; (setq-default js2-mode-show-parse-errors nil)
        ;; (setq-default js2-mode-show-strict-warnings nil)
        (setq-default js2-highlight-external-variables t)
        (setq-default js2-strict-trailing-comma-warning nil)

        (defun my-web-mode-indent-setup ()
          (setq web-mode-markup-indent-offset 2) ; web-mode, html tag in html file
          (setq web-mode-css-indent-offset 2)    ; web-mode, css in html file
          (setq web-mode-code-indent-offset 2) ; web-mode, js code in html file
          )

        (add-hook 'web-mode-hook 'my-web-mode-indent-setup)

        (defun my-toggle-web-indent ()
          (interactive)
          ;; web development
          (if (or (eq major-mode 'js-mode) (eq major-mode 'js2-mode))
              (progn
                (setq js-indent-level (if (= js-indent-level 2) 4 2))
                (setq js2-basic-offset (if (= js2-basic-offset 2) 4 2))))

          (if (eq major-mode 'web-mode)
              (progn (setq web-mode-markup-indent-offset (if (= web-mode-markup-indent-offset 2) 4 2))
                     (setq web-mode-css-indent-offset (if (= web-mode-css-indent-offset 2) 4 2))
                     (setq web-mode-code-indent-offset (if (= web-mode-code-indent-offset 2) 4 2))))
          (if (eq major-mode 'css-mode)
              (setq css-indent-offset (if (= css-indent-offset 2) 4 2)))

          (setq indent-tabs-mode nil))


        (spacemacs/set-leader-keys-for-major-mode 'js2-mode
          "oi" 'my-toggle-web-indent)
        (spacemacs/set-leader-keys-for-major-mode 'js-mode
          "oi" 'my-toggle-web-indent)
        (spacemacs/set-leader-keys-for-major-mode 'web-mode
          "oi" 'my-toggle-web-indent)
        (spacemacs/set-leader-keys-for-major-mode 'css-mode
          "oi" 'my-toggle-web-indent)

        (spacemacs/declare-prefix-for-mode 'js2-mode "mo" "toggle")
        (spacemacs/declare-prefix-for-mode 'js-mode "mo" "toggle")
        (spacemacs/declare-prefix-for-mode 'web-mode "mo" "toggle")
        (spacemacs/declare-prefix-for-mode 'css-mode "mo" "toggle")

        (autoload 'flycheck-get-checker-for-buffer "flycheck")
        (defun sanityinc/disable-js2-checks-if-flycheck-active ()
          (unless (flycheck-get-checker-for-buffer)
            (set (make-local-variable 'js2-mode-show-parse-errors) t)
            (set (make-local-variable 'js2-mode-show-strict-warnings) t)))
        (add-hook 'js2-mode-hook 'sanityinc/disable-js2-checks-if-flycheck-active)
        (eval-after-load 'tern-mode
          '(spacemacs|hide-lighter tern-mode))
        ))

    (evilified-state-evilify js2-error-buffer-mode js2-error-buffer-mode-map)


    (defun js2-imenu-make-index ()
      (interactive)
      (save-excursion
        ;; (setq imenu-generic-expression '((nil "describe\\(\"\\(.+\\)\"" 1)))
        (imenu--generic-function '(("describe" "\\s-*describe\\s-*(\\s-*[\"']\\(.+\\)[\"']\\s-*,.*" 1)
                                   ("it" "\\s-*it\\s-*(\\s-*[\"']\\(.+\\)[\"']\\s-*,.*" 1)
                                   ("test" "\\s-*test\\s-*(\\s-*[\"']\\(.+\\)[\"']\\s-*,.*" 1)
                                   ("before" "\\s-*before\\s-*(\\s-*[\"']\\(.+\\)[\"']\\s-*,.*" 1)
                                   ("after" "\\s-*after\\s-*(\\s-*[\"']\\(.+\\)[\"']\\s-*,.*" 1)
                                   ("Controller" "[. \t]controller([ \t]*['\"]\\([^'\"]+\\)" 1)
                                   ("Controller" "[. \t]controllerAs:[ \t]*['\"]\\([^'\"]+\\)" 1)
                                   ("Filter" "[. \t]filter([ \t]*['\"]\\([^'\"]+\\)" 1)
                                   ("State" "[. \t]state([ \t]*['\"]\\([^'\"]+\\)" 1)
                                   ("Factory" "[. \t]factory([ \t]*['\"]\\([^'\"]+\\)" 1)
                                   ("Service" "[. \t]service([ \t]*['\"]\\([^'\"]+\\)" 1)
                                   ("Module" "[. \t]module([ \t]*['\"]\\([a-zA-Z0-9_\.]+\\)" 1)
                                   ("ngRoute" "[. \t]when(\\(['\"][a-zA-Z0-9_\/]+['\"]\\)" 1)
                                   ("Directive" "[. \t]directive([ \t]*['\"]\\([^'\"]+\\)" 1)
                                   ("Event" "[. \t]\$on([ \t]*['\"]\\([^'\"]+\\)" 1)
                                   ("Config" "[. \t]config([ \t]*function *( *\\([^\)]+\\)" 1)
                                   ("Config" "[. \t]config([ \t]*\\[ *['\"]\\([^'\"]+\\)" 1)
                                   ("OnChange" "[ \t]*\$(['\"]\\([^'\"]*\\)['\"]).*\.change *( *function" 1)
                                   ("OnClick" "[ \t]*\$([ \t]*['\"]\\([^'\"]*\\)['\"]).*\.click *( *function" 1)
                                   ("Watch" "[. \t]\$watch( *['\"]\\([^'\"]+\\)" 1)
                                   ("Function" "function[ \t]+\\([a-zA-Z0-9_$.]+\\)[ \t]*(" 1)
                                   ("Function" "^[ \t]*\\([a-zA-Z0-9_$.]+\\)[ \t]*=[ \t]*function[ \t]*(" 1)
                                   ("Function" "^var[ \t]*\\([a-zA-Z0-9_$.]+\\)[ \t]*=[ \t]*function[ \t]*(" 1)
                                   ("Function" "^[ \t]*\\([a-zA-Z0-9_$.]+\\)[ \t]*()[ \t]*{" 1)
                                   ("Function" "^[ \t]*\\([a-zA-Z0-9_$.]+\\)[ \t]*:[ \t]*function[ \t]*(" 1)
                                   ("Class" "^[ \t]*var[ \t]*\\([0-9a-zA-Z]+\\)[ \t]*=[ \t]*\\([a-zA-Z]*\\).extend" 1)
                                   ("Class" "^[ \t]*cc\.\\(.+\\)[ \t]*=[ \t]*cc\.\\(.+\\)\.extend" 1)
                                   ("Task" "[. \t]task([ \t]*['\"]\\([^'\"]+\\)" 1)))))

    (add-hook 'js2-mode-hook
              (lambda ()
                (setq imenu-create-index-function 'js2-imenu-make-index)))
    ))

(defun zilongshanren-programming/post-init-css-mode ()
  (progn
    (dolist (hook '(css-mode-hook sass-mode-hook less-mode-hook))
      (add-hook hook 'rainbow-mode))

    (defun css-imenu-make-index ()
      (save-excursion
        (imenu--generic-function '((nil "^ *\\([^ ]+\\) *{ *$" 1)))))

    (add-hook 'css-mode-hook
              (lambda ()
                (setq imenu-create-index-function 'css-imenu-make-index)))))

(defun zilongshanren-programming/post-init-tagedit ()
  (add-hook 'web-mode-hook (lambda () (tagedit-mode 1))))

;; For each extension, define a function zilongshanren/init-<extension-name>
;;
(defun zilongshanren-programming/init-doxymacs ()
  "Initialize doxymacs"
  (use-package doxymacs
    :init
    (add-hook 'c-mode-common-hook 'doxymacs-mode)
    :config
    (progn
      (defun my-doxymacs-font-lock-hook ()
        (if (or (eq major-mode 'c-mode) (eq major-mode 'c++-mode))
            (doxymacs-font-lock)))
      (add-hook 'font-lock-mode-hook 'my-doxymacs-font-lock-hook)
      (spacemacs|hide-lighter doxymacs-mode))))

;; https://atlanis.net/blog/posts/nodejs-repl-eval.html
(defun zilongshanren-programming/init-nodejs-repl-eval ()
  (use-package nodejs-repl-eval
    :commands (nodejs-repl-eval-buffer nodejs-repl-eval-dwim nodejs-repl-eval-function)
    :init
    :defer t
    ))
