# Nim bindings for the Impeller graphics library
#
# (c) 2026 George Lemon | MIT License
#     Made by Humans from OpenPeeps
#     https://github.com/openpeeps/impeller-nim

## This module provides low-level bindings to the Impeller graphics library.
## These bindings are designed to be as thin and direct as possible, closely
## mirroring the C API of Impeller.
## 
## They are intended for users who want maximum control and flexibility when
## using Impeller from Nim.

type
  # Opaque handles
  ImpellerContext* = pointer
  ImpellerDisplayList* = pointer
  ImpellerDisplayListBuilder* = pointer
  ImpellerPaint* = pointer
  ImpellerColorFilter* = pointer
  ImpellerColorSource* = pointer
  ImpellerImageFilter* = pointer
  ImpellerMaskFilter* = pointer
  ImpellerTypographyContext* = pointer
  ImpellerParagraph* = pointer
  ImpellerParagraphBuilder* = pointer
  ImpellerParagraphStyle* = pointer
  ImpellerLineMetrics* = pointer
  ImpellerGlyphInfo* = pointer
  ImpellerPath* = pointer
  ImpellerPathBuilder* = pointer
  ImpellerSurface* = pointer
  ImpellerTexture* = pointer
  ImpellerVulkanSwapchain* = pointer
  ImpellerFragmentProgram* = pointer

{.push importc, header:"<impeller.h>".}

