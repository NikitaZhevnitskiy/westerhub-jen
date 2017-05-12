require 'test_helper'

# TODO: Discuss which fields for user registration are required (necessary)
# TODO: check http code response when user not registered after Act

class RegistrationFlowsTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:user1)
    assert @user.valid?

    @invalid_data="?"
    @valid_password = "qwerty"
  end

  def teardown
    @user=nil
  end

  def logout
   delete  "/users/sign_out"
  end

  def registerNewUser(firstname, lastname, username, email, password, confirmation)
    post "/users",
         params: { user:
                       {first_name: firstname,
                        last_name: lastname,
                        username: username,
                        email: email,
                        password: password,
                        password_confirmation: confirmation}}
  end

  private
  def getValidUser
    user_valid = User.new(
        email: "nik@nik.no",
        password: "foobar123",
        username: "rubymess",
        first_name: "Nikita",
        last_name: "Difficult")
    assert user_valid.valid?
    return user_valid
  end


  test "user_logout" do
    #Arrange
    logout

    #Assert
    assert_response :redirect
    follow_redirect!
    assert_equal '/', path
  end

  test "register_new_user_valid_data" do
    #Arrange
    logout
    assert_equal(1, User.all.count)
    user = getValidUser
    #Act
    registerNewUser(user.first_name,
                    user.last_name,
                    user.username,
                    user.email,
                    @valid_password,
                    @valid_password)
    #Assert
    # no error messages (just prepare for selenium)
    assert_select "div#error_explanation", 0
    assert_equal(2, User.all.count)

    assert_response :redirect
    assert_equal '/users', path
    follow_redirect!
    assert_response :success
    assert_equal '/', path
  end

  test "register_new_user_not_valid_data" do
    #Arrange
    logout
    assert_equal(1, User.all.count)
    user=getValidUser

    registerNewUser(@invalid_data,
                    @invalid_data,
                    user.username,
                    user.email,
                    @valid_password,
                    @invalid_data)

    # error messages
    # assert_select "div#error_explanation", 1, "Need error message on page, date for registration user is not valid"

    assert_equal 1, User.all.count,
                 "Backend has no validation for request body next params\nfirst_name, last_name, password_confirmation"
  end

  test "register_new_user_not_valid_username" do
    logout
    assert_equal(1, User.all.count)

    user = getValidUser
    registerNewUser(user.first_name,
                    user.last_name,
                    @invalid_data,
                    user.email,
                    @valid_password,
                    @valid_password)

    assert_equal 1, User.all.count,
                 "Backend has no validation for request body next params\nusername"
  end

  test "register_new_user_not_valid_email" do
    #Arrange
    logout
    assert_equal(1, User.all.count)
    #Act
    user = getValidUser
    registerNewUser(user.first_name,
                    user.last_name,
                    user.username,
                    @invalid_data,
                    @valid_password,
                    @valid_password)
    #Assert
    assert_response :success
    assert_equal '/users', path
    assert_select ("div#error_explanation")
  end

  test "register_new_user_not_valid_password" do
    logout
    assert_equal(1, User.all.count)

    user = getValidUser
    registerNewUser(user.first_name,
                    user.last_name,
                    user.username,
                    user.email,
                    @invalid_data,
                    @invalid_data)

    assert_equal 1, User.all.count,
                 "Backend has no validation for request body next params\npassword"
  end

  test "register_new_user_twice" do
    #Arrange
    logout
    assert_equal(1, User.all.count)
    user = getValidUser

    #Act
    for i in 0..1
      registerNewUser(user.first_name,
                      user.last_name,
                      user.username,
                      user.email,
                      @valid_password,
                      @valid_password)
    end

    #Assert
    assert_equal 2, User.all.count,
                 "Backend has no validation to prevent register twice same user data"
  end





  test "login_existing_user" do
    logout
    assert_equal 0, @user.sign_in_count
    post "/users/sign_in",
         params: {user: {
             email: @user.email,
             password: "foofoo",
             remember_me: 0
         }}
    assert_response :redirect
    assert_equal '/users/sign_in', path
    follow_redirect!
    assert_response :success
    assert_equal '/', path
    # refresh object with new db data
    @user.reload
    assert_equal 1, @user.sign_in_count
  end

end
