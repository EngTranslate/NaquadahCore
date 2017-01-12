# module NaquadahCore
#   package code goes here
# end # module

include("GraphDraw.jl")
include("DomUtilities.jl")
include("DomTree.jl")

using Gtk, Gtk.ShortNames, Cairo   # Colors
using NaquadahDOM, Naquadraw


defaultPage = "file:///src/SamplePages/test.json"
global PATH = pwd() * "/data/"



function CreateLayoutTree(document, node)
    isa(node.shape, NText) && return

    node.rows  = []
    l,t,w,h = getContentBox(node.shape, getReal(node.shape)...)
    children = node.children

    for i in 1:length(children)
        child = children[i]
        length(child.children) > 0   &&   Row(child.rows, l,t,w)
        AtributesToLayout(child)
        if isa(child.shape, NText) #node.shape.flags[] == true row =
            textToRows(node, child)
        else
            PushToRow(node, child)
        end

        CreateLayoutTree(document, child)
        if child.shape.flags[FixedHeight] == false
            child.shape.height = child.scroll.contentHeight
            if child.scroll.contentHeight > node.rows[end].height
                node.rows[end].height = child.scroll.contentHeight
            end
        end
    end

    if length(node.rows) > 0
        node.scroll.contentHeight = node.rows[end].y + node.rows[end].height - node.shape.top
        node.scroll.contentWidth  = node.rows[end].x + node.rows[end].width  - node.shape.left
    end
end
# ======================================================================================
function DrawANode(document)
    c = document.canvas
    node = document.children[1]

   @guarded draw(c) do widget
        ctx = getgc(c)
        h   = height(c)
        w   = width(c)
       set_antialias(ctx,1)
       setWindowSize(w,h, node)
       AttatchEvents(document)
       CreateLayoutTree(document, node)
       MoveAll(node,node.scroll.x,node.scroll.y)
       DrawContent(ctx, node)
   end
show(c)
end
# ======================================================================================
c = @Canvas()
win = @Window("Canvas", 1000, 800)
push!(win, c)
document = FetchPage(defaultPage, c)
DrawANode(document)
