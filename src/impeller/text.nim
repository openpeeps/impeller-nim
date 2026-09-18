# Nim bindings for the Impeller graphics library - High-level Text API
#
# (c) 2026 George Lemon | MIT License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/impeller-nim

import std/options
import pkg/chroma

import ./bindings/impeller_api

## High-level API for working with text in the Impeller rendering engine, including
## typography contexts, text styles, and paragraph layout and drawing:
## 
## - TypographyContext for managing fonts and text layout
## - TextStyle for defining the appearance of text
## - Paragraph for representing laid out text ready to be drawn
## - Alignment, direction, and decoration options for rich text styling
## - Utility functions for converting between our types and Impeller's types

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

proc registerFont*(ctx: var TypographyContext, fontData: openArray[byte], family: string): bool =
  ## Registers a font from memory for use in this context.
  ## `fontData` must be non-empty. Impeller copies the data synchronously.
  if fontData.len == 0:
    return false
  var mapping = ImpellerMapping(
    data: cast[ptr uint8](unsafeAddr fontData[0]),
    length: uint64(fontData.len),
    on_release: nil)
  ImpellerTypographyContextRegisterFont(ctx.handle, addr mapping, nil, family)

proc registerFontFile*(ctx: var TypographyContext, path, family: string): bool =
  ## Convenience: loads a font file and registers it.
  let bytes = readFile(path)
  if bytes.len == 0: return false
  var mapping = ImpellerMapping(
    data: cast[ptr uint8](unsafeAddr bytes[0]),
    length: uint64(bytes.len),
    on_release: nil)
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

proc applyStyle(ps: ImpellerParagraphStyle, style: TextStyle,
    foregroundPaint, backgroundPaint: var ImpellerPaint,
    decorationStorage: var ImpellerTextDecoration,
    hasDecoration: var bool) =
  ## Applies a TextStyle to a native paragraph style. `decorationStorage`
  ## must outlive the paragraph build (pass a caller-owned var).
  foregroundPaint = ImpellerPaintNew()
  var impColor = toImpellerColor(style.color)
  ImpellerPaintSetColor(foregroundPaint, addr impColor)
  ImpellerParagraphStyleSetForeground(ps, foregroundPaint)

  backgroundPaint = nil
  if style.background.isSome:
    backgroundPaint = ImpellerPaintNew()
    var bgColor = toImpellerColor(style.background.get)
    ImpellerPaintSetColor(backgroundPaint, addr bgColor)
    ImpellerParagraphStyleSetBackground(ps, backgroundPaint)

  ImpellerParagraphStyleSetFontFamily(ps, cstring(style.fontFamily))
  ImpellerParagraphStyleSetFontSize(ps, style.fontSize)
  ImpellerParagraphStyleSetFontWeight(ps, style.fontWeight)
  ImpellerParagraphStyleSetFontStyle(ps, style.fontStyle)

  if style.align != kImpellerTextAlignmentLeft:
    ImpellerParagraphStyleSetTextAlignment(ps, style.align)
  ImpellerParagraphStyleSetTextDirection(ps, style.direction)

  hasDecoration = style.decoration.isSome
  if hasDecoration:
    decorationStorage = style.decoration.get
    ImpellerParagraphStyleSetTextDecoration(ps, addr decorationStorage)

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

proc toParagraphStyle(style: TextStyle, foregroundPaint, backgroundPaint: var ImpellerPaint,
    decorationStorage: var ImpellerTextDecoration,
    hasDecoration: var bool): ImpellerParagraphStyle =
  # Generate the ImpellerParagraphStyle from the TextStyle, creating ImpellerPaints
  # for foreground and background colors as needed. Decoration storage must
  # outlive the paragraph build, hence caller-owned.
  result = ImpellerParagraphStyleNew()
  applyStyle(result, style, foregroundPaint, backgroundPaint,
    decorationStorage, hasDecoration)

proc setMaxLines*(ps: ImpellerParagraphStyle, n: uint32) {.inline.} =
  ImpellerParagraphStyleSetMaxLines(ps, n)

proc setHeight*(ps: ImpellerParagraphStyle, h: float32) {.inline.} =
  ImpellerParagraphStyleSetHeight(ps, h)

proc setLocale*(ps: ImpellerParagraphStyle, locale: string) {.inline.} =
  ImpellerParagraphStyleSetLocale(ps, cstring(locale))

proc setEllipsis*(ps: ImpellerParagraphStyle, ellipsis: string) {.inline.} =
  ImpellerParagraphStyleSetEllipsis(ps, cstring(ellipsis))