type
  # Function pointer types
  ImpellerCallback* = proc(user_data: pointer) {.cdecl.}
  ImpellerProcAddressCallback* = proc(proc_name: cstring, user_data: pointer): pointer {.cdecl.}
  ImpellerVulkanProcAddressCallback* = proc(vulkan_instance: pointer, vulkan_proc_name: cstring, user_data: pointer): pointer {.cdecl.}

  # Enums
  ImpellerFillType* {.size: sizeof(cint).} = enum
    kImpellerFillTypeNonZero,
    kImpellerFillTypeOdd

  ImpellerClipOperation* {.size: sizeof(cint).} = enum
    kImpellerClipOperationDifference,
    kImpellerClipOperationIntersect

  ImpellerBlendMode* {.size: sizeof(cint).} = enum
    kImpellerBlendModeClear,
    kImpellerBlendModeSource,
    kImpellerBlendModeDestination,
    kImpellerBlendModeSourceOver,
    kImpellerBlendModeDestinationOver,
    kImpellerBlendModeSourceIn,
    kImpellerBlendModeDestinationIn,
    kImpellerBlendModeSourceOut,
    kImpellerBlendModeDestinationOut,
    kImpellerBlendModeSourceATop,
    kImpellerBlendModeDestinationATop,
    kImpellerBlendModeXor,
    kImpellerBlendModePlus,
    kImpellerBlendModeModulate,
    kImpellerBlendModeScreen,
    kImpellerBlendModeOverlay,
    kImpellerBlendModeDarken,
    kImpellerBlendModeLighten,
    kImpellerBlendModeColorDodge,
    kImpellerBlendModeColorBurn,
    kImpellerBlendModeHardLight,
    kImpellerBlendModeSoftLight,
    kImpellerBlendModeDifference,
    kImpellerBlendModeExclusion,
    kImpellerBlendModeMultiply,
    kImpellerBlendModeHue,
    kImpellerBlendModeSaturation,
    kImpellerBlendModeColor,
    kImpellerBlendModeLuminosity

  ImpellerDrawStyle* {.size: sizeof(cint).} = enum
    kImpellerDrawStyleFill,
    kImpellerDrawStyleStroke,
    kImpellerDrawStyleStrokeAndFill

  ImpellerStrokeCap* {.size: sizeof(cint).} = enum
    kImpellerStrokeCapButt,
    kImpellerStrokeCapRound,
    kImpellerStrokeCapSquare

  ImpellerStrokeJoin* {.size: sizeof(cint).} = enum
    kImpellerStrokeJoinMiter,
    kImpellerStrokeJoinRound,
    kImpellerStrokeJoinBevel

  ImpellerPixelFormat* {.size: sizeof(cint).} = enum
    kImpellerPixelFormatRGBA8888

  ImpellerTextureSampling* {.size: sizeof(cint).} = enum
    kImpellerTextureSamplingNearestNeighbor,
    kImpellerTextureSamplingLinear

  ImpellerTileMode* {.size: sizeof(cint).} = enum
    kImpellerTileModeClamp,
    kImpellerTileModeRepeat,
    kImpellerTileModeMirror,
    kImpellerTileModeDecal

  ImpellerBlurStyle* {.size: sizeof(cint).} = enum
    kImpellerBlurStyleNormal,
    kImpellerBlurStyleSolid,
    kImpellerBlurStyleOuter,
    kImpellerBlurStyleInner

  ImpellerColorSpace* {.size: sizeof(cint).} = enum
    kImpellerColorSpaceSRGB,
    kImpellerColorSpaceExtendedSRGB,
    kImpellerColorSpaceDisplayP3

  ImpellerFontWeight* {.size: sizeof(cint).} = enum
    kImpellerFontWeight100,
    kImpellerFontWeight200,
    kImpellerFontWeight300,
    kImpellerFontWeight400,
    kImpellerFontWeight500,
    kImpellerFontWeight600,
    kImpellerFontWeight700,
    kImpellerFontWeight800,
    kImpellerFontWeight900

  ImpellerFontStyle* {.size: sizeof(cint).} = enum
    kImpellerFontStyleNormal,
    kImpellerFontStyleItalic

  ImpellerTextAlignment* {.size: sizeof(cint).} = enum
    kImpellerTextAlignmentLeft,
    kImpellerTextAlignmentRight,
    kImpellerTextAlignmentCenter,
    kImpellerTextAlignmentJustify,
    kImpellerTextAlignmentStart,
    kImpellerTextAlignmentEnd

  ImpellerTextDirection* {.size: sizeof(cint).} = enum
    kImpellerTextDirectionRTL,
    kImpellerTextDirectionLTR

  ImpellerTextDecorationType* {.size: sizeof(cint).} = enum
    kImpellerTextDecorationTypeNone = 0,
    kImpellerTextDecorationTypeUnderline = 1,
    kImpellerTextDecorationTypeOverline = 2,
    kImpellerTextDecorationTypeLineThrough = 4

  ImpellerTextDecorationStyle* {.size: sizeof(cint).} = enum
    kImpellerTextDecorationStyleSolid,
    kImpellerTextDecorationStyleDouble,
    kImpellerTextDecorationStyleDotted,
    kImpellerTextDecorationStyleDashed,
    kImpellerTextDecorationStyleWavy

  # Structs
  ImpellerRect* {.byCopy.} = object
    x*, y*, width*, height*: cfloat

  ImpellerPoint* {.byCopy.} = object
    x*, y*: cfloat

  ImpellerSize* {.byCopy.} = object
    width*, height*: cfloat

  ImpellerISize* {.byCopy.} = object
    width*, height*: int64

  ImpellerRange* {.byCopy.} = object
    start*, `end`*: uint64

  ImpellerMatrix* {.byCopy.} = object
    m*: array[16, cfloat]

  ImpellerColorMatrix* {.byCopy.} = object
    m*: array[20, cfloat]

  ImpellerRoundingRadii* {.byCopy.} = object
    top_left*, bottom_left*, top_right*, bottom_right*: ImpellerPoint

  ImpellerColor* {.byCopy.} = object
    red*, green*, blue*, alpha*: cfloat
    color_space*: ImpellerColorSpace

  ImpellerTextureDescriptor* {.byCopy.} = object
    pixel_format*: ImpellerPixelFormat
    size*: ImpellerISize
    mip_count*: uint32

  ImpellerMapping* {.byCopy.} = object
    data*: ptr uint8
    length*: uint64
    on_release*: ImpellerCallback

  ImpellerContextVulkanSettings* {.byCopy.} = object
    user_data*: pointer
    proc_address_callback*: ImpellerVulkanProcAddressCallback
    enable_vulkan_validation*: bool

  ImpellerContextVulkanInfo* {.byCopy.} = object
    vk_instance*: pointer
    vk_physical_device*: pointer
    vk_logical_device*: pointer
    graphics_queue_family_index*: uint32
    graphics_queue_index*: uint32

  ImpellerTextDecoration* {.byCopy.} = object
    types*: cint
    color*: ImpellerColor
    style*: ImpellerTextDecorationStyle
    thickness_multiplier*: cfloat

