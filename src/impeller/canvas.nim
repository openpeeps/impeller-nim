# Nim bindings for the Impeller graphics library - High-level Canvas API
#
# (c) 2026 George Lemon | MIT License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/impeller-nim

import pkg/chroma
import ./bindings/impeller_api
import ./paint
import ./displaylist
import ./colorsource

export paint, displaylist, colorsource

## This module defines high-level canvas-related types and procedures
## for working with shapes and gradients in the Impeller rendering engine.

#
# Shape API
#
type
  RectShape* = ImpellerRect
    ## Represents a rectangle shape with position and dimensions.
  
  CircleShape* = object
    ## Represents a circle shape defined by its center point and radius.
    center*: ImpellerPoint
    radius*: cfloat

proc newRectangle*(width, height: float32, x: float32 = 0, y: float32 = 0): RectShape =
  ## Creates a new rectangle shape with the specified position and dimensions.
  RectShape(x: x.cfloat, y: y.cfloat, width: width.cfloat, height: height.cfloat)

proc newRect*(width, height: float32, x: float32 = 0, y: float32 = 0): RectShape {.inline.} =
  ## Creates a new rectangle shape with the specified position and dimensions.
  newRectangle(width, height, x, y)

proc newSquare*(size: float32, x: float32 = 0, y: float32 = 0): RectShape =
  ## Creates a new square shape with the specified position and size.
  newRectangle(size, size, x, y)

proc newCircle*(radius: float32, x: float32 = 0, y: float32 = 0): CircleShape =
  ## Creates a new circle shape with the specified center and radius.
  CircleShape(center: ImpellerPoint(x: x.cfloat, y: y.cfloat), radius: radius.cfloat)

proc circleOvalRect*(circle: CircleShape): ImpellerRect =
  ## Pure helper: bounding rect of a circle. Separated for testability.
  let diameter = circle.radius * 2
  ImpellerRect(
    x: circle.center.x - circle.radius,
    y: circle.center.y - circle.radius,
    width: diameter,
    height: diameter
  )

proc drawCircle*(builder: ImpellerDisplayListBuilder, circle: CircleShape, paint: ImpellerPaint) =
  var ovalRect = circleOvalRect(circle)
  ImpellerDisplayListBuilderDrawOval(builder, addr ovalRect, paint)

#
# Gradient API
#
type
  LinearGradient* = object
    ## Defines a gradient for use in painting operations
    width*, height*: float32
    startPoint*, endPoint*: ImpellerPoint
      # The start and end points for the gradient. For a linear gradient,
      # these define the line along which the colors will transition.
      # For a radial gradient, the start point is the center and the
      # end point defines the radius.
    colors*: seq[GradientColor]
      ## The colors for the gradient. The length of this
      ## sequence should match the length of `stops`.
    stops*: seq[float32]
      ## The positions for each color in the gradient, typically in the range [0.0
    rect: ImpellerRect
      # The rectangle area for this color stop, used for rendering purposes.
    paint: ImpellerPaint
      # The paint object associated with this color stop, used for rendering purposes.
  
  GradientColor* = object
    ## Represents a single color stop in a gradient
    color*: ColorRGBA
      ## The color of this stop, including alpha for transparency.
    impellerColor*: ImpellerColor
      # The color at this stop, including alpha for transparency.
    position*: float32
      ## The position of this color stop along the gradient, typically in the range [0.0, 1.0].

proc addGradientPoint*(gradient: var LinearGradient, color: ColorRGBA, position: cfloat) =
  ## Adds a color stop to the gradient at the specified position.
  gradient.colors.add(
    GradientColor(
      color: color,
      impellerColor: toImpellerColor(color),
      position: position
    )
  )

proc addGradientPoint*(gradient: var LinearGradient, color: string, position: float32) =
  ## Adds a color stop to the gradient using a hex color string.
  let rgba = parseHtmlColor(color).asRgba
  addGradientPoint(gradient, rgba, position.cfloat)

proc initGradientPoint*(color: string, position: float32): GradientColor =
  ## Initializes a gradient color stop from a hex color string and position.
  let rgba = parseHtmlColor(color).asRgba
  GradientColor(
    color: rgba,
    impellerColor: rgba.toImpellerColor(),
    position: position
  )

proc initGradientPointAlpha*(color: string, alpha: uint8, position: float32): GradientColor =
  ## Initializes a gradient color stop from a hex color string, alpha value, and position.
  var rgba = parseHtmlColor(color).asRgba
  rgba.a = alpha
  GradientColor(
    color: rgba,
    impellerColor: rgba.toImpellerColor(),
    position: position
  )

proc initGradientPointHexAlpha*(color: string, position: float32): GradientColor =
  ## Initializes a gradient color stop from a hex color string with alpha and position.
  let rgba = parseHexAlpha(color).asRgba
  GradientColor(
    color: rgba,
    impellerColor: rgba.toImpellerColor(),
    position: position
  )

