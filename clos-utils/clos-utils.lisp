;;;; cl-ana is a Common Lisp data analysis library.
;;;; Copyright 2013, 2014 Gary Hollis
;;;; 
;;;; This file is part of cl-ana.
;;;; 
;;;; cl-ana is free software: you can redistribute it and/or modify it
;;;; under the terms of the GNU General Public License as published by
;;;; the Free Software Foundation, either version 3 of the License, or
;;;; (at your option) any later version.
;;;; 
;;;; cl-ana is distributed in the hope that it will be useful, but
;;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;;; General Public License for more details.
;;;; 
;;;; You should have received a copy of the GNU General Public License
;;;; along with cl-ana.  If not, see <http://www.gnu.org/licenses/>.
;;;;
;;;; You may contact Gary Hollis (me!) via email at
;;;; ghollisjr@gmail.com
(in-package :clos-utils)

(defun slot-names (obj)
  "Returns the list of slot symbols for a structure/CLOS class
instance."
  ;; This is implementation dependent, so I'm including the
  ;; implementation for those I have access to:
  #+sbcl
  (loop
     for slot in (sb-pcl:class-slots (class-of obj))
     collect (sb-pcl:slot-definition-name slot))
  #+clisp
  (loop
     for slot in (clos:class-slots (class-of obj))
     collect (clos:slot-definition-name slot)))

(defun slot-keyword-names (obj)
  (mapcar #'keywordify (slot-names obj)))

(defun slot-values (obj)
  "Returns a list of the slot values in a structure/CLOS class
instance."
  (let ((slot-names (slot-names obj)))
    (mapcar (lambda (sym)
              (slot-value obj sym))
            slot-names)))

;;;; A clist is a list directly representing a CLOS class instance.
;;;; The first element is the class name of the object; the rest of
;;;; the list is a plist where each field symbol is the slot name and
;;;; each field value is the value of the slot.  clists are convenient
;;;; for providing text-file storage of data.

(defun clist-type (clist)
  "Returns the type symbol for the type of the object the clist
represents."
  (first clist))

(defun clist-field-symbols (clist)
  "Returns the field symbols for the object the clist represents."
  (every-nth clist 2 1))

(defun clist-field-values (clist)
  (every-nth clist 2 2))

(defun object->clist (obj)
  "Returns a clist for the object obj."
  (cons (class-name (class-of obj))
        (mapcan #'list
                (slot-keyword-names obj)
                (slot-values obj))))

(defun clist->object (clist)
  "Returns "
  (apply #'make-instance
         (clist-type clist)
         (mapcan #'list
                 (clist-field-symbols clist)
                 (clist-field-values clist))))

(defgeneric type-constructor (object)
  (:documentation "Returns the function responsible for constructing
  objects of the same type as the object.  Default value is nil unless
  a method is defined for an object/type.")
  (:method (obj)
    nil))