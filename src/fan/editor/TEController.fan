// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   2022-10-30 yangjiandong Creation
//
using vaseGraphics
using vaseWindow
using vaseGui
**
** TEController
**
class TEController
{
  TextEditor editor
  ChangeStack changeStack
  
  new make(TextEditor editor) {
    this.editor = editor
    this.changeStack = ChangeStack()
  }
  
  private Doc doc() { editor.model }
  
  private TECaret caret() { editor.caret }
  
  TEOptions options() { doc.options }
  
  private Void consume(KeyEvent e) {
    editor.clearSelected
    editor.repaint
    e.consume
  }
  
  internal Void modify(Int start, Int len, Str newText)
  {
    doc := editor.model
    oldText := doc.textRange(start, len)
    change := SimpleChange(start, oldText, newText)
    change.execute(editor)
    changeStack.push(change)
  }

  Void keyEvent(KeyEvent e)
  {
    //echo(e)
    if (e.type == KeyEvent.pressed) {
        if (navigation(e)) return
        if (editor.isReadonly) return
        if (specialModify(e)) return
        if (!e.key.isModifier()) clearSelection(e)
    }
    else if (e.type == KeyEvent.typed) {
        if (e.keyChar <= 31 || e.keyChar == 127) return
        str := e.keyChar.toChar
        typed(str)
        e.consume
    }
  }
  
  private Void typed(Str str) {
    if (editor.hasSelected) {
        modify(editor.selectionStart, editor.selectionEnd-editor.selectionStart, str)
        editor.updateCaretByOffset(editor.selectionStart+str.size)
    }
    else {
        pos := doc.offsetAtLine(caret.lineIndex) + caret.offset
        modify(pos, 0, str)
        editor.updateCaretByOffset(pos+str.size)
    }
    editor.clearSelected
    editor.repaint
  }
  
  private Bool navigation(KeyEvent e) {
    key := e.key
    navKey := key
    if (navKey.isShift) navKey = navKey - Key.shift

    // navigation
    switch (navKey.toStr)
    {
      case Keys.up:
        editor.updateCaretAt(caret.lineIndex-1, caret.offset)
        consume(e)
        return true
      case Keys.down:
        editor.updateCaretAt(caret.lineIndex+1, caret.offset)
        consume(e)
        return true
      case Keys.left:
        editor.updateCaretAt(caret.lineIndex, caret.offset-1, false)
        consume(e)
        return true
      case Keys.right:
        editor.updateCaretAt(caret.lineIndex, caret.offset+1, false)
        consume(e)
        return true
      //case Keys.prevWord:
      //case Keys.nextWord:
      //case Keys.lineStart:
      //case Keys.lineEnd:
      case Keys.docStart:
        editor.updateCaretByOffset(0)
        consume(e)
        return true
      case Keys.docEnd:
        editor.updateCaretByOffset(doc.charCount)
        consume(e)
        return true
      //case Keys.pageUp:
      //case Keys.pageDown:
      case Keys.copy:
        if (editor.hasSelected) {
          text := doc.textRange(editor.selectionStart, editor.selectionEnd-editor.selectionStart)
          Toolkit.cur.clipboard.setText(text)
        }
        e.consume
        return true
    }
    return false
  }
  
  private Bool clearSelection(KeyEvent e) {
    if (editor.hasSelected) {
        modify(editor.selectionStart, editor.selectionEnd-editor.selectionStart, "")
        editor.updateCaretByOffset(editor.selectionStart)
        consume(e)
        return true
    }
    return false
  }

