import unittest
import helpers

suite "version":
  test "linked library reports the packed 1.4.0 version":
    requiresLib()
    check ImpellerGetVersion() == ImpellerVersion

  test "make/get round-trips variant, major, minor, patch":
    let v = impellerMakeVersion(1, 1, 4, 0)
    check impellerVersionGetVariant(v) == 1
    check impellerVersionGetMajor(v) == 1
    check impellerVersionGetMinor(v) == 4
    check impellerVersionGetPatch(v) == 0

  test "ImpellerVersion constant equals make(1, 1, 4, 0)":
    check ImpellerVersion == impellerMakeVersion(
      ImpellerVersionVariant, ImpellerVersionMajor,
      ImpellerVersionMinor, ImpellerVersionPatch)
