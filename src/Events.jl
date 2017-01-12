
# module NaquadahEvents
using Cairo, Gtk, Gtk.ShortNames#, Naquadraw # Graphics,

export AttatchEvents
export EventType

type EventType
  pressed::Point
  released::Point
  EventType() = new(Point(0,0),Point(0,0))
end

function AttatchEvents(document)
  println(LOAD_PATH)
	    canvas = document.canvas

    canvas.mouse.button1press = @guarded (widget, event) -> begin
        # ctx = getgc(widget)
        document.event.pressed = Point(event.x, event.y)
    end

    canvas.mouse.button1release = @guarded (widget, event) -> begin
    ctx = getgc(widget)
           if -5 < (document.event.pressed.x - event.x) < 5 &&
              -5 < (document.event.pressed.y - event.y) < 5
             splotch(ctx,event,1.0,0.0,0.0)
             reveal(widget)
           end
    end

    # SEE: https://people.gnome.org/~gcampagna/docs/Gdk-3.0/Gdk.EventScroll.html
    canvas.mouse.scroll = @guarded (widget, event) -> begin
    ctx = getgc(widget)
    node = document.children[1]
    h   = node.shape.height
    w   = node.shape.width

    # I am scrolling(jumping) by 30px here but Opera scrolls by about 50px
    # Opera lacks smoothness too but it seems to transition-scroll by the 50px
    # ...so using the mouse wheel it is impossible to move less than that increment.


    if event.direction == 0
        node.scroll.y += 30
        MoveAll(node,0,30)

        set_source_rgb(ctx, 1,1,1)
        rectangle(ctx, 0, 0, w, h )
        fill(ctx);

        DrawContent(ctx, node)
        reveal(widget)

    else
        node.scroll.y -= 30
        height = node.scroll.contentHeight - node.shape.height
        if node.scroll.y < height
            node.scroll.y = height
            MoveAll(node,0,height)
        else
            MoveAll(node,0,-30)
        end

        set_source_rgb(ctx, 1,1,1)
        rectangle(ctx,  0,  0, w,  h )
        fill(ctx);

        DrawContent(ctx, node)
        reveal(widget)

    end


    end



end



# ======================================================================================
# Draw a splotch
# CALLED FROM:
# ======================================================================================
function splotch(ctx,event,r,g,b)
            deg = (pi/180.0)
        s1, e1 = 1 * deg, 100 * deg
        s2, e2 = 120 * deg, 220 * deg
        s3, e3 = 240 * deg, 340 * deg
move_to(ctx, event.x, event.y)
        set_line_width(ctx, 2.56);
        set_antialias(ctx,4)
        set_source_rgb(ctx, r, g, b)
        arc(ctx, event.x, event.y, 2, 0, 2pi) # 0, 2pi
        stroke(ctx)

        #set_line_width(ctx, 3);
        set_source_rgba(ctx, r, g, b, 0.7)
        arc(ctx, event.x, event.y, 5, s1, e1) # 0, 2pi
        stroke(ctx)
        arc(ctx, event.x, event.y, 5, s2, e2) # 0, 2pi
        stroke(ctx)
        arc(ctx, event.x, event.y, 5, s3, e3) # 0, 2pi
        stroke(ctx)
        # arc_negative(cr, xc, yc, node.shape.radius,
        #     node.shape.angle[1] * (pi/180.0),
        #     node.shape.angle[2] * (pi/180.0));

        #set_line_width(ctx, 2);
        set_source_rgba(ctx, r, g, b, 0.5)
        arc(ctx, event.x, event.y, 8, s1, e1)
        stroke(ctx)
        arc(ctx, event.x, event.y, 8, s2, e2)
        stroke(ctx)
        arc(ctx, event.x, event.y, 8, s3, e3)
        stroke(ctx)

        #set_line_width(ctx, 1);
        set_source_rgba(ctx, r, g, b, 0.3)
        arc(ctx, event.x, event.y, 11, s1, e1)
        stroke(ctx)
        arc(ctx, event.x, event.y, 11, s2, e2)
        stroke(ctx)
        arc(ctx, event.x, event.y, 11, s3, e3)
        stroke(ctx)


end



# end # module
