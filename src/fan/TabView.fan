// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   2022-10-30 yangjiandong Creation
//
using vaseGui
using vaseGraphics


internal class TabItem {
    HBox? button
    Str? id
    Widget? view
    Str? name
}

**
** TabsView
**
class TabView
{
  EdgeBox pane
  private HBox tabBar
  private TabItem[] items = [,]

  private Int curTab = -1
  
  new make() {
    tabBar = HBox{
      inlineStyle = PaneStyle { background = Color(0x555555) }
    }
    pane = EdgeBox {
        layout.height = Layout.matchParent
        top = tabBar
    }
  }
  
  private Int findIndex(Str id) {
    return items.findIndex { it.id == id }
  }
  
  private Void activeIndex(Int i) {
    if (i >= items.size) i = -1
    
    if (curTab != -1) {
        tabBar.getChild(curTab).inlineStyle = PaneStyle { background = Color(0x555555); arc = 0 }
    }
    curTab = i
    if (curTab != -1) {
        tabBar.getChild(curTab).inlineStyle = PaneStyle { background = Color.white; arc = 0 }
    }
    
    if (i == -1) {
        pane.center = null
        pane.relayout
        return
    }
    
    item := items[i]
    pane.center = item.view
    pane.center.relayout
    tabBar.relayout
  }
  
  Void addTab(Str id, Str name, Widget v, Bool newTab) {
    //try active
    p := findIndex(id)
    if (p != -1) {
        activeIndex(p)
        return
    }
    
    //add new tab
    if (curTab == -1 || newTab) {
        item := TabItem { it.id = id; it.view = v; it.name = name; it.button = makeTab(id, name, v) }
        items.add(item)
        tabBar.add(item.button)
        activeIndex(items.size-1)
        return
    }
    
    //replace
    item := items[curTab]
    item.id = id
    item.view = v
    item.name = name
    item.button = makeTab(id, name, v)
    tabBar.replaceAt(curTab, item.button)
    activeIndex(curTab)
  }
  
  private Void closeView(Str id, Widget v) {
    i := findIndex(id)
    if (i == -1) return
    
    item := items[i]
    tabBar.remove(item.button)
    items.removeAt(i)
    
    if (curTab < i) {
        tabBar.relayout
        return
    }
    else if (curTab > i) {
        curTab = curTab-1
    }
    else if (curTab == i) {
        if (curTab >= items.size) {
            curTab = curTab-1
        }
    }
    activeIndex(curTab)
  }
  
  private Widget makeTab(Str id, Str name, Widget v) {
    HBox {
        inlineStyle = PaneStyle { background = Color(0x555555); arc = 0 }
        padding = Insets(10)
        layout.width = Layout.wrapContent
        Label {
            layout.width = Layout.wrapContent; it.text = name
            clickAnimation = false
            onClick {
               activeIndex(findIndex(id))
            }
        },
        Button {
            it.text = ""
            layout.width = 50
            layout.height = 50
            padding = Insets(5)
            inlineStyle = ImageButtonStyle { image = Image.fromUri(Uri("fan://fcode/res/close.png")) }
            onClick {
               closeView(id, v)
            }
        },
    }
  }
}
