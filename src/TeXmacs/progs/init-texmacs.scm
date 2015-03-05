
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; MODULE      : init-texmacs.scm
;; DESCRIPTION : This is the standard TeXmacs initialization file
;; COPYRIGHT   : (C) 1999  Joris van der Hoeven
;;
;; This software falls under the GNU general public license version 3 or later.
;; It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
;; in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;(debug-enable 'backtrace 'debug)

(define boot-start (texmacs-time))
(define remote-list (list))

(define developer-mode?
  (equal? (cpp-get-preference "developer tool" "off") "on"))

(define (%new-read-hook sym) (noop)) ; for autocompletion

(define-public macro-keywords '(define-macro define-public-macro 
                                tm-define-macro))
(define-public def-keywords
  `(define-public provide-public
    tm-define tm-menu menu-bind tm-widget ,@macro-keywords))

(define old-read read)
(define (new-read port)
  "A redefined reader which stores line number and file name in symbols."
  ;; FIXME: handle overloaded definitions
  (let ((form (old-read port)))
    (if (and (pair? form) (member (car form) def-keywords))
        (let* ((l (source-property form 'line))
               (c (source-property form 'column))
               (f (source-property form 'filename))
               (sym  (if (pair? (cadr form)) (caadr form) (cadr form))))
          (if (symbol? sym) ; Just in case
              (let ((old (or (symbol-property sym 'defs) '()))
                    (new `(,f ,l ,c)))
                (%new-read-hook sym)
                (if (and (member (car form) macro-keywords)
                         (not (member sym def-keywords)))
                    (set! def-keywords (cons sym def-keywords)))
                (if (not (member new old))
                    (set-symbol-property! sym 'defs (cons new old)))))))
    form))

(define old-primitive-load primitive-load)
(define (new-primitive-load filename)
  ;; We explicitly circumvent guile's decision to set the current-reader
  ;; to #f inside ice-9/boot-9.scm, try-module-autoload
  (with-fluids ((current-reader read))
               (old-primitive-load filename)))

