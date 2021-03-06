class ChangeGqueryKeysToIds < ActiveRecord::Migration
  def self.up
    gqueries = Api::Gquery.all
    gqueries.each do |gquery|
      gquery_id = gquery.id
      gquery_key = gquery.key
      say "Looking for #{gquery_key}"
      Constraint.where(:gquery_key => gquery_key).each do |constraint|
        say "Updating constraint #{constraint.id} #{gquery_key} => #{gquery_id}"
        constraint.update_attribute :gquery_key, gquery_id
      end
      OutputElementSerie.where(:gquery => gquery_key).each do |serie|
        say "Updating serie #{serie.id} #{gquery_key} => #{gquery_id}"
        serie.update_attribute :gquery, gquery_id
      end
    end
  end

  def self.down
    gqueries = Api::Gquery.all
    gqueries.each do |gquery|
      gquery_id = gquery.id
      gquery_key = gquery.key
      say "Looking for #{gquery_id}"
      Constraint.where(:gquery_key => gquery_id).each do |constraint|
        say "Updating constraint #{constraint.id} #{gquery_id} => #{gquery_key}"
        constraint.update_attribute :gquery_key, gquery_key
      end
      OutputElementSerie.where(:gquery => gquery_id).each do |serie|
        say "Updating serie #{serie.id} #{gquery_id} => #{gquery_key}"
        serie.update_attribute :gquery, gquery_key
      end
    end
  end
end
