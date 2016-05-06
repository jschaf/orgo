;;; orgo-test.el --- test for orgo -*- lexical-binding: t -*-

;;; Commentary:

;; Tests for orgo.el functionality.

;;; Code:

(defvar orgo-test/test-path
  (directory-file-name (file-name-directory load-file-name))
  "Path to tests directory.")

(defvar orgo-test/root-path
  (directory-file-name (file-name-directory orgo-test/test-path))
  "Path to root directory.")

(load (expand-file-name "orgo" orgo-test/root-path) 'noerror 'nomessage)

(require 'ert)
(require 's)

(defvar orgo/cursor-placeholder "-!-"
  "Representation of a cursor in a buffer.")

(defmacro orgo-test/with-mock-buffer (str &rest body)
  "Create buffer with STR and run BODY."
  (declare (indent 1))
  `(with-temp-buffer
     (insert ,str)
     (goto-char (point-min))
     (org-mode)
     (if (search-forward orgo/cursor-placeholder nil t)
         (progn
           (replace-match "")
           (goto-char (match-beginning 0)))
       (goto-char (point-min)))
     ,@body))

(defvar orgo-test/new-point-placeholder "<^>"
  "The placeholder indicating where the new point should be.")

(defun orgo-test/assert-point-changes (buffer-string function &rest args)
  "Assert that BUFFER-STRING match what FUNCTION does.
ARGS are the arguments to FUNCTION."
  (unless (s-contains? orgo-test/new-point-placeholder buffer-string)
    (error "The buffer-string must contain <!> to indicate the
    new point location"))

  (let ((new-point-position
         ;; Add 1 because buffers start at 1, but strings start at 0
         (1+ (caar (s-matched-positions-all
                    "<^>"
                    buffer-string))))
        (clean-buffer-string (s-replace "<^>" "" buffer-string)))
    (orgo-test/with-mock-buffer clean-buffer-string
      (apply function args)
      (should (equal new-point-position (point))))))

(ert-deftest orgo-test/goto-nearest-publishable-parent ()
  "Assert that the point moves to the nearest TODO header."
  (orgo-test/assert-point-changes
   "<^>* TODO header 1
-!-"
   #'orgo-goto-nearest-publishable-parent)
  (orgo-test/assert-point-changes
   "<^>* TODO header 1

** header 2
-!-"
   #'orgo-goto-nearest-publishable-parent))

(ert-deftest orgo-test/goto-nearest-publishable-parent-nil ()
  "Assert that the point doesn't change if there is no TODO
  handler post to move to."
  (orgo-test/assert-point-changes
   "<^>-!-"
   #'orgo-goto-nearest-publishable-parent)
  (orgo-test/assert-point-changes
   "* not a post header<^>-!-"
   #'orgo-goto-nearest-publishable-parent)
  (orgo-test/assert-point-changes
   "* not a post header<^>-!-
* TODO post header"
   #'orgo-goto-nearest-publishable-parent)
  )


(provide 'orgo-test)
;;; orgo-test.el ends here
