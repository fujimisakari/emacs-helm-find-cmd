;;; helm-find-cmd.el --- execture find command with helm interface  -*- lexical-binding: t; -*-

;; Copyright (C) 2017 by Ryo Fujimoto

;; Author: Ryo Fujimoto <fujimisakri@gmail.com>
;; URL: https://github.com/fujimisakari/emacs-helm-find-cmd
;; Version: 1.0.0
;; Package-Requires: ((helm "1.5") (emacs "24"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; helm-find-cmd.el will be able to use find command through helm interface
;;

;; To use this package, add these lines to your init.el or .emacs file:
;;
;;  (require 'helm-find-cmd)
;;
;; ----------------------------------------------------------------
;;
;; Execute `find . -type f`
;; M-x helm-find-cmd-type-file
;;
;; Execute `find . -type d`
;; M-x helm-find-cmd-type-directory
;;

;;; Code:

(require 'helm)
(require 'helm-utils)

(defgroup helm-find-cmd nil
  "Use find command with helm interface"
  :group 'helm)

(defcustom helm-find-cmd-maximum-candidates 200
  "Maximum number of helm candidates"
  :type 'integer
  :group 'helm-find-cmd)

(defcustom helm-find-cmd-log-level -1
  "Logging level, only messages with level lower or equal will be logged.
-1 = NONE, 0 = ERROR, 1 = WARNING, 2 = INFO, 3 = DEBUG"
  :type 'integer
  :group 'helm-find-cmd)

(defconst helm-find-cmd--buffer "*helm find cmd*")

(defvar helm-find-cmd--current-type nil
  "type in use")

(defun helm-find-cmd-log (level text &rest args)
  "Log a message at level LEVEL.
If LEVEL is higher than `helm-find-cmd-log', the message is
ignored.  Otherwise, it is printed using `message'.
TEXT is a format control string, and the remaining arguments ARGS
are the string substitutions (see `format')."
  (if (<= level helm-find-cmd-log-level)
      (let* ((msg (apply 'format text args)))
        (message "%s" msg))))

(defun helm-find-cmd--construct-command ()
  (let* ((cmd "find")
         (path ".")
         (opt "-type")
         (ignore "| grep -v '\\.git'")
         (cmds (list cmd path opt helm-find-cmd--current-type ignore)))
    (mapconcat 'identity cmds " ")))

(defun helm-find-cmd--excecute-command (cmd-str)
  (let ((call-shell-command-fn 'shell-command-to-string))
    (helm-find-cmd-log 3 "shell command: %s" cmd-str)
    (funcall call-shell-command-fn cmd-str)))

(defun helm-find-cmd--get-candidates ()
  (let* ((ret (helm-find-cmd--excecute-command (helm-find-cmd--construct-command)))
         (candidates (split-string ret "\n")))
    candidates))

(defun helm-find-cmd--search-init ()
  (let ((buf-coding buffer-file-coding-system))
    (with-current-buffer (helm-candidate-buffer 'global)
      (let ((coding-system-for-read buf-coding)
            (coding-system-for-write buf-coding))
        (mapc (lambda (row) (insert (concat row "\n"))) (helm-find-cmd--get-candidates))))))

(defun helm-find-cmd--action (target-path)
  (helm-find-cmd-log 3 (format "target-path: %s" target-path))
  (find-file target-path))

(defvar helm-source-find-cmd
  (helm-build-in-buffer-source "helm find cmd"
    :init 'helm-find-cmd--search-init
    :candidate-number-limit helm-find-cmd-maximum-candidates
    :action 'helm-find-cmd--action))

;;;###autoload
(defun helm-find-cmd-type-file ()
  "execute `find . -type f`"
  (interactive)
  (setq helm-find-cmd--current-type "f")
  (helm :sources '(helm-source-find-cmd) :buffer helm-find-cmd--buffer))

;;;###autoload
(defun helm-find-cmd-type-directory ()
  "execute `find . -type d`"
  (interactive)
  (setq helm-find-cmd--current-type "d")
  (helm :sources '(helm-source-find-cmd) :buffer helm-find-cmd--buffer))

(provide 'helm-find-cmd)

;;; helm-find-cmd.el ends here
