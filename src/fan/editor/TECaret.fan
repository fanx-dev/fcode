// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   2022-10-30 yangjiandong Creation
//

using vaseGraphics
using vaseWindow
using vaseGui


class TECaret : Caret {

  //pixcel position
  internal Int x
  internal Int y

  Int lineIndex := 0

  TextEditor area

  protected TextInput? host

  private Bool isActive := false
  
  new make(TextEditor area) { this.area = area }

  Void open() {
    isActive = true
    init
  }

  Void close() {
    isActive = false
    hide
  }
  
  private Void init() {
    if (!isActive) return
    if (host != null) return
    Int inputType = 1
    host = area.getRootView?.host?.textInput(inputType)
    if (host == null) return
    
//    host.onTextChange = |Str text->Str| {
//        if (!invalidChagneEvent && text != this.text) {
//            area.controller.modify(area.model.offsetAtLine(lineIndex), area.model.line(lineIndex).size, text)
//            area.repaint
//        }
//        return text
//    }

    host.onKeyPress = |KeyEvent e| {
        area.controller.keyEvent(e)
        if (e.type == KeyEvent.typed) {
            Toolkit.cur.callLater(0) |->| {
                host.setText("")
            }
        }
    }
  }

  internal Void updateHost(Bool all := true) {
    init
    if (host == null) return

    if (!all) {
      c := area.posOnWindow
      host.setPos(c.x.toInt+x, c.y.toInt+y, 1, area.rowHeight)
      return
    }
    

    host.setType(0, true)

    c := area.posOnWindow
    host.setPos(c.x.toInt+x, c.y.toInt+y, 1, area.rowHeight)

    host.setStyle(area.font, Color.black, Color.white)
    host.setText("")
    //host.select(this.offset, this.offset)
    host.focus
    
  }
  
  //private Str text() { area.model.line(lineIndex) }
  
  Void hide() {
    if (host != null) {
      host.close
      host = null
    }
  }
}