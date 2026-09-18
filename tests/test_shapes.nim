import unittest
import helpers

suite "shapes":
  test "newRectangle stores x, y, width, height":
    let r = newRectangle(100, 50, 10, 20)
    check r.x == 10
    check r.y == 20
    check r.width == 100
    check r.height == 50

  test "newSquare is width == height":
    let s = newSquare(32, 1, 2)
    check s.width == 32
    check s.height == 32
    check s.x == 1
    check s.y == 2

  test "newCircle stores center + radius":
    let c = newCircle(5, 3, 4)
    check c.center.x == 3
    check c.center.y == 4
    check c.radius == 5

  test "circleOvalRect computes the bounding box":
    let c = newCircle(5, 10, 10)
    let o = circleOvalRect(c)
    check o.x == 5
    check o.y == 5
    check o.width == 10
    check o.height == 10

  test "uniformRadii sets all corners":
    let r = uniformRadii(8)
    check r.top_left.x == 8
    check r.bottom_right.y == 8
