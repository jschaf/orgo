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

;;; Code:

(require 's)
(require 'dash)


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
       (goto-char old-point)))))

(defun orgo-publish-entry ()
  "Marks current entry as DONE and writes it to a file for Hugo."
  ;; check for subtree
  ;; get title
  ;; get content
  ;; convert to markdown
  ;; write file
 
  )



(provide 'orgo)
;;; orgo.el ends here
