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
        InitializeRow(child, l,t,w,h ) # sterilize!

        AtributesToLayout(child)
        if isa(child.shape, NText) #node.shape.flags[] == true row =
            textToRows(node, child)
        else
            PushToRow(node, child)
        end

        CreateLayoutTree(document, child)

    end
end
# ======================================================================================
function DrawANode(document)
    c = document.canvas
    print("length", length(document.children) )
    node = document.children[1]
   @guarded draw(c) do widget
         # document
         #tab = Doc(n)
         #tab.canvas = c
         AttatchEvents(document)


       ctx = getgc(c)
        h = height(c)
        w = width(c)
       set_antialias(ctx,1)
       setWindowSize(w,h, node)
       CreateLayoutTree(document, node)

       # node = n.children[1]
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