proc initGradientPointHexAlpha*(color: Color, position: float32): GradientColor =
  ## Initializes a gradient color stop from a Color object with alpha and position.
  let rgba = color.asRgba
  GradientColor(
    color: rgba,
    impellerColor: rgba.toImpellerColor(),
    position: position
  )

proc initLinearGradient*(colors: seq[GradientColor],
        startPoint: ImpellerPoint = ImpellerPoint(x: 0, y: 0),
        endPoint: ImpellerPoint = ImpellerPoint(),
        width: float32 = 100'f32,
        height: float32 = 100'f32): LinearGradient =
  ## Creates a new linear gradient with the specified colors and points.
  LinearGradient(
    width: width.cfloat,
    height: height.cfloat,
    startPoint: startPoint,
    endPoint: endPoint,
    colors: colors
  )

proc drawGradient*(builder: ImpellerDisplayListBuilder, gradient: var LinearGradient) =
  ## Draws the specified gradient using the provided display list builder.
  if gradient.colors.len < 2:
    raise newException(ValueError, "gradient needs at least 2 color stops")
  var stops: seq[cfloat]
  var impellerColors: seq[ImpellerColor]
  for color in gradient.colors:
    impellerColors.add(color.impellerColor)
    stops.add(color.position.cfloat)

  var identity = identityMatrix()
  let grView = ImpellerColorSourceCreateLinearGradientNew(
    addr gradient.startPoint, addr gradient.endPoint,
    uint32(stops.len), addr impellerColors[0], addr stops[0],
    kImpellerTileModeClamp, addr identity
  )
  if grView == nil:
    raise newException(OSError, "ImpellerColorSourceCreateLinearGradientNew failed")
  let paintView = ImpellerPaintNew()
  try:
    ImpellerPaintSetColorSource(paintView, grView)
    var rect = ImpellerRect(x: 0, y: 0, width: gradient.width.cfloat, height: gradient.height.cfloat)
    ImpellerDisplayListBuilderDrawRect(builder, addr rect, paintView)
  finally:
    ImpellerColorSourceRelease(grView)
    ImpellerPaintRelease(paintView)

proc setColor*(paint: ImpellerPaint, color: ColorRGBA) =
  ## Sets the color of the given paint object using a ColorRGBA value.
  let impellerColor = toImpellerColor(color)
  ImpellerPaintSetColor(paint, addr impellerColor)

proc setColor*(paint: ImpellerPaint, color: string) =
  ## Sets the color of the given paint object using a hex color string.
  let rgba = parseHtmlColor(color).asRgba
  setColor(paint, rgba)

proc setColor*(paint: ImpellerPaint, color: ImpellerColor) =
  ## Sets the color of the given paint object using an ImpellerColor.
  ImpellerPaintSetColor(paint, addr color)

proc drawRect*(builder: ImpellerDisplayListBuilder, rect: RectShape, color: ColorRGBA) =
  ## Draws a rectangle with the given color.
  let paint = ImpellerPaintNew()
  try:
    paint.setColor(color)
    ImpellerDisplayListBuilderDrawRect(builder, addr rect, paint)
  finally:
    ImpellerPaintRelease(paint)

proc drawRect*(builder: ImpellerDisplayListBuilder, rect: RectShape, color: string) =
  ## Draws a rectangle with the given hex color string.
  let paint = ImpellerPaintNew()
  try:
    paint.setColor(color)
    ImpellerDisplayListBuilderDrawRect(builder, addr rect, paint)
  finally:
    ImpellerPaintRelease(paint)

proc drawLine*(builder: ImpellerDisplayListBuilder, x0, y0, x1, y1: float32,
    color: ColorRGBA, width: float32 = 1.0) =
  ## Convenience: line with solid color + width.
  let paint = ImpellerPaintNew()
  try:
    paint.setColor(color)
    ImpellerPaintSetDrawStyle(paint, kImpellerDrawStyleStroke)
    ImpellerPaintSetStrokeWidth(paint, width.cfloat)
    ImpellerPaintSetStrokeCap(paint, kImpellerStrokeCapRound)
    var a = ImpellerPoint(x: x0.cfloat, y: y0.cfloat)
    var b = ImpellerPoint(x: x1.cfloat, y: y1.cfloat)
    ImpellerDisplayListBuilderDrawLine(builder, addr a, addr b, paint)
  finally:
    ImpellerPaintRelease(paint)

proc drawOval*(builder: ImpellerDisplayListBuilder, cx, cy, rx, ry: float32,
    color: ColorRGBA) =
  let paint = ImpellerPaintNew()
  try:
    paint.setColor(color)
    var oval = ImpellerRect(x: (cx - rx).cfloat, y: (cy - ry).cfloat,
      width: (rx * 2).cfloat, height: (ry * 2).cfloat)
    ImpellerDisplayListBuilderDrawOval(builder, addr oval, paint)
  finally:
    ImpellerPaintRelease(paint)