# Version
proc ImpellerGetVersion*(): uint32

# Context
proc ImpellerContextCreateOpenGLESNew*(version: uint32, gl_proc_address_callback: ImpellerProcAddressCallback, gl_proc_address_callback_user_data: pointer): ImpellerContext
proc ImpellerContextCreateMetalNew*(version: uint32): ImpellerContext

proc ImpellerContextCreateVulkanNew*(version: uint32, settings: ptr ImpellerContextVulkanSettings): ImpellerContext
proc ImpellerContextRetain*(context: ImpellerContext)
proc ImpellerContextRelease*(context: ImpellerContext)
proc ImpellerContextGetVulkanInfo*(context: ImpellerContext, out_vulkan_info: ptr ImpellerContextVulkanInfo): bool

# Vulkan Swapchain
proc ImpellerVulkanSwapchainCreateNew*(context: ImpellerContext, vulkan_surface_khr: pointer): ImpellerVulkanSwapchain
proc ImpellerVulkanSwapchainRetain*(swapchain: ImpellerVulkanSwapchain)
proc ImpellerVulkanSwapchainRelease*(swapchain: ImpellerVulkanSwapchain)
proc ImpellerVulkanSwapchainAcquireNextSurfaceNew*(swapchain: ImpellerVulkanSwapchain): ImpellerSurface

# Surface
proc ImpellerSurfaceCreateWrappedFBONew*(context: ImpellerContext, fbo: uint64, format: ImpellerPixelFormat, size: ptr ImpellerISize): ImpellerSurface
proc ImpellerSurfaceCreateWrappedMetalDrawableNew*(context: ImpellerContext, metal_drawable: pointer): ImpellerSurface

proc ImpellerSurfaceRetain*(surface: ImpellerSurface)
proc ImpellerSurfaceRelease*(surface: ImpellerSurface)
proc ImpellerSurfaceDrawDisplayList*(surface: ImpellerSurface, display_list: ImpellerDisplayList): bool

proc ImpellerSurfacePresent*(surface: ImpellerSurface): bool

# Path
proc ImpellerPathRetain*(path: ImpellerPath)
proc ImpellerPathRelease*(path: ImpellerPath)
proc ImpellerPathGetBounds*(path: ImpellerPath, out_bounds: ptr ImpellerRect)

# Path Builder
proc ImpellerPathBuilderNew*(): ImpellerPathBuilder
proc ImpellerPathBuilderRetain*(builder: ImpellerPathBuilder)
proc ImpellerPathBuilderRelease*(builder: ImpellerPathBuilder)
proc ImpellerPathBuilderMoveTo*(builder: ImpellerPathBuilder, location: ptr ImpellerPoint)
proc ImpellerPathBuilderLineTo*(builder: ImpellerPathBuilder, location: ptr ImpellerPoint)
proc ImpellerPathBuilderQuadraticCurveTo*(builder: ImpellerPathBuilder, control_point: ptr ImpellerPoint, end_point: ptr ImpellerPoint)
proc ImpellerPathBuilderCubicCurveTo*(builder: ImpellerPathBuilder, control_point_1: ptr ImpellerPoint, control_point_2: ptr ImpellerPoint, end_point: ptr ImpellerPoint)
proc ImpellerPathBuilderAddRect*(builder: ImpellerPathBuilder, rect: ptr ImpellerRect)
proc ImpellerPathBuilderAddArc*(builder: ImpellerPathBuilder, oval_bounds: ptr ImpellerRect, start_angle_degrees: cfloat, end_angle_degrees: cfloat)
proc ImpellerPathBuilderAddOval*(builder: ImpellerPathBuilder, oval_bounds: ptr ImpellerRect)
proc ImpellerPathBuilderAddRoundedRect*(builder: ImpellerPathBuilder, rect: ptr ImpellerRect, rounding_radii: ptr ImpellerRoundingRadii)
proc ImpellerPathBuilderClose*(builder: ImpellerPathBuilder)
proc ImpellerPathBuilderCopyPathNew*(builder: ImpellerPathBuilder, fill: ImpellerFillType): ImpellerPath
proc ImpellerPathBuilderTakePathNew*(builder: ImpellerPathBuilder, fill: ImpellerFillType): ImpellerPath

