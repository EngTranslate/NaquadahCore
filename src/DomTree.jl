include("GraphDraw.jl")
include("DomUtilities.jl")

#include("Events.jl")
module NaquadahDOM

import Base
using JSON, Requests
using Naquadraw # , NaquadahEvents






export Page, FetchPage
# ======================================================================================
# ======================================================================================
type Page
         parent::Any  # First node needs a Psudo-parent too ..maybe!
         children::Array{Element,1} # First node in a tree-like data structure representing all elements on page
         styles::Dict
         head::Dict

         url::Any         # URL of page
         # events::EventTypes  # All registered events
         flags::BitArray{1}        #  buttonPressed
         mousedown::Point       # These may be better than trying to copy the nodes
         mouseup::Point
         focusNode::Any
         hoverNode::Any
         canvas::Any
         event::EventType
         # ui::PageUI   # Window
             function Page(url::String)
                     children::Array{Element,1} = [Element()]
                     parent = children[1]
                     children[1].parent = parent
                 new(parent, children, Dict(), Dict(), url, falses(8), Point(0, 0), Point(0, 0), 0, 0, 0, EventType())
             end
end
include("DomToLayout.jl")

# ======================================================================================
# Print out Dict but not children
# CALLED FROM: Below, third button event line 100+
# ======================================================================================

# ======================================================================================
#
# ======================================================================================
function CreateDomTree(document::Page, parent::Element)
    DOM = parent.DOM
        if isa(DOM["nodes"], Array)
            DOM_nodes = DOM["nodes"]

            for i in eachindex(DOM_nodes)
                push!(parent.children, Element(DOM_nodes[i]))
                    node = parent.children[end]

                    if haskey(DOM_nodes[i], "nodes") # Instantiate Children
                        CreateDomTree(document, node)
                    end
            end
        end
end

# ======================================================================================
#
# ======================================================================================
function FetchPage(URL::String, canvas)
       # .......................................................................
       # get the file...
       uri = URI(URL)
              if uri.scheme == "file"
                 File = pwd() * uri.path
                       Page_text = readstring(open(File))
              elseif uri.scheme == "http" || uri.scheme == "https"
                  got = get(URL; timeout = 10.0)
                  Page_text = readall(got)
              end

        pageContent = JSON.parse(Page_text)
        # ......................................................................
        document = Page(URL)
        document.canvas = canvas
        node = document.children[1]
        parent = document.parent

        if haskey(pageContent, "head")
            document.head = pageContent["head"]
        end
        if haskey(pageContent, "style")
            document.styles = pageContent["style"]
        end
        if haskey(pageContent, "body")
            node.DOM = Dict( ">" => "window", "display" => "inline-block", "padding" => [10,10,10,10],
                  "font" => Dict( "size" => 13, "family" => "Sans", "weight" => "bold", "color" => "black" )	)
                #  , "nodes" => []
            #push!(node.DOM["nodes"], Dict("nodes" => pageContent["body"]))
            node.DOM["nodes"] = pageContent["body"]
        end
        # ......................................................................
        # ParseDictionary(document, node)  # maybe some extra preproccessing.
        # SetDOMdefaults(document, node) # Set tag, class and style attributes.
        CreateDomTree(document, node)
        # SetConstantAtributes(document, node) # this is to set layout attributes that will not change
        return document
end



# ==============================================================================

# ======================================================================================
#
# ======================================================================================
end # module










# ======================================================================================
# ======================================================================================
# type Point
#     x::Float32
#     y::Float32
# end
# ======================================================================================

# ======================================================================================


# type Doc
#   document::Element
#   event::EventType
#   canvas::Any
#   Doc(document) = new(document,EventType(), 0)
# end
