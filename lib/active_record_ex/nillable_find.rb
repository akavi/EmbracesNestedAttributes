module ActiveRecordEx
  module NillableFind
    class NillableArel
      def initialize(base, ids, parent_scope)
        @base = base
        @ids = ids
        @parent_scope = parent_scope
      end

      def method_missing(method_name, *args, &block)
        return super unless  @base.respond_to? method_name

        normals = @base.where(id: @ids).send(method_name, *args)
        return normals unless @ids.include? nil

        used = @base.send(method_name, *args)
        # return those in normals AND those in parent scope not belonging to another
        normals.disjunct(used.relative_complement(@parent_scope))
      end
    end

    def self.included(base)
      raise ArgumentError.new("#{base} must include ManyToMany") unless base.included_modules.include? ActiveRecordEx::ManyToMany
      base.extend(ClassMethods)
    end

    module ClassMethods
      def nillable_find(ids, parent_scope)
        NillableArel.new(self, ids, parent_scope)
      end
    end
  end
end
