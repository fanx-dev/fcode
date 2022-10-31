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


class MainFrame
{
  ProjTreeView treeView
  Toolbar toolbar
  HBox bottmBox
  Label bottomLabel
  TabView tabView
  
  new make() {
    treeView = ProjTreeView(this)
    toolbar = Toolbar(this)
    
    bottmBox = HBox {
      inlineStyle = PaneStyle { background = Color(0x555555) }
      padding = Insets(10)
      Label {
        bottomLabel = it
        text = ""
        inlineStyle = LabelStyle { fontColor = Color.white }
      },
    }
    
    tabView = TabView()
    
    onSelectFile(File.os("D:\\workspace\\temp\\swing.fan"), true)
  }
  
  Void onSelectFile(File f, Bool newTab) {
    if (f.isDir) {
    
    }
    else {
        try {
            text := f.readAllStr
            editor := TextEditor {
                model = SyntaxModel(f, text)
            }
            tabView.addTab(f.uri.toStr, f.name, editor, newTab)
        }
        catch (Err e) {
            e.trace
        }
    }
  }
  
  Void show() {
    vaseGui::Frame {
      name = "FCode"
      Pane {
        layout.height = Layout.matchParent
        EdgeBox
        {
          //inlineStyle = PaneStyle { background = Color(0x555555) }
          layout.height = Layout.matchParent
          top = VBox {
            spacing = 0
            toolbar.menue,
            toolbar.makeToolBar,
          }
          left = treeView.view
          center =  tabView.pane
          //right = fieldView.view
          bottom = bottmBox
        },
      },
    }.show
  }
}