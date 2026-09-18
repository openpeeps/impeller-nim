import unittest
import helpers

suite "smoke":
  test "library loads and reports a version":
    requiresLib()
    check ImpellerGetVersion() != 0

  test "core modules construct without a GPU":
    check newRectangle(10, 10).width == 10
    check newCircle(5).radius == 5
    check identityMatrix().m[0] == 1.0
    check newTextStyle().fontSize == 14
