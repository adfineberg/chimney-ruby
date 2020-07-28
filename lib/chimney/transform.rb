module Chimney
  module Transform
    def transform_into(other_struct)
      into(other_struct).transform
    end

    def into(other_struct)
      @__other_struct__ = other_struct
      @__transformations__ = []
      @__allow_defaults__ = true

      self
    end

    def transform
      transformed_attributes = @__transformations__.reduce(attributes.clone) { |attributes, t| t.call(attributes) }
      @__other_struct__.new transformed_attributes
    end

    def with_field_const(field, value)
      @__transformations__ << proc { |attributes| attributes.merge(field => value) }

      self
    end

    def with_field_computed(field, value_proc)
      @__transformations__ << proc { |attributes| attributes.merge(field => value_proc.call(self)) }

      self
    end

    def with_field_renamed(orig_field, renamed_field)
      @__transformations__ << proc do |attributes|
        attributes.reject { |k| k == orig_field }.merge(renamed_field => attributes[orig_field])
      end

      self
    end
  end
end
Dry::Struct.include Chimney::Transform
