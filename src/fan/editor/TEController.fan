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
  TextEditor textEditor
  
  new make(TextEditor textEditor) {
    this.textEditor = textEditor
  }

  Void keyEvent(KeyEvent e)
  {
    echo(e)
    if (e.type == KeyEvent.pressed) {
      //echo(e.key)
      if (e.key == Key.left) {
        textEditor.updateCaretAt(textEditor.caret.lineIndex, textEditor.caret.offset-1, false)
        textEditor.clearSelected
        textEditor.repaint
        e.consume
        return
      }
      else if (e.key == Key.right) {
        textEditor.updateCaretAt(textEditor.caret.lineIndex, textEditor.caret.offset+1, false)
        textEditor.clearSelected
        textEditor.repaint
        e.consume
        return
      }
      else if (e.key == Key.down) {
        textEditor.updateCaretAt(textEditor.caret.lineIndex+1, textEditor.caret.offset)
        textEditor.clearSelected
        textEditor.repaint
        e.consume
        return
      }
      else if (e.key == Key.up) {
        textEditor.updateCaretAt(textEditor.caret.lineIndex-1, textEditor.caret.offset)
        textEditor.clearSelected
        textEditor.repaint
        e.consume
        return
      }
      //new line
      else if (e.key == Key.enter) {
        if (textEditor.hasSelected) {
          textEditor.model.modify(textEditor.selectionStart, textEditor.selectionEnd-textEditor.selectionStart, "\n")
        }
        else {
          pos := textEditor.model.offsetAtLine(textEditor.caret.lineIndex) + textEditor.caret.offset
          textEditor.model.modify(pos, 0, "\n")
        }
        textEditor.updateCaretAt(textEditor.caret.lineIndex+1, 0)
        textEditor.clearSelected
        textEditor.repaint
        e.consume
        return
      }
      //copy
      else if (e.key.primary == Key.c && e.key.isCtrl) {
        //echo("copy")
        if (textEditor.hasSelected) {
          Toolkit.cur.clipboard.setText(textEditor.model.textRange(textEditor.selectionStart, textEditor.selectionEnd-textEditor.selectionStart))
        }
        e.consume
        return
      }
      //paste
      else if (e.key.primary == Key.v && e.key.isCtrl) {
        //echo("paste")
        if (textEditor.hasSelected) {
          textEditor.model.modify(textEditor.selectionStart, textEditor.selectionEnd-textEditor.selectionStart, "")
          textEditor.clearSelected
        }

        Toolkit.cur.clipboard.getText |text|{
          if (text == null) lret
          pos := textEditor.model.offsetAtLine(textEditor.caret.lineIndex) + textEditor.caret.offset
          textEditor.model.modify(pos, 0, text)
          textEditor.repaint
        }
        e.consume
        return
      }
      else if (!e.key.hasModifier) {
        if (textEditor.hasSelected) {
          textEditor.model.modify(textEditor.selectionStart, textEditor.selectionEnd-textEditor.selectionStart, "")
          textEditor.clearSelected
          textEditor.repaint
          e.consume
        }
      }
      
    }
  }
  
//////////////////////////////////////////////////////////////////////////
// Brace Matching
//////////////////////////////////////////////////////////////////////////

  Doc doc() { textEditor.model }

  Void clearBraceMatch()
  {
    if (doc.bracketLine1 == null) return
    oldLine1 := doc.bracketLine1
    oldLine2 := doc.bracketLine2
    doc.bracketLine1 = doc.bracketCol1 = null
    doc.bracketLine2 = doc.bracketCol2 = null
    textEditor.repaint
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
    textEditor.repaint
  }
}
