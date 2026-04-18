require 'sketchup'
require_relative 'wall_detector'
require_relative 'scene_creator'
require_relative 'layout_exporter'
require_relative 'ui_dialog'

module KitchenWallViews
  module Main
    def self.run
      model = Sketchup.active_model
      unless model
        UI.messagebox('No hay ningún modelo abierto.')
        return
      end

      dialog = UIDialog.new
      dialog.show do |options|
        generate(model, options)
      end
    end

    def self.generate(model, options)
      pattern = Regexp.new(options[:pattern], Regexp::IGNORECASE)
      walls   = WallDetector.find_walls(model, pattern)

      if walls.empty?
        UI.messagebox("No se encontraron grupos o componentes con el patrón \"#{options[:pattern]}\".\nRevisa los nombres de tus grupos en el modelo.")
        return
      end

      model.start_operation('Generar vistas de muros', true)

      begin
        scene_pairs = []
        if options[:create_scenes]
          scene_pairs = SceneCreator.create_scenes(model, walls)
        end

        if options[:export_layout] && !scene_pairs.empty?
          model_path = model.path
          if model_path.empty?
            UI.messagebox('Guarda el modelo primero para poder exportar a Layout.')
          else
            output_path = LayoutExporter.export(model_path, scene_pairs)
            UI.messagebox("Layout generado:\n#{output_path}")
          end
        end

        model.commit_operation
        UI.messagebox("Proceso completado.\n#{walls.size} muro(s) procesado(s).")
      rescue => e
        model.abort_operation
        UI.messagebox("Error: #{e.message}\n#{e.backtrace.first(3).join("\n")}")
      end
    end

    unless file_loaded?(__FILE__)
      UI.menu('Extensions').add_item('Kitchen Wall Views - Generar Vistas...') { run }
      file_loaded(__FILE__)
    end
  end
end
