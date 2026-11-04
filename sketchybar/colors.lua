-- Material-dark palette, modeled on Dank/Dux Modular Shell's default theme
return {
  black = 0xff141218,
  white = 0xffe6e0e9,
  red = 0xfff2b8b5,
  green = 0xff9ed072,
  blue = 0xff8ecdf4,
  yellow = 0xffe7c664,
  orange = 0xfff39660,
  magenta = 0xffd0bcff,
  grey = 0xff938f99,
  transparent = 0x00000000,

  accent = 0xffd0bcff,
  on_accent = 0xff381e72,

  bar = {
    bg = 0xf0141218,
    border = 0xff141218,
  },
  popup = {
    bg = 0xf0211f26,
    border = 0xff36343b,
  },
  bg1 = 0xff211f26, -- chip
  bg2 = 0xff36343b, -- raised / inactive pill

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
