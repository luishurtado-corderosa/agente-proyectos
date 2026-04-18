# modulo_csv.rb — Loader para la extensión Generador de Módulos CSV
# Colocar este archivo en la carpeta Plugins de SketchUp.

require 'sketchup.rb'
require 'extensions.rb'

module ModuloCSV
  PLUGIN_NAME = 'Generador de Módulos CSV'
  VERSION     = '1.0.0'

  unless file_loaded?(__FILE__)
    loader = File.join(File.dirname(__FILE__), 'modulo_csv', 'main.rb')
    ex = SketchupExtension.new(PLUGIN_NAME, loader)
    ex.description = 'Genera archivos CSV y tags de SketchUp para módulos con dimensiones paramétricas (W, D, H).'
    ex.version     = VERSION
    ex.creator     = ''
    Sketchup.register_extension(ex, true)
    file_loaded(__FILE__)
  end
end
