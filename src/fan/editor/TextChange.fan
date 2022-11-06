//
// Copyright (c) 2012, Brian Frank
// Licensed under the Academic Free License version 3.0
//
// History:
//   22 Apr 12  Brian Frank  Creation
//

using vaseGraphics
using syntax
using concurrent

**************************************************************************
** ChangeStack
**************************************************************************
class ChangeStack
{
  new make()
  {
    this.changes = Change[,]
    this.curChange = -1
  }

  ** Push a Change onto the stack.
  Void push(Change change)
  {
    // everything has been undone -- reset stack
    if (curChange == -1)
    {
      changes = [,]
      changes.push(change)
    }
    // at least one change has been undone -- truncate stack
    else if (curChange < changes.size - 1)
    {
      changes = changes[0..curChange]
      changes.push(change)
    }
    // nothing has been undone -- proceed 'normally'
    else
    {
      if (change is SimpleChange)
      {
        simple := change as SimpleChange
        // Maybe we can merge this change with the previous one.
        // This represents an 'in-progress' edit that is inserting
        // characters sequentially.
        top := changes.peek as SimpleChange
        if (isAtomicUndo(top, simple))
        {
          changes[-1] = SimpleChange(top.pos, top.oldText, top.newText+simple.newText)
        }
        else
        {
          changes.push(simple)
        }
      }
      else
      {
        changes.push(change)
      }
    }
    curChange = changes.size - 1
    //dump
  }
  private Bool isAtomicUndo(SimpleChange? a, SimpleChange b)
  {
    if (a == null) return false
    if (a.oldText.size > 0) return false
    if (b.newText.size > 1) return false
    return a.pos + a.newText.size == b.pos
  }

  ** Undo a change.  Do nothing if all change have
  ** already been undone.
  Void onUndo(TextEditor editor)
  {
    if (curChange == -1) return
    c := changes[curChange--]
    c.undo(editor)
    //dump
  }

  ** Redo a change.  Do nothing if all change have
  ** already been redone.
  Void onRedo(TextEditor editor)
  {
    if (curChange == changes.size - 1) return
    c := changes[++curChange]
    c.execute(editor)
  }
  ** Debug dump of the ChangeStack.
  **
  internal Void dump(OutStream out := Env.cur.out)
  {
    out.printLine("")
    out.printLine("==== ChangeStack.dump ===")
    out.printLine("size=$changes.size")
    out.printLine("curChange=$curChange")
    changes.each |Change change| { out.printLine(change.toStr) }
    out.printLine("")
    out.flush
  }

  private Change[] changes
  // this points to the last change that was executed
  private Int curChange
}

**************************************************************************
** Change
**************************************************************************
abstract const class Change
{
  abstract Void execute(TextEditor editor)
  abstract Void undo(TextEditor editor)
}

**************************************************************************
** SimpleChange
**************************************************************************
const class SimpleChange : Change
{
  new make(Int pos, Str oldText, Str newText)
  {
    this.pos     = pos
    this.oldText = oldText
    this.newText = newText
  }
  override Str toStr()
  {
    "[SimpleChange pos:$pos oldText:'$oldText' newText:'$newText']"
  }

  const Int pos
  const Str oldText
  const Str newText

  override Void execute(TextEditor editor)
  {
    doc := editor.model
    replaceText(editor, pos, oldText.size, newText)
  }

  override Void undo(TextEditor editor)
  {
    doc := editor.model
    replaceText(editor, pos, newText.size, oldText)
  }

  ** replace whatever is in the given span with the given text
  private Void replaceText(TextEditor editor, Int start, Int len, Str text)
  {
    editor.model.modify(start, len, text)
    newPos := start + text.size
    pos := editor.model.posAtOffset(newPos)
    editor.goto(pos.y, pos.x)
  }
}

**************************************************************************
** BatchChange
**************************************************************************
const class BatchChange : Change
{
  new make(Change[] changes) { this.changes = changes }
  const Change[] changes
  override Str toStr()
  {
    "[BatchChange changes:$changes]"
  }

  override Void execute(TextEditor editor)
  {
    changes.each |c| { c.execute(editor) }
  }

  override Void undo(TextEditor editor)
  {
    changes.eachr |c| { c.undo(editor) }
  }
}


