require_relative 'camera_calculator'

module KitchenWallViews
  module SceneCreator
    # Creates two scenes per wall (orthographic elevation + perspective).
    # Returns an array of hashes: [{ wall_name:, ortho_index:, persp_index: }, ...]
    def self.create_scenes(model, walls)
      view       = model.active_view
      pages      = model.pages
      scene_pairs = []

      walls.each do |wall|
        wall_name = WallDetector.entity_name(wall)

        # --- Orthographic elevation scene ---
        ortho_cam = CameraCalculator.orthographic_camera(wall)
        view.camera = ortho_cam
        ortho_scene_name = "#{wall_name} - Elevación"
        remove_existing_scene(pages, ortho_scene_name)
        ortho_page = pages.add(ortho_scene_name)
        ortho_page.update(Sketchup::Page::PAGE_USE_CAMERA |
                          Sketchup::Page::PAGE_USE_HIDDEN |
                          Sketchup::Page::PAGE_USE_RENDERING_OPTIONS)

        # --- Perspective scene ---
        persp_cam = CameraCalculator.perspective_camera(wall)
        view.camera = persp_cam
        persp_scene_name = "#{wall_name} - Perspectiva"
        remove_existing_scene(pages, persp_scene_name)
        persp_page = pages.add(persp_scene_name)
        persp_page.update(Sketchup::Page::PAGE_USE_CAMERA |
                          Sketchup::Page::PAGE_USE_HIDDEN |
                          Sketchup::Page::PAGE_USE_RENDERING_OPTIONS)

        scene_pairs << {
          wall_name:   wall_name,
          ortho_index: pages.to_a.index(ortho_page),
          persp_index: pages.to_a.index(persp_page)
        }
      end

      scene_pairs
    end

    private

    def self.remove_existing_scene(pages, name)
      existing = pages.to_a.find { |p| p.name == name }
      pages.erase(existing) if existing
    end
  end
end
