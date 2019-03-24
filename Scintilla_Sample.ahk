#Include <Scintilla>
; Assumes Scintilla.ahk is in a lib folder

main := GuiCreate()
main.MarginX := main.MarginY := 0

sci := new Scintilla(main, "w600 h600 vEdit", , 0, 0)
; apply generic styling
setupSciControl(sci)

; listen for double clicks and show the current selection if it contains text
sci.OnNotify(sci.SCN_DOUBLECLICK, (ctrl, l) => showCurrentSelection(sci, l))

main.show()
Return

showCurrentSelection(sci, l) {
    ; if the selection just contains spaces, this will be false
    if (trim(text := GetSelText(sci))) {
        ToolTip(text)
        SetTimer(() => ToolTip(), -3000) ; close after 3 seconds
    }
}

; helper to get text from buffer
GetSelText(sci) {
    len := sci.GetSelText() - 1
    VarSetCapacity(text, len)
    sci.GetSelText("", &text)
    Return StrGet(&Text,, "UTF-8")
}

setupSciControl(sci) {
    sci.SetBufferedDraw(0) ; Scintilla docs recommend turning this off for current systems as they perform window buffering
    sci.SetTechnology(1) ; uses Direct2D and DirectWrite APIs for higher quality

    sci.SetLexer(7) ; SQL
    
    ; Indentation
    sci.SetTabWidth(4)
    sci.SetUseTabs(false) ; Indent with spaces
    sci.SetTabIndents(1)
    sci.SetBackspaceUnindents(1) ; Backspace will delete spaces that equal a tab
    sci.SetIndentationGuides(sci.SC_IV_LOOKBOTH)
    
    sci.StyleSetFont(sci.STYLE_DEFAULT, "Consolas", 1)
    sci.StyleSetSize(sci.STYLE_DEFAULT, 10)
    sci.StyleSetFore(sci.STYLE_DEFAULT, CvtClr(0xF8F8F2))
    sci.StyleSetBack(sci.STYLE_DEFAULT, CvtClr(0x272822))
    sci.StyleClearAll() ; This message sets all styles to have the same attributes as STYLE_DEFAULT.

    ; Active line background color
    sci.SetCaretLineBack(CvtClr(0x3E3D32))
    sci.SetCaretLineVisible(True)
    sci.SetCaretLineVisibleAlways(1)
    sci.SetCaretFore(CvtClr(0xF8F8F0))

    sci.StyleSetFore(sci.STYLE_LINENUMBER, CvtClr(0xF8F8F2)) ; Margin foreground color
    sci.StyleSetBack(sci.STYLE_LINENUMBER, CvtClr(0x272822)) ; Margin background color

    ; Selection
    Sci.SetSelBack(1, CvtClr(0xBEC0BD))
    sci.SetSelAlpha(80)

    sci.StyleSetFore(sci.SCE_SQL_COMMENT, CvtClr(0x75715E))
    sci.StyleSetFore(sci.SCE_SQL_COMMENTLINE, CvtClr(0x75715E))
    sci.StyleSetFore(sci.SCE_SQL_COMMENTDOC, CvtClr(0x75715E))
    sci.StyleSetFore(sci.SCE_SQL_COMMENTDOCKEYWORD, CvtClr(0x66D9EF))
    sci.StyleSetFore(sci.SCE_SQL_WORD, CvtClr(0xF92672))
    sci.StyleSetFore(sci.SCE_SQL_NUMBER, CvtClr(0xAE81FF))
    sci.StyleSetFore(sci.SCE_SQL_STRING, CvtClr(0xE6DB74))
    sci.StyleSetFore(sci.SCE_SQL_OPERATOR, CvtClr(0xF92672))
    sci.StyleSetFore(sci.SCE_SQL_USER1, CvtClr(0x66D9EF))

    sci.SetKeywords(0, keywords("keywords"), 1)
    sci.SetKeywords(4, keywords("functions"), 1)

    ; line number margin
    PixelWidth := sci.TextWidth(sci.STYLE_LINENUMBER, "9999", 1)
    sci.SetMarginWidthN(0, PixelWidth)
    sci.SetMarginLeft(0, 2) ; Left padding
    
    ; used as a border between line numbers and content
    borderMarginW := 1
    sci.SetMarginTypeN(1, sci.SC_MARGIN_FORE) ; change the second margin to be of type SC_MARGIN_FORE
    sci.SetMarginWidthN(1, borderMarginW) ; set width to 1 pixel

    sci.SetScrollWidth(sci.ctrl.pos.w - PixelWidth - SysGet(11)) ; Also subtract the width of a vertical scrollbar
}

keywords(key) {
    static keywords := {
        keywords: "abort action add after all alter analyze and as asc attach autoincrement before begin between by cascade case cast check collate column commit conflict constraint create cross current current_date current_time current_timestamp database default deferrable deferred delete desc detach distinct do drop each else end escape except exclusive exists explain fail filter following for foreign from full glob group having if ignore immediate in index indexed initially inner insert instead intersect into is isnull join key left like limit match natural no not nothing notnull null of offset on or order outer over partition plan pragma preceding primary query raise range recursive references regexp reindex release rename replace restrict right rollback row rows savepoint select set table temp temporary then to transaction trigger unbounded union unique update using vacuum values view virtual when where window with without",
        functions: "abs avg changes char coalesce count cume_dist date datetime dense_rank first_value glob group_concat hex ifnull instr json json_array json_array_length json_extract json_insert json_object json_patch json_remove json_replace json_set json_type json_valid json_quote json_group_array json_group_object json_each json_tree julianday lag last_insert_rowid last_value lead length like likelihood likely load_extension lower ltrim max min nth_value ntile nullif percent_rank printf quote random randomblob rank replace round row_number rtrim soundex sqlite_compileoption_get sqlite_compileoption_used sqlite_offset sqlite_source_id sqlite_version strftime substr substr sum time total total_changes trim typeof unicode unlikely upper zeroblob"
    }
    
    return keywords.HasKey(key) ? keywords[key] : ""
}

CvtClr(Color) {
    Return (Color & 0xFF) << 16 | (Color & 0xFF00) | (Color >> 16)
}
