//
// Copyright (c) 2011, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2012-07-15  Jed Young  Creation
//

using vaseGraphics
using vaseWindow
using vaseGui

**
** Text
**
class TextEditor : ScrollPane
{  
  Bool isReadonly = false
  
  ** offset for lineNumber
  internal Int textLeftSideOffset := 0

  **
  ** Convenience for 'model.text' (model must be installed).
  **
  Str text
  {
    get { return model.text }
    set { model.text = it }
  }


  Int rowHeight() { font.height }

  @Transient
  TECaret caret := TECaret(this) { private set }

  internal Font font() {
    getStyle.font(this)
  }


  ** Inclusive start position
  Int selectionStart := -1

  ** Exclusive end position
  Int selectionEnd := -1

  @Transient
  private Bool draging := false
  
  TEController controller { private set }

  new make(|This|? f := null)
  {
    this.inlineStyle = TEStyle {
        fontInfo.name = "Monospaced"
        fontInfo.size = 36
    }
    
    if (f != null) f(this)
    super.autoScrollContent = false
    autoResetOffset = true
    focusable = true
    dragable = false
    
    onFocusChanged.add |e| {
      focused := e.data
      if (!focused) {
        caret.hide
        repaint
      }
    }
    
    controller = TEController(this)
  }

  protected override Size prefContentSize(Int hintsWidth := -1, Int hintsHeight := -1) {
    Int h := model.lineCount * rowHeight

    Int max := 0
    Int maxIndex := 0
    n := model.lineCount
    for (i:=0; i<n; ++i)
    {
      line := model.line(i)
      if (max < line.size)
      {
        max = line.size
        maxIndex = i
      }
    }
    w := font.width(model.line(maxIndex))
    return Size(w, h)
  }


  **
  ** Backing data model of text document.
  ** The model cannot be changed once the widget has been
  ** been mounted into an open window.
  **
  @Transient
  TEModel? model := DefTEModel("")

//////////////////////////////////////////////////////////////////////////
// Utils
//////////////////////////////////////////////////////////////////////////

  internal Void updateCaretByOffset(Int offset) {
    position := model.posAtOffset(offset)
    updateCaretAt(position.y, position.x)
  }

  private Int? updateCaretByCoord(Int x, Int y) {
    Int absX := x + offsetX
    Int absY := y + offsetY

    //echo("absX$absX,absY$absY,dx$offsetX,dy$offsetY")

    Int lineIndex := absY / rowHeight
    if (lineIndex >= model.lineCount) return null
    Int lineOffset := textIndexAtX(model.line(lineIndex) , absX)

    updateCaretAt(lineIndex, lineOffset)

    return model.offsetAtLine(lineIndex) + lineOffset
  }

  protected override Void doPaint(Rect clip, Graphics g) {
    //update caret pos before paint
//    if (caret.host != null) {
//      caretPos := caret.host.caretPos
//      if (caret.offset != caretPos) {
//        echo("reset caret: $caret.offset to $caretPos")
//        updateCaretAt(caret.lineIndex, caretPos, true, false)
//      }
//    }
    super.doPaint(clip, g)
  }

  internal Void updateCaretAt(Int row, Int column, Bool clipColumn := true, Bool updateAll := true) {
    //echo("updateCaretAt row $row column $column")

    if (row < 0) row = 0
    else if (row >= model.lineCount) row = model.lineCount-1

    if (clipColumn) {
      if (column < 0) column = 0
      else if (column > model.line(row).size) column = model.line(row).size
    }
    else {
      if (column == -1) {
        --row
        if (row < 0) row = 0
        column = model.line(row).size
      }
      if (column > model.line(row).size) {
        if (row < model.lineCount-1) {
          ++row
          column = 0
        }
        else if (column > 0) {
          --column
        }
      }
    }

    //echo("row $row column $column ${model.line(row)}")

    caret.lineIndex = row
    caret.y = (row) * rowHeight - offsetY
    caret.x = font.width(model.line(row)[0..<column]) + textLeftSideOffset - offsetX
    //caret.offset = model.offsetAtLine(row) + column
    caret.visible = true
    if (caret.y < 0 || caret.y+rowHeight > this.height) caret.visible = false
    if (caret.x < 0 || caret.x > this.width) caret.visible = false
    caret.offset = column

    if (caret.visible)
        caret.updateHost(updateAll)
    else
        caret.hide
        
    controller.checkBraceMatch(model.offsetAtLine(caret.lineIndex) + caret.offset)
  }

