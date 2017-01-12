

include("DomUtilities.jl")

module Naquadraw

using Cairo, Gtk.ShortNames # , NaquadahEvents # Graphics,
using Gtk

  include("GraphFlags.jl")
  include("GraphTypes.jl")
  include("GraphMethods.jl")


export
          # get real data (margin, padding, border) instead of Nullables
          getReal, DrawBox, DrawCircle, DrawRoundedBox, textToRows, DrawText,
          PushToRow, FinalizeRow,
          # get calculated metrics
          getBorderBox, getContentBox, getMarginBox, getSize,
          TotalShapeWidth, TotalShapeHeight,
          DrawContent, DrawANode, setWindowSize, InitializeRow
          include("Events.jl")

include("LayoutBuild.jl")
# ======================================================================================

# ======================================================================================

# ======================================================================================
function setWindowSize(w,h, n)
  n.shape = NBox()
    n.shape.color = [.5,.8,.8]
    n.shape.padding = BoxOutline(10,10,10,10,20,20)
    # we need to make sure we set VP based on padding!
    padding = get(n.shape.padding, BoxOutline(0,0,0,0,0,0))
    n.shape.left    = 0
    n.shape.top     = 0
    n.shape.width   = w # - padding.width
    n.shape.height  = h # - padding.height
    # IsHScroll, IsVScroll
    n.shape.flags[IsVScroll] = true
end

# ======================================================================================
function DrawContent(ctx, node)
  rows = node.rows
  parentArea = getContentBox(node.shape, getReal(node.shape)... )

  for i in 1:length(rows)
      row = rows[i]
      for j in 1:length(row.nodes)
          child = row.nodes[j]
          shape = getShape(child)

          if length(row.nodes) > 0 && shape.flags[LineBreakBefore] == true # break-line before element
              println("Yes")
              # row = 
              LineBreak(node)
          end

          # Only draw if visible! node.shape.flags[FixedHeight] == true &&
          if row.y < (node.shape.top + node.shape.height) && node.shape.flags[DisplayNone] == false
                 isa(shape, TextLine) && DrawText(ctx, row, shape)
                 isa(shape, Circle) && DrawCircle(ctx, parentArea, shape)
                 isa(shape, NBox) &&
                   if child.shape.flags[IsRoundBox] == true
                     DrawRoundedBox(ctx, 1, shape)
                   else
                     DrawBox(ctx, shape)
                   end


                !isa(child, TextLine) && DrawContent(ctx, child)

         end
      end
  end
end

























# ======================================================================================
#
# CALLED FROM:
# ======================================================================================
function DrawCircle(ctx::CairoContext, parentArea, circle::Circle)

        pl, pt, pw, ph = parentArea

    border = get(circle.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))

              radius = circle.radius + border.left
              l = circle.left  + radius #+ pl
              t = circle.top   + radius #+ pt
set_antialias(ctx,6)
          set_source_rgb( ctx, circle.color...)
                  move_to(ctx, l, t)
                  arc(ctx, l, t, radius, 0, 2*pi);
                  fill(ctx);
                  # fill_preserve(ctx);
          set_source_rgb( ctx, border.color...)
                  arc(ctx, l, t, radius, 0, 2*pi);

                  set_line_width(ctx, border.top);
                  stroke(ctx);

                  select_font_face(ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_BOLD);
end
#======================================================================================#
# TODO: see if curveTo() will work to simplify this.
#======================================================================================#
function DrawBox(ctx::CairoContext, box::NBox)
    border = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
    l,t,w,h = getBorderBox(box, border)
    r, b = l+w, t+h
