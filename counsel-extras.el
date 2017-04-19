;;; counsel-extras.el --- More friendly display transformer for ivy.

;; Package-Requires: ((emacs "24.4") (counsel "0.9.0"))
;; Keywords: counsel matching
;; Homepage: https://github.com/a13/counsel-extras

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Custom interactive functions for counsel

;;; Code:

(require 'counsel)

(defun counsel-extras-grep-or-isearch-or-swiper ()
  "Adaptive search using `swiper' or `counsel-grep' or `isearch-forward'."
  (interactive)
  (let ((big (> (buffer-size)
                (if (eq major-mode 'org-mode)
                    (/ counsel-grep-swiper-limit 4)
                  counsel-grep-swiper-limit))))
    (if big
        (let* ((bfn (buffer-file-name))
               (not-local (or (not bfn)
                              (buffer-narrowed-p)
                              (ignore-errors
                                (file-remote-p bfn))
                              (string-match
                               counsel-compressed-file-regex
                               bfn))))
          (if not-local
              (call-interactively #'isearch-forward)
            (progn
              (save-buffer)
              (counsel-grep))))
      (swiper--ivy (swiper--candidates)))))

(defun counsel-extras-xmms2-jump (do-not-play)
  "Jump to \"xmms2\" track and play it if DO-NOT-PLAY is not set."
  (interactive "p")
  (let ((cands
         (split-string
          (shell-command-to-string "xmms2 list") "\n" t)))
    (ivy-read "xmms2: " cands
              :action (lambda (x)
                        (string-match "^\s*\\(->\\)?\\[\\([0-9]+\\)/[0-9]+\\]\s+\\w+" x)
                        (let ((n (match-string 2 x)))
                          (call-process-shell-command
                           (format "xmms2 jump %s" n))
                          (unless do-not-play
                            (call-process-shell-command
                             "xmms2 play"))
                          (message x)))
              :caller 'counsel-xmms2)))

(provide 'counsel-extras)

;;; counsel-extras.el ends here.
