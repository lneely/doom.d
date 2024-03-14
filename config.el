;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Levi Neely"
      user-mail-address "lkn@uber.space")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "Fira Code" :size 18 :weight 'regular))
;;doom-variable-pitch-font (font-spec :family "Fira Sans" :size 20))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-material)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(use-package all-the-icons
  :if (display-graphic-p))

(with-eval-after-load 'doom-themes
  (doom-themes-treemacs-config))

(setq deft-directory "~/Documents/notes")
(setq deft-default-extension "org")
(after! org
  (setq org-archive-location "%s_archive::datetree/")
  (setq org-stuck-projects
        '("+proj-done-hold-maybe/-DONE" ("STRT" "TODO") nil
          "SCHEDULED:\\|DEADLINE:"))
  (setq org-tags-exclude-from-inheritance '("proj"))
  (setq org-todo-keywords
        '((sequence "TODO(t)" "STRT(s)" "WAIT(w)" "HOLD(h)" "PROJ(p)" "|" "DONE(d)" "KILL(k)")
          (sequence "[ ](T)" "[-](S)" "[?](W)" "|" "[X](D)")))
  (setq org-agenda-todo-keywords
        '((sequence "TODO(t)" "STRT(s)" "WAIT(w)" "HOLD(h)" "PROJ(p)" "|" "DONE(d)" "KILL(k)")
          (sequence "[ ](T)" "[-](S)" "[?](W)" "|" "[X](D)")))
  (setq org-hide-leading-stars nil
        org-startup-indented nil)
  (setq org-mouse-1-follows-link nil)
  (setq org-agenda-custom-commands
        '(("n" "Next Actions"
           ((tags-todo "+@work-hold")
            (tags-todo "+@home-hold"))))))


(remove-hook 'org-mode-hook #'org-superstar-mode)
(setq focus-follows-mouse t)
(setq mouse-1-click-follows-link t)
(setq mouse-autoselect-window t)
(global-set-key [mouse-3] #'ffap-at-mouse)

(setq display-buffer-base-action '(display-buffer-below-selected))

(setq rcirc-server-alist
      '(("irc.sdf.org" :channels
         ("#sdf" "#anonradio")
         :port 6667 :encription tls)))

(setq fill-column 72)

;; ```
;;  find-file@with-line-number: advice for opening file at line number
;;  Copyright (C) 2022  Peter H. Mao
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License for more details.
;;
;;  You should have received a copy of the GNU General Public License
;;  along with this program.  If not, see <https://www.gnu.org/licenses/>.
;;;
;;; advice for find-file to open at line-number using <filename>:<line-number> format

(define-advice find-file (:around (proc filename &optional wildcards) with-line-number)
  "if format is <filename>:#, open file at line-number #"
  (let* (;; fap-<junk> deals with ffap stripping line numbers
         (fap (thing-at-point 'filename t))
         (fap-lino-idx (if fap (string-match ":[0-9]+$" fap)))
         (fap-line-num (if fap-lino-idx
                           (string-to-number (substring fap (1+ (match-beginning 0)) (match-end 0)))))
         (fap-name (if fap (expand-file-name (if fap-lino-idx (substring fap 0 fap-lino-idx) fap))))
         ;; fn-<junk> deals with the filename in the minibuffer
         (fn-lino-idx (string-match ":[0-9]+$" filename))
         (fn-line-num (if fn-lino-idx
                          (string-to-number (substring filename (1+ (match-beginning 0)) (match-end 0)))))
         (filename (if fn-lino-idx (substring filename 0 fn-lino-idx) filename))
         ;; pick out the right line number (fap- or fn-, which may have been edited by the user)
         (line-number (cond (;; the first condition is necessary becaue fn-line-num nil with
                             ;; fap-line-num non-nil would default to wrong line number
                             (not (equal filename fap-name)) fn-line-num)
                            (fn-line-num fn-line-num)   ; prefer user's line-num ...
                            (fap-line-num fap-line-num) ; ... over fap's line-num
                            (t nil)))                   ; no line numbers anywhere
         (res (apply proc filename '(wildcards)))) ; funcall also works with same syntax
    (when line-number
      (goto-char (point-min))
      (forward-line (1- line-number)))
    res))

;; eval below to deactivate:
;; (advice-remove 'find-file #'find-file@with-line-number)
(map! :after org
      :map org-mode-map
      :localleader
      "$" 'org-timestamp
      "%" 'org-timestamp-inactive)

(defun region-as-argument-to-command (cmd)
  (interactive "sCommand: ")
  (shell-command
   (format
    "%s %s"
    cmd
    (shell-quote-argument
     (buffer-substring (region-beginning)
                       (region-end))))))

(require 'wand)
(prefer-coding-system 'utf-8)

(setq word-wrap nil)
(defun buffer-file-name-with-line (&optional buffer)
  (replace-regexp-in-string ":Line " ":" (concat (buffer-file-name buffer) ":" (what-line) "\n")))

(defun show-file-name ()
  "Gets the name of the file the current buffer is based on."
  (interactive)
  (setq fpath (buffer-file-name-with-line (window-buffer (minibuffer-selected-window))))
  (with-current-buffer
      (get-buffer-create "temp")
    (insert fpath)))

(map!
 :leader
 "=" 'show-file-name)

(setq global-ligature-mode 1)


