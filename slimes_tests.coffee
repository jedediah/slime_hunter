equals = (a,b) ->
  if a.equals?
    a.equals(b)
  else if b.equals?
    b.equals(a)
  else
    a == b

assert = (msg, cond) ->
  throw msg unless cond

assert_equal = (actual, expected) ->
  assert "expected #{expected} but got #{actual}", equals(expected, actual)

assert_not_equal = (actual, expected) ->
  assert "expected #{expected} to not equal #{actual}", not equals(expected, actual)

window.assert_equal = assert_equal

Setup = ->

Tests = [
  -> assert_equal int64(0), int64(0)
  -> assert_not_equal int64(0), int64(1)

  -> assert_equal int64(0), int64(0,0)
  -> assert_equal int64(1), int64(0,1)
  -> assert_equal int64(-1), int64(-1,-1)
  -> assert_equal int64(0x7fffffff), int64(0,0x7fffffff)
  -> assert_equal int64(0x80000000), int64(0,-0x80000000)
  -> assert_equal int64(0xffffffff), int64(0,-1)
  -> assert_equal int64(0x100000000), int64(1,0)

  -> assert_equal int64(0).add(int64(1)), int64(1)
  -> assert_equal int64(1).add(int64(1)), int64(2)
  -> assert_equal int64(0x7fffffff).add(int64(1)), int64(0x80000000)
  -> assert_equal int64(0xffffffff).add(int64(1)), int64(0x100000000)
  -> assert_equal int64(0).add(int64(-1)), int64(-1)
  -> assert_equal int64(1).add(int64(-1)), int64(0)
  -> assert_equal int64(-1).add(int64(2)), int64(1)
  -> assert_equal int64(-0x7fffffff).add(int64(-1)), int64(-0x80000000)
  -> assert_equal int64(-0xffffffff).add(int64(-1)), int64(-0x100000000)
  -> assert_equal int64(-0xffffffff).add(int64(0x1fffffffe)), int64(0xffffffff)

  -> assert_equal int64(0).sub(int64(1)), int64(-1)
  -> assert_equal int64(0).sub(int64(-1)), int64(1)
  -> assert_equal int64(1).sub(int64(2)), int64(-1)
  -> assert_equal int64(-1).sub(int64(-2)), int64(1)

  -> assert_equal int64(0).negate(), int64(0)
  -> assert_equal int64(1).negate(), int64(-1)
  -> assert_equal int64(-1).negate(), int64(1)
  -> assert_equal int64(0x7fffffff,-1).negate(), int64(-0x80000000,1)
  -> assert_equal int64(-0x80000000,1).negate(), int64(0x7fffffff,-1)
  -> assert_equal int64(-0x80000000,0).negate(), int64(-0x80000000,0)

  -> assert_equal int64( 0).mul(int64( 0)), int64(0)
  -> assert_equal int64( 1).mul(int64( 0)), int64(0)
  -> assert_equal int64( 0).mul(int64( 1)), int64(0)
  -> assert_equal int64(-1).mul(int64( 0)), int64(0)
  -> assert_equal int64( 0).mul(int64(-1)), int64(0)
  -> assert_equal int64( 1).mul(int64( 1)), int64(1)
  -> assert_equal int64(-1).mul(int64(-1)), int64(1)
  -> assert_equal int64( 1).mul(int64(-1)), int64(-1)
  -> assert_equal int64(-1).mul(int64( 1)), int64(-1)

  -> assert_equal int64(0).not(), int64(-1)
  -> assert_equal int64(-2).not(), int64(1)

  -> assert_equal int64(1).shl(0), int64(1)
  -> assert_equal int64(1).shl(1), int64(2)
  -> assert_equal int64(0xabcd).shl(20), int64(0xabcd00000)
  -> assert_equal int64(1).shl(32), int64(0x100000000)
  -> assert_equal int64(1).shl(62), int64(0x40000000,0)
  -> assert_equal int64(1).shl(63), int64(-0x80000000,0)

  -> assert_equal int64(1).shr(0), int64(1)
  -> assert_equal int64(1).shr(1), int64(0)
  -> assert_equal int64(2).shr(1), int64(1)
  -> assert_equal int64(0x123400000).shr(20), int64(0x1234)
  -> assert_equal int64(-1).shr(1), int64(0x7fffffff,-1)
  -> assert_equal int64(-1).shr(63), int64(1)
  -> assert_equal int64(0xfffffffff).sshr(20), int64(0xffff)
  -> assert_equal int64(-1).sshr(1), int64(-1)
  -> assert_equal int64(-1).sshr(63), int64(-1)
  -> assert_equal int64(-0x80000000).sshr(3), int64(-0x10000000)
]

passed = failed = 0

for test in Tests
  try
    Setup()
    test()
    ++passed
  catch ex
    ++failed
    $('tests')?.insert "<strong>#{ex}</strong><br/><pre>#{test}</pre><br/>"
    console.log ex + "\n#{test}\n"

epilogue = "Tests finished, #{passed} passed, #{failed} failed"
$('tests')?.insert "<strong>#{epilogue}</strong><br/>"
console.log epilogue
