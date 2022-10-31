// To change this License template, choose Tools / Templates
// and edit Licenses / FanDefaultLicense.txt
//
// History:
//   2022-10-30 yangjiandong Creation
//
using vaseGraphics
using vaseWindow
using syntax


internal class StyledLine {
    Obj[] segs = [,]
}

**
** SyntaxModel
**
class SyntaxModel : DefTEModel
{
    File file
    SyntaxRules? rules
    TEOptions options
    private StyledLine[]? styledLines
    
    new make(File f, Str text) : super.make(text) {
        options = TEOptions()
        file = f
        rules = SyntaxRules.loadForFile(file)
        parse(file.in)
    }
    
    RichTextStyle findStyle(SyntaxType type) {
        switch (type) {
        case SyntaxType.text:
            return options.text
        case SyntaxType.bracket:
            return options.bracket
        case SyntaxType.keyword:
            return options.keyword
        case SyntaxType.literal:
            return options.literal
        case SyntaxType.comment:
            return options.comment
        }
        return options.text
    }
    
    Void parse(InStream in) {
        if (rules == null) return
        styledLines = [,]
        
        SyntaxDoc? doc
        try
            doc = SyntaxParser(rules).with { it.tabsToSpaces = 0 }.parse(in)
        finally
            in.close

        doc.eachLine |SyntaxLine line| {
            sline := StyledLine()
            pos := 0
            line.eachSegment |type, text| {
                sline.segs.add(pos)
                style := findStyle(type)
                sline.segs.add(style)
                
                //Env.cur.out.print("[$pos][$type]$text")
                pos += text.size
            }
            //Env.cur.out.print("\n")
            styledLines.add(sline)
        }
    }
    
    ** [Int, RichTextStyle, Int, RichTextStyle, ...]
    override Obj[]? lineStyling(Int lineIndex) { 
        if (styledLines == null) return null
        if (lineIndex < 0 || lineIndex >= styledLines.size) return null
        return styledLines[lineIndex].segs
    }
    
    protected override Void onTextChanged() {
        parse(text.in)
    }
}
