;;; orgo-test.el --- test for orgo -*- lexical-binding: t -*-

;;; Commentary:

;; Tests for orgo.el functionality.

;;; Code:

(defvar orgo-test/test-path
  (directory-file-name (file-name-directory (or load-file-name (buffer-file-name))))
  "Path to tests directory.")

(defvar orgo-test/root-path
  (directory-file-name (file-name-directory orgo-test/test-path))
  "Path to root directory.")

(load (expand-file-name "orgo" orgo-test/root-path) 'noerror 'nomessage)
(require 'ert)
(require 's)
(require 'dash)

(defvar orgo/cursor-placeholder "-!-"
  "Representation of a cursor in a buffer.")

(defmacro orgo-test/with-mock-buffer (str &rest body)
  "Create buffer with STR and run BODY."
  (declare (indent 1))
  `(with-temp-buffer
     (insert ,str)
     (goto-char (point-min))
     (org-mode)
     (outline-show-all)
     (if (search-forward orgo/cursor-placeholder nil t)
         (progn
           (replace-match "")
           (goto-char (match-beginning 0)))
       (goto-char (point-min)))
     ,@body))

(defun orgo-test/assert-point-changes (buffer-string function &rest args)
  "Assert that BUFFER-STRING match what FUNCTION does.
ARGS are the arguments to FUNCTION."
  (unless (s-contains? "<^>" buffer-string)
    (error "The buffer-string must contain <^> to indicate the
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
   #'orgo-goto-nearest-publishable-parent))

(ert-deftest orgo-test/goto-nearest-publishable-parent-returns-nil ()
  "Assert that we get nil if we don't move"
  (should
   (equal nil
          (orgo-test/with-mock-buffer
              "-!-"
            (orgo-goto-nearest-publishable-parent)))))

(ert-deftest orgo-test/goto-nearest-publishable-parent-returns-point ()
  "Assert that we get the new point if we do move."
  (should
   (equal 1
          (orgo-test/with-mock-buffer
              "* TODO header
-!-"
            (orgo-goto-nearest-publishable-parent)))))

(ert-deftest orgo-test/publishable-tree-p-works ()
  (should
   (equal t
          (orgo-test/with-mock-buffer
              "* TODO header -!-"
            (orgo-publishable-tree-p))))
  (should
   (equal nil
          (orgo-test/with-mock-buffer
              "* header -!-"
            (orgo-publishable-tree-p)))))

(ert-deftest orgo-test/get-entry-title-errors-if-not-in-tree ()
  (should-error
   (orgo-test/with-mock-buffer
       "* header -!-"
     (orgo-get-entry-title)))                                                )

(ert-deftest orgo-test/get-entry-title-gets-a-title ()
  (should
   (equal
    "header"
    (orgo-test/with-mock-buffer
        "* TODO header -!-"
      (orgo-get-entry-title))))

  (should
   (equal
    "header"
    (orgo-test/with-mock-buffer
        "* TODO header
  ** Other header-!-"
      (orgo-get-entry-title))))

  (should
   (equal
    "Other header"
    (orgo-test/with-mock-buffer
        "* TODO header

** TODO Other header-!-"
      (orgo-get-entry-title)))))


(ert-deftest orgo-test/publish-entry-errors-if-not-in-tree ()
  (should-error
   (orgo-test/with-mock-buffer
       "* header -!-"
     (orgo-publish-entry)))
  (should-error
   (orgo-test/with-mock-buffer
       "-!-
* TODO header"
     (orgo-publish-entry))))

(ert-deftest orgo/sanitize-file-name ()
  (-each '(("" . "")
           ("a" . "a")
           ("a b" . "a-b")
           ("a b  c" . "a-b-c")
           ("a(b)" . "a")
           ("a1" . "a1")
           ("a++~" . "a-"))
    (lambda (elem)
      (should (equal (cdr elem)
                     (orgo-sanitize-file-name (car elem)))))))

(provide 'orgo-test)
;;; orgo-test.el ends here
