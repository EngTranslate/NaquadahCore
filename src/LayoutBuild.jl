export MoveAll
#======================================================================================#
function getShape(item)
      if isa(item, TextLine)
        return item
      else
        return item.shape
      end
end
#======================================================================================#
#
#======================================================================================#
function FinalizeRow(thing, row)
    if row.flags[RowFinalized] == true
        return
    end
    # move objects up or down (withing row space) depending on layout options.
    # Be sure that the heights of all objects have been set.
    # Float the floats
    # The contents of a container may effect the container itself. Such as height; set that!
    # Set any node heights that are % values.
  # thing.width
  shiftAll = 0
  #..........................................
  # vertical/hirizintal shift
  #..........................................
      X = 0
  #if row.flags[TextCenter] == true
#      X = row.space * .5
 # elseif row.flags[TextRight] == true
#      X = row.space
#      row.space = 0
 # end

  for i in 1:length(row.nodes)
    item = row.nodes[i]
    Y = 0

    if isa(item, TextLine)
        TextLike = item.reference.shape
    else
        TextLike = item.shape
    end


            if TextLike.flags[TextCenter] == true
                X = row.space * .5
            elseif TextLike.flags[TextRight] == true
                X = row.space
                row.space = 0
            end

            TextLike.flags[AlignBase]    &&  (Y = (row.height-TextLike.height))
            if TextLike.flags[AlignMiddle]  &&  row.height > TextLike.height
                Y = (row.height-TextLike.height) *.5
                println(Y)
            end


        MoveAll(row.nodes[i], X,Y)
      end
    #..........................................
    # float LEFT: MoveNodeToLeft(row, index)
    #..........................................
    for i in 2:length(row.nodes)
        # item = row.nodes[i].shape
          shape = getShape(row.nodes[i])
        if shape.flags[FloatLeft] == true
            w, h = getSize(shape)
            s = getShape(row.nodes[1])
            MoveAll(row.nodes[i], -(shape.left - s.left) ,0)
            for j in 1:(i-1)
              MoveAll(row.nodes[j],w,0)
            end
            MoveNodeToLeft(row, i)
        end
    end
    #..........................................
    # float RIGHT: MoveNodeToRight(row, index)
    #..........................................
    for i in length(row.nodes):-1:1
      # row.space
      shape = getShape(row.nodes[i])
        if shape.flags[FloatRight] == true
            w, h = getSize(shape)
            for j in (i+1):length(row.nodes)
                row.nodes[j].shape.left -= w
            end
            wide,high = getSize(row.nodes[end].shape)
            shape.left = row.nodes[end].shape.left + wide + row.space
        end
    end

    # Mark row as finalized!
    row.flags[RowFinalized] = true
end

#======================================================================================#
# PushToRow(rows, parentArea, circle, circleHeight, circleWidth)
function PushToRow(node, thing) # .rows, parentArea

  shape = node.shape
  if isa(thing,TextLine)
      thingShape = thing
  else
      thingShape = thing.shape
  end
      rows = node.rows
      box = getContentBox(shape, getReal(shape)... )
      l, t, w, h = box
      thingWidth, thingHeight = getSize(thingShape)
  #end

    # Make new row if: object too wide
    if length(rows) < 1
        Row(rows, l, t, w)
    end
    row = rows[end]

    if thingShape.flags[DisplayBlock] == true && thingShape.width < 1
        if length(row.nodes) > 0
            FinalizeRow(box, row)
            row = Row(rows, l, row.y + row.height, w)
        end
        thingShape.width = w #- (thingShape.border + )
        row.space = 0
    else
        # not enough space.. new row!
        if row.space < thingWidth
            FinalizeRow(box, row)
            newRow = Row(rows,  l + thingWidth,  row.y + row.height,  w - thingWidth)
            push!(newRow.nodes, thing)
            newRow.height = thingHeight
            thingShape.left = l
            thingShape.top = newRow.y
            return
        end
    end
    # if object height is greater than row reset row.height
    if row.height < thingHeight
            row.height = thingHeight
    end
    # add object to row and calculate remaining space
    if row.y == 0
      row.y = t
    end

    thingShape.top = row.y # TODO: a bunch of stuff
    thingShape.left = row.x
    row.space -= thingWidth
    row.x += thingWidth


    #    node.shape.flags[LineBreakAfter] == true

    push!(row.nodes, thing)




