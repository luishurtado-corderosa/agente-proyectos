# Kitchen Wall Views - SketchUp Pro Extension
# Automatically creates wall elevation scenes and exports to Layout
require 'sketchup'
require 'extensions'

module KitchenWallViews
  EXTENSION = SketchupExtension.new('Kitchen Wall Views', 'kitchen_wall_views/main')
  EXTENSION.version     = '1.0.0'
  EXTENSION.description = 'Detecta muros en modelos de cocina y genera vistas ortográficas y en perspectiva, exportando a Layout automáticamente.'
  EXTENSION.creator     = 'Kitchen Wall Views'
  Sketchup.register_extension(EXTENSION, true)
end
