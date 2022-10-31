//
// Copyright (c) 2011, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2015-12-5  Jed Young  Creation
//
using vaseGui
using vaseGraphics
using vaseWindow

class ProjTreeView
{
  MainFrame frame
  new make(MainFrame frame) {
    this.frame = frame
  }
  
  Widget view() {
    Bool clickValid = true
    
    return ResizePane {
        layout.height = Layout.matchParent
        layout.width = 500
        padding = Insets(0, 15, 0, 0)
        inlineStyle = ResizePaneStyle { background = Color(0x555555); stroke = true; outlineColor = Color.black }
        TreeView {
            model = ProjTreeModel()
            onSelected = |TreeItem item, Int clickType| {
                //double click
                if (clickType == 4) {
                    frame.onSelectFile(item.node, true)
                    clickValid = false
                }
                else {
                    clickValid = true
                    Toolkit.cur.callLater(200) |->|{
                        if (clickValid) {
                          frame.onSelectFile(item.node, false)
                        }
                        clickValid = false
                    }
                }
            }
        },
    }
  }
}

class ProjTreeModel : TreeModel
{
  File[] files = [,]
  
  new make() { files = File.osRoots }
  
  override Obj[] roots() { files }
  override Str text(Obj node) {
    file := node as File
    return file.name
  }
  override Bool hasChildren(Obj node) {
    file := node as File
    return file.isDir
  }
  
  override Obj[] children(Obj node) {
    file := node as File
    return file.list
  }
}