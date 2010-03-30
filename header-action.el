; -*- Mode: Emacs-Lisp -*- 
;;; header-action.el --- Do something before sending mail/news
;;;                      based on some header settings.

;; Revision 1.1
;; $Id: header-action.el,v 1.2 1999-06-23 14:01:09+02 schauer Exp schauer $

;; Copyright (C) 1998, 1999 Holger Schauer

;; Author: Holger Schauer <Holger.Schauer@gmx.de>
;; Keywords: utils mail

;; This file is not part of Emacs.

;; Developed under XEmacs 20.4. Should work with most other Emacs-sen.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:
;; This mainly defines a function `header-action' which should be
;; hooked into `mail-send-hook', `news-inews-hook' and `message-send-hook'.
;; It will reference the variable `header-action-list' to try to
;; match one of the headers of the message you have composed and to
;; execute some given command.
;; For example, to insert some specific signature or using an other
;; mail-address when posting to newsgroups, I use:
;;
;;(setq header-action-list
;;      '(("To:"
;;	  ("foo" 
;;	      (lambda ()
;;              (make-variable-buffer-local 'mail-signature-file)
;;              (setq mail-signature-file "~/.signature-foo")
;;		(mail-signature)
;;		(message "Mail to foo is underway !"))))
;;	("Newsgroups:"
;;	  ("de\\.comp\\.os\\.linux\\..*"
;;	      (lambda ()
;;		(message "Found Linux-Group, changing mail-address")
;;		(make-variable-buffer-local 'user-mail-address)
;;		(setq user-mail-address "Holger.Schauer@gmx.de"))))))
;;
;; For adding Fidonet-Style X-Comment-To: Header only in fidonet,
;; one could use something along the following lines:
;; (setq header-action-list
;;  '(("Newsgroups:" ; matche alle Gruppen mit "fido." am Anfang
;;     ("fido\\..*" 
;;      (lambda ()
;;	  (if sc-attributions
;;	    (save-excursion 
;;	      (mail-position-on-field "X-Comment-To")
;;	      (insert (cdr (assoc "sc-author" sc-mail-info)))))
;;	(make-variable-buffer-local 'user-mail-address)
;;	(setq user-mail-address 
;;	      "Holger.Schauer@p1.f2.n3.z4.fidonet.org"))))))
;; This solution requires the use of supercite and sendmail.el.
;;
;;; Installation:
;; Put this file somewhere where Emacs can find it and add the following
;; lines to your .emacs:
;; (autoload 'header-action "header-action" t)
;; (add-hook 'mail-send-hook 'header-action)
;; (add-hook 'message-send-hook 'header-action)
;; And, of course, you will need to specify some header actions....

(defvar header-action-list nil
  "List of message-headers and values for which some action is taken.

Format of entries: ((<message-header> 
                       (<value> <function>)
                       ...)
                     ...

Note that <value> is interpreted as a regular expression. <function> may
be a lambda construct or a symbol which is funcall-able.")


(defun header-action ()
  "Execute an action before sending message if one of the headers in it
has a matching value and a function specified in `header-action-list'."

  (dolist (header-value-list header-action-list)
    (dolist (value (cdr header-value-list))
      (let ((search-string
	     (concat "^"
		     (car header-value-list)
		     "\\s-*.*\\("
		     (car value)
		     "\\)$")))
	(save-excursion
	  (goto-line (point-min))
	  (if (search-forward-regexp
	              search-string
		      (or (save-excursion
			    (search-forward-regexp 
			     mail-header-separator
			     (point-max) t))
			  (point-max))
		      t)
	      (funcall (car (cdr value)))))))))

(provide 'header-action)

 