proc layoutParagraph*(ctx: TypographyContext, text: string, style: TextStyle, width: float32): Paragraph =
  ## Lays out a paragraph of text with the given style and width.
  let builder = ImpellerParagraphBuilderNew(ctx.handle)

  var fgPaint: ImpellerPaint = nil
  var bgPaint: ImpellerPaint = nil
  var decStorage: ImpellerTextDecoration
  var hasDec = false
  let ps = style.toParagraphStyle(fgPaint, bgPaint, decStorage, hasDec)

  try:
    ImpellerParagraphBuilderPushStyle(builder, ps)
    if text.len > 0:
      ImpellerParagraphBuilderAddText(builder,
        cast[ptr uint8](unsafeAddr text[0]), uint32(text.len))
    let para = ImpellerParagraphBuilderBuildParagraphNew(builder, width)
    ImpellerParagraphBuilderPopStyle(builder)
    result = Paragraph(handle: para)
  finally:
    if bgPaint != nil: ImpellerPaintRelease(bgPaint)
    if fgPaint != nil: ImpellerPaintRelease(fgPaint)
    ImpellerParagraphStyleRelease(ps)
    ImpellerParagraphBuilderRelease(builder)

type
  StyledSpan* = tuple[text: string, style: TextStyle]
    ## One run of text with its own style, for rich paragraphs.

proc layoutRichParagraph*(ctx: TypographyContext,
    spans: openArray[StyledSpan], width: float32,
    maxLines: uint32 = 0, ellipsis: string = ""): Paragraph =
  ## Lays out a multi-style paragraph. Each span pushes its style, adds
  ## text, then pops. `maxLines`/`ellipsis` apply to the whole paragraph
  ## via an extra base style... kept simple: applied per-span is a no-op,
  ## so we set them on the first span's native style when present.
  let builder = ImpellerParagraphBuilderNew(ctx.handle)
  var paints: seq[ImpellerPaint] = @[]
  var styles: seq[ImpellerParagraphStyle] = @[]
  # Decoration storages must outlive the build: one per span.
  var decStorages = newSeq[ImpellerTextDecoration](spans.len)
  var hasDecs = newSeq[bool](spans.len)
  try:
    for i, span in spans:
      var fg, bg: ImpellerPaint = nil
      let ps = span.style.toParagraphStyle(fg, bg, decStorages[i], hasDecs[i])
      if maxLines > 0 and i == 0:
        ImpellerParagraphStyleSetMaxLines(ps, maxLines)
      if ellipsis.len > 0 and i == 0:
        ImpellerParagraphStyleSetEllipsis(ps, cstring(ellipsis))
      styles.add(ps)
      if fg != nil: paints.add(fg)
      if bg != nil: paints.add(bg)
      ImpellerParagraphBuilderPushStyle(builder, ps)
      if span.text.len > 0:
        ImpellerParagraphBuilderAddText(builder,
          cast[ptr uint8](unsafeAddr spans[i].text[0]),
          uint32(span.text.len))
    let para = ImpellerParagraphBuilderBuildParagraphNew(builder, width)
    for _ in spans:
      ImpellerParagraphBuilderPopStyle(builder)
    result = Paragraph(handle: para)
  finally:
    for p in paints:
      if p != nil: ImpellerPaintRelease(p)
    for s in styles:
      ImpellerParagraphStyleRelease(s)
    ImpellerParagraphBuilderRelease(builder)

proc getWidth*(p: Paragraph): float32 =
  ## Returns the max width of the paragraph.
  ImpellerParagraphGetMaxWidth(p.handle).float32

proc getHeight*(p: Paragraph): float32 =
  ## Returns the height of the paragraph.
  ImpellerParagraphGetHeight(p.handle).float32

proc getLongestLineWidth*(p: Paragraph): float32 {.inline.} =
  ImpellerParagraphGetLongestLineWidth(p.handle).float32

proc getMinIntrinsicWidth*(p: Paragraph): float32 {.inline.} =
  ImpellerParagraphGetMinIntrinsicWidth(p.handle).float32

proc getMaxIntrinsicWidth*(p: Paragraph): float32 {.inline.} =
  ImpellerParagraphGetMaxIntrinsicWidth(p.handle).float32

proc getLineCount*(p: Paragraph): uint32 {.inline.} =
  ImpellerParagraphGetLineCount(p.handle)

proc getWordBoundary*(p: Paragraph, index: int): tuple[first, last: uint64] =
  var r: ImpellerRange
  ImpellerParagraphGetWordBoundary(p.handle, index.csize_t, addr r)
  (r.start, r.`end`)

proc drawParagraph*(builder: ImpellerDisplayListBuilder,
    para: Paragraph, x: float32 = 0, y: float32 = 0) =
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
