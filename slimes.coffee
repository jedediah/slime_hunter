
# to detect typos
X7fffffff  = 0x7fffffff
X80000000  = 0x80000000
Xffffffff  = 0xffffffff
X100000000 = 0x100000000

int32 = (n) ->
  n %= X100000000
  if n >= X80000000
    n - X100000000
  else if n < -X80000000
    n + X100000000
  else
    n

uint32 = (n) ->
  n %= X100000000
  if n < 0
    n + X100000000
  else
    n

int64 = (a,b) -> new Int64(a,b)

class Int64
  constructor: (a, b) ->
    this.assign(a,b)

  assign: (a, b) ->
    if b?
      @high = a | 0
      @low  = b | 0
    else if a instanceof String
      # todo
    else
      @high = Math.floor(a / X100000000)
      @low  = a | 0

    this

  clone: -> new Int64(@high, @low)

  equals: (o) ->
    @low == o.low and @high == o.high

  inspect: ->
    "#{@high.toString(16)}:#{@low.toString(16)}"

  toString: (radix=10) ->
    s = []
    n = @clone()

    negative = n.high < 0
    n.negate() if negative

    l = n.low >>> 0
    h = n.high

    loop
      digit = (h * (X100000000 % radix) + l) % radix
      s.unshift digit.toString(radix)

      break if h == 0 && l < radix

      l = Math.floor(((h % radix) * X100000000 + l) / radix) #
      h = Math.floor(h / radix)

    s.unshift('-') if negative
    s.join('')

  mod32: (i32) ->
    throw "modulus by zero is forbidden by math god" if i32 == 0

    i32 = -i32 if i32 < 0

    negated = @high < 0
    @negate() if negated

    # note that
    #    (a + b) % n = (a % n + b) % n
    # and also
    #    (a * K) % n = (a * (K % n)) % n
    # therefor
    #    (a * K + b) % n = ((a * K) % n + b) % n = (a * (K % n) + b) % n

    @low = (@high * (X100000000 % i32) + @low) % i32
    @high = 0

  add: (o) ->
    carry = (@low >>> 0) + (o.low >>> 0)
    @low = carry | 0
    carry -= @low >>> 0
    @high = (@high + o.high + Math.floor(carry / X100000000)) | 0
    this

  sub: (o) ->
    borrow = (@low >>> 0) - (o.low >>> 0)
    @low = borrow | 0
    borrow -= @low >>> 0
    @high = (@high - o.high + Math.floor(borrow / X100000000)) | 0
    this

  negate: ->
    @low = ((~@low) + 1) | 0
    carry = if @low == 0 then 1 else 0
    @high = ((~@high) + carry) | 0
    this

  mul: (o) ->
    if @low == 0 and @high == -X80000000
      @high = 0 if (o.low & 1) == 0
    else if o.low == 0 and o.high == -X80000000
      @high = 0 if (@low & 1) == 0
    else
      negated = no
      if @high < 0
        this.negate()
        negated = not negated
      if o.high < 0
        o = o.clone().negate()
        negated = not negated

      a00 = @low & 0xffff
      a16 = @low >>> 16
      a32 = @high & 0xffff
      a48 = @high >>> 16

      b00 = o.low & 0xffff
      b16 = o.low >>> 16
      b32 = o.high & 0xffff
      b48 = o.high >>> 16

      c00 = c16 = c32 = c48 = 0

      c00 += a00 * b00
      c16 += c00 >>> 16
      c00 &= 0xffff

      c16 += a16 * b00
      c32 += c16 >>> 16
      c16 &= 0xffff

      c16 += a00 * b16
      c32 += c16 >>> 16
      c16 &= 0xffff

      c32 += a32 * b00
      c48 += c32 >>> 16
      c32 &= 0xffff

      c32 += a16 * b16
      c48 += c32 >>> 16
      c32 &= 0xffff

      c32 += a00 * b32
      c48 += c32 >>> 16
      c32 &= 0xffff

      c48 += (a48 * b00) + (a32 * b16) + (a16 * b32) + (a00 * b48)
      c48 &= 0xffff

      @low  = c00 | (c16 << 16)
      @high = c32 | (c48 << 16)

      this.negate() if negated

    this

  or: (o) ->
    @high |= o.high
    @low  |= o.low
    this

  and: (o) ->
    @high &= o.high
    @low  &= o.low
    this

  xor: (o) ->
    @high ^= o.high
    @low  ^= o.low
    this

  not: ->
    @high = ~@high
    @low =  ~@low
    this

  shl: (n) ->
    if n >= 32
      @high = @low << (n-32)
      @low = 0
    else if n > 0
      mask = ~(-1 >>> n)
      carry = @low & mask
      @low <<= n
      @high <<= n
      @high |= carry >>> (32-n)

    this

  shr: (n) ->
    if n >= 32
      @low = @high >>> (n-32)
      @high = 0
    else if n > 0
      mask = ~(-1 << n)
      carry = @high & mask
      @low >>>= n
      @high >>>= n
      @low |= carry << (32-n)

    this

  sshr: (n) ->
    if n >= 32
      @low = @high >> (n-32)
      @high = if @high < 0 then -1 else 0
    else if n > 0
      mask = ~(-1 << n)
      carry = @high & mask
      @low >>>= n
      @high >>= n
      @low |= carry << (32-n)

    this


