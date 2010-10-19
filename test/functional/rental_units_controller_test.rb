require 'test_helper'

class RentalUnitsControllerTest < ActionController::TestCase
  setup do
    @rental_unit = rental_units(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:rental_units)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create rental_unit" do
    assert_difference('RentalUnit.count') do
      post :create, :rental_unit => @rental_unit.attributes
    end

    assert_redirected_to rental_unit_path(assigns(:rental_unit))
  end

  test "should show rental_unit" do
    get :show, :id => @rental_unit.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @rental_unit.to_param
    assert_response :success
  end

  test "should update rental_unit" do
    put :update, :id => @rental_unit.to_param, :rental_unit => @rental_unit.attributes
    assert_redirected_to rental_unit_path(assigns(:rental_unit))
  end

  test "should destroy rental_unit" do
    assert_difference('RentalUnit.count', -1) do
      delete :destroy, :id => @rental_unit.to_param
    end

    assert_redirected_to rental_units_path
  end
end
