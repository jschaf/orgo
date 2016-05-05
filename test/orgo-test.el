;;; orgo-test.el --- test for orgo -*- lexical-binding: t -*-

;;; Commentary:

;; Tests for orgo.el functionality.

;;; Code:

(load (expand-file-name "orgo.el" default-directory))
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
         (replace-match "")
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

  (let ((new-point-position (caar (s-matched-positions-all
                                    "<^>"
                                    buffer-string)))
        (clean-buffer-string (s-replace "<^>" "" buffer-string)))
    (orgo-test/with-mock-buffer clean-buffer-string
      (apply function args)
      (should (equal new-point-position (point))))))

(ert-deftest orgo-test/goto-nearest-publishable-parent ()
  "Assert that the point moves to the nearest TODO header."
  (orgo-test/assert-point-changes
      "*<^> TODO header 1
-!-"
      #'orgo-goto-nearest-publishable-parent)
  (orgo-test/assert-point-changes
   "*<^> TODO header 1

** header 2
-!-"
   #'orgo-goto-nearest-publishable-parent))


(provide 'orgo-test)
;;; orgo-test.el ends here