class JavaRandom
  constructor: (seed) ->
    this.setSeed(seed)

  setSeed: (seed) ->
    @seed = seed.clone()
    @seed.xor(int64(0x5deece66d))
    @seed.and(int64(0xffff,-1))

  next: (bits) ->
    @seed.mul(int64(0x5deece66d))
    @seed.add(int64(0xb))
    @seed.and(int64(0xffff,-1))
    r = @seed.clone()
    r.shr(48 - bits)
    r.low

  nextInt: (n) ->
    if not n?
      this.next(32)
    else if n <= 0
      throw "range must be positive"
    else if (n & -n) == n
      int64(n).mul(int64(this.next(31))).sshr(31).low
    else
      bits = this.next(31)
      val = bits % n
      while bits - val + (n-1) < 0
        bits = this.next(31)
        val = bits % n

      val

Int64.fromString = (str) ->
  str = ""+str
  val = int64(0)
  ten = int64(10)

  negative = str.charAt(0) == '-'
  str = str.substring(1) if negative

  for i in [0..str.length-1]
    c = str.charCodeAt(i)
    if c >= 48 and c <= 57
      val.mul(ten)
      val.add(int64(c-48))
    else
      return null

  val.negate() if negative
  return val

hashCode = (str) ->
  n = 0
  e = 1

  for i in [str.length-1..0]
    n = int32(n + int32(str.charCodeAt(i) * e))
    e = int32(e * 31)

  n


javaRandom = new JavaRandom(int64(0))

isSlimeChunk = (s,x,z) ->
  s = s.clone()
  s.add(int64((((x * x) | 0) * 0x4c1906) | 0))
  s.add(int64((x * 0x5ac0db) | 0))
  s.add(int64((z * z) | 0).mul(int64(0x4307a7)))
  s.add(int64((z * 0x5f24f) | 0))
  s.xor(int64(0x3ad8025f))
  javaRandom.setSeed s
  javaRandom.nextInt(10) == 0

seed = null
map = $('map')
map.style.cursor = 'crosshair'

tooltip = $('tooltip')

coord_x_tl = $('coord_x_tl')
coord_x_tm = $('coord_x_tm')
coord_x_tr = $('coord_x_tr')
coord_x_bl = $('coord_x_bl')
coord_x_bm = $('coord_x_bm')
coord_x_br = $('coord_x_br')

coord_z_tl = $('coord_z_tl')
coord_z_ml = $('coord_z_ml')
coord_z_bl = $('coord_z_bl')
coord_z_tr = $('coord_z_tr')
coord_z_mr = $('coord_z_mr')
coord_z_br = $('coord_z_br')

cellNodes = null;

mapSize = 576
cellSizes  = [12,16,24,32,48,72,96]
#coordSteps = [4, 3, 2, 2, 1, 1, 1, 1, 1]

zoomLevel = 3
mapCenter = [0,0]

cellSize = mapCells = null

buildMap = ->
  map.update ''
  cellNodes = []

  cellSize = cellSizes[zoomLevel]
  mapCells = mapSize / cellSize

  for z in [0...mapCells]
    row = new Element 'tr', {style: "height: #{cellSize}px;"}
    map.insert row

    for x in [0...mapCells]
      cell = new Element 'td', {id: "chunk_#{x}_#{z}", class: 'chunk', style: "width: #{cellSize - (if x == 0 then 2 else 1)}px;"}
      cell.x = x-mapCells/2
      cell.z = z-mapCells/2
      cell.onmouseover = chunkMouseOver
      #cell.onmouseout = chunkMouseOut

      cellNodes.push cell
      row.insert cell