end


#======================================================================================#
#
#======================================================================================#



#======================================================================================#
function MoveNodeToLeft(row, index)
  node = row.nodes[index]
  for n in index:-1:2
    row.nodes[n] = row.nodes[n-1]
  end
  row.nodes[1] = node
end
#======================================================================================#
function MoveNodeToRight(row, index)
  node = row.nodes[index]
  for n in index:length(row.nodes)-1
    row.nodes[n] = row.nodes[n+1]
  end
  row.nodes[end] = node
end
#======================================================================================#
#    This is only to translate a shape with all children by x,y
#    It may also be nesesary to move the node to another location in its row!
#======================================================================================#
function MoveAll(node,x,y)
  shape = getShape(node)
  shape.left += x # Move this object!
  shape.top  += y
    if isdefined(node, :rows) # ..it has rows of children so let's move them!
      for i in 1:length(node.rows)
        row = node.rows[i]
        row.x += x # ...don't forget to move the actual row
        row.y += y
        for j in 1:length(row.nodes)
            MoveAll(row.nodes[j],x,y) # do the same for each child
        end
      end
    end
end
#======================================================================================#
#======================================================================================#
function LineBreak(node) # .rows, parentArea
    row = node.rows[end]
    box = getContentBox(node.shape, getReal(node.shape)... )
    l, t, w, h = box
    FinalizeRow(box, row)
    return Row(node.rows,  l,  row.y + row.height,  w)
end
#======================================================================================#
#
#======================================================================================#
function fontSlant(shape)
    if shape.flags[TextItalic] == true
        return Cairo.FONT_SLANT_ITALIC
    elseif shape.flags[TextOblique] == true
        return Cairo.FONT_SLANT_OBLIQUE
    else
        return Cairo.FONT_SLANT_NORMAL
    end
end
#======================================================================================#
function fontWeight(shape)
    if shape.flags[TextBold] == true
        return Cairo.FONT_WEIGHT_BOLD
    else
        return Cairo.FONT_WEIGHT_NORMAL
    end
end
#======================================================================================#
#
#======================================================================================#
function textToRows(node, MyText) # .rows, parentArea
      shape = node.shape
      MyTextShape = MyText.shape
      c = CairoRGBSurface(0,0);
      ctx = CairoContext(c);
      slant  = fontSlant(MyTextShape)
      weight = fontWeight(MyTextShape)
      select_font_face(ctx, MyTextShape.family, slant, weight);
      set_font_size(ctx, MyTextShape.size);

    pl, pt, width, ph = getContentBox(shape, getReal(shape)... )

# when we want to add text to a row that already has content
      rows = node.rows

      if length(rows) == 0 # no row!
        Row(rows, pl, pt, width)
      end
      if length(rows[end].nodes) > 0 # Already has nodes!
          lineWidth = rows[end].space
          lineLeft = rows[end].x
          isPartRow = true
      else
          lineWidth = width
          lineLeft = pl
          isPartRow = false
      end


     # set up some variables to get started
     lines = []
     lastLine = ""
     lineTop = pt + MyTextShape.size # Because text is drawn above the line!
     words = split(MyTextShape.text, r"(?<=.)(?=[\s])")
     # split(MyTextShape.text) # TODO: this needs improved!
     line = words[1]

    for w in 2:length(words)
        lastLine = line
        line = lastLine * words[w]
        extetents = text_extents(ctx,line )
        # long enough ...cut!
        if extetents[3] >= lineWidth
            te = text_extents(ctx, lastLine )
            textLine = TextLine(MyText, lastLine, lineLeft, 0, te[3], MyTextShape.height)
            PushToRow(node, textLine)
            line = words[w]
            # What's this for?
            if isPartRow == true
                lineWidth = width
                lineLeft = pl
                isPartRow = false
            end
        end

    end
    # Make sure we flush out the last row!
    te = text_extents(ctx,line )
    textLine = TextLine(MyText, line, lineLeft, 0, te[3], MyTextShape.height)
    PushToRow(node, textLine)
end