  private Bool specialModify(KeyEvent e) {
    key := e.key
    // handle special modify keys
    switch (key.toStr)
    {
      case Keys.enter:
        if (editor.hasSelected) {
          modify(editor.selectionStart, editor.selectionEnd-editor.selectionStart, "\n")
        }
        else {
          pos := doc.offsetAtLine(caret.lineIndex) + caret.offset
          modify(pos, 0, "\n")
        }
        //editor.updateCaretAt(caret.lineIndex+1, 0)
        consume(e)
        return true
      case Keys.backspace:
        if (clearSelection(e)) return true
        pos := doc.offsetAtLine(caret.lineIndex) + caret.offset
        if (pos > 0) {
            modify(pos-1, 1, "")
            //editor.updateCaretByOffset(pos-1)
            consume(e)
        }
        return true
        
      //case Keys.backspaceWord:
      //case Keys.backspaceLine:
      case Keys.del:
        if (clearSelection(e)) return true
        pos := doc.offsetAtLine(caret.lineIndex) + caret.offset
        if (doc.charCount > 0) {
            modify(pos, 1, "")
            consume(e)
        }
        return true
      //case Keys.delWord:
      case Keys.delLine:
        pos := doc.offsetAtLine(caret.lineIndex)
        modify(pos, doc.line(caret.lineIndex).size, "")
        consume(e)
        return true
      case Keys.dupLine:
        pos := doc.offsetAtLine(caret.lineIndex)
        modify(pos + doc.line(caret.lineIndex).size, 0, doc.line(caret.lineIndex)+"\n")
        consume(e)
        return true
      case Keys.cutLine:
        pos := doc.offsetAtLine(caret.lineIndex)
        text := doc.textRange(pos, doc.line(caret.lineIndex).size)
        Toolkit.cur.clipboard.setText(text)
        if (pos > 0) {
            modify(pos-1, doc.line(caret.lineIndex).size, "")
        }
        else if (pos+doc.line(caret.lineIndex).size > doc.charCount()) {
            modify(pos, doc.line(caret.lineIndex).size+1, "")
        }
        consume(e)
        return true
      case Keys.cut:
        if (editor.hasSelected) {
          text := doc.textRange(editor.selectionStart, editor.selectionEnd-editor.selectionStart)
          Toolkit.cur.clipboard.setText(text)
          modify(editor.selectionStart, editor.selectionEnd-editor.selectionStart, "")
        }
        consume(e)
        return true
      case Keys.paste:
        if (editor.hasSelected) {
          modify(editor.selectionStart, editor.selectionEnd-editor.selectionStart, "")
        }

        Toolkit.cur.clipboard.getText |text|{
          if (text == null) lret
          pos := doc.offsetAtLine(caret.lineIndex) + caret.offset
          modify(pos, 0, text)
          editor.updateCaretByOffset(pos+text.size)
        }
        consume(e)
        return true
      case Keys.undo:
        changeStack.onUndo(editor);
        consume(e)
        return true
      case Keys.redo:
        changeStack.onRedo(editor);
        consume(e)
        return true
      case Keys.indent:
        onTab(true);
        e.consume
        editor.repaint
        return true
      case Keys.unindent:
        onTab(false);
        e.consume
        editor.repaint
        return true
    }
    return false
  }
  
//////////////////////////////////////////////////////////////////////////
// tab indent
//////////////////////////////////////////////////////////////////////////

  private Void onTab(Bool indent)
  {
    // if batch indent/detent
    if (editor.hasSelected) { onBatchTab(indent); return }

    // indent single line
    if (indent)
    {
      col := caret.offset + 1
      while (col % options.tabSpacing != 0) col++
      spaces := Str.spaces(col - caret.offset)
      pos := doc.offsetAtLine(caret.lineIndex) + caret.offset
      modify(pos, 0, spaces)
    }
    else
    {
      line := doc.line(caret.lineIndex)
      col := caret.offset - 1
      while (col % options.tabSpacing != 0 && line[col].isSpace) col--
      if (col < 0) col = 0
      if (col == caret.offset) return
      pos := doc.offsetAtLine(caret.lineIndex) + col
      modify(pos, caret.offset-col, "")
    }
  }

  private Void onBatchTab(Bool indent)
  {
    changes := Change[,]
    SelectionInfo sel := SelectionInfo()
    sel.init(editor)
    endLine := sel.selectionEndLine
    
    changeLen := 0
    
    if (endLine > sel.selectionStartLine && sel.selectionEndOffset == 0) endLine--
    for (linei := sel.selectionStartLine; linei <= endLine; ++linei)
    {
      pos := doc.offsetAtLine(linei)
      if (indent)
      {
        spaces := Str.spaces(options.tabSpacing)
        changes.add(SimpleChange(pos, "", spaces))
        changeLen += spaces.size
      }
      else
      {
        // find first non-space
        first := 0
        line := doc.line(linei)
        while (first < line.size && line[first].isSpace) first++

        if (first == 0) continue
        len := first.min(options.tabSpacing)
        changes.add(SimpleChange(pos, Str.spaces(len), ""))
        
        changeLen -= len
      }
      changes.last.execute(editor)
    }

    if (changes.size > 0)
    {
      batch := BatchChange(changes)
      //batch.execute(editor)
      changeStack.push(batch)
      
      editor.selectionEnd += changeLen
      editor.updateCaretByOffset(editor.selectionEnd)
    }
  }
  
//////////////////////////////////////////////////////////////////////////
// Brace Matching
//////////////////////////////////////////////////////////////////////////

  Void clearBraceMatch()
  {
    if (doc.bracketLine1 == null) return
    oldLine1 := doc.bracketLine1
    oldLine2 := doc.bracketLine2
    doc.bracketLine1 = doc.bracketCol1 = null
    doc.bracketLine2 = doc.bracketCol2 = null
    editor.repaint
  }

  Void checkBraceMatch(Int offset)
  {
    // clear old brace match
    clearBraceMatch

    // get character before caret
    lineIndex := doc.lineAtOffset(offset)
    lineOffset := doc.offsetAtLine(lineIndex)
    col := offset-lineOffset-1
    if (lineOffset >= offset) return
    ch := doc.line(lineIndex)[col]
    if (!doc.rules.brackets.containsChar(ch)) return

    // attempt to find match
    matchOffset := doc.matchBracket(offset-1)
    if (matchOffset == null) return
    matchLine := doc.lineAtOffset(matchOffset)

    // cache bracket locations doc and repaint
    matchCol := matchOffset-doc.offsetAtLine(matchLine)
    doc.setBracketMatch(lineIndex, col, matchLine, matchCol)
    editor.repaint
  }
}
