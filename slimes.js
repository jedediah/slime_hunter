(function() {
  var Int64, JavaRandom, X100000000, X7fffffff, X80000000, Xffffffff, buildMap, cellNodes, cellSize, cellSizes, chunkMouseOver, coord_x_bl, coord_x_bm, coord_x_br, coord_x_tl, coord_x_tm, coord_x_tr, coord_z_bl, coord_z_br, coord_z_ml, coord_z_mr, coord_z_tl, coord_z_tr, dragChunk, dragOrigin, drawMap, goThere, goThereAndDrawMap, hashCode, hideToolTip, int32, int64, isSlimeChunk, javaRandom, map, mapCells, mapCenter, mapSize, moveAndDrawMap, seed, showToolTip, tooltip, uint32, updateSeed, updateZoomButtons, zoomLevel;
  X7fffffff = 0x7fffffff;
  X80000000 = 0x80000000;
  Xffffffff = 0xffffffff;
  X100000000 = 0x100000000;
  int32 = function(n) {
    n %= X100000000;
    if (n >= X80000000) {
      return n - X100000000;
    } else if (n < -X80000000) {
      return n + X100000000;
    } else {
      return n;
    }
  };
  uint32 = function(n) {
    n %= X100000000;
    if (n < 0) {
      return n + X100000000;
    } else {
      return n;
    }
  };
  int64 = function(a, b) {
    return new Int64(a, b);
  };
  Int64 = (function() {
    function Int64(a, b) {
      this.assign(a, b);
    }
    Int64.prototype.assign = function(a, b) {
      if (b != null) {
        this.high = a | 0;
        this.low = b | 0;
      } else if (a instanceof String) {} else {
        this.high = Math.floor(a / X100000000);
        this.low = a | 0;
      }
      return this;
    };
    Int64.prototype.clone = function() {
      return new Int64(this.high, this.low);
    };
    Int64.prototype.equals = function(o) {
      return this.low === o.low && this.high === o.high;
    };
    Int64.prototype.inspect = function() {
      return "" + (this.high.toString(16)) + ":" + (this.low.toString(16));
    };
    Int64.prototype.toString = function(radix) {
      var digit, h, l, n, negative, s;
      if (radix == null) {
        radix = 10;
      }
      s = [];
      n = this.clone();
      negative = n.high < 0;
      if (negative) {
        n.negate();
      }
      l = n.low >>> 0;
      h = n.high;
      while (true) {
        digit = (h * (X100000000 % radix) + l) % radix;
        s.unshift(digit.toString(radix));
        if (h === 0 && l < radix) {
          break;
        }
        l = Math.floor(((h % radix) * X100000000 + l) / radix);
        h = Math.floor(h / radix);
      }
      if (negative) {
        s.unshift('-');
      }
      return s.join('');
    };
    Int64.prototype.mod32 = function(i32) {
      var negated;
      if (i32 === 0) {
        throw "modulus by zero is forbidden by math god";
      }
      if (i32 < 0) {
        i32 = -i32;
      }
      negated = this.high < 0;
      if (negated) {
        this.negate();
      }
      this.low = (this.high * (X100000000 % i32) + this.low) % i32;
      return this.high = 0;
    };
    Int64.prototype.add = function(o) {
      var carry;
      carry = (this.low >>> 0) + (o.low >>> 0);
      this.low = carry | 0;
      carry -= this.low >>> 0;
      this.high = (this.high + o.high + Math.floor(carry / X100000000)) | 0;
      return this;
    };
    Int64.prototype.sub = function(o) {
      var borrow;
      borrow = (this.low >>> 0) - (o.low >>> 0);
      this.low = borrow | 0;
      borrow -= this.low >>> 0;
      this.high = (this.high - o.high + Math.floor(borrow / X100000000)) | 0;
      return this;
    };
    Int64.prototype.negate = function() {
      var carry;
      this.low = ((~this.low) + 1) | 0;
      carry = this.low === 0 ? 1 : 0;
      this.high = ((~this.high) + carry) | 0;
      return this;
    };
    Int64.prototype.mul = function(o) {
      var a00, a16, a32, a48, b00, b16, b32, b48, c00, c16, c32, c48, negated;
      if (this.low === 0 && this.high === -X80000000) {
        if ((o.low & 1) === 0) {
          this.high = 0;
        }
      } else if (o.low === 0 && o.high === -X80000000) {
        if ((this.low & 1) === 0) {
          this.high = 0;
        }
      } else {
        negated = false;
        if (this.high < 0) {
          this.negate();
          negated = !negated;
        }
        if (o.high < 0) {
          o = o.clone().negate();
          negated = !negated;
        }
        a00 = this.low & 0xffff;
        a16 = this.low >>> 16;
        a32 = this.high & 0xffff;
        a48 = this.high >>> 16;
        b00 = o.low & 0xffff;
        b16 = o.low >>> 16;
        b32 = o.high & 0xffff;
        b48 = o.high >>> 16;
        c00 = c16 = c32 = c48 = 0;
        c00 += a00 * b00;
        c16 += c00 >>> 16;
        c00 &= 0xffff;
        c16 += a16 * b00;
        c32 += c16 >>> 16;
        c16 &= 0xffff;
        c16 += a00 * b16;
        c32 += c16 >>> 16;
        c16 &= 0xffff;
        c32 += a32 * b00;
        c48 += c32 >>> 16;
        c32 &= 0xffff;
        c32 += a16 * b16;
        c48 += c32 >>> 16;
        c32 &= 0xffff;
        c32 += a00 * b32;
        c48 += c32 >>> 16;
        c32 &= 0xffff;
        c48 += (a48 * b00) + (a32 * b16) + (a16 * b32) + (a00 * b48);
        c48 &= 0xffff;
        this.low = c00 | (c16 << 16);
        this.high = c32 | (c48 << 16);
        if (negated) {
          this.negate();
        }
      }
      return this;
    };
    Int64.prototype.or = function(o) {
      this.high |= o.high;
      this.low |= o.low;
      return this;
    };
    Int64.prototype.and = function(o) {
      this.high &= o.high;
      this.low &= o.low;
      return this;
    };
    Int64.prototype.xor = function(o) {
      this.high ^= o.high;
      this.low ^= o.low;
      return this;
    };
    Int64.prototype.not = function() {
      this.high = ~this.high;
      this.low = ~this.low;
      return this;
    };
    Int64.prototype.shl = function(n) {
      var carry, mask;
      if (n >= 32) {
        this.high = this.low << (n - 32);
        this.low = 0;
      } else if (n > 0) {
        mask = ~(-1 >>> n);
        carry = this.low & mask;
        this.low <<= n;
        this.high <<= n;
        this.high |= carry >>> (32 - n);
      }
      return this;
    };
    Int64.prototype.shr = function(n) {
      var carry, mask;
      if (n >= 32) {
        this.low = this.high >>> (n - 32);
        this.high = 0;
      } else if (n > 0) {
        mask = ~(-1 << n);
        carry = this.high & mask;
        this.low >>>= n;
        this.high >>>= n;
        this.low |= carry << (32 - n);
      }
      return this;
    };
    Int64.prototype.sshr = function(n) {
      var carry, mask;
      if (n >= 32) {
        this.low = this.high >> (n - 32);
        this.high = this.high < 0 ? -1 : 0;
      } else if (n > 0) {
        mask = ~(-1 << n);
        carry = this.high & mask;
        this.low >>>= n;
        this.high >>= n;
        this.low |= carry << (32 - n);
      }
      return this;
    };
    return Int64;
  })();
  JavaRandom = (function() {
    function JavaRandom(seed) {
      this.setSeed(seed);
    }
    JavaRandom.prototype.setSeed = function(seed) {
      this.seed = seed.clone();
      this.seed.xor(int64(0x5deece66d));
      return this.seed.and(int64(0xffff, -1));
    };
    JavaRandom.prototype.next = function(bits) {
      var r;
      this.seed.mul(int64(0x5deece66d));
      this.seed.add(int64(0xb));
      this.seed.and(int64(0xffff, -1));
      r = this.seed.clone();
      r.shr(48 - bits);
      return r.low;
    };
    JavaRandom.prototype.nextInt = function(n) {
      var bits, val;
      if (!(n != null)) {
        return this.next(32);
      } else if (n <= 0) {
        throw "range must be positive";
      } else if ((n & -n) === n) {
        return int64(n).mul(int64(this.next(31))).sshr(31).low;
      } else {
        bits = this.next(31);
        val = bits % n;
        while (bits - val + (n - 1) < 0) {
          bits = this.next(31);
          val = bits % n;
        }
        return val;
      }
    };
    return JavaRandom;
  })();
  Int64.fromString = function(str) {
    var c, i, negative, ten, val, _ref;
    str = "" + str;
    val = int64(0);
    ten = int64(10);
    negative = str.charAt(0) === '-';
    if (negative) {
      str = str.substring(1);
    }
    for (i = 0, _ref = str.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
      c = str.charCodeAt(i);
      if (c >= 48 && c <= 57) {
        val.mul(ten);
        val.add(int64(c - 48));
      } else {
        return null;
      }
    }
    if (negative) {
      val.negate();
    }
    return val;
  };
  hashCode = function(str) {
    var e, i, n, _ref;
    n = 0;
    e = 1;
    for (i = _ref = str.length - 1; _ref <= 0 ? i <= 0 : i >= 0; _ref <= 0 ? i++ : i--) {
      n = int32(n + int32(str.charCodeAt(i) * e));
      e = int32(e * 31);
    }
    return n;
  };
  javaRandom = new JavaRandom(int64(0));
  isSlimeChunk = function(s, x, z) {
    s = s.clone();
    s.add(int64((((x * x) | 0) * 0x4c1906) | 0));
    s.add(int64((x * 0x5ac0db) | 0));
    s.add(int64((z * z) | 0).mul(int64(0x4307a7)));
    s.add(int64((z * 0x5f24f) | 0));
    s.xor(int64(0x3ad8025f));
    javaRandom.setSeed(s);
    return javaRandom.nextInt(10) === 0;
  };
  seed = null;
  map = $('map');
  map.style.cursor = 'crosshair';
  tooltip = $('tooltip');
  coord_x_tl = $('coord_x_tl');
  coord_x_tm = $('coord_x_tm');
  coord_x_tr = $('coord_x_tr');
  coord_x_bl = $('coord_x_bl');
  coord_x_bm = $('coord_x_bm');
  coord_x_br = $('coord_x_br');
  coord_z_tl = $('coord_z_tl');
  coord_z_ml = $('coord_z_ml');
  coord_z_bl = $('coord_z_bl');
  coord_z_tr = $('coord_z_tr');
  coord_z_mr = $('coord_z_mr');
  coord_z_br = $('coord_z_br');
  cellNodes = null;
  mapSize = 576;
  cellSizes = [12, 16, 24, 32, 48, 72, 96];
  zoomLevel = 3;
  mapCenter = [0, 0];
  cellSize = mapCells = null;
  buildMap = function() {
    var cell, row, x, z, _results;
    map.update('');
    cellNodes = [];
    cellSize = cellSizes[zoomLevel];
    mapCells = mapSize / cellSize;
    _results = [];
    for (z = 0; 0 <= mapCells ? z < mapCells : z > mapCells; 0 <= mapCells ? z++ : z--) {
      row = new Element('tr', {
        style: "height: " + cellSize + "px;"
      });
      map.insert(row);
      _results.push((function() {
        var _results2;
        _results2 = [];
        for (x = 0; 0 <= mapCells ? x < mapCells : x > mapCells; 0 <= mapCells ? x++ : x--) {
          cell = new Element('td', {
            id: "chunk_" + x + "_" + z,
            "class": 'chunk',
            style: "width: " + (cellSize - (x === 0 ? 2 : 1)) + "px;"
          });
          cell.x = x - mapCells / 2;
          cell.z = z - mapCells / 2;
          cell.onmouseover = chunkMouseOver;
          cellNodes.push(cell);
          _results2.push(row.insert(cell));
        }
        return _results2;
      })());
    }
    return _results;
  };
  drawMap = function() {
    var i, mapTopLeft, x, y, _results;
    $('coord_x').value = mapCenter[0] * 16;
    $('coord_z').value = mapCenter[1] * 16;
    mapTopLeft = [mapCenter[0] - mapCells / 2, mapCenter[1] - mapCells / 2];
    coord_x_tl.update(mapTopLeft[0] * 16);
    coord_x_bl.update(mapTopLeft[0] * 16);
    coord_x_tm.update((mapTopLeft[0] + mapCells / 2) * 16);
    coord_x_bm.update((mapTopLeft[0] + mapCells / 2) * 16);
    coord_x_tr.update((mapTopLeft[0] + mapCells) * 16);
    coord_x_br.update((mapTopLeft[0] + mapCells) * 16);
    coord_z_tl.update(mapTopLeft[1] * 16);
    coord_z_tr.update(mapTopLeft[1] * 16);
    coord_z_ml.update((mapTopLeft[1] + mapCells / 2) * 16);
    coord_z_mr.update((mapTopLeft[1] + mapCells / 2) * 16);
    coord_z_bl.update((mapTopLeft[1] + mapCells) * 16);
    coord_z_br.update((mapTopLeft[1] + mapCells) * 16);
    i = 0;
    _results = [];
    for (y = 0; 0 <= mapCells ? y < mapCells : y > mapCells; 0 <= mapCells ? y++ : y--) {
      _results.push((function() {
        var _results2;
        _results2 = [];
        for (x = 0; 0 <= mapCells ? x < mapCells : x > mapCells; 0 <= mapCells ? x++ : x--) {
          if ((seed != null) && isSlimeChunk(seed, mapTopLeft[0] + x, mapTopLeft[1] + y)) {
            cellNodes[i].style.backgroundColor = '#8f8';
          } else {
            cellNodes[i].style.backgroundColor = '#fff';
          }
          _results2.push(i += 1);
        }
        return _results2;
      })());
    }
    return _results;
  };
  chunkMouseOver = function(ev) {
    var v;
    v = [(mapCenter[0] + ev.target.x) * 16, (mapCenter[1] + ev.target.z) * 16];
    return $('tooltip').update("" + v[0] + "," + v[1] + " to " + (v[0] + 16) + "," + (v[1] + 16));
  };
  moveAndDrawMap = function(newCenter) {
    if (newCenter[0] !== mapCenter[0] || newCenter[1] !== mapCenter[1]) {
      mapCenter = newCenter;
      return drawMap();
    }
  };
  updateSeed = function() {
    var str;
    str = $('seed').value;
    if (str.length !== 0) {
      seed = Int64.fromString(str) || int64(hashCode(str));
      console.log(seed);
      return $('actual_seed').update(seed.toString());
    }
  };
  Event.observe($('update'), 'click', function() {
    updateSeed();
    return drawMap();
  });
  Event.observe($('seed'), 'keypress', function(ev) {
    if (ev.keyCode === 13) {
      updateSeed();
      return drawMap();
    }
  });
  updateZoomButtons = function() {
    $('zoom_in').disabled = zoomLevel === cellSizes.length - 1;
    return $('zoom_out').disabled = zoomLevel === 0;
  };
  Event.observe($('zoom_in'), 'click', function() {
    if (zoomLevel < cellSizes.length - 1) {
      zoomLevel += 1;
      updateZoomButtons();
      buildMap();
      return drawMap();
    }
  });
  Event.observe($('zoom_out'), 'click', function() {
    if (zoomLevel > 0) {
      zoomLevel -= 1;
      updateZoomButtons();
      buildMap();
      return drawMap();
    }
  });
  goThere = function() {
    var v;
    v = [parseInt($('coord_x').value), parseInt($('coord_z').value)];
    if (!(isNaN(v[0]) || isNaN(v[1]))) {
      return mapCenter = [Math.floor(v[0] / 16), Math.floor(v[1] / 16)];
    }
  };
  goThereAndDrawMap = function() {
    goThere();
    return drawMap();
  };
  Event.observe($('jump'), 'click', goThereAndDrawMap);
  Event.observe($('coord_x'), 'keypress', function(ev) {
    if (ev.keyCode === 13) {
      return goThereAndDrawMap();
    }
  });
  Event.observe($('coord_z'), 'keypress', function(ev) {
    if (ev.keyCode === 13) {
      return goThereAndDrawMap();
    }
  });
  Event.observe($('nudge_left'), 'click', function() {
    return moveAndDrawMap([mapCenter[0] - 1, mapCenter[1]]);
  });
  Event.observe($('nudge_right'), 'click', function() {
    return moveAndDrawMap([mapCenter[0] + 1, mapCenter[1]]);
  });
  Event.observe($('nudge_up'), 'click', function() {
    return moveAndDrawMap([mapCenter[0], mapCenter[1] - 1]);
  });
  Event.observe($('nudge_down'), 'click', function() {
    return moveAndDrawMap([mapCenter[0], mapCenter[1] + 1]);
  });
  dragOrigin = null;
  dragChunk = null;
  showToolTip = function(ev) {
    tooltip.style.left = ev.pageX + 32;
    tooltip.style.top = ev.pageY - 16;
    return tooltip.style.visibility = 'visible';
  };
  hideToolTip = function() {
    return tooltip.style.visibility = 'hidden';
  };
  Event.observe(map, 'mouseenter', function(ev) {
    if (dragOrigin == null) {
      return showToolTip(ev);
    }
  });
  Event.observe(map, 'mouseleave', function(ev) {
    dragOrigin = null;
    map.style.cursor = 'crosshair';
    return hideToolTip();
  });
  Event.observe(map, 'mousedown', function(ev) {
    if (ev.button === 0) {
      dragOrigin = [ev.clientX, ev.clientY];
      dragChunk = mapCenter;
      map.style.cursor = 'move';
      ev.preventDefault();
      return hideToolTip();
    }
  });
  Event.observe(map, 'mouseup', function(ev) {
    if (ev.button === 0) {
      dragOrigin = null;
      map.style.cursor = 'crosshair';
      ev.preventDefault();
      return showToolTip(ev);
    }
  });
  Event.observe(map, 'mousemove', function(ev) {
    if (dragOrigin != null) {
      return moveAndDrawMap([dragChunk[0] - Math.floor((ev.clientX - dragOrigin[0]) / cellSize), dragChunk[1] - Math.floor((ev.clientY - dragOrigin[1]) / cellSize)]);
    } else {
      return showToolTip(ev);
    }
  });
  updateZoomButtons();
  buildMap();
  goThere();
  updateSeed();
  drawMap();
}).call(this);
