#!/usr/bin/env ruby
# Requirements:
#   - [cocore](https://github.com/KoharaKazuya/cocore)

require 'erb'
require 'fileutils'
require 'ostruct'

#
# Settings:
#

colors = [
  { name: :red,     hue: 0   },
  { name: :yellow,  hue: 60  },
  { name: :green,   hue: 120 },
  { name: :cyan,    hue: 180 },
  { name: :blue,    hue: 240 },
  { name: :magenta, hue: 300 },
]
monos = [
  {name: :white, frame_color: 217, toolbar_color: 230},
  {name: :black, frame_color:  51, toolbar_color:  77},
]

#
# Generator Code:
#

def color_to_variables(color)
  # hue to rgb
  frame_color_rgb   = `cocore --to=rgb 'hsl(#{color[:hue]}, 35%, 50%)'`.scan /[0-9]+/
  toolbar_color_rgb = `cocore --to=rgb 'hsl(#{color[:hue]}, 45%, 65%)'`.scan /[0-9]+/

  {
    color_name: color[:name].to_s,
    frame_color_r: frame_color_rgb[0],
    frame_color_g: frame_color_rgb[1],
    frame_color_b: frame_color_rgb[2],
    toolbar_color_r: toolbar_color_rgb[0],
    toolbar_color_g: toolbar_color_rgb[1],
    toolbar_color_b: toolbar_color_rgb[2],
  }
end

def mono_to_variables(color)
  {
    color_name: color[:name].to_s,
    frame_color_r: color[:frame_color],
    frame_color_g: color[:frame_color],
    frame_color_b: color[:frame_color],
    toolbar_color_r: color[:toolbar_color],
    toolbar_color_g: color[:toolbar_color],
    toolbar_color_b: color[:toolbar_color],
  }
end

variable_set = colors.map{|c| color_to_variables c}.concat monos.map{|c| mono_to_variables c}

# clean previous artifact
FileUtils.rm_r "#{__dir__}/dist"

variable_set.each do |variables|
  # create directory
  theme_dir = "#{__dir__}/dist/monochromatic-#{variables[:color_name]}"
  FileUtils.mkdir_p theme_dir

  # template
  template = File.read "#{__dir__}/src/manifest.json.erb"
  manifest_json = ERB.new(template).result(OpenStruct.new(variables).instance_eval { binding })

  # create manifest file
  File.write "#{theme_dir}/manifest.json", manifest_json
end
