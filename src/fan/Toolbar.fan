// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   2022-10-30 yangjiandong Creation
//
using vaseGui
using vaseGraphics
using vaseWindow
using concurrent


class Toolbar {
  MainFrame frame

  new make(MainFrame frame) {
    this.frame = frame
  }

  Widget menue() {
    Menu
    {
      MenuItem
      {
        text = "$<File>"
        MenuItem
        {
          text = "$<Open>"
          onClick {

          }
        },
        MenuItem
        {
          text = "$<Save>"
          onClick {

          }
        },
      },
      MenuItem
      {
        text = "$<Help>"
        MenuItem
        {
          text = "$<About>"
          onClick
          {
            AlertDialog("chunmap editor 2.0, $<CopyRight>", "OK").show(it)
          }
        },
      },
    }
  }

  Widget makeToolBar()
  {
    HBox
    {
      inlineStyle = PaneStyle { background = Color(0x444444); arc = 0 }
      padding = Insets(0, 0, 8, 0)
      Button {
            tooltip = "$<Save>"
            it.text = ""
            layout.width = 70
            layout.height = 70
            padding = Insets(20)
            inlineStyle = ImageButtonStyle { image = Image.fromUri(Uri("fan://fcode/res/save.png")) }
            onClick {
               // save()
            }
      },
    }
  }
}