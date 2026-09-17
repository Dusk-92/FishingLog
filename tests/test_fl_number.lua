-- Pure-Lua regression tests for FishingLog's numeric guard.
dofile("Dusk/FishingLog/FL_Number.lua")

local function expect(actual,expected,label)
    assert(actual==expected,
        (label or "value")..": expected "..tostring(expected)..
        ", got "..tostring(actual))
end

expect(FL_ToNumber("12.5"),12.5,"dot decimal")
expect(FL_ToNumber("12,5"),12.5,"comma decimal")
expect(FL_ToNumber("FF",16),255,"explicit base")
expect(FL_ToNumber(math.huge),nil,"positive infinity")
expect(FL_ToNumber(-math.huge),nil,"negative infinity")
expect(FL_ToNumber(0/0),nil,"NaN")

expect(FL_ToNonNegativeInteger(0),0,"zero integer")
expect(FL_ToNonNegativeInteger("42"),42,"string integer")
expect(FL_ToNonNegativeInteger("42,0"),42,"locale integer")
expect(FL_ToNonNegativeInteger(-1),nil,"negative integer")
expect(FL_ToNonNegativeInteger(2.5),nil,"fractional count")
expect(FL_ToNonNegativeInteger("1e309"),nil,"overflow")

print("FishingLog numeric tests: OK")
