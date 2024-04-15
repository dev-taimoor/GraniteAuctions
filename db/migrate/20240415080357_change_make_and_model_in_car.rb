class ChangeMakeAndModelInCar < ActiveRecord::Migration[7.0]
  def change
    change_column :cars, :make_model, :string, null: true
    add_column :cars, :make, :string
    add_column :cars, :model, :string
    Car.all.each do |car|
      make, model = car.make_model.split(' ')
      car.update_columns(make: make, model: model)
    end
  end
end
