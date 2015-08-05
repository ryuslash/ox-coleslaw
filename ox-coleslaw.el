;;; ox-coleslaw.el --- Export to coleslaw post       -*- lexical-binding: t; -*-

;; Copyright (C) 2015  Tom Willemse

;; Author: Tom Willemse <tom@ryuslash.org>
;; Keywords:

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

;;; Code:

(require 'ox-html)

(org-export-define-derived-backend 'coleslaw 'html
  :menu-entry
  '(?C "Coleslaw: export to HTML with Coleslaw front matter."
       ((?H "As HTML buffer" org-coleslaw-export-as-html)
        (?h "As HTML file" org-coleslaw-export-to-html)))
  :translate-alist
  '((template . org-coleslaw-template)
    (inner-template . org-coleslaw-inner-template))
  :options-alist
  '((:coleslaw-tags "COLESLAW_TAGS" nil "")))

(defun org-coleslaw-template (contents info)
  "Return complete document string after HTML conversion.

CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  (concat
   (org-coleslaw--front-matter info)
   contents))

(defun org-coleslaw-inner-template (contents info)
  "Return body of document string after HTML conversion.

CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  (concat contents
          (org-html-footnote-section info)))

(defun org-coleslaw--front-matter (info)
  (let ((title (org-export-data (plist-get info :title) info))
        (date (org-export-data (plist-get info :date) info))
        (tags (org-export-data (plist-get info :coleslaw-tags) info)))
    (concat
     ";;;;;\n"
     "title: " title "\n"
     "date: " date "\n"
     "tags: " tags "\n"
     "format: html\n"
     ";;;;;\n")))

;;;###autoload
(defun org-coleslaw-export-as-html
    (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer to a HTML buffer adding some front matter."
  (interactive)
  (if async
      (org-export-async-start
          (lambda (output)
            (with-current-buffer
                (get-buffer-create "*Org Coleslaw HTML export*")
              (erase-buffer)
              (insert output)
              (goto-char (point-min))
              (funcall org-html-display-buffer-mode)
              (org-export-add-to-stack (current-buffer) 'coleslaw)))
        `(org-export-as 'coleslaw ,subtreep ,visible-only ,body-only, ',ext-plist))
    (let ((outbuf (org-export-to-buffer
                      'coleslaw "*Org Coleslaw HTML Export*"
                    nil subtreep visible-only body-only ext-plist)))
      (with-current-buffer outbuf (set-auto-mode t))
      (when org-export-show-temporary-export-buffer
        (switch-to-buffer-other-window outbuf)))))

;;;###autoload
(defun org-coleslaw-export-to-html
    (&optional async subtreep visible-only body-only ext-plist)
  "Export current buffer to a HTML file adding some front matter."
  (interactive)
  (let* ((extension (concat "." org-html-extension))
         (file (org-export-output-file-name extension subtreep))
         (org-export-coding-system org-html-coding-system))
    (if async
        (org-export-async-start
            (lambda (f) (org-export-add-to-stack f 'coleslaw))
          `(expand-file-name
            (org-export-to-file
                'coleslaw ,file nil ,subtreep ,visible-only ,body-only ',ext-plist)))
      (org-export-to-file
          'coleslaw file nil subtreep visible-only body-only ext-plist))))

(defun org-coleslaw-publish-to-html (plist filename pub-dir)
  "Publish an org file to HTML with front matter.

FILENAME is the filename of the Org file to be published.  PLIST
is the property list for the given project.  PUB-DIR is the
publishing directory.

Return output file name."
  (org-publish-org-to 'coleslaw filename ".post" plist pub-dir))

(provide 'ox-coleslaw)
;;; ox-coleslaw.el ends here
