# Nim bindings for the Impeller graphics library - High-level Text API
#
# (c) 2026 George Lemon | MIT License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/impeller-nim

import std/options
import pkg/chroma

import ./bindings/impeller_api

## High-level API for text, typography, font sizes, and text colors.

type
  FontWeight* = ImpellerFontWeight
  FontStyle* = ImpellerFontStyle
  TextAlign* = ImpellerTextAlignment
  TextDirection* = ImpellerTextDirection

  TextStyle* = object
    ## Represents a style for a run of text.
    fontFamily*: string
      ## The font family to use for this text. This should match a family registered in the TypographyContext.
    fontSize*: float32
      ## The font size in pixels. This can be set directly or derived from a TypographyPreset.
    fontWeight*: FontWeight
      ## The font weight (e.g. normal, bold). This can be set directly or derived from a TypographyPreset.
    fontStyle*: FontStyle
      ## The font style (e.g. normal, italic).
    color*: ColorRGBA
      ## The text color. This is required and cannot be none. Use rgba(0,0,0,0) as a sentinel for "not set" if needed.
    background*: Option[ColorRGBA]
      ## Optional background color for the text. If none, no background will be drawn.
    align*: TextAlign
      ## The text alignment for this style. If not set, the paragraph's default will be used.
    direction*: TextDirection = kImpellerTextDirectionLTR
      ## The text direction (LTR or RTL). If not set, the paragraph's default will be used.
    decoration*: Option[ImpellerTextDecoration]
      ## Optional text decoration (underline, line-through). If none, no decoration will be drawn.

  Paragraph* = object
    ## Represents a laid out paragraph.
    handle*: ImpellerParagraph

  TypographyContext* = object
    ## Represents a typography context for font registration and text layout.
    handle*: ImpellerTypographyContext

proc newTypographyContext*(): TypographyContext =
  ## Creates a new typography context.
  TypographyContext(handle: ImpellerTypographyContextNew())

proc registerFont*(ctx: var TypographyContext, fontData: seq[byte], family: string): bool =
  ## Registers a font from memory for use in this context.
  var mapping: ImpellerMapping
  mapping.data = cast[ptr uint8](unsafeAddr fontData[0])
  mapping.length = uint64(fontData.len)
  mapping.on_release = nil
  ImpellerTypographyContextRegisterFont(ctx.handle, addr mapping, nil, family)

proc toImpellerColor(c: ColorRGBA): ImpellerColor =
  # Converts a ColorRGBA to an ImpellerColor, normalizing to [0,1].
  ImpellerColor(
    red: if c.r > 1: c.r.float32 / 255 else: c.r.float32,
    green: if c.g > 1: c.g.float32 / 255 else: c.g.float32,
    blue: if c.b > 1: c.b.float32 / 255 else: c.b.float32,
    alpha: if c.a > 1: c.a.float32 / 255 else: c.a.float32,
    color_space: kImpellerColorSpaceSRGB
  )

proc toImpellerTextAlign(align: TextAlign): ImpellerTextAlignment =
  align

proc toImpellerTextDirection(dir: TextDirection): ImpellerTextDirection =
  dir

proc toImpellerFontWeight(weight: FontWeight): ImpellerFontWeight =
  weight

proc toImpellerFontStyle(style: FontStyle): ImpellerFontStyle =
  style

proc toImpellerTextDecoration(dec: ImpellerTextDecoration): ptr ImpellerTextDecoration =
  addr dec

proc newTextStyle*(
    fontFamily: string = "sans-serif",
    fontSize: float32 = 14,
    fontWeight: FontWeight = kImpellerFontWeight400,
    fontStyle: FontStyle = kImpellerFontStyleNormal,
    color: ColorRGBA = rgba(0,0,0,255),
    background: Option[ColorRGBA] = none(ColorRGBA),
    align: TextAlign = kImpellerTextAlignmentLeft,
    direction: TextDirection = kImpellerTextDirectionLTR,
    decoration: Option[ImpellerTextDecoration] = none(ImpellerTextDecoration)
  ): TextStyle =
  ## Creates a new text style with the specified properties
  TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    fontStyle: fontStyle,
    color: color,
    background: background,
    align: align,
    direction: direction,
    decoration: decoration
  )

