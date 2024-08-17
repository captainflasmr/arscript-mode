;;; arscript-mode.el --- Major mode for editing arscript files
;;
;; Author: James Dyer <captainflasmr@gmail.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "25.1"))
;; Keywords: convenience
;; URL: https://github.com/captainflasmr/arscript-mode
;;
;; This file is not part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;; arscript-mode is an Emacs major mode designed to facilitate the
;; editing of arscript files, providing syntax highlighting and other
;; useful editing features tailored specifically for the arscript file
;; format.

;;; Code:

(require 'regexp-opt)

(defun arscript-indent-line ()
  "Indent current line as ARSCRIPT code."
  (interactive)
  (beginning-of-line)
  (if (bobp)  ; Check if it's the beginning of the buffer
    (indent-line-to 0)  ; Set indent to 0 at the start of the buffer.
    (let ((not-indented t) (cur-indent nil))
      (if (looking-at "^[ \t]*\\(</\\)")
        (progn
          (save-excursion
            (forward-line -1)
            (setq cur-indent (- (current-indentation) tab-width)))
          (when (< cur-indent 0)
            (setq cur-indent 0)))
        (save-excursion
          (while not-indented
            (forward-line -1)
            (cond
              ;; If the line starts with a closing tag, match the opening tag's indentation.
              ((looking-at "^.*[ \t]*</") ; Matches a closing tag
                (setq cur-indent (current-indentation))
                (setq not-indented nil))
              ;; If the line starts with an opening tag, indent the next line more.
              ((looking-at "^.*[ \t]*<[^/]")
                (setq cur-indent (+ (current-indentation) tab-width))
                (setq not-indented nil))
              ((bobp)
                (setq not-indented nil))
              ))))
      (indent-line-to (or cur-indent (current-indentation) 0)))))

;;;###autoload
(define-derived-mode arscript-mode prog-mode "arscript"
  "Major mode for editing arscript art files."
  (kill-all-local-variables)
  ;; Syntax highlighting
  (setq font-lock-defaults
    `((
        ;; Comments
        ("\\(//.*\\)" . font-lock-comment-face)

        ;; Keywords
        (,(regexp-opt '("EvType" "CommandID" "ParamType" "Value" "Count"
                         "Idx" "Channels" "Path"
                         "Script Startup Features"
                         "Reference Image"
                         "ArtRage Version" "ArtRage Build"
                         "Professional Edition" "Script Version"
                         "Painting Name" "Painting Width" "Painting Height"
                         "Painting DPI" "Mask Edge Map Width"
                         "Mask Edge Map Height" "Mask Edge Map Height"
                         "Author Name" "Script Name" "Comment"
                         "Script Type" "Script Feature Flags"
                         "Tool Data")
            'words)
          . font-lock-keyword-face)

        ;; constants
        (,(regexp-opt '("SetForeColour" "SetForeColor" "Pixel" "Command" "Yes" "No"
                         "CanvasXForm" "ReferenceImageXForm" "SetMetallicValue"
                         "Undo" "SetToolProperty" "ToolProp" "CID_SetClearCanvas"
                         "CID_ToolSelect" "CID_SetSpecificToolPressure"
                         "CID_ToggleSpecificLayerVisible" "CID_MergeSpecificLayerDown"
                         "CID_DuplicateSpecificLayer" "CID_SetSpecificLayerBlend"
                         "LayerXForm" "CID_SelectSpecificLayer"
                         "CID_SetSpecificLayerOpacity" "LayerProp"
                         "ExportLayer" "Canvas Reset All"
                         "LoadReferenceImage" "ToolPreset" "flag" "true")
            'words)
          . font-lock-constant-face)

        ;; brush types
        (,(regexp-opt '("Oil Brush" "Eraser"
                         "Oil Paint")
            'words)
          . font-lock-string-face)

        ;; Tags like <Version>, <Header>
        ("\\(<[^>]+>\\)" . font-lock-type-face)

        ;; Numerical pairs of values (<num>, <num>)
        ("\\(\\<\\(?:Loc\\|Dr\\|Hd\\|Off\\|Size\\|Scale\\):\\)\\s-+\\((\\)\\([-0-9\\.]+\\),\\s-*\\([-0-9\\.]+\\)\\()\\)"
         (1 font-lock-keyword-face)
         (3 font-lock-constant-face)
         (4 font-lock-constant-face))

        ;; hex values
        ("0x[0-9A-Fa-f]+"
          . font-lock-string-face)

        ;;
        ("\\(\\<\\(?:Rv\\|Iv\\):\\)\\s-+\\(.*\\)"
          (1 font-lock-string-face)
          (2 font-lock-constant-face))

        ;; Separate out Wait for variation
        ("\\(Wait:\\)\s+\\([0-9\\.s]+\\)"
          (1 font-lock-string-face)
          (2 font-lock-constant-face))

        ;; Single numerical value
        ("\\([A-Za-z]+:\\)\s+\\([0-9\\.s]+\\)"
          (1 font-lock-keyword-face)
          (2 font-lock-constant-face))

        )))
  ;; Comments
  (setq comment-start "//")
  (setq comment-end "")
  ;; Indentation (basic, can be improved for specific structures)
  (setq indent-tabs-mode nil)
  (setq indent-line-function #'arscript-indent-line)
  ;; Key bindings could be added here if necessary
  )

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.arscript\\'" . arscript-mode))

(provide 'arscript-mode)

;;; arscript-mode.el ends here