# Paint
proc ImpellerPaintNew*(): ImpellerPaint
proc ImpellerPaintRetain*(paint: ImpellerPaint)
proc ImpellerPaintRelease*(paint: ImpellerPaint)
proc ImpellerPaintSetColor*(paint: ImpellerPaint, color: ptr ImpellerColor)
proc ImpellerPaintSetBlendMode*(paint: ImpellerPaint, mode: ImpellerBlendMode)
proc ImpellerPaintSetDrawStyle*(paint: ImpellerPaint, style: ImpellerDrawStyle)
proc ImpellerPaintSetStrokeCap*(paint: ImpellerPaint, cap: ImpellerStrokeCap)
proc ImpellerPaintSetStrokeJoin*(paint: ImpellerPaint, join: ImpellerStrokeJoin)
proc ImpellerPaintSetStrokeWidth*(paint: ImpellerPaint, width: cfloat)
proc ImpellerPaintSetStrokeMiter*(paint: ImpellerPaint, miter: cfloat)
proc ImpellerPaintSetColorFilter*(paint: ImpellerPaint, color_filter: ImpellerColorFilter)
proc ImpellerPaintSetColorSource*(paint: ImpellerPaint, color_source: ImpellerColorSource)
proc ImpellerPaintSetImageFilter*(paint: ImpellerPaint, image_filter: ImpellerImageFilter)
proc ImpellerPaintSetMaskFilter*(paint: ImpellerPaint, mask_filter: ImpellerMaskFilter)

# Texture
proc ImpellerTextureCreateWithContentsNew*(
  context: ImpellerContext,
  descriptor: ptr ImpellerTextureDescriptor,
  contents: ptr ImpellerMapping,
  contents_on_release_user_data: pointer
): ImpellerTexture

proc ImpellerTextureCreateWithOpenGLTextureHandleNew*(
  context: ImpellerContext,
  descriptor: ptr ImpellerTextureDescriptor,
  handle: uint64
): ImpellerTexture

proc ImpellerTextureRetain*(texture: ImpellerTexture)
proc ImpellerTextureRelease*(texture: ImpellerTexture)
proc ImpellerTextureGetOpenGLHandle*(texture: ImpellerTexture): uint64

# Fragment Program
proc ImpellerFragmentProgramNew*(data: ptr ImpellerMapping, data_release_user_data: pointer): ImpellerFragmentProgram
proc ImpellerFragmentProgramRetain*(fragment_program: ImpellerFragmentProgram)
proc ImpellerFragmentProgramRelease*(fragment_program: ImpellerFragmentProgram)

# Color Sources
proc ImpellerColorSourceRetain*(color_source: ImpellerColorSource)
proc ImpellerColorSourceRelease*(color_source: ImpellerColorSource)
proc ImpellerColorSourceCreateLinearGradientNew*(start_point: ptr ImpellerPoint, end_point: ptr ImpellerPoint, stop_count: uint32, colors: ptr ImpellerColor, stops: ptr cfloat, tile_mode: ImpellerTileMode, transformation: ptr ImpellerMatrix): ImpellerColorSource
proc ImpellerColorSourceCreateRadialGradientNew*(center: ptr ImpellerPoint, radius: cfloat, stop_count: uint32, colors: ptr ImpellerColor, stops: ptr cfloat, tile_mode: ImpellerTileMode, transformation: ptr ImpellerMatrix): ImpellerColorSource
proc ImpellerColorSourceCreateConicalGradientNew*(start_center: ptr ImpellerPoint, start_radius: cfloat, end_center: ptr ImpellerPoint, end_radius: cfloat, stop_count: uint32, colors: ptr ImpellerColor, stops: ptr cfloat, tile_mode: ImpellerTileMode, transformation: ptr ImpellerMatrix): ImpellerColorSource
proc ImpellerColorSourceCreateSweepGradientNew*(center: ptr ImpellerPoint, start: cfloat, `end`: cfloat, stop_count: uint32, colors: ptr ImpellerColor, stops: ptr cfloat, tile_mode: ImpellerTileMode, transformation: ptr ImpellerMatrix): ImpellerColorSource
proc ImpellerColorSourceCreateImageNew*(image: ImpellerTexture, horizontal_tile_mode: ImpellerTileMode, vertical_tile_mode: ImpellerTileMode, sampling: ImpellerTextureSampling, transformation: ptr ImpellerMatrix): ImpellerColorSource
proc ImpellerColorSourceCreateFragmentProgramNew*(context: ImpellerContext, fragment_program: ImpellerFragmentProgram, samplers: ptr ImpellerTexture, samplers_count: csize_t, data: ptr uint8, data_bytes_length: csize_t): ImpellerColorSource