(if developer-mode?
    (begin
      (module-export! (current-module)
                      '(%new-read-hook old-read new-read def-keywords))
      (set! read new-read)
      (module-export! (current-module)
                      '(old-primitive-load new-primitive-load))
      (set! primitive-load new-primitive-load)))

;; TODO: scheme file caching using (set! primitive-load ...) and
;; (set! %search-load-path)

;;(debug-enable 'backtrace 'debug)
;; (define load-indent 0)
;; (define old-primitive-load primitive-load)
;; (define (new-primitive-load . x)
;;   (for-each display (make-list load-indent "  "))
;;   (display "Load ") (apply display x) (display "\n")
;;   (set! load-indent (+ load-indent 1))
;;   (apply old-primitive-load x)
;;   (set! load-indent (- load-indent 1))
;;   (for-each display (make-list load-indent "  "))
;;   (display "Done\n"))
;; (set! primitive-load new-primitive-load)

;(display "Booting TeXmacs kernel functionality\n")
(if (os-mingw?)
    (load "kernel/boot/boot.scm")
    (load (url-concretize "$TEXMACS_PATH/progs/kernel/boot/boot.scm")))
(inherit-modules (kernel boot compat) (kernel boot abbrevs)
                 (kernel boot debug) (kernel boot srfi)
                 (kernel boot ahash-table) (kernel boot prologue))
(inherit-modules (kernel library base) (kernel library list)
                 (kernel library tree) (kernel library content))
(inherit-modules (kernel regexp regexp-match) (kernel regexp regexp-select))
(inherit-modules (kernel logic logic-rules) (kernel logic logic-query)
                 (kernel logic logic-data))
(inherit-modules (kernel texmacs tm-define)
                 (kernel texmacs tm-preferences) (kernel texmacs tm-modes)
                 (kernel texmacs tm-plugins) (kernel texmacs tm-secure)
                 (kernel texmacs tm-convert) (kernel texmacs tm-dialogue)
                 (kernel texmacs tm-language) (kernel texmacs tm-file-system)
                 (kernel texmacs tm-states))
(inherit-modules (kernel gui gui-markup)
                 (kernel gui menu-define) (kernel gui menu-widget)
                 (kernel gui kbd-define) (kernel gui kbd-handlers)
                 (kernel gui menu-test)
                 (kernel old-gui old-gui-widget)
                 (kernel old-gui old-gui-factory)
                 (kernel old-gui old-gui-form)
                 (kernel old-gui old-gui-test))
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting utilities\n")
(lazy-define (utils library cursor) notify-cursor-moved)
(lazy-define (utils cas cas-out) cas->stree)
(lazy-define (utils plugins plugin-cmd) pre-serialize verbatim-serialize)
(use-modules (utils library smart-table))
(use-modules (utils plugins plugin-convert))
(use-modules (utils misc markup-funcs))
(use-modules (utils handwriting handwriting))
(define supports-email? (url-exists-in-path? "mmail"))
(if supports-email? (use-modules (utils email email-tmfs)))
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting BibTeX style modules\n")
(use-modules (bibtex bib-utils))
(lazy-define (bibtex bib-complete) current-bib-file citekey-completions)
(lazy-menu (bibtex bib-widgets) open-bibliography-inserter)
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;;(display "Booting main TeXmacs functionality\n")
(use-modules (texmacs texmacs tm-server) (texmacs texmacs tm-view)
             (texmacs texmacs tm-files) (texmacs texmacs tm-print))
(use-modules (texmacs keyboard config-kbd))
(lazy-keyboard (texmacs keyboard prefix-kbd) always?)
(lazy-keyboard (texmacs keyboard latex-kbd) always?)
(lazy-menu (texmacs menus file-menu) file-menu go-menu
           new-file-menu load-menu save-menu print-menu close-menu)
(lazy-menu (texmacs menus edit-menu) edit-menu)
(lazy-menu (texmacs menus view-menu) view-menu)
(lazy-menu (texmacs menus tools-menu) tools-menu)
(lazy-menu (texmacs menus preferences-menu) preferences-menu page-setup-menu)
(lazy-menu (texmacs menus preferences-widgets) open-preferences)
(use-modules (texmacs menus main-menu))
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting generic mode\n")
(lazy-keyboard (generic generic-kbd) always?)
(lazy-menu (generic generic-menu) focus-menu texmacs-focus-icons)
(lazy-menu (generic format-menu) format-menu
           font-size-menu color-menu horizontal-space-menu
           transform-menu specific-menu
           vertical-space-menu indentation-menu line-break-menu
           page-header-menu page-footer-menu page-numbering-menu
           page-break-menu)
(lazy-menu (generic document-menu) document-menu
           project-menu document-style-menu global-language-menu)
(lazy-menu (generic document-part) document-part-menu project-manage-menu)
(lazy-menu (generic insert-menu) insert-menu texmacs-insert-icons
           insert-link-menu insert-image-menu insert-animation-menu)
(lazy-define (generic document-edit) update-document)
(lazy-define (generic generic-edit) notify-activated notify-disactivated)
(lazy-define (generic generic-doc) focus-help)
(lazy-define (generic generic-widgets) search-toolbar replace-toolbar
             open-search toolbar-search-start interactive-search
             open-replace toolbar-replace-start interactive-replace
             search-next-match)
(lazy-define (generic format-widgets) open-paragraph-format open-page-format)
(lazy-define (generic document-widgets) open-source-tree-preferences
             open-document-paragraph-format open-document-page-format
             open-document-metadata open-document-colors)
(tm-property (open-search) (:interactive #t))
(tm-property (open-replace) (:interactive #t))
(tm-property (open-paragraph-format) (:interactive #t))
(tm-property (open-page-format) (:interactive #t))
(tm-property (open-source-tree-preferences) (:interactive #t))
(tm-property (open-document-paragraph-format) (:interactive #t))
(tm-property (open-document-page-format) (:interactive #t))
(tm-property (open-document-metadata) (:interactive #t))
(tm-property (open-document-colors) (:interactive #t))
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting text mode\n")
(lazy-keyboard (text text-kbd) in-text?)
(lazy-menu (text text-menu) text-format-menu text-format-icons
	   text-menu text-icons)
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting math mode\n")
(lazy-keyboard (math math-kbd) in-math?)
(lazy-menu (math math-menu) math-format-menu math-format-icons
	   math-menu math-icons insert-math-menu
           math-correct-menu semantic-math-preferences-menu
           context-preferences-menu)
(lazy-initialize (math math-menu) (in-math?))
(lazy-define (math math-edit) brackets-refresh)
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting programming modes\n")
(lazy-keyboard (prog prog-kbd) in-prog?)
(lazy-menu (prog prog-menu) prog-format-menu prog-format-icons
	   prog-menu prog-icons)
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting source mode\n")
(lazy-keyboard (source source-kbd) always?)
(lazy-menu (source source-menu) source-macros-menu source-menu source-icons
           source-transformational-menu source-executable-menu)
(lazy-define (source macro-edit) has-macro-source? edit-macro-source)
(lazy-define (source macro-widgets) editable-macro? open-macro-editor
	     open-macros-editor)
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting table mode\n")
(lazy-keyboard (table table-kbd) in-table?)
(lazy-menu (table table-menu) insert-table-menu)
(lazy-define (table table-edit) table-resize-notify)
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting graphics mode\n")
(lazy-keyboard (graphics graphics-kbd) in-active-graphics?)
(lazy-menu (graphics graphics-menu) graphics-menu graphics-icons)
(lazy-define (graphics graphics-edit)
             graphics-busy?
             graphics-reset-context graphics-undo-enabled
             graphics-release-left graphics-release-middle
             graphics-release-right graphics-start-drag-left
             graphics-dragging-left graphics-end-drag-left)
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting formal and natural languages\n")
(lazy-language (language minimal) minimal)
(lazy-language (language std-math) std-math)
(lazy-define (language natural) replace)
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting dynamic features\n")
(lazy-keyboard (dynamic fold-kbd) always?)
(lazy-keyboard (dynamic scripts-kbd) always?)
(lazy-keyboard (dynamic calc-kbd) always?)
(lazy-menu (dynamic fold-menu) insert-fold-menu dynamic-menu dynamic-icons)
(lazy-menu (dynamic session-menu) insert-session-menu session-help-icons)
(lazy-menu (dynamic scripts-menu) scripts-eval-menu scripts-plot-menu
           plugin-eval-menu plugin-eval-toggle-menu plugin-plot-menu)
(lazy-menu (dynamic calc-menu) calc-table-menu calc-insert-menu)
(lazy-define (dynamic session-edit) scheme-eval)
(lazy-define (dynamic calc-edit) calc-ready? calc-table-renumber)
(lazy-initialize (dynamic session-menu) (in-session?))
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting documentation\n")
(lazy-keyboard (doc tmdoc-kbd) in-manual?)
(lazy-keyboard (doc apidoc-kbd) developer-mode?)
(lazy-menu (doc tmdoc-menu) tmdoc-menu tmdoc-icons)
(lazy-menu (doc help-menu) help-menu)
(lazy-define (doc tmdoc) tmdoc-expand-help tmdoc-expand-help-manual
             tmdoc-expand-this tmdoc-include)
(lazy-define (doc docgrep) docgrep-in-doc docgrep-in-src docgrep-in-texts)
(lazy-define (doc tmdoc-search) tmdoc-search-style tmdoc-search-tag
             tmdoc-search-parameter tmdoc-search-scheme)
(lazy-define (doc tmweb) tmweb-convert-dir tmweb-update-dir
             tmweb-convert-dir-keep-texmacs tmweb-update-dir-keep-texmacs
             tmweb-interactive-build tmweb-interactive-update)
(lazy-define (doc apidoc) apidoc-all-modules apidoc-all-symbols)
(lazy-menu (doc apidoc-menu) apidoc-menu)
(lazy-tmfs-handler (doc docgrep) grep)
(lazy-tmfs-handler (doc tmdoc) help)
(lazy-tmfs-handler (doc apidoc) apidoc)
(define-secure-symbols tmdoc-include)

;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting converters\n")
(lazy-format (convert rewrite init-rewrite) texmacs scheme cpp verbatim)
(lazy-format (convert tmml init-tmml) tmml)
(lazy-format (convert latex init-latex) latex)
(lazy-format (convert html init-html) html)
(lazy-format (convert bibtex init-bibtex) bibtex)
(lazy-format (convert images init-images)
             postscript pdf xfig xmgrace svg xpm jpeg ppm gif png pnm)
(lazy-define (convert images tmimage)
             export-selection-as-graphics clipboard-copy-image)
(lazy-define (convert rewrite init-rewrite) texmacs->code texmacs->verbatim)
(lazy-define (convert html tmhtml-expand) tmhtml-env-patch)
(lazy-define (convert latex latex-drd) latex-arity latex-type)
(lazy-define (convert latex tmtex) tmtex-env-patch)
(lazy-define (convert latex latex-tools) latex-set-virtual-packages
             latex-has-style? latex-has-package?
             latex-has-texmacs-style? latex-has-texmacs-package?)
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting database facilities\n")
(lazy-menu (database bib-menu) bib-menu)
(lazy-tmfs-handler (database db-tmfs) db)
(lazy-keyboard (database bib-kbd) in-bib?)
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting remote facilities\n")
(lazy-menu (server server-menu) server-menu)
(lazy-menu (client client-menu) client-menu remote-menu)
(lazy-tmfs-handler (client client-tmfs) remote-file)
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting linking facilities\n")
(lazy-menu (link link-menu) link-menu)
(lazy-keyboard (link link-kbd) with-linking-tool?)
(lazy-define (link link-edit) create-unique-id)
(lazy-define (link link-navigate) link-active-upwards link-active-ids
             link-follow-ids)
(lazy-define (link link-extern) get-constellation
             get-link-locations register-link-locations)
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting versioning facilities\n")
(lazy-menu (version version-menu) version-menu)
(lazy-keyboard (version version-kbd) with-versioning-tool?)
(lazy-define (version version-tmfs) update-buffer commit-buffer)
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting debugging and developer facilities\n")
(lazy-menu (debug debug-menu) debug-menu)
(lazy-menu (texmacs menus developer-menu) developer-menu)
(lazy-define (debug debug-widgets) notify-debug-message
             open-debug-console open-error-messages)
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting plugins\n")
(for-each lazy-plugin-initialize (plugin-list))
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting fonts\n")
(use-modules (fonts fonts-ec) (fonts fonts-adobe) (fonts fonts-x)
             (fonts fonts-math) (fonts fonts-foreign) (fonts fonts-misc)
             (fonts fonts-composite) (fonts fonts-truetype))
(lazy-define (fonts font-old-menu)
	     text-font-menu math-font-menu prog-font-menu)
(lazy-define (fonts font-new-widgets)
             open-font-selector open-document-font-selector)
(tm-property (open-font-selector) (:interactive #t))
(tm-property (open-document-font-selector) (:interactive #t))
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "Booting regression testing\n")
(lazy-define (check check-master) check-all)
;(display* "time: " (- (texmacs-time) boot-start) "\n")

;(display "------------------------------------------------------\n")
(delayed (:idle 10000) (autosave-delayed))
(texmacs-banner)
;(display "Initialization done\n")

;(display "Booting autoupdater\n")
(if (updater-supported?) 
  (begin 
    (use-modules (utils misc updater))
    (delayed (:idle 2000) (updater-initialize))))
;(display* "time: " (- (texmacs-time) boot-start) "\n")

