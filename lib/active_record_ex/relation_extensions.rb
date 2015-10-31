module ActiveRecord
  class Relation
    def none
      self.where('1=0')
    end
  end
end