# Color Filters
proc ImpellerColorFilterRetain*(color_filter: ImpellerColorFilter)
proc ImpellerColorFilterRelease*(color_filter: ImpellerColorFilter)
proc ImpellerColorFilterCreateBlendNew*(color: ptr ImpellerColor, blend_mode: ImpellerBlendMode): ImpellerColorFilter
proc ImpellerColorFilterCreateColorMatrixNew*(color_matrix: ptr ImpellerColorMatrix): ImpellerColorFilter

# Mask Filters
proc ImpellerMaskFilterRetain*(mask_filter: ImpellerMaskFilter)
proc ImpellerMaskFilterRelease*(mask_filter: ImpellerMaskFilter)
proc ImpellerMaskFilterCreateBlurNew*(style: ImpellerBlurStyle, sigma: cfloat): ImpellerMaskFilter

# Image Filters
proc ImpellerImageFilterRetain*(image_filter: ImpellerImageFilter)
proc ImpellerImageFilterRelease*(image_filter: ImpellerImageFilter)
proc ImpellerImageFilterCreateBlurNew*(x_sigma: cfloat, y_sigma: cfloat, tile_mode: ImpellerTileMode): ImpellerImageFilter
proc ImpellerImageFilterCreateDilateNew*(x_radius: cfloat, y_radius: cfloat): ImpellerImageFilter
proc ImpellerImageFilterCreateErodeNew*(x_radius: cfloat, y_radius: cfloat): ImpellerImageFilter
proc ImpellerImageFilterCreateMatrixNew*(matrix: ptr ImpellerMatrix, sampling: ImpellerTextureSampling): ImpellerImageFilter
proc ImpellerImageFilterCreateFragmentProgramNew*(context: ImpellerContext, fragment_program: ImpellerFragmentProgram, samplers: ptr ImpellerTexture, samplers_count: csize_t, data: ptr uint8, data_bytes_length: csize_t): ImpellerImageFilter
proc ImpellerImageFilterCreateComposeNew*(outer: ImpellerImageFilter, inner: ImpellerImageFilter): ImpellerImageFilter

# Display List
proc ImpellerDisplayListRetain*(display_list: ImpellerDisplayList)
proc ImpellerDisplayListRelease*(display_list: ImpellerDisplayList)

# Display List Builder
proc ImpellerDisplayListBuilderNew*(cull_rect: ptr ImpellerRect): ImpellerDisplayListBuilder
proc ImpellerDisplayListBuilderRetain*(builder: ImpellerDisplayListBuilder)
proc ImpellerDisplayListBuilderRelease*(builder: ImpellerDisplayListBuilder)
proc ImpellerDisplayListBuilderCreateDisplayListNew*(builder: ImpellerDisplayListBuilder): ImpellerDisplayList