proc toParagraphStyle(style: TextStyle, foregroundPaint, backgroundPaint: var ImpellerPaint): ImpellerParagraphStyle =
  # Generate the ImpellerParagraphStyle from the TextStyle, creating ImpellerPaints
  # for foreground and background colors as needed
  let ps = ImpellerParagraphStyleNew()

  # Foreground color (keep alive until paragraph is built)
  foregroundPaint = ImpellerPaintNew()
  let impColor = toImpellerColor(style.color)
  ImpellerPaintSetColor(foregroundPaint, addr impColor)
  ImpellerParagraphStyleSetForeground(ps, foregroundPaint)

  # Background color (keep alive until paragraph is built)
  backgroundPaint = nil
  if style.background.isSome:
    backgroundPaint = ImpellerPaintNew()
    let bgColor = toImpellerColor(style.background.get)
    ImpellerPaintSetColor(backgroundPaint, addr bgColor)
    ImpellerParagraphStyleSetBackground(ps, backgroundPaint)

  # Font family, size, weight, style
  ImpellerParagraphStyleSetFontFamily(ps, cstring(style.fontFamily))
  ImpellerParagraphStyleSetFontSize(ps, style.fontSize)
  ImpellerParagraphStyleSetFontWeight(ps, style.fontWeight)
  ImpellerParagraphStyleSetFontStyle(ps, style.fontStyle)

  if style.align != kImpellerTextAlignmentLeft:
    ImpellerParagraphStyleSetTextAlignment(ps, style.align)

  ImpellerParagraphStyleSetTextDirection(ps, style.direction)

  if style.decoration.isSome:
    var dec = style.decoration.get
    ImpellerParagraphStyleSetTextDecoration(ps, addr dec)

  ps

proc layoutParagraph*(ctx: TypographyContext, text: string, style: TextStyle, width: float32): Paragraph =
  ## Lays out a paragraph of text with the given style and width.
  let builder = ImpellerParagraphBuilderNew(ctx.handle)

  var fgPaint: ImpellerPaint = nil
  var bgPaint: ImpellerPaint = nil
  let ps = style.toParagraphStyle(fgPaint, bgPaint)

  ImpellerParagraphBuilderPushStyle(builder, ps)
  ImpellerParagraphBuilderAddText(builder, cast[ptr uint8](text.cstring), uint32(text.len))

  let para = ImpellerParagraphBuilderBuildParagraphNew(builder, width)
  ImpellerParagraphBuilderPopStyle(builder)

  # Release after build
  if bgPaint != nil:
    ImpellerPaintRelease(bgPaint)
  if fgPaint != nil:
    ImpellerPaintRelease(fgPaint)

  ImpellerParagraphStyleRelease(ps)
  ImpellerParagraphBuilderRelease(builder)
  result = Paragraph(handle: para)

proc getWidth*(p: Paragraph): float32 =
  ## Returns the max width of the paragraph.
  ImpellerParagraphGetMaxWidth(p.handle).float32

proc getHeight*(p: Paragraph): float32 =
  ## Returns the height of the paragraph.
  ImpellerParagraphGetHeight(p.handle).float32

proc drawParagraph*(builder: ImpellerDisplayListBuilder,
    para: Paragraph, x, y: float32 = 0) =
  ## Draws the paragraph at the given position.
  var pt = ImpellerPoint(x: x, y: y)
  ImpellerDisplayListBuilderDrawParagraph(builder, para.handle, addr pt)

proc release*(p: var Paragraph) =
  ## Releases the paragraph resources.
  if p.handle != nil:
    ImpellerParagraphRelease(p.handle)
    p.handle = nil

proc release*(ctx: var TypographyContext) =
  ## Releases the typography context.
  if ctx.handle != nil:
    ImpellerTypographyContextRelease(ctx.handle)
    ctx.handle = nil