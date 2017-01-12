include("ColorDefinitions.jl")
export AtributesToLayout
# ======================================================================================
# EX: GetTheColor(border["color"])
# CALLED FROM:
# ======================================================================================
function GetTheColor(DOMColor)
                if isa(DOMColor, Array)
                    if length(DOMColor) == 3
                        color = [DOMColor[1]+0.0,DOMColor[2]+0.0,DOMColor[3]+0.0]
                    else
                        color = [DOMColor[1]+0.0,DOMColor[2]+0.0,DOMColor[3]+0.0,DOMColor[4]+0.0]
                    end
                else
                    c = collect(color_names[ DOMColor ])
                    color = [c[1]*0.00390625, c[2]*0.00390625, c[3]*0.00390625]
                end
        # TODO: Add opacity
        #  if node.flags[HasOpacity] == true && length(color) == 3
        #      push!(color,node.opacity)
        #  end
    return color
end
# ======================================================================================
function AtributesToLayout(node)
    DOM = node.DOM


    if haskey(DOM, ">")
      E = DOM[">"]
      if E == "div"
          node.shape = NBox()
      end

      if E == "circle"
          node.shape = Circle()
      end
      if E == "p"
          node.shape = NText()
      end
      if E == "arc"
          node.shape = Arc()
      end
      # println(node.shape)
      #.........................................................................""

      if haskey(DOM, "float")
          if DOM["float"] == "right"
              node.shape.flags[FloatRight] = true
          elseif DOM["float"] == "left"
              node.shape.flags[FloatLeft] = true
          end
      end
      if haskey(DOM, "radius")
                    node.shape.radius = DOM["radius"]
      end
      if haskey(DOM, "text")
                    node.shape.text = DOM["text"]
                  end
      if haskey(DOM, "color")
                    node.shape.color = GetTheColor(DOM["color"])
                  end
      if haskey(DOM, "display")
                    # node.shape.display = DOM["display"]
                  end
      if haskey(DOM, "width")
              node.shape.width = DOM["width"]
            end
      if haskey(DOM, "height")
              node.shape.height = DOM["height"]
              node.shape.flags[FixedHeight] = true
            end
            #.........................................................................
if haskey(DOM, "border")
          border = DOM["border"]
             color = [0,0,0]
             radius = [0,0,0,0]
             style = "solid"
             width = [0,0,0,0, 0,0]
          if haskey(border, "color")
            color = GetTheColor(border["color"]) # only works for: [.5,.8,.8]
          end
          if haskey(border, "radius")
               r = border["radius"]
              if isa(r, Array)
                radius = r
              else
                radius = [r,r,r,r]
              end
              node.shape.flags[IsRoundBox] = true # IsRoundBox
          end
          if haskey(border, "style")
              style = border["style"]
          end
          if haskey(border, "width")
                  w = border["width"]
                 if isa(w, Array) && length(w) == 4
                   width = [ w[1],w[2],w[3],w[4],  w[1]+w[3], w[2]+w[4] ]
                 else
                   if w == "thin"
                     width = [1,1,1,1,  2,2]
                   end
                   if w == "medium"
                     width = [3,3,3,3,  6,6]
                   end
                   if w == "thick"
                     width = [4,4,4,4,  8,8]
                   end
                 end
          end
          node.shape.border  = Border(width... , style, color, radius)
      end
      #.........................................................................
      if haskey(DOM, "padding")
        p = DOM["padding"]
        padding = []
               if isa(p, Array)
                     if length(p) == 4
                       padding = [ p[1],p[2],p[3],p[4],  p[1]+p[3], p[2]+p[4] ]
                     end
                     if length(p) == 2
                       padding = [ p[1],p[2],p[1],p[2],  p[1]*2, p[2]*2 ]
                     end
               else
                 padding = [ p,p,p,p,  p*2, p*2 ]
               end
        node.shape.padding = BoxOutline(padding...)
      end
      #.........................................................................
      if haskey(DOM, "font")
        font = DOM["font"]
        if haskey(font, "color")
                node.shape.color = GetTheColor(font["color"])
        end
        if haskey(font, "align")
            if font["align"] == "center"
                node.shape.flags[TextCenter] = true
            elseif font["align"] == "right"
                node.shape.flags[TextRight] = true
            #else node.shape.flags[TextJustify] = true
            end
        end

        if haskey(font, "vertical-align")
            if font["vertical-align"] == "bottom"
                node.shape.flags[AlignBase] = true
            elseif font["vertical-align"] == "middle"
                node.shape.flags[AlignMiddle] = true
            #else node.shape.flags[TextJustify] = true
            end
        end
        if haskey(font, "style")
                if font["style"] == "italic"
                    node.shape.flags[TextItalic] = true
                elseif font["style"] == "oblique"
                    node.shape.flags[TextOblique] = true
                end
        end
        if haskey(font, "size")
                node.shape.size = font["size"]
        end
        if haskey(font, "lineHeight")
                node.shape.lineHeight = font["lineHeight"]
                node.shape.height = node.shape.size * node.shape.lineHeight
        end
        if haskey(font, "weight")
          if font["weight"] == "bold"
              node.shape.flags[TextBold] = true
          end
        end
        if haskey(font, "family")
                node.shape.family = font["family"]
              #  println("----------------",node.shape)
        end
      end





      #"font":{"color":"black", "size":12,
      #  "style":"italic",
      #  "align":"left",
      #  "lineHeight":1.4,
      #  "weight":"bold",
      #  "family":"Georgia" },









    end



end # function
# ======================================================================================
