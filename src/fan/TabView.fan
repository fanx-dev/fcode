// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   2022-10-30 yangjiandong Creation
//
using vaseGui
using vaseGraphics

**
** TabsView
**
class TabView
{
  EdgeBox pane
  HBox tabBar
  Widget[] views = [,]
  
  Int curTab = -1
  
  new make() {
    tabBar = HBox{}
    pane = EdgeBox {
        layout.height = Layout.matchParent
        top = tabBar
    }
  }
  
  Void addTab(Str name, Widget v, Bool newTab) {
    if (curTab == -1 || newTab) {
        pane.center = v
        tabBar.add(makeTab(name, v))
        views.add(v)
        curTab = views.size-1
        pane.relayout
        return
    }
    
    views[curTab] = v
    tabBar.replaceAt(curTab, makeTab(name, v))
    pane.center = v
    pane.relayout
  }
  
  private Widget makeTab(Str name, Widget v) {
    HBox {
        inlineStyle = PaneStyle { background = Color(0x555555) }
        padding = Insets(10)
        layout.width = Layout.wrapContent
        Label { layout.width = Layout.wrapContent; it.text = name },
    }
  }
}
