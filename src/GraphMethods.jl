#include("GeomTypes.jl")
# export getContentBox, getReal
# ==============================================================================
# This returns a temporary BoxElement with offset applied
# and Nullables instantiated.
function getReal(box::Draw)
    return (  get(box.padding, BoxOutline(0,0,0,0,0,0)),
              get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0])),
              get(box.margin,  BoxOutline(0,0,0,0,0,0))    )
end # padding, border, margin

macro BorderLeft(box, border)
    return :( $(box).left  - ($(border).left *.5) )
end
macro BorderTop(box, border)
    return :( $(box).top  - ($(border).top *.5) )
end

function getBorderBox(box::NBox, border)
    return ( @BorderLeft(box, border), # l += border.left  *.5
             @BorderTop(box, border),  # t += border.top  *.5
             box.width  + (border.width  ),
             box.height + (border.height )  )
end
function getContentBox(box::NBox, padding, border, margin)
    return ( box.left + padding.left , #   + padding.left + margin.left
             box.top  + padding.top  ,  #   + padding.top  + margin.top
             box.width  - padding.width  - (border.width *.5) ,
             box.height - padding.height - (border.height *.5) )
end
function getMarginBox(box::NBox)
  border = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
  margin = get(box.margin,  BoxOutline(0,0,0,0,0,0))
    return ( box.left - border.left -margin.left,
             box.top  - border.top  -margin.top,
             box.width  + border.width  + margin.width ,
             box.height + border.height + margin.height )
end
function getMarginBox(box::NBox, border, margin)
    return ( box.left - border.left -margin.left,
             box.top  - border.top  -margin.top,
             box.width  + border.width  + margin.width ,
             box.height + border.height + margin.height )
end
function getSize(box::NBox)
  border = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
  margin = get(box.margin,  BoxOutline(0,0,0,0,0,0))
    return ( box.width  + border.width  + margin.width ,
             box.height + border.height + margin.height )
end













function getContentBox(circle::Circle, padding, border, margin)
  dia = circle.radius*2+1
    return ( circle.left   + border.left   + padding.left + margin.left   ,
             circle.top    + border.top    + padding.top  + margin.top    ,
             dia + border.width  + margin.width ,
             dia + border.height + margin.height )
end


function setTopPosition(box::NBox, border, margin)

end
function setTopPosition(circle::Circle, border, margin)

end
function setTopPosition(text::TextLine, border, margin)

end
function getSize(text::TextLine)
    return ( text.width, text.height )
end
function getSize(circle::Circle)
  border = get(circle.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
  margin = get(circle.margin,  BoxOutline(0,0,0,0,0,0))
    dia = circle.radius*2+1
    return ( dia + border.width  + margin.width ,
             dia + border.height + margin.height )
end
function getMarginBox(circle::Circle, border, margin)
    dia = circle.radius*2+1
    return ( circle.left,
             circle.top,
             dia + border.width  + margin.width ,
             dia + border.height + margin.height )
end
function getMarginBox(circle::Circle)
  border = get(circle.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
  margin = get(circle.margin,  BoxOutline(0,0,0,0,0,0))
    dia = circle.radius*2+1
    return ( circle.left,
             circle.top,
             dia + border.width  + margin.width ,
             dia + border.height + margin.height )
end







 # TODO: getRelativeBox to calculate a box relative to parent
function getRelativeBox(window::Draw, box::Draw, border, margin)
    return ( box.left,
             box.top,
             box.width  + border.width  + margin.width ,
             box.height + border.height + margin.height
             )
end
# ==============================================================================
function topLeft(box::Draw)
    offset = get(box.offset,Point(0,0))
     return Point(box.left + offset.x, box.top + offset.y)
 end
function bottomRight(box::Draw)
    offset = get(box.offset,Point(0,0))
     return Point(box.right + offset.x, box.bottom + offset.y)
 end
# function Border(box::BoxElement,padding,border,margin)
#     return box.width + padding.left + padding.right + border.left + border.right + margin.left + margin.right
# end
function TotalShapeWidth(box::NBox)
      border = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
      margin = get(box.margin,  BoxOutline(0,0,0,0,0,0))
    return box.width + margin.width + border.width
end
function TotalShapeWidth(box::Draw,border,margin)
    return box.width + margin.width + border.width
end
function TotalShapeHeight(box::Draw,border,margin)
    return box.height + border.height + margin.height
end


function topLeft(circle::Circle)
     return Point(origin.x - radius, origin.y - radius)
end
function bottomRight(circle::Circle)
    return Point(origin.x + radius, origin.y + radius)
end
function TotalShapeWidth(circle::Circle,padding,border,margin)
    width = radius*2
    return width + padding.left + padding.right + border.left + border.right + margin.left + margin.right
end
function TotalShapeHeight(circle::Circle,padding,border,margin)
    height = radius*2
    return height + padding.top + padding.bottom + border.top + border.bottom + margin.top + margin.bottom
end
