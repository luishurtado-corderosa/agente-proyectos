module KitchenWallViews
  module WallDetector
    def self.find_walls(model, pattern = /muro|wall/i)
      entities = model.active_entities
      groups     = entities.grep(Sketchup::Group)
      components = entities.grep(Sketchup::ComponentInstance)

      walls = (groups + components).select do |entity|
        name = entity_name(entity)
        name && name.match?(pattern)
      end

      # Sort alphabetically for consistent scene ordering
      walls.sort_by { |e| entity_name(e).downcase }
    end

    def self.entity_name(entity)
      if entity.is_a?(Sketchup::Group)
        entity.name
      elsif entity.is_a?(Sketchup::ComponentInstance)
        entity.name.empty? ? entity.definition.name : entity.name
      end
    end
  end
end
