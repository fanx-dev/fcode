class TextChange
{
  ** Zero based offset of modification
  Int startOffset

  ** Zero based line number of modification
  Int startLine

  ** Old text which was replaced
  Str? oldText

  ** New text inserted
  Str? newText

  ** Number of newlines in `oldText` or zero if no newlines
  ** This field will lazily be calcualted if null.
  Int? oldNumNewlines
  {
    get
    {
      if (&oldNumNewlines == null) &oldNumNewlines = numNewlines(oldText)
      return &oldNumNewlines
    }
  }

  ** Number of newlines in `newText` or zero if no newlines.
  ** This field will lazily be calcualted if null.
  Int? newNumNewlines
  {
    get
    {
      if (&newNumNewlines == null) &newNumNewlines = numNewlines(newText)
      return &newNumNewlines
    }
  }
  
  public static Int numNewlines(Str? self)
  {
    if (self == null) return 0
    numLines := 0;
    len := self.size();
    for (i:=0; i<len; ++i)
    {
      c := self[i];
      if (c == '\n') numLines++;
      else if (c == '\r')
      {
        numLines++;
        if (i+1<len && self[i+1] == '\n') i++;
      }
    }
    return numLines;
  }

  ** Zero based offset of where repaint should start, or if
  ** null then `startOffset` is assumed.
  Int? repaintStart

  ** Zero based offset of where repaint should end,
  ** or if null then 'newText.size' is assumed.
  Int? repaintLen

  override Str toStr()
  {
    o := oldText ?: ""; if (o.size > 10) o = o[0..<10]+"..<"
    n := newText ?: ""; if (n.size > 10) n = n[0..<10]+"..<"
    return "startOffset=$startOffset startLine=$startLine " +
           "newText=$n.toCode oldText=$o.toCode " +
           "oldNumNewlines=$oldNumNewlines newNumNewlines=$newNumNewlines"
  }

//////////////////////////////////////////////////////////////////////////
// Undo/Redo Support
//////////////////////////////////////////////////////////////////////////

  **
  ** Undo this modification on the given widget.
  **
  Void undo(TextEditor widget)
  {
    //widget.modify(startOffset, newText.size, oldText)
    //widget.select(startOffset + oldText.size, 0)
  }

  **
  ** Redo this modification on the given widget.
  **
  Void redo(TextEditor widget)
  {
    //widget.modify(startOffset, oldText.size, newText)
    //widget.select(startOffset + newText.size, 0)
  }

}