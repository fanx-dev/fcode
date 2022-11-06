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

internal class SelectionInfo {
  Int selectionStartLine := -1
  Int selectionEndLine := -1
  Int selectionStartOffset := -1
  Int selectionEndOffset := -1
  Bool hasSelection := false
  
  internal Void init(TextEditor area, Int startLine = -1, Int endLine = Int.maxVal) {
    //get selection
    hasSelection = false
    if (area.hasSelected)
    {
      min := area.selectionStart.min(area.selectionEnd)
      max := area.selectionEnd.max(area.selectionStart)
      selectionStartLine = area.model.lineAtOffset(min)
      selectionEndLine = area.model.lineAtOffset(max)

      selectionStartOffset = min - area.model.offsetAtLine(selectionStartLine)
      selectionEndOffset = max - area.model.offsetAtLine(selectionEndLine)

      if (selectionStartLine > endLine || selectionEndLine < startLine)
      {
      }
      else
      {
        hasSelection = true
      }
    }
  }
}

class TEStyle : WidgetStyle
{
  private SelectionInfo selectionInfo := SelectionInfo()
  private Int selStart := -1
  private Int selEnd := -1
  
  private Void getLineSelectInfo(Int i, Int lineSize) {
      if (selectionInfo.hasSelection)
      {
        if (i == selectionInfo.selectionStartLine) {
          selStart = selectionInfo.selectionStartOffset
        }
        else if (i > selectionInfo.selectionStartLine) {
          selStart = 0
        }
        else {
          selStart = -1
        }

        if (i == selectionInfo.selectionEndLine) {
          selEnd = selectionInfo.selectionEndOffset
        }
        else if (i < selectionInfo.selectionEndLine) {
          selEnd = lineSize
        }
        else {
          selEnd = -1
        }
      }
      else {
        selStart = -1
        selEnd = -1
      }
  }
    
  override Void doPaint(Widget widget, Graphics g)
  {
    TextEditor area := widget
    top := widget.paddingTop
    left := widget.paddingLeft
    font := this.font(widget)
    g.font = font

    Int startLine := area.offsetY / area.rowHeight
    Int topOffset := area.offsetY - (startLine * area.rowHeight)
    Int endLine := ((area.offsetY+area.contentHeight).toFloat/area.rowHeight).ceil.toInt
    if (endLine >= area.model.lineCount) {
      endLine = area.model.lineCount
    }
    Int fontOffset := font.ascent + font.leading

    selectionInfo.init(area, startLine, endLine)

    //echo("hasSelection:$hasSelection: $selectionStartLine($area.selectionStart), $selectionEndLine($area.selectionEnd)")
    lineNumWidth := 3.max(Math.log10(area.model.lineCount.toFloat).ceil.toInt) * font.width("8") + font.height
    area.textLeftSideOffset = lineNumWidth

    //draw line
    Int x := -area.offsetX + left + lineNumWidth
    Int y := -topOffset + top
    //Int bottomY := top + area.contentHeight
    for (i := startLine; i< endLine; ++i)
    {
      lineText := area.model.line(i)
      getLineSelectInfo(i, lineText.size)
      
      //echo("- $selStart, $selEnd")
      lineStyle := area.model.lineStyling(i)
      drawLineText(g, area.rowHeight, fontOffset, x, y, lineText, selStart, selEnd, lineStyle)

      y += area.rowHeight
      //if (y > bottomY) {
      //  break
      //}
    }
    
    //drawLineNum
    g.brush = Color.gray
    pos := -topOffset + top
    x = left + dpToPixel(4)
    for (i := startLine; i< endLine; ++i)
    {
        text := (i+1).toStr
        g.drawText(text, x, pos+fontOffset)
        pos += area.rowHeight
    }

    //draw caret
    drawCaret(area, g, startLine, endLine)
  }

  private Void drawCaret(TextEditor area, Graphics g, Int startLine, Int endLine) {
    if (area.caret.visible)
    {
      Int lineIndex := area.caret.lineIndex
      if (lineIndex < startLine || lineIndex > endLine)
      {
      }
      else
      {
        Int y := area.caret.y
        Int x = area.caret.x
        //echo("x $x, offsetX:${area.offsetX} ${line[0..<xOffset]}")
        g.brush = Color.black
        g.lineWidth = dpToPixel(5).toFloat
        g.drawLine(x, y, x, y + area.rowHeight)
      }
    }
  }
  
  private Str convertTab(Str str) {
    return str.replace("\t", "    ")
  }

  protected virtual Void drawLineText(Graphics g, Int rowHeight, Int fontOffset
     , Int left, Int top, Str text, Int selStart, Int selEnd, Obj[]? lineStyle)
  {
    //backgound
    if (selStart >= 0 && selEnd >= 0)
    {
      g.brush = Color.makeRgb(200, 200, 200)
      selection := text[selStart..<selEnd]
      g.fillRect(g.font.width(text[0..<selStart])+left, top, g.font.width(selection), rowHeight)
    }

    //text
    if (lineStyle == null) {
        g.brush = fontColor
        g.drawText(text, left, top+fontOffset)
    }
    else {
        for (i:= 0; i<lineStyle.size; i += 2) {
            try {
                Int pos := lineStyle[i]
                Int end = text.size
                if (i+2 < lineStyle.size) {
                    end = lineStyle[i+2]
                }
                str := text[pos..<end]
                str = convertTab(str)
                textw := g.font.width(str)
                
                fcode::RichTextStyle style := lineStyle[i+1]
                if (style.bg != null) {
                    g.brush = style.bg
                    g.fillRect(left, top, textw, g.font.height)
                }
                g.brush = style.fg
                //echo("$str: $textw")
                g.drawText(str, left, top+fontOffset)
                left += textw
            } catch (Err e) {
                e.trace
                echo("ERROR: text:"+text)
                echo("ERROR: style:"+lineStyle)
            }
        }
    }
  }
}