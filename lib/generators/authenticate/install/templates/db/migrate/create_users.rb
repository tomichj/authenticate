class CreateUsers < ActiveRecord::Migration
  def change

    create_table :users do |t|
    <% config[:new_columns].values.each do |column| -%>
      <%= column %>
    <% end -%>
    end

<% config[:new_indexes].values.each do |index| -%>
    <%= index %>
<% end -%>
  end
end
