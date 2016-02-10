class CreateUsers < ActiveRecord::Migration
  def change
    create_table :<%= table_name %> do |t|
    <% config[:new_columns].values.each do |column| -%>
      <%= column %>
    <% end -%>
    end

<% config[:new_indexes].values.each do |index| -%>
    <%= index %>
<% end -%>
  end
end
