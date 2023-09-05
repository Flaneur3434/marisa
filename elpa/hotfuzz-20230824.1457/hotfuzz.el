;;; hotfuzz.el --- Fuzzy completion style  -*- lexical-binding: t -*-

;; Copyright (C) 2021 Axel Forsman

;; Author: Axel Forsman <axel@axelf.se>
;; Version: 0.1
;; Package-Requires: ((emacs "27.1"))
;; Keywords: matching
;; Homepage: https://github.com/axelf4/hotfuzz
;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:

;; This is a fuzzy Emacs completion style similar to the built-in
;; `flex' style, but with a better scoring algorithm. Specifically, it
;; is non-greedy and ranks completions that match at word; path
;; component; or camelCase boundaries higher.

;; To use this style, prepend `hotfuzz' to `completion-styles'.

;;; Code:

;; See: Myers, Eugene W., and Webb Miller. "Optimal alignments in
;;      linear space." Bioinformatics 4.1 (1988): 11-17.

(eval-when-compile (require 'cl-lib))
(declare-function hotfuzz--filter-c "hotfuzz-module")

(defgroup hotfuzz nil
  "Fuzzy completion style."
  :group 'minibuffer)

(defcustom hotfuzz-max-highlighted-completions 25
  "The number of top-ranking completions that should be highlighted.
Large values will decrease performance."
  :type 'integer)

;; Since the vectors are pre-allocated the optimization where
;; symmetricity w.r.t. to insertions/deletions means it suffices to
;; allocate min(#needle, #haystack) for C/D when only calculating the
;; cost does not apply.
(defconst hotfuzz--max-needle-len 128)
(defconst hotfuzz--max-haystack-len 512)
(defvar hotfuzz--c (make-vector hotfuzz--max-needle-len 0))
(defvar hotfuzz--d (make-vector hotfuzz--max-needle-len 0))
(defvar hotfuzz--bonus (make-vector hotfuzz--max-haystack-len 0))

(defconst hotfuzz--bonus-prev-luts
  (eval-when-compile
    (let ((bonus-state-special (make-char-table 'hotfuzz-bonus-lut 0))
          (bonus-state-upper (make-char-table 'hotfuzz-bonus-lut 0))
          (bonus-state-lower (make-char-table 'hotfuzz-bonus-lut 0))
          (word-bonus 80))
      (cl-loop for (ch . bonus) in `((?/ . 90) (?. . 60)
                                     (?- . ,word-bonus) (?_ . ,word-bonus)
                                     (?\  . ,word-bonus))
               do (aset bonus-state-upper ch bonus) (aset bonus-state-lower ch bonus))
      (cl-loop for ch from ?a to ?z do (aset bonus-state-upper ch word-bonus))
      (vector bonus-state-special bonus-state-upper bonus-state-lower)))
  "LUTs of the bonus associated with the previous character.")
(defconst hotfuzz--bonus-cur-lut
  (eval-when-compile
    (let ((bonus-cur-lut (make-char-table 'hotfuzz-bonus-lut 0)))
      (cl-loop for ch from ?A to ?Z do (aset bonus-cur-lut ch 1))
      (cl-loop for ch from ?a to ?z do (aset bonus-cur-lut ch 2))
      bonus-cur-lut))
  "LUT of the `hotfuzz--bonus-prev-luts' index based on the current character.")

(defun hotfuzz--calc-bonus (haystack)
  "Precompute all potential bonuses for matching certain characters in HAYSTACK."
  (cl-loop for ch across haystack and i from 0 and lastch = ?/ then ch do
           (let ((lut (aref hotfuzz--bonus-prev-luts (aref hotfuzz--bonus-cur-lut ch))))
             (aset hotfuzz--bonus i (aref lut lastch)))))

;; Aᵢ denotes the prefix a₀,...,aᵢ₋₁ of A
(defun hotfuzz--match-row (a b i nc nd pc pd)
  "Calculate costs for transforming Aᵢ to Bⱼ with deletions for all j.
The matrix C[i][j] represents the minimum cost of a conversion, and D,
the minimum cost when aᵢ is deleted. The costs for row I are written
into NC/ND, using the costs for row I-1 in PC/PD. The vectors NC/PC
and ND/PD respectively may alias."
  (cl-loop
   with m = (length b)
   and g = 100 and h = 5 ; Every k-symbol gap is penalized by g+hk
   ;; s threads the old value C[i-1][j-1] throughout the loop
   for j below m and s = (if (zerop i) 0 (+ g (* h i))) then oldc
   for oldc = (aref pc j) do
   ;; Either extend optimal conversion of (i) Aᵢ₋₁ to Bⱼ₋₁, by
   ;; matching bⱼ (C[i-1,j-1]-bonus); or (ii) Aᵢ₋₁ to Bⱼ, by deleting
   ;; aᵢ and opening a new gap (C[i-1,j]+g+h) or enlarging the
   ;; previous gap (D[i-1,j]+h).
   (aset nc j (min (aset nd j (+ (min (aref pd j) (+ oldc g))
                                 (if (= j (1- m)) h (* 2 h))))
                   (if (char-equal (aref a i) (aref b j))
                       (- s (aref hotfuzz--bonus i))
                     most-positive-fixnum)))))

(defun hotfuzz--cost (needle haystack)
  "Return the difference score of NEEDLE and the match HAYSTACK."
  (let ((n (length haystack)) (m (length needle)))
    (if (> n hotfuzz--max-haystack-len)
        10000
      (hotfuzz--calc-bonus haystack)
      (let ((c (fillarray hotfuzz--c 10000)) (d (fillarray hotfuzz--d 10000)))
        (dotimes (i n) (hotfuzz--match-row haystack needle i c d c d))
        (aref c (1- m)))))) ; Final cost

(defun hotfuzz-highlight (needle haystack)
  "Highlight the characters that NEEDLE matched in HAYSTACK.
HAYSTACK has to be a match according to `hotfuzz-all-completions'."
  (let ((n (length haystack)) (m (length needle))
        (c hotfuzz--c) (d hotfuzz--d)
        (case-fold-search completion-ignore-case))
    (unless (or (> n hotfuzz--max-haystack-len) (> m hotfuzz--max-needle-len))
      (fillarray c 10000)
      (fillarray d 10000)
      (hotfuzz--calc-bonus haystack)
      (cl-loop
       with rows initially
       (cl-loop for i below n and pc = c then nc and pd = d then nd
                and nc = (make-vector m 0) and nd = (make-vector m 0) do
                (hotfuzz--match-row haystack needle i nc nd pc pd)
                (push (cons nc nd) rows))
       ;; Backtrack to find matching positions
       for j from (1- m) downto 0 and i downfrom (1- n) do
       (cl-destructuring-bind (c . d) (pop rows)
         (when (<= (aref d j) (aref c j))
           (while (progn (setq i (1- i))
                         (> (aref d j) (aref (setq d (cdr (pop rows))) j))))))
       (add-face-text-property i (1+ i) 'completions-common-part nil haystack))))
  haystack)

;;; Completion style implementation

;;;###autoload
(defun hotfuzz-all-completions (string table &optional pred point)
  "Get hotfuzz-completions of STRING in TABLE.
See `completion-all-completions' for the semantics of PRED and POINT.
This function prematurely sorts the completions; mutating the returned
list before passing it to `display-sort-function' or
`cycle-sort-function' will lead to inaccuracies."
  (unless point (setq point (length string)))
  (let* ((beforepoint (substring string 0 point))
         (afterpoint (substring string point))
         (bounds (completion-boundaries beforepoint table pred afterpoint))
         (prefix (substring beforepoint 0 (car bounds)))
         (needle (substring beforepoint (car bounds)))
         (use-module-p (require 'hotfuzz-module nil t))
         (case-fold-search completion-ignore-case)
         (completion-regexp-list
          (if use-module-p completion-regexp-list
            (let ((re (mapconcat
                       (lambda (ch) (let ((s (char-to-string ch)))
                                      (concat "[^" s "]*" (regexp-quote s))))
                       needle "")))
              (cons (concat "\\`" re) completion-regexp-list))))
         (all (if (and (string= prefix "") (or (stringp (car-safe table)) (null table))
                       (not (or pred completion-regexp-list (string= needle ""))))
                  table
                (all-completions prefix table pred))))
    ;; `completion-pcm--all-completions' tests completion-regexp-list
    ;; again with functional tables even though they should handle it.
    (cond
     ((or (null all) (string= needle "")))
     (use-module-p (setq all (hotfuzz--filter-c needle all completion-ignore-case)))
     ((> (length needle) hotfuzz--max-needle-len))
     (t (cl-loop for x in-ref all do (setf x (cons (hotfuzz--cost needle x) x))
                 finally (setq all (mapcar #'cdr (sort all #'car-less-than-car))))))
    (when all
      (unless (string= needle "")
        ;; Without deferred highlighting (bug#47711) only highlight
        ;; the top completions.
        (cl-loop repeat hotfuzz-max-highlighted-completions and for x in-ref all
                 do (setf x (hotfuzz-highlight needle (copy-sequence x))))
        (when (zerop hotfuzz-max-highlighted-completions)
          (setcar all (copy-sequence (car all))))
        (put-text-property 0 1 'completion-sorted t (car all)))
      (if (string= prefix "") all (nconc all (length prefix))))))

(defun hotfuzz--adjust-metadata (metadata)
  "Adjust completion METADATA for hotfuzz sorting."
  (let ((existing-dsf (completion-metadata-get metadata 'display-sort-function))
        (existing-csf (completion-metadata-get metadata 'cycle-sort-function)))
    (cl-flet ((compose-sort-fn (existing-sort-fn)
                (lambda (completions)
                  (if (or (null completions)
                          (get-text-property 0 'completion-sorted (car completions)))
                      completions
                    (funcall existing-sort-fn completions)))))
      `(metadata
        (display-sort-function . ,(compose-sort-fn (or existing-dsf #'identity)))
        (cycle-sort-function . ,(compose-sort-fn (or existing-csf #'identity)))
        . ,(cdr metadata)))))

;;;###autoload
(progn
  ;; Why is the Emacs completions API so cursed?
  (put 'hotfuzz 'completion--adjust-metadata #'hotfuzz--adjust-metadata)
  (add-to-list 'completion-styles-alist
               '(hotfuzz completion-flex-try-completion hotfuzz-all-completions
                         "Fuzzy completion.")))

;;; Vertico integration

(declare-function vertico--all-completions "ext:vertico")
(declare-function corfu--all-completions "ext:corfu")

(defun hotfuzz--vertico--all-completions-advice (fun &rest args)
  "Advice for FUN `vertico--all-completions' to defer hotfuzz highlighting."
  (cl-letf* ((hl nil)
             ((symbol-function #'hotfuzz-highlight)
              (lambda (pattern cand)
                (setq hl (apply-partially
                          #'mapcar
                          (lambda (x) (hotfuzz-highlight pattern (copy-sequence x)))))
                cand))
             (hotfuzz-max-highlighted-completions 1)
             (result (apply fun args)))
    (when hl (setcdr result hl))
    result))

;;;###autoload
(define-minor-mode hotfuzz-vertico-mode
  "Toggle hotfuzz compatibility code for the Vertico&Corfu completion systems.
Contrary to what the name might suggest, this mode does not enable
hotfuzz. You still have to customize e.g. `completion-styles'."
  :global t
  (if hotfuzz-vertico-mode
      (progn
        (advice-add #'vertico--all-completions :around #'hotfuzz--vertico--all-completions-advice)
        (advice-add #'corfu--all-completions :around #'hotfuzz--vertico--all-completions-advice))
    (advice-remove #'vertico--all-completions #'hotfuzz--vertico--all-completions-advice)
    (advice-remove #'corfu--all-completions #'hotfuzz--vertico--all-completions-advice)))

(provide 'hotfuzz)
;;; hotfuzz.el ends here
