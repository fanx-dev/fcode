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
  Int x
  Int y

  Int lineIndex := 0

  TextEditor area

  new make(TextEditor area) { this.area = area }

  protected TextInput? host
  
  private Void init() {
    if (host != null) return
    Int inputType = 1
    host = area.getRootView?.host?.textInput(inputType)
    if (host == null) return
    
    host.onTextChange = |Str text->Str| {
        area.model.modifyLine(lineIndex, text, false)
        area.repaint
        return text
    }
    host.onKeyPress = |e| {
        area.keyEvent(e)
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
    host.setText(text)
    host.select(this.offset, this.offset)
    host.focus
  }
  
  private Str text() { area.model.line(lineIndex) }
  
  Void hide() {
    if (host != null) {
      host.close
      host = null
    }
  }
}