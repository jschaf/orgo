;;; orgo.el --- Tools for developing a Org-Mode blog with Hugo -*- lexical-binding: t; -*-

;; Copyright (C) 2016 Joe Schafer

;; Author: Joe Schafer <joe@jschaf.com>
;; Maintainer: Joe Schafer <joe@jschaf.com>
;; Version: 0.01
;; Keywords: files, hypermedia, tools
;; URL: http://github.com/jschaf/orgo.el
;; Package-Requires: ((s "1.7.0") (dash "2.2.0"))

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;;; Code:

(require 'dash)
(require 'org)
(require 's)

(defun orgo-goto-nearest-publishable-parent ()
  "Go to first sub-tree with a TODO state and return `point'.
If there is no parent tree with a TODO state, return nil and
leave point unchanged."
  (let ((old-point (point)))
    (condition-case nil
        (progn
          (if (org-entry-get (point) "TODO" nil t)
              (org-backward-heading-same-level 0)
            (while (null (org-entry-get (point) "TODO" nil t))
              (outline-up-heading 1 t)))
          (point))
      (error
       (goto-char old-point)
       nil))))

(defun orgo-publishable-tree-p ()
  "Return t if in a publishable tree."
  (save-excursion
    (and (orgo-goto-nearest-publishable-parent) t)))

(defun orgo-validate-is-publishable ()
  "Check if we're in a publishable tree, otherwise error out."
  (unless (orgo-publishable-tree-p)
    (error "Not in an org tree that is publishable.  No parent
 tree is marked with a TODO state")))

(defun orgo-get-raw-entry-title ()
  "Get the title of the publishable entry."
  (orgo-validate-is-publishable)
  (save-excursion
    (orgo-goto-nearest-publishable-parent)
    (substring-no-properties (org-get-heading 'no-tags 'no-todo))))

(defun orgo-sanitize-file-name (name)
  "Make NAME safe for filenames.
Performs the following transformations:
1. downcases the string
2. removes any occurrence of parentheses including the content between
   the parenthesis
3. trims the result
4. transforms anything that's not alphanumeric into dashes"
  (require 'url-util)
  (require 'subr-x)
  (url-hexify-string
   (downcase
    (replace-regexp-in-string
     "[^[:alnum:]]+" "-"
     (s-trim
      (replace-regexp-in-string
       "(.*)" "" name))))))

(defun orgo-get-entry-title ()
  "Get the sanitized title of the publishable entry."
  (orgo-sanitize-file-name (orgo-get-raw-entry-title)))

(defun orgo-get-raw-entry-content ()
  "Get the string of the current publishable entry."
  (orgo-validate-is-publishable)
  (save-excursion
    (save-restriction
      (orgo-goto-nearest-publishable-parent)
      (org-narrow-to-subtree)
      (buffer-substring-no-properties (point-min) (point-max)))))

(defun orgo-get-front-matter ()
  "Return everything before the first headline in current buffer.
If there are no headlines, return the empty string."
  (save-excursion
    (goto-char (point-min))
    (if (search-forward-regexp "^\\*+ " nil t)
        (buffer-substring-no-properties (point-min) (match-beginning 0))
      "")))

(defun orgo-publish-entry ()
  "Mark current entry as DONE and write it to a file for Hugo."
  (orgo-validate-is-publishable)
  (let ((title (orgo-get-entry-title)))

    )
  ;; get content
  ;; convert to markdown
  ;; write file
  )



(provide 'orgo)
;;; orgo.el ends here
