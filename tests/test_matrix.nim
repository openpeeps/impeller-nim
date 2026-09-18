import unittest
import helpers

suite "matrices":
  test "identity has ones on the diagonal":
    let m = identityMatrix()
    for i in 0 ..< 16:
      if i mod 5 == 0:
        check m.m[i] == 1.0
      else:
        check m.m[i] == 0.0

  test "translation stores x, y in m[12], m[13]":
    let m = translationMatrix(3, 4)
    check m.m[12] == 3
    check m.m[13] == 4
    check m.m[0] == 1.0

  test "scale stores sx, sy in m[0], m[5]":
    let m = scaleMatrix(2, 5)
    check m.m[0] == 2
    check m.m[5] == 5
    check m.m[10] == 1.0

  test "grayscale color matrix is well-formed":
    let m = grayscaleColorMatrix()
    check m.m.len == 20
    check abs(m.m[0] - 0.2126) < 1e-6
    check m.m[19] == 0

  test "invert color matrix has -1 diagonal + 255 translation":
    let m = invertColorMatrix()
    check m.m[0] == -1.0
    check m.m[4] == 255
    check m.m[18] == 1
