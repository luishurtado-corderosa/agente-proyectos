module KitchenWallViews
  class UIDialog
    HTML = <<~HTML
      <!DOCTYPE html>
      <html lang="es">
      <head>
        <meta charset="UTF-8">
        <style>
          * { box-sizing: border-box; margin: 0; padding: 0; }
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            font-size: 13px;
            background: #f5f5f5;
            padding: 16px;
            color: #333;
          }
          h2 { font-size: 15px; margin-bottom: 14px; color: #1a1a1a; }
          label { display: block; margin-bottom: 10px; }
          label span { display: block; margin-bottom: 4px; font-weight: 500; }
          input[type=text] {
            width: 100%;
            padding: 6px 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 13px;
          }
          .checkbox-row {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 10px;
          }
          .checkbox-row input { width: 15px; height: 15px; cursor: pointer; }
          .actions { margin-top: 16px; display: flex; gap: 8px; justify-content: flex-end; }
          button {
            padding: 7px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 13px;
          }
          #btn-generate { background: #0073e6; color: #fff; }
          #btn-generate:hover { background: #005bb5; }
          #btn-cancel { background: #e0e0e0; color: #333; }
          #btn-cancel:hover { background: #cacaca; }
          .hint { font-size: 11px; color: #888; margin-top: 3px; }
        </style>
      </head>
      <body>
        <h2>Kitchen Wall Views</h2>

        <label>
          <span>Patrón de nombre de muros</span>
          <input type="text" id="pattern" value="muro">
          <div class="hint">Coincide con cualquier grupo/componente que contenga este texto (no distingue mayúsculas)</div>
        </label>

        <div class="checkbox-row">
          <input type="checkbox" id="create-scenes" checked>
          <label for="create-scenes">Crear escenas en el modelo SketchUp</label>
        </div>

        <div class="checkbox-row">
          <input type="checkbox" id="export-layout" checked>
          <label for="export-layout">Generar archivo Layout (.layout)</label>
        </div>

        <div class="actions">
          <button id="btn-cancel">Cancelar</button>
          <button id="btn-generate">Generar</button>
        </div>

        <script>
          document.getElementById('btn-generate').addEventListener('click', function () {
            var options = {
              pattern:       document.getElementById('pattern').value.trim() || 'muro',
              create_scenes: document.getElementById('create-scenes').checked,
              export_layout: document.getElementById('export-layout').checked
            };
            sketchup.generate(options);
          });

          document.getElementById('btn-cancel').addEventListener('click', function () {
            sketchup.cancel();
          });
        </script>
      </body>
      </html>
    HTML

    def initialize
      @dialog = Sketchup::HtmlDialog.new(
        dialog_title:    'Kitchen Wall Views',
        preferences_key: 'KitchenWallViews',
        width:           380,
        height:          280,
        resizable:       false
      )
      @dialog.set_html(HTML)
    end

    # Yields options hash when user clicks Generar, then closes dialog.
    def show(&block)
      @dialog.add_action_callback('generate') do |_ctx, options|
        @dialog.close
        block.call(
          pattern:       options['pattern'],
          create_scenes: options['create_scenes'],
          export_layout: options['export_layout']
        )
      end

      @dialog.add_action_callback('cancel') { @dialog.close }

      @dialog.show
    end
  end
end
