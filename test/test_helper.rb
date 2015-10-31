require 'active_record'
require 'test/unit'
require 'shoulda'
require 'mocha'

require 'active_record_ex/relation_extensions'

class ActiveSupport::TestCase
  def db_expects(arel, query, response = nil)
    response_columns = response.try(:first).try(:keys).try(:map, &:to_s) || []
    response_rows = response.try(:map, &:values) || []
    response = ActiveRecord::Result.new(response_columns, response_rows)

    case query.first
    when /^SELECT/
      arel.connection.expects(:exec_query).with(*query).returns(response)
    when /^DELETE/
      arel.connection.expects(:exec_delete).with(*query).returns(response)
    end
  end
end

# Used as a "dummy" model in tests to avoid using a database connection
class StubModel < ActiveRecord::Base
  self.abstract_class = true

  conn = Class.new(ActiveRecord::ConnectionAdapters::AbstractAdapter) do
    def quote_column_name(name)
      "`#{name.to_s.gsub('`', '``')}`"
    end

    def quote_table_name(name)
      quote_column_name(name).gsub('.', '`.`')
    end

    def select(sql, name = nil, _ = [])
      exec_query(sql, name).to_a
    end
  end

  visitor = Class.new(Arel::Visitors::ToSql) do
    def table_exists?(*_)
      true
    end

    def column_for(attr)
      pk = attr == 'id'
      column = ActiveRecord::ConnectionAdapters::Column.new(attr, nil, pk ? :integer : :string)
      column.primary = pk
      column
    end
  end

  @@connection = conn.new({})
  @@connection.visitor = visitor.new(@@connection)

  class << self
    def connection
      @@connection
    end

    def columns; []; end

    def get_primary_key(*_); 'id'; end
  end

  # prevent AR from hitting the DB to get the schema
  def get_primary_key(*_); 'id'; end

  def with_transaction_returning_status; yield; end
end

# SQLCounter is part of ActiveRecord but is not distributed with the gem (used for internal tests only)
# see https://github.com/rails/rails/blob/3-2-stable/activerecord/test/cases/helper.rb#L59
module ActiveRecord
  class SQLCounter
    cattr_accessor :ignored_sql
    self.ignored_sql = [/^PRAGMA (?!(table_info))/, /^SELECT currval/, /^SELECT CAST/, /^SELECT @@IDENTITY/, /^SELECT @@ROWCOUNT/, /^SAVEPOINT/, /^ROLLBACK TO SAVEPOINT/, /^RELEASE SAVEPOINT/, /^SHOW max_identifier_length/, /^BEGIN/, /^COMMIT/]

    # FIXME: this needs to be refactored so specific database can add their own
    # ignored SQL.  This ignored SQL is for Oracle.
    ignored_sql.concat [/^select .*nextval/i, /^SAVEPOINT/, /^ROLLBACK TO/, /^\s*select .* from all_triggers/im]

    cattr_accessor :log
    self.log = []

    attr_reader :ignore

    def initialize(ignore = self.class.ignored_sql)
      @ignore   = ignore
    end

    def call(name, start, finish, message_id, values)
      sql = values[:sql]

      # FIXME: this seems bad. we should probably have a better way to indicate
      # the query was cached
      return if 'CACHE' == values[:name] || ignore.any? { |x| x =~ sql }
      self.class.log << sql
    end
  end

  ActiveSupport::Notifications.subscribe('sql.active_record', SQLCounter.new)
end
