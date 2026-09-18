<p align="center">
  👑 Nim Bindings to Flutter's 2D vector graphics renderer<br>
</p>

<p align="center">
  <code>nimble install impeller</code> | <code>clue install impeller</code>
</p>

<p align="center">
  <a href="https://openpeeps.github.io/impeller-nim">API reference</a><br>
  <img src="https://github.com/openpeeps/impeller-nim/workflows/test/badge.svg" alt="Github Actions">  <img src="https://github.com/openpeeps/impeller-nim/workflows/docs/badge.svg" alt="Github Actions">
</p>

Impeller is a 2D graphics rendering engine used in Flutter. This package provides Nim bindings to the standalone Impeller library (without Flutter) via the C API. It covers the full low-level API plus thin high-level wrappers with RAII cleanup.

Impeller needs a GPU. There is no software renderer upstream, so rendering requires Metal (macOS), Vulkan, or OpenGL ES (Linux, other).


## 😍 Key Features
- High-performance 2D rendering
- Support for multiple backends (Metal, Vulkan, OpenGL)
- Advanced text rendering & Layouting
- Rich set of drawing primitives and effects
- Cross-platform support (Windows, macOS, Linux)
- Easy to Embed (Any OpenGL/Vulkan/Metal)-based app can embed Impeller
- Low-level API access for maximum control and flexibility
- High-level API for easier development (coming soon)

## Requirements

