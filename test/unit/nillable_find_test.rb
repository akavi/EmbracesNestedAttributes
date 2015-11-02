require 'test_helper'
require 'active-record-ex/many_to_many'
require 'active-record-ex/nillable_find'

class NillableFindTest < ActiveSupport::TestCase
  class Parent < StubModel
    include ActiveRecordEx::ManyToMany
    include ActiveRecordEx::NillableFind

    has_many :children
  end

  class Child < StubModel
  end

  context 'ActiveRecordEx::NillableFind' do
    context '#nillable_find' do
      setup { @arel = Parent.scoped }
      # RC == relative complement
      should 'request the RC of the base scope in the parent scope when just passed nil' do
        # fetch IDs
        db_expects(@arel, ['SELECT `parents`.`id` FROM `parents`  WHERE `parents`.`id` IS NULL'], [])
        # fetch outside set
        db_expects(@arel, ['SELECT `parents`.`id` FROM `parents` '], [{id: 1}, {id: 2}])
        # disjunct
        db_expects(@arel, ['SELECT `children`.* FROM `children`  WHERE ((1=0 OR NOT (`children`.`parent_id` IN (1, 2)) AND `children`.`foo` = \'bar\'))', 'NillableFindTest::Child Load'], [])

        Parent.nillable_find([nil], Child.where(foo: 'bar')).children.all
      end

      should 'request the disjunct of the RC of base scope in parent scope and all children of non-nil ids' do
        # fetch IDs
        db_expects(@arel, ['SELECT `parents`.`id` FROM `parents`  WHERE ((`parents`.`id` IN (1) OR `parents`.`id` IS NULL))'], [{id: 1}])
        # fetch outside set
        db_expects(@arel, ['SELECT `parents`.`id` FROM `parents` '], [{id: 1}, {id: 2}])
        # disjunct
        db_expects(@arel, ['SELECT `children`.* FROM `children`  WHERE ((`children`.`parent_id` IN (1) OR NOT (`children`.`parent_id` IN (1, 2)) AND `children`.`foo` = \'bar\'))', 'NillableFindTest::Child Load'], [])

        Parent.nillable_find([1, nil], Child.where(foo: 'bar')).children.all
      end

      should 'request nothing when passed no an empty set of ids' do
        db_expects(@arel, ['SELECT `parents`.`id` FROM `parents`  WHERE 1=0'], [])
        db_expects(@arel, ['SELECT `children`.* FROM `children`  WHERE 1=0', 'NillableFindTest::Child Load'], [])

        Parent.nillable_find([], Child.where(foo: 'bar')).children.all
      end

      should 'request as a normal many-to-many when passed only normal ids' do
        db_expects(@arel, ['SELECT `parents`.`id` FROM `parents`  WHERE `parents`.`id` IN (1)'], [{id: 1}])
        db_expects(@arel, ['SELECT `children`.* FROM `children`  WHERE `children`.`parent_id` IN (1)', 'NillableFindTest::Child Load'], [])

        Parent.nillable_find([1], Child.where(foo: 'bar')).children.all
      end
    end
  end
end
