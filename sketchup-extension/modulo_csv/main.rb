require 'sketchup.rb'
require 'csv'
require 'json'

module ModuloCSV
  DIALOG_HTML = File.join(File.dirname(__FILE__), 'ui.html')

  def self.show_dialog
    @dialog.close if @dialog && @dialog.visible?

    @dialog = UI::HtmlDialog.new(
      dialog_title:    'Generador de Módulos CSV',
      preferences_key: 'ModuloCSV_v1',
      width:           520,
      height:          700,
      min_width:       420,
      min_height:      500,
      resizable:       true
    )
    @dialog.set_file(DIALOG_HTML)

    @dialog.add_action_callback('preview') do |_ctx, data|
      result = generate_codes(data)
      @dialog.execute_script("setPreview(#{result[:codes].to_json}, #{result[:codes].length})")
    end

    @dialog.add_action_callback('generate_csv') do |_ctx, data|
      result = generate_codes(data)
      save_csv(result[:codes], result[:filename])
    end

    @dialog.add_action_callback('create_tags') do |_ctx, data|
      result = generate_codes(data)
      create_sketchup_tags(result[:codes], result[:folder_name])
    end

    @dialog.show
  end

  # ── Genera la lista de códigos según la configuración ─────────────────────

  def self.generate_codes(data)
    nombre  = data['nombre'].to_s.strip
    herraje = data['herraje'].to_s.strip

    w_values = dimension_range(data, 'w')
    d_values = dimension_range(data, 'd')
    h_values = dimension_range(data, 'h')

    codes = []
    h_values.each do |h|
      d_values.each do |d|
        w_values.each do |w|
          parts = [nombre]
          parts << herraje   unless herraje.empty?
          parts << "#{w}W"   if w
          parts << "#{d}D"   if d
          parts << "#{h}H"   if h
          codes << parts.join(' ')
        end
      end
    end

    base      = herraje.empty? ? nombre : "#{nombre} #{herraje}"
    { codes: codes, folder_name: base, filename: "#{base}.csv" }
  end

  def self.dimension_range(data, dim)
    return [nil] unless data["#{dim}_enabled"]

    min  = data["#{dim}_min"].to_i
    max  = data["#{dim}_max"].to_i
    step = [data["#{dim}_step"].to_i, 1].max

    return [nil] if step <= 0 || min > max

    values = []
    v = min
    while v <= max
      values << v
      v += step
    end
    values.empty? ? [nil] : values
  end

  # ── Exportar CSV ──────────────────────────────────────────────────────────

  def self.save_csv(codes, filename)
    if codes.empty?
      UI.messagebox('No hay códigos para exportar. Verifica la configuración.')
      return
    end

    path = UI.savepanel('Guardar CSV', '', filename)
    return unless path

    CSV.open(path, 'w') do |csv|
      codes.each { |code| csv << [code] }
    end

    UI.messagebox("CSV guardado con #{codes.length} registros.\n#{path}")
  end

  # ── Crear tags en SketchUp ────────────────────────────────────────────────

  def self.create_sketchup_tags(codes, folder_name)
    if codes.empty?
      UI.messagebox('No hay códigos para crear. Verifica la configuración.')
      return
    end

    model  = Sketchup.active_model
    layers = model.layers

    model.start_operation('Crear Tags de Módulos', true)
    begin
      folder = find_or_create_folder(layers, folder_name)

      codes.each do |code|
        layer = layers[code] || layers.add(code)
        assign_to_folder(layer, folder)
      end

      model.commit_operation
      msg = "Se crearon #{codes.length} tags"
      msg += " en la carpeta '#{folder_name}'" if folder
      UI.messagebox(msg + '.')
    rescue => e
      model.abort_operation
      UI.messagebox("Error al crear tags: #{e.message}")
    end
  end

  def self.find_or_create_folder(layers, folder_name)
    return nil unless layers.respond_to?(:add_folder)

    existing = layers.folders.find { |f| f.display_name == folder_name }
    existing || layers.add_folder(folder_name)
  end

  def self.assign_to_folder(layer, folder)
    return unless folder && layer.respond_to?(:folder=)
    layer.folder = folder
  end

  # ── Registro de menú ──────────────────────────────────────────────────────

  unless file_loaded?(__FILE__)
    UI.menu('Extensions').add_item('Generador de Módulos CSV') { ModuloCSV.show_dialog }
    file_loaded(__FILE__)
  end
end
