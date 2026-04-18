module KitchenWallViews
  module LayoutExporter
    # Layout page dimensions (inches) — Letter landscape
    PAGE_W = 11.0
    PAGE_H = 8.5

    MARGIN    = 0.4   # inches
    TITLE_H   = 0.35  # inches reserved for title text
    VIEWPORT_GAP = 0.3

    # Creates a .layout document with one page per wall.
    # Each page shows: left = orthographic elevation, right = perspective view.
    # Returns the output file path.
    def self.export(skp_path, scene_pairs)
      output_path = layout_output_path(skp_path)

      doc = Layout::Document.new

      # Set page size to Letter landscape
      page_info = doc.page_info
      page_info.width  = PAGE_W
      page_info.height = PAGE_H
      page_info.top_margin    = MARGIN
      page_info.bottom_margin = MARGIN
      page_info.left_margin   = MARGIN
      page_info.right_margin  = MARGIN

      default_page = doc.pages.first
      layer        = doc.layers.first

      scene_pairs.each_with_index do |pair, idx|
        page = idx == 0 ? default_page : doc.pages.add(pair[:wall_name])
        page.name = pair[:wall_name]

        add_title(doc, layer, page, pair[:wall_name])
        add_viewports(doc, layer, page, skp_path, pair)
      end

      doc.save(output_path)
      output_path
    end

    private

    def self.layout_output_path(skp_path)
      dir      = File.dirname(skp_path)
      basename = File.basename(skp_path, '.skp')
      File.join(dir, "#{basename}_muros.layout")
    end

    def self.add_title(doc, layer, page, wall_name)
      title_bounds = Geom::Bounds2d.new(MARGIN, MARGIN, PAGE_W - MARGIN * 2, TITLE_H)
      text = Layout::FormattedText.new(wall_name, Geom::Point2d.new(MARGIN, MARGIN))
      doc.add_entity(text, layer, page)
    end

    def self.add_viewports(doc, layer, page, skp_path, pair)
      content_top  = MARGIN + TITLE_H + 0.1
      content_h    = PAGE_H - content_top - MARGIN
      half_w       = (PAGE_W - MARGIN * 2 - VIEWPORT_GAP) / 2.0

      # Orthographic viewport — left side
      ortho_bounds = Geom::Bounds2d.new(MARGIN, content_top, half_w, content_h)
      ortho_vp = Layout::SketchUpModel.new(skp_path, ortho_bounds)
      ortho_vp.current_scene = pair[:ortho_index]
      ortho_vp.render_mode   = Layout::SketchUpModel::VECTOR_RENDER
      doc.add_entity(ortho_vp, layer, page)
      ortho_vp.render if ortho_vp.render_needed?

      # Perspective viewport — right side
      persp_x      = MARGIN + half_w + VIEWPORT_GAP
      persp_bounds = Geom::Bounds2d.new(persp_x, content_top, half_w, content_h)
      persp_vp = Layout::SketchUpModel.new(skp_path, persp_bounds)
      persp_vp.current_scene = pair[:persp_index]
      persp_vp.render_mode   = Layout::SketchUpModel::RASTER_RENDER
      doc.add_entity(persp_vp, layer, page)
      persp_vp.render if persp_vp.render_needed?
    end
  end
end
