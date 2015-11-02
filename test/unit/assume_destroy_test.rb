require 'test_helper'
require 'active-record-ex/assume_destroy'

class AssumeDestroyTest < ActiveRecord::TestCase
  class AssumesDestroy < StubModel
    include ActiveRecordEx::AssumeDestroy

    has_many :destroyees
    accepts_nested_attributes_for :destroyees,  assume_destroy: true
  end

  class Destroyee < StubModel
  end

  context 'ActiveRecordEx::AssumeDestroy' do
    setup do 
      @subject = AssumesDestroy.new
      @subject.stubs(:new_record?).returns(false)
    end

    context 'preconditions in ActiveRecord' do
      should 'DELETE records marked for destruction' do
        attrs = []
        stub_association_query(@subject, '\'\'', [{'id' => 1}, {'id' => 2}])
        db_expects(@subject, ['SELECT `destroyees`.* FROM `destroyees`  WHERE `destroyees`.`assumes_destroy_id` IS NULL AND `destroyees`.`id` IN (1, 2)', 'AssumeDestroyTest::Destroyee Load'], [{'id' => 1}, {'id' => 2}])
        db_expects(@subject.destroyees, ['DELETE FROM `destroyees` WHERE `destroyees`.`id` = ?', 'SQL', [[nil, 1]]])
        db_expects(@subject.destroyees, ['DELETE FROM `destroyees` WHERE `destroyees`.`id` = ?', 'SQL', [[nil, 2]]])

        @subject.update_attributes(destroyees_attributes: attrs)
      end
    end

    should 'not mark any for destruction if subject is new' do
      @subject.stubs(:new_record?).returns(true)
      attrs = [{name: 'one'}]
      expected_attrs = [{name: 'one'}]
      @subject.expects(:destroyees_attributes_without_assume=).with(expected_attrs)

      # shouldn't even hit the DB
      assert_no_queries { @subject.destroyees_attributes = attrs }
    end

    should 'mark all associations for destruction when passed an empty array' do
      attrs = []
      stub_association_query(@subject, '\'\'', [{'id' => 1}, {'id' => 2}])

      expected_attrs = [{id: 1, _destroy: true}, {id: 2, _destroy: true}]
      @subject.expects(:destroyees_attributes_without_assume=).with(expected_attrs)
      @subject.destroyees_attributes = attrs
    end

    should 'mark all existing associations for destruction when passed an array of just new' do
      attrs = [{name: 'one'}]
      stub_association_query(@subject, '\'\'', [{'id' => 1}, {'id' => 2}])

      expected_attrs = [{name: 'one'}, {id: 1, _destroy: true}, {id: 2, _destroy: true}]
      @subject.expects(:destroyees_attributes_without_assume=).with(expected_attrs)
      @subject.destroyees_attributes = attrs
    end

    should 'not mark explicitly passed in associations for destruction' do
      attrs = [{name: 'one'}, {id: 1}]
      stub_association_query(@subject, '1', [{id: 2}])

      expected_attrs = [{name: 'one'}, {id: 1}, {id: 2, _destroy: true}]
      @subject.expects(:destroyees_attributes_without_assume=).with(expected_attrs)
      @subject.destroyees_attributes = attrs
    end

    should 'preserve existing marks for destruction' do 
      attrs = [{name: 'one'}, {id: 1, _destroy: true}]
      stub_association_query(@subject, '1', [{id: 2}])

      expected_attrs = [{name: 'one'}, {id: 1, _destroy: true}, {id: 2, _destroy: true}]
      @subject.expects(:destroyees_attributes_without_assume=).with(expected_attrs)
      @subject.destroyees_attributes = attrs
    end
  end

  def stub_association_query(subject, id_string, id_response)
    db_expects(subject, ["SELECT `destroyees`.* FROM `destroyees`  WHERE `destroyees`.`assumes_destroy_id` IS NULL AND (id NOT IN (#{id_string}))", 'AssumeDestroyTest::Destroyee Load'], id_response)
  end
end