  **
  ** Map a coordinate on the widget to an offset in the text,
  ** or return null if no mapping at specified point.
  **
  private Int? offsetAtScreen(Int x, Int y)
  {
    Int absX := x + offsetX
    Int absY := y + offsetY

    //echo("absX$absX,absY$absY,dx$offsetX,dy$offsetY")

    Int lineIndex := absY / rowHeight
    if (lineIndex >= model.lineCount) return null
    Int lineOffset := textIndexAtX(model.line(lineIndex) , absX)
    return model.offsetAtLine(lineIndex) + lineOffset
  }

  private Int textIndexAtX(Str text, Int w)
  {
    w = w - textLeftSideOffset
    Int size := text.size
    for (i := 0; i<size; ++i)
    {
      Int tw := font.width(text[0..<i+1])
      if (tw > w) {
        //echo(text[0..<i+1] + ":tw$tw, w$w")
        return i
      }
    }
    return size
  }

  override Void onViewportChanged()
  {
    updateCaretAt(caret.lineIndex, caret.offset, false)
  }

//////////////////////////////////////////////////////////////////////////
// 
//////////////////////////////////////////////////////////////////////////

  **
  ** Ensure the editor is scrolled such that the specified line is visible.
  **
  Void goto(Int lineIndex, Int lineOffset)
  {
    updateCaretAt(lineIndex, lineOffset)
  }
  
  Bool hasSelected() {
    selectionStart != selectionEnd && selectionStart != -1 && selectionEnd != -1
  }
  
  Void clearSelected() {
    selectionStart = -1
    selectionEnd = -1
  }
  
//////////////////////////////////////////////////////////////////////////
// Event
//////////////////////////////////////////////////////////////////////////

  protected override Void motionEvent(MotionEvent e)
  {
    super.motionEvent(e)
    //if (e.consumed) return

    sx := e.relativeX - this.x
    sy := e.relativeY - this.y
    if (e.type == MotionEvent.pressed)
    {
      //echo("e.x$e.x,e.y$e.y")
      this.focus
      clearSelected
      offset := updateCaretByCoord(sx, sy) ?: model.charCount
      selectionStart = offset
      selectionEnd = -1
      draging = true
      //if (caret.host != null) caret.host.update
      //focus
      this.repaint
      e.consume
    }
    else if (draging)
    {
      if (e.type == MotionEvent.moved) {
        selectionEnd = offsetAtScreen(sx, sy) ?: model.charCount
        this.repaint
        //echo("move: $selectionStart, $selectionEnd")
        e.consume
      }
      if (e.type == MotionEvent.released) {
        //swap value
        if (selectionStart > selectionEnd)
        {
          temp := selectionStart
          selectionStart = selectionEnd
          selectionEnd = temp
        }
        
        //updateCaretByCoord(sx, sy)
        if (caret.host != null) {
          caret.updateHost
          //caret.host.select(caret.offset, caret.offset)
        }
        draging = false
        e.consume
        this.repaint
      }
    }
    else if (e.type == MotionEvent.released) {
      //updateCaretByCoord(sx, sy)
      if (caret.host != null) {
        caret.updateHost
        //caret.host.select(caret.offset, caret.offset)
      }
      draging = false
    }
  }


//  override Void keyEvent(KeyEvent e)
//  {
//    controller.keyEvent(e)
//  }

}