# Display List Builder: Managing the transformation stack
proc ImpellerDisplayListBuilderSave*(builder: ImpellerDisplayListBuilder)
proc ImpellerDisplayListBuilderSaveLayer*(builder: ImpellerDisplayListBuilder, bounds: ptr ImpellerRect, paint: ImpellerPaint, backdrop: ImpellerImageFilter)
proc ImpellerDisplayListBuilderRestore*(builder: ImpellerDisplayListBuilder)
proc ImpellerDisplayListBuilderScale*(builder: ImpellerDisplayListBuilder, x_scale, y_scale: cfloat)
proc ImpellerDisplayListBuilderRotate*(builder: ImpellerDisplayListBuilder, angle_degrees: cfloat)
proc ImpellerDisplayListBuilderTranslate*(builder: ImpellerDisplayListBuilder, x_translation, y_translation: cfloat)
proc ImpellerDisplayListBuilderTransform*(builder: ImpellerDisplayListBuilder, transform: ptr ImpellerMatrix)
proc ImpellerDisplayListBuilderSetTransform*(builder: ImpellerDisplayListBuilder, transform: ptr ImpellerMatrix)
proc ImpellerDisplayListBuilderGetTransform*(builder: ImpellerDisplayListBuilder, out_transform: ptr ImpellerMatrix)
proc ImpellerDisplayListBuilderResetTransform*(builder: ImpellerDisplayListBuilder)
proc ImpellerDisplayListBuilderGetSaveCount*(builder: ImpellerDisplayListBuilder): uint32
proc ImpellerDisplayListBuilderRestoreToCount*(builder: ImpellerDisplayListBuilder, count: uint32)

# Display List Builder: Clipping
proc ImpellerDisplayListBuilderClipRect*(builder: ImpellerDisplayListBuilder, rect: ptr ImpellerRect, op: ImpellerClipOperation)
proc ImpellerDisplayListBuilderClipOval*(builder: ImpellerDisplayListBuilder, oval_bounds: ptr ImpellerRect, op: ImpellerClipOperation)
proc ImpellerDisplayListBuilderClipRoundedRect*(builder: ImpellerDisplayListBuilder, rect: ptr ImpellerRect, radii: ptr ImpellerRoundingRadii, op: ImpellerClipOperation)
proc ImpellerDisplayListBuilderClipPath*(builder: ImpellerDisplayListBuilder, path: ImpellerPath, op: ImpellerClipOperation)

# Display List Builder: Drawing Shapes
proc ImpellerDisplayListBuilderDrawPaint*(builder: ImpellerDisplayListBuilder, paint: ImpellerPaint)
proc ImpellerDisplayListBuilderDrawLine*(builder: ImpellerDisplayListBuilder, `from`: ptr ImpellerPoint, to: ptr ImpellerPoint, paint: ImpellerPaint)
proc ImpellerDisplayListBuilderDrawDashedLine*(builder: ImpellerDisplayListBuilder, `from`: ptr ImpellerPoint, to: ptr ImpellerPoint, on_length, off_length: cfloat, paint: ImpellerPaint)
proc ImpellerDisplayListBuilderDrawRect*(builder: ImpellerDisplayListBuilder, rect: ptr ImpellerRect, paint: ImpellerPaint)
proc ImpellerDisplayListBuilderDrawOval*(builder: ImpellerDisplayListBuilder, oval_bounds: ptr ImpellerRect, paint: ImpellerPaint)
proc ImpellerDisplayListBuilderDrawRoundedRect*(builder: ImpellerDisplayListBuilder, rect: ptr ImpellerRect, radii: ptr ImpellerRoundingRadii, paint: ImpellerPaint)
proc ImpellerDisplayListBuilderDrawRoundedRectDifference*(builder: ImpellerDisplayListBuilder, outer_rect: ptr ImpellerRect, outer_radii: ptr ImpellerRoundingRadii, inner_rect: ptr ImpellerRect, inner_radii: ptr ImpellerRoundingRadii, paint: ImpellerPaint)
proc ImpellerDisplayListBuilderDrawPath*(builder: ImpellerDisplayListBuilder, path: ImpellerPath, paint: ImpellerPaint)
proc ImpellerDisplayListBuilderDrawDisplayList*(builder: ImpellerDisplayListBuilder, display_list: ImpellerDisplayList, opacity: cfloat)
proc ImpellerDisplayListBuilderDrawParagraph*(builder: ImpellerDisplayListBuilder, paragraph: ImpellerParagraph, point: ptr ImpellerPoint)
proc ImpellerDisplayListBuilderDrawShadow*(builder: ImpellerDisplayListBuilder, path: ImpellerPath, color: ptr ImpellerColor, elevation: cfloat, occluder_is_transparent: bool, device_pixel_ratio: cfloat)

