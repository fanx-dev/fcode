//
// Copyright (c) 2011, chunquedong
// Licensed under the Academic Free License version 3.0
//
// History:
//   2015-12-5  Jed Young  Creation
//
using vaseGui
using vaseGraphics

class ProjTreeView
{
  MainFrame frame
  new make(MainFrame frame) {
    this.frame = frame
  }
  
  Widget view() {
    ResizePane {
        layout.height = Layout.matchParent
        layout.width = 500
        padding = Insets(0, 15, 0, 0)
        inlineStyle = ResizePaneStyle { background = Color(0x555555); stroke = true; outlineColor = Color.black }
        TreeView {
            model = ProjTreeModel()
            onSelected = |TreeItem item, Int clickType| {
                frame.onSelectFile(item.node, clickType == 4)
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