drawMap = ->
  $('coord_x').value = mapCenter[0] * 16
  $('coord_z').value = mapCenter[1] * 16

  mapTopLeft = [mapCenter[0] - mapCells/2, mapCenter[1] - mapCells/2]

  coord_x_tl.update mapTopLeft[0]*16
  coord_x_bl.update mapTopLeft[0]*16

  coord_x_tm.update (mapTopLeft[0]+mapCells/2)*16
  coord_x_bm.update (mapTopLeft[0]+mapCells/2)*16

  coord_x_tr.update (mapTopLeft[0]+mapCells)*16
  coord_x_br.update (mapTopLeft[0]+mapCells)*16

  coord_z_tl.update mapTopLeft[1]*16
  coord_z_tr.update mapTopLeft[1]*16

  coord_z_ml.update (mapTopLeft[1]+mapCells/2)*16
  coord_z_mr.update (mapTopLeft[1]+mapCells/2)*16

  coord_z_bl.update (mapTopLeft[1]+mapCells)*16
  coord_z_br.update (mapTopLeft[1]+mapCells)*16

  i = 0
  for y in [0...mapCells]
    for x in [0...mapCells]
      if seed? and isSlimeChunk(seed, mapTopLeft[0]+x, mapTopLeft[1]+y)
        cellNodes[i].style.backgroundColor = '#8f8'
      else
        cellNodes[i].style.backgroundColor = '#fff'

      i += 1

chunkMouseOver = (ev) ->
  v = [(mapCenter[0] + ev.target.x)*16, (mapCenter[1] + ev.target.z)*16]
  $('tooltip').update "#{v[0]},#{v[1]} to #{v[0]+16},#{v[1]+16}"

moveAndDrawMap = (newCenter) ->
  if newCenter[0] != mapCenter[0] or newCenter[1] != mapCenter[1]
    mapCenter = newCenter
    drawMap()


updateSeed = ->
  str = $('seed').value
  unless str.length == 0
    seed = Int64.fromString(str) or int64(hashCode(str))
    console.log seed
    $('actual_seed').update seed.toString()

Event.observe $('update'), 'click', ->
  updateSeed()
  drawMap()

Event.observe $('seed'), 'keypress', (ev) ->
  if ev.keyCode == 13
    updateSeed()
    drawMap()

updateZoomButtons = ->
  $('zoom_in').disabled = zoomLevel == cellSizes.length-1
  $('zoom_out').disabled = zoomLevel == 0

Event.observe $('zoom_in'), 'click', ->
  if zoomLevel < cellSizes.length-1
    zoomLevel += 1
    updateZoomButtons()
    buildMap()
    drawMap()

Event.observe $('zoom_out'), 'click', ->
  if zoomLevel > 0
    zoomLevel -= 1
    updateZoomButtons()
    buildMap()
    drawMap()

goThere = ->
  v = [parseInt($('coord_x').value), parseInt($('coord_z').value)]
  unless isNaN(v[0]) or isNaN(v[1])
    mapCenter = [Math.floor(v[0]/16), Math.floor(v[1]/16)]

goThereAndDrawMap = ->
  goThere()
  drawMap()

Event.observe $('jump'), 'click', goThereAndDrawMap
Event.observe $('coord_x'), 'keypress', (ev) -> goThereAndDrawMap() if ev.keyCode == 13
Event.observe $('coord_z'), 'keypress', (ev) -> goThereAndDrawMap() if ev.keyCode == 13

Event.observe $('nudge_left'),  'click', -> moveAndDrawMap [mapCenter[0]-1, mapCenter[1]]
Event.observe $('nudge_right'), 'click', -> moveAndDrawMap [mapCenter[0]+1, mapCenter[1]]
Event.observe $('nudge_up'),    'click', -> moveAndDrawMap [mapCenter[0],   mapCenter[1]-1]
Event.observe $('nudge_down'),  'click', -> moveAndDrawMap [mapCenter[0],   mapCenter[1]+1]

dragOrigin = null
dragChunk = null

showToolTip = (ev) ->
  tooltip.style.left = ev.pageX + 32
  tooltip.style.top = ev.pageY - 16
  tooltip.style.visibility = 'visible'

hideToolTip = ->
  tooltip.style.visibility = 'hidden'

Event.observe map, 'mouseenter', (ev) ->
  showToolTip ev unless dragOrigin?

Event.observe map, 'mouseleave', (ev) ->
  dragOrigin = null
  map.style.cursor = 'crosshair'
  hideToolTip()

Event.observe map, 'mousedown', (ev) ->
  if ev.button == 0
    dragOrigin = [ev.clientX, ev.clientY]
    dragChunk = mapCenter
    map.style.cursor = 'move'
    ev.preventDefault()
    hideToolTip()

Event.observe map, 'mouseup', (ev) ->
  if ev.button == 0
    dragOrigin = null
    map.style.cursor = 'crosshair'
    ev.preventDefault()
    showToolTip ev

Event.observe map, 'mousemove', (ev) ->
  if dragOrigin?
    moveAndDrawMap [dragChunk[0] - Math.floor((ev.clientX-dragOrigin[0])/cellSize),
                    dragChunk[1] - Math.floor((ev.clientY-dragOrigin[1])/cellSize)]
  else
    showToolTip ev

updateZoomButtons()
buildMap()
goThere()
updateSeed()
drawMap()