#= Draw a frame around outside of box!=#
    #set_source_rgb(ctx, border.color...)
    #set_line_width(ctx, border.left);
    #rectangle(ctx,l-1,t-1,w+3,h+3 )
    #stroke(ctx);

    if box.flags[BordersSame] == true
        rectangle(ctx,l,t,w,h )
        set_source_rgb(ctx, box.color...)
        fill(ctx);

        set_source_rgb(ctx, border.color...)
        set_line_width(ctx, border.left);
        rectangle(ctx,l,t,w,h )
        stroke(ctx);
    else
          borderWidth = max(border.left,border.top,border.right,border.bottom)
          rectangle(ctx,l,t,w,h )
          clip(ctx)

                line = (borderWidth/2)
                t -= (line - border.top)
                l -= (line - border.left)
                w += (line - border.left)+(line - border.right)
                h += (line - border.left)+(line - border.bottom)
                rectangle(ctx,l,t,w,h )
                set_source_rgb(ctx, box.color...)
          		fill_preserve(ctx);

          	    # Borders...
                set_source_rgb(ctx, border.color...)
          		set_line_width(ctx, borderWidth);
          		stroke(ctx);
          		set_antialias(ctx,1)
          reset_clip(ctx)
      end
end

#======================================================================================#
# TODO: see if curveTo() will work to simplify this.
#======================================================================================#
function DrawRoundedBox(ctx::CairoContext, parentArea, box::NBox)
    border = get(box.border,  Border(0,0,0,0,0,0, 0,[],[0,0,0,0]))
    l,t,w,h = getBorderBox(box, border)
    r, b = l+w, t+h
    set_antialias(ctx,1)
#= Draw a frame around outside of box!
    set_source_rgb(ctx, 0,0,0)
    rectangle(ctx, l-1,t-1,w+3,h+3 )
    set_line_width(ctx, 1);
    stroke(ctx);
=#
        set_antialias(ctx,6)
        borderWidth = max(border.left,border.top,border.right,border.bottom)
  radius = get(border.radius,[0,0,0,0])
                    TR = radius[1]
                    BR = radius[2]
                    BL = radius[3]
                    TL = radius[4]

        rot   =   1.5707963    # 90 * degrees

    new_sub_path(ctx);
   		arc(ctx, r - TR, t + TR, TR,     -rot,   0   );    # topRight
   		arc(ctx, r - BR, b - BR, BR,     0,      rot ); # bottomRight
   		arc(ctx, l + BL, b - BL, BL,     rot,    pi  );   # bottomLeft
   		arc(ctx, l + TL, t + TL, TL,     pi,     -rot);      # topLeft
 		close_path(ctx);

clip(ctx)
# border.left, border.top, border.right, border.bottom
line = (borderWidth/2)
t -= (line - border.top)
l -= (line - border.left)
r -= (border.right - line)
b -= (border.bottom - line)
		new_sub_path(ctx);
		arc(ctx, r - TR, t + TR, TR,     -rot,   0   );    # topRight
		arc(ctx, r - BR, b - BR, BR,     0,      rot ); # bottomRight
		arc(ctx, l + BL, b - BL, BL,     rot,    pi  );   # bottomLeft
		arc(ctx, l + TL, t + TL, TL,     pi,     -rot);      # topLeft
		close_path(ctx);

		# setcolor( cr, box.color...)
      #fill(ctx);
      set_source_rgb(ctx, box.color...)
		fill_preserve(ctx);

		# Borders...
    set_source_rgb(ctx, border.color...)
			set_line_width(ctx, borderWidth);
			stroke(ctx);
			set_antialias(ctx,1)
reset_clip(ctx)
end
#======================================================================================#
function DrawText(ctx, row, node)
  MyText = node.Reference.shape
  left = node.left

    slant  = fontSlant(MyText)
    weight = fontWeight(MyText)
    select_font_face(ctx, MyText.family, slant, weight);
    set_font_size(ctx, MyText.size);

    move_to(ctx, node.left, node.top + MyText.size);
    set_source_rgb(ctx, MyText.color...)
    show_text(ctx, node.text);
end

#======================================================================================#
# Draw node text
# Cairo tutorial: https://www.cairographics.org/tutorial/
# CALLED FROM: DrawNode()
#======================================================================================#






end # module
