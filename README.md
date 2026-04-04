<p align="center">
  👑 Nim Bindings to Flutter's 2D vector graphics renderer<br>
  
</p>

<p align="center">
  <code>nimble install {PKG}</code>
</p>

<p align="center">
  <a href="https://github.com/">API reference</a><br>
  <img src="https://github.com/openpeeps/impeller-nim/workflows/test/badge.svg" alt="Github Actions">  <img src="https://github.com/openpeeps/impeller-nim/workflows/docs/badge.svg" alt="Github Actions">
</p>

Impeller is a 2D graphics rendering engine used in Flutter. This package provides Nim bindings to the standalone Impeller library (without Flutter) via the C API. It allows you to use Impeller's powerful rendering capabilities in your Nim applications.

## 😍 Key Features
- High-performance 2D rendering
- Support for multiple backends (Metal, Vulkan, OpenGL)
- Advanced text rendering & Layouting
- Rich set of drawing primitives and effects
- Cross-platform support (Windows, macOS, Linux)
- Easy to Embed (Any OpenGL/Vulkan/Metal)-based app can embed Impeller
- Low-level API access for maximum control and flexibility
- High-level API for easier development (coming soon)

## Installation
First, you will need to install the Impeller library on your system. Follow the instructions from the [Impeller Standalone SDK](https://github.com/flutter/flutter/blob/main/engine/src/flutter/impeller/toolkit/interop/README.md) to build and install the library for your platform.

Then, add the Nim bindings to your project:

```nim
nimble install impeller
```

todo. tests, examples, stuff

### ❤ Contributions & Support
- 🐛 Found a bug? [Create a new Issue](https://github.com/openpeeps/impeller-nim/issues)
- 👋 Wanna help? [Fork it!](https://github.com/openpeeps/impeller-nim/fork)
- 😎 [Get €20 in cloud credits from Hetzner](https://hetzner.cloud/?ref=Hm0mYGM9NxZ4)

### 🎩 License
MIT license. [Made by Humans from OpenPeeps](https://github.com/openpeeps).<br>
Copyright OpenPeeps & Contributors &mdash; All rights reserved.