# Display List Builder: Drawing Textures
proc ImpellerDisplayListBuilderDrawTexture*(builder: ImpellerDisplayListBuilder, texture: ImpellerTexture, point: ptr ImpellerPoint, sampling: ImpellerTextureSampling, paint: ImpellerPaint)
proc ImpellerDisplayListBuilderDrawTextureRect*(builder: ImpellerDisplayListBuilder, texture: ImpellerTexture, src_rect: ptr ImpellerRect, dst_rect: ptr ImpellerRect, sampling: ImpellerTextureSampling, paint: ImpellerPaint)

# Typography Context
proc ImpellerTypographyContextNew*(): ImpellerTypographyContext
proc ImpellerTypographyContextRetain*(context: ImpellerTypographyContext)
proc ImpellerTypographyContextRelease*(context: ImpellerTypographyContext)
proc ImpellerTypographyContextRegisterFont*(context: ImpellerTypographyContext, contents: ptr ImpellerMapping, contents_on_release_user_data: pointer, family_name_alias: cstring): bool

# Paragraph Style
proc ImpellerParagraphStyleNew*(): ImpellerParagraphStyle
proc ImpellerParagraphStyleRetain*(paragraph_style: ImpellerParagraphStyle)
proc ImpellerParagraphStyleRelease*(paragraph_style: ImpellerParagraphStyle)
proc ImpellerParagraphStyleSetForeground*(paragraph_style: ImpellerParagraphStyle, paint: ImpellerPaint)
proc ImpellerParagraphStyleSetBackground*(paragraph_style: ImpellerParagraphStyle, paint: ImpellerPaint)
proc ImpellerParagraphStyleSetFontWeight*(paragraph_style: ImpellerParagraphStyle, weight: ImpellerFontWeight)
proc ImpellerParagraphStyleSetFontStyle*(paragraph_style: ImpellerParagraphStyle, style: ImpellerFontStyle)
proc ImpellerParagraphStyleSetFontFamily*(paragraph_style: ImpellerParagraphStyle, family_name: cstring)
proc ImpellerParagraphStyleSetFontSize*(paragraph_style: ImpellerParagraphStyle, size: cfloat)
proc ImpellerParagraphStyleSetHeight*(paragraph_style: ImpellerParagraphStyle, height: cfloat)
proc ImpellerParagraphStyleSetTextAlignment*(paragraph_style: ImpellerParagraphStyle, align: ImpellerTextAlignment)
proc ImpellerParagraphStyleSetTextDirection*(paragraph_style: ImpellerParagraphStyle, direction: ImpellerTextDirection)
proc ImpellerParagraphStyleSetTextDecoration*(paragraph_style: ImpellerParagraphStyle, decoration: ptr ImpellerTextDecoration)
proc ImpellerParagraphStyleSetMaxLines*(paragraph_style: ImpellerParagraphStyle, max_lines: uint32)
proc ImpellerParagraphStyleSetLocale*(paragraph_style: ImpellerParagraphStyle, locale: cstring)
proc ImpellerParagraphStyleSetEllipsis*(paragraph_style: ImpellerParagraphStyle, ellipsis: cstring)

# Paragraph Builder
proc ImpellerParagraphBuilderNew*(context: ImpellerTypographyContext): ImpellerParagraphBuilder
proc ImpellerParagraphBuilderRetain*(paragraph_builder: ImpellerParagraphBuilder)
proc ImpellerParagraphBuilderRelease*(paragraph_builder: ImpellerParagraphBuilder)
proc ImpellerParagraphBuilderPushStyle*(paragraph_builder: ImpellerParagraphBuilder, style: ImpellerParagraphStyle)
proc ImpellerParagraphBuilderPopStyle*(paragraph_builder: ImpellerParagraphBuilder)
proc ImpellerParagraphBuilderAddText*(paragraph_builder: ImpellerParagraphBuilder, data: ptr uint8, length: uint32)
proc ImpellerParagraphBuilderBuildParagraphNew*(paragraph_builder: ImpellerParagraphBuilder, width: cfloat): ImpellerParagraph