- Nim >= 2.0.0
- The Impeller library on your system. Follow the instructions from the [Impeller Standalone SDK](https://github.com/flutter/flutter/blob/main/engine/src/flutter/impeller/toolkit/interop/README.md) to build and install the library for your platform.

## Basic examples

The snippets below record drawing commands into a display-list `builder`
(the frame scaffold in `examples/common.nim` hands you one per frame via
`beginFrame`, then presents it with `endFrame`).

Centered text starts with a typography context and a style. Setting
`align` to center and laying the paragraph out at the full screen width
centers the glyphs, so drawing at x = 0 lands "Hello, World" in the
middle of the screen.

```nim
import chroma
import impeller

var tctx = newTypographyContext()
discard tctx.registerFontFile("/System/Library/Fonts/Helvetica.ttc", "Helvetica")

let style = newTextStyle(fontFamily = "Helvetica", fontSize = 48,
  fontWeight = kImpellerFontWeight700,
  color = rgba(234, 234, 234, 255),
  align = kImpellerTextAlignmentCenter)
var para = tctx.layoutParagraph("Hello, World", style, 800)
drawParagraph(builder.handle, para, 0, 180)
```

A rectangle is built from a position and a size, then drawn with a solid
color. The hex string overload parses the color for you.

```nim
import impeller

var rect = newRectangle(200, 120, 100, 200)
drawRect(builder.handle, rect, "#e94560")
```

A circle is described by its center and radius. `drawOval` takes a chroma
color, so parse the hex string first when you want CSS-style colors.

```nim
import chroma
import impeller

drawOval(builder.handle, 400, 300, 80, 80,
  parseHtmlColor("#0f3460").asRgba)
```

Lines, rounded rectangles, and freeform paths cover the rest of the
everyday shapes. Paths are recorded with a builder, then drawn or
closed into polygons.

```nim
import impeller

drawLine(builder.handle, 60, 500, 740, 500,
  parseHtmlColor("#eaeaea").asRgba, 3.0)

var box = newRectangle(300, 90, 250, 320)
var radii = uniformRadii(16)
withPaint(p):
  p.setColor("#533483")
  builder.drawRoundedRect(box, radii, p)

var pb = newPathBuilder()
pb.moveTo(60, 540)
pb.lineTo(220, 540)
pb.lineTo(140, 420)
pb.close()
var tri = pb.takePath()
withPaint(p):
  p.setColor("#00ffcc")
  builder.drawPath(tri, p)
```

Blending modes control how new pixels mix with what is already on screen.
Set one on a `Paint` and every draw with that paint composites
accordingly, which is how you get multiply shadows, screen glows, and
overlay tints from overlapping shapes.

```nim
import impeller

var base = newRectangle(220, 220, 150, 150)
drawRect(builder.handle, base, "#ff9a3c")

withPaint(p):
  p.setColor("#0f3460")
  p.setBlendMode(kImpellerBlendModeMultiply)
  var top = newRectangle(220, 220, 260, 220)
  builder.drawRect(top, p)

withPaint(p):
  p.setColor("#e94560")
  p.setBlendMode(kImpellerBlendModeScreen)
  var glow = newRectangle(160, 160, 320, 280)
  builder.drawRect(glow, p)
```

### Example with GPU
```nim
import impeller
import impeller/bindings/glfw3_api

discard glfwInit()
defer: glfwTerminate()

# macOS: NO_API window, Metal takes over from here (see examples/common.nim
# for the full CAMetalLayer setup). Other platforms: default GL window.
glfwWindowHint(0x00022001, 0) # GLFW_CLIENT_API, GLFW_NO_API
let win = glfwCreateWindow(800, 600, "hello", nil, nil)
defer: glfwDestroyWindow(win)

var ctx = Context(handle: ImpellerContextCreateMetalNew(ImpellerVersion))

var builder = newDisplayListBuilder(0, 0, 800, 600)
withPaint(bg):
  bg.setColor("#1a1a2e")
  builder.drawPaint(bg)
var rect = newRectangle(200, 200, 100, 200)
drawRect(builder.handle, rect, "#e94560")
let dl = builder.finish()
# wrap a drawable as a Surface, then surf.render(dl)
```

Runnable versions live in `examples/`. Build them with:

```sh
nim c examples/hello.nim
nim c examples/shapes.nim
nim c examples/text.nim
```

## API overview

The low-level bindings in `impeller/bindings/impeller_api` cover the whole
C API (contexts, swapchains, surfaces, paths, paints, textures, fragment
programs, color sources, color/image/mask filters, display lists,
typography, paragraphs, line metrics, glyph info).

High-level wrappers (RAII via `=destroy`, no manual `Release` needed):

| Module | Wraps |
|---|---|
| `context` | `Context`: OpenGL ES / Metal / Vulkan constructors, `glfwProcLoader` for GLFW |
| `paint` | `Paint`: colors (chroma, hex, RGBA), blend, draw style, strokes, filters |
| `path` | `PathBuilder` / `Path`: lines, curves, rects, arcs, ovals, rounded rects |
| `displaylist` | `DisplayListBuilder`: transforms, clips, all draw calls, matrix helpers |
| `surface` | `Surface` (FBO / Metal drawable), Vulkan swapchain, `render` = draw + present |
| `texture` | `Texture` upload from bytes or GL handle, solid color helper |
| `colorsource` | linear, radial, conical, sweep, and image gradients |
| `filters` | blend / color-matrix, blur / dilate / erode / matrix / compose, blur masks |
| `canvas` | shape constructors plus one-call draw helpers |
| `text` | typography context, font registration, single- and multi-style paragraphs |

GLFW bindings for windowing ship under `impeller/bindings/glfw3_api`
(`glfw3native_api` has the Cocoa handle getters).

## Examples

| File | Shows |
|---|---|
| `examples/hello.nim` | window, backend context, animated rect per frame |
| `examples/shapes.nim` | gradients, clips, transforms, paths, shadows, blur layers |
| `examples/text.nim` | system font registration, plain and rich paragraphs |
| `examples/common.nim` | shared window + backend + frame scaffold used by the above |

## Tests

```sh
nimble test
```

Covers version macros, color conversion, shapes, matrices, gradients,
paints, paths, display lists, filters, typography (all runnable without a
GPU), plus one real GPU test that opens a window and presents a frame
(Metal on macOS, GLES elsewhere). Override the library prefix with
`LIBIMPELLER_DIR=/custom/prefix nimble test`.

## What is still missing

- Image file decoding is not bundled: upload textures with
  `newTextureWithContents` from your own PNG/JPEG loader.
- Fragment shaders need `impellerc`-compiled binaries; loading is wrapped
  (`newFragmentProgram`, `loadFragmentProgram`), authoring is up to you.
- Vulkan swapchain helpers exist (`newVulkanSwapchain`,
  `acquireNextSurface`) but there is no full Vulkan example yet.
- Text needs a registered font (`registerFontFile`); shaping otherwise
  falls back to the system default.

### ❤ Contributions & Support
- 🐛 Found a bug? [Create a new Issue](https://github.com/openpeeps/impeller-nim/issues)
- 👋 Wanna help? [Fork it!](https://github.com/openpeeps/impeller-nim/fork)

### 🎩 License
MIT license. [Made by Humans from OpenPeeps](https://github.com/openpeeps).<br>
Copyright OpenPeeps & Contributors &mdash; All rights reserved.
