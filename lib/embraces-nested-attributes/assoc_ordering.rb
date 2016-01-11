# Extends setters for has_many associations
# So that ordering of association arrays is persisted
module EmbracesNestedAttributes
  module AssocOrdering
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def has_many(assoc_name, options = {}, &extension)
        order_field = options.delete(:order_on)
        super
        return unless order_field

        define_model_setter(assoc_name, order_field)
      end

      def accepts_nested_attributes_for(assoc_name, options = {})
        order_field = options.delete(:order_on)
        allow_destroy = options[:allow_destroy] || options[:assume_destroy]
        super
        return unless order_field

        define_attribute_setter(assoc_name, order_field, allow_destroy)
      end

      protected

      def define_model_setter(assoc_name, order_field)
        setter_name = "#{assoc_name}="
        unordering_setter_name = "#{assoc_name}_without_ordering="
        ordering_setter_name = "#{assoc_name}_with_ordering="

        define_method(ordering_setter_name) do |models|
          models.each_with_index{ |m, i| m.send("#{order_field}=", i + 1) }
          self.send(unordering_setter_name, models)
        end
        alias_method_chain setter_name, :ordering
      end

      def define_attribute_setter(assoc_name, order_field, allow_destroy)
        attrs_name = "#{assoc_name}_attributes"
        setter_name = "#{attrs_name}="
        unordering_setter_name = "#{attrs_name}_without_ordering="
        ordering_setter_name = "#{attrs_name}_with_ordering="

        define_method(ordering_setter_name) do |attrs|
          new_attrs = attrs
          new_attrs = attrs.reject{ |a| a[:_destroy] } if allow_destroy
          new_attrs.each_with_index{ |a, i| a[order_field] = i + 1 }
          self.send(unordering_setter_name, attrs)
        end
        alias_method_chain setter_name, :ordering
      end
    end
  end
end