# Paragraph
proc ImpellerParagraphRetain*(paragraph: ImpellerParagraph)
proc ImpellerParagraphRelease*(paragraph: ImpellerParagraph)
proc ImpellerParagraphGetMaxWidth*(paragraph: ImpellerParagraph): cfloat
proc ImpellerParagraphGetHeight*(paragraph: ImpellerParagraph): cfloat
proc ImpellerParagraphGetLongestLineWidth*(paragraph: ImpellerParagraph): cfloat
proc ImpellerParagraphGetMinIntrinsicWidth*(paragraph: ImpellerParagraph): cfloat
proc ImpellerParagraphGetMaxIntrinsicWidth*(paragraph: ImpellerParagraph): cfloat
proc ImpellerParagraphGetIdeographicBaseline*(paragraph: ImpellerParagraph): cfloat
proc ImpellerParagraphGetAlphabeticBaseline*(paragraph: ImpellerParagraph): cfloat
proc ImpellerParagraphGetLineCount*(paragraph: ImpellerParagraph): uint32
proc ImpellerParagraphGetWordBoundary*(paragraph: ImpellerParagraph, code_unit_index: csize_t, out_range: ptr ImpellerRange)
proc ImpellerParagraphGetLineMetrics*(paragraph: ImpellerParagraph): ImpellerLineMetrics
proc ImpellerParagraphCreateGlyphInfoAtCodeUnitIndexNew*(paragraph: ImpellerParagraph, code_unit_index: csize_t): ImpellerGlyphInfo
proc ImpellerParagraphCreateGlyphInfoAtParagraphCoordinatesNew*(paragraph: ImpellerParagraph, x, y: cdouble): ImpellerGlyphInfo

# Line Metrics
proc ImpellerLineMetricsRetain*(line_metrics: ImpellerLineMetrics)
proc ImpellerLineMetricsRelease*(line_metrics: ImpellerLineMetrics)
proc ImpellerLineMetricsGetUnscaledAscent*(metrics: ImpellerLineMetrics, line: csize_t): cdouble
proc ImpellerLineMetricsGetAscent*(metrics: ImpellerLineMetrics, line: csize_t): cdouble
proc ImpellerLineMetricsGetDescent*(metrics: ImpellerLineMetrics, line: csize_t): cdouble
proc ImpellerLineMetricsGetBaseline*(metrics: ImpellerLineMetrics, line: csize_t): cdouble
proc ImpellerLineMetricsIsHardbreak*(metrics: ImpellerLineMetrics, line: csize_t): bool
proc ImpellerLineMetricsGetWidth*(metrics: ImpellerLineMetrics, line: csize_t): cdouble
proc ImpellerLineMetricsGetHeight*(metrics: ImpellerLineMetrics, line: csize_t): cdouble
proc ImpellerLineMetricsGetLeft*(metrics: ImpellerLineMetrics, line: csize_t): cdouble
proc ImpellerLineMetricsGetCodeUnitStartIndex*(metrics: ImpellerLineMetrics, line: csize_t): csize_t
proc ImpellerLineMetricsGetCodeUnitEndIndex*(metrics: ImpellerLineMetrics, line: csize_t): csize_t
proc ImpellerLineMetricsGetCodeUnitEndIndexExcludingWhitespace*(metrics: ImpellerLineMetrics, line: csize_t): csize_t
proc ImpellerLineMetricsGetCodeUnitEndIndexIncludingNewline*(metrics: ImpellerLineMetrics, line: csize_t): csize_t

# Glyph Info
proc ImpellerGlyphInfoRetain*(glyph_info: ImpellerGlyphInfo)
proc ImpellerGlyphInfoRelease*(glyph_info: ImpellerGlyphInfo)
proc ImpellerGlyphInfoGetGraphemeClusterCodeUnitRangeBegin*(glyph_info: ImpellerGlyphInfo): csize_t
proc ImpellerGlyphInfoGetGraphemeClusterCodeUnitRangeEnd*(glyph_info: ImpellerGlyphInfo): csize_t
proc ImpellerGlyphInfoGetGraphemeClusterBounds*(glyph_info: ImpellerGlyphInfo, out_bounds: ptr ImpellerRect)
proc ImpellerGlyphInfoIsEllipsis*(glyph_info: ImpellerGlyphInfo): bool
proc ImpellerGlyphInfoGetTextDirection*(glyph_info: ImpellerGlyphInfo): ImpellerTextDirection

{.pop.}