module KitchenWallViews
  module CameraCalculator
    PADDING_FACTOR = 1.15  # 15% padding around wall
    PERSP_ANGLE    = 35    # degrees, field of view for perspective
    PERSP_OFFSET   = 1.5   # multiplier of wall diagonal for perspective eye distance

    # Returns an orthographic Sketchup::Camera looking straight at the wall face.
    # The wall's shallowest bbox axis is assumed to be its depth (the normal direction).
    def self.orthographic_camera(wall)
      bounds = transformed_bounds(wall)
      normal, eye_offset = wall_normal_and_offset(bounds)

      center = bounds.center
      eye    = center.offset(normal, eye_offset)
      target = center
      up     = Geom::Vector3d.new(0, 0, 1)

      cam = Sketchup::Camera.new(eye, target, up)
      cam.perspective = false
      # height in model units: use the taller of the two visible dimensions
      cam.height = [bounds.width, bounds.height].max * PADDING_FACTOR
      cam
    end

    # Returns a perspective Sketchup::Camera at a 3/4 angle relative to the wall face.
    def self.perspective_camera(wall)
      bounds = transformed_bounds(wall)
      normal, _ = wall_normal_and_offset(bounds)

      diagonal  = bounds.diagonal
      center    = bounds.center

      # Offset diagonally: along the normal AND along the perpendicular horizontal axis
      perp = normal.axes.first  # one of the horizontal perpendiculars
      eye = center
             .offset(normal, diagonal * PERSP_OFFSET * 0.7)
             .offset(perp,   diagonal * PERSP_OFFSET * 0.4)
             .offset(Geom::Vector3d.new(0, 0, 1), diagonal * 0.3)

      cam = Sketchup::Camera.new(eye, center, Geom::Vector3d.new(0, 0, 1))
      cam.perspective = true
      cam.fov = PERSP_ANGLE
      cam
    end

    private

    # Returns the bounding box in world coordinates for a group/component.
    def self.transformed_bounds(entity)
      entity.bounds
    end

    # Detects the wall face normal as the axis with the shortest extent.
    # Returns [normal_vector, eye_distance].
    def self.wall_normal_and_offset(bounds)
      dx = (bounds.max.x - bounds.min.x).abs
      dy = (bounds.max.y - bounds.min.y).abs
      dz = (bounds.max.z - bounds.min.z).abs

      visible_dims = [dx, dy, dz].reject { |d| d < 1.0 }
      max_dim = visible_dims.max || 100.0

      # The shallowest non-vertical axis is the depth (normal direction)
      if dx <= dy
        normal = Geom::Vector3d.new(1, 0, 0)
        depth  = dx
      else
        normal = Geom::Vector3d.new(0, 1, 0)
        depth  = dy
      end

      # Eye distance: enough to see the full wall + padding
      eye_distance = [max_dim * PADDING_FACTOR * 1.5, depth + 50.0].max
      [normal, eye_distance]
    end
  end
end
