require 'test_helper'

class GraphqlAuthenticationTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: 'owner@example.com',
      password: 'password12',
      password_confirmation: 'password12'
    )
    @task = @user.tasks.create!(title: 'Owned task', status: 'pending')
  end

  test 'tasks without bearer returns graphql error' do
    post '/graphql',
      params: { query: '{ tasks { id } }' },
      as: :json
    assert_response :success
    body = JSON.parse(response.body)
    assert body['errors'].present?
    assert_includes body.dig('errors', 0, 'message'), 'Authentication required'
  end

  test 'tasks with valid bearer returns tasks' do
    post '/graphql',
      params: { query: '{ tasks { id title } }' },
      headers: { 'Authorization' => "Bearer #{@user.api_token}" },
      as: :json
    assert_response :success
    body = JSON.parse(response.body)
    assert_nil body['errors']
    ids = body.dig('data', 'tasks').map { |t| t['id'] }
    assert_includes ids, @task.id.to_s
  end

  test 'sign up returns token' do
    post '/graphql',
      params: {
        query: <<~GQL
          mutation {
            signUp(email: "new@example.com", password: "password12") {
              apiToken
              errors
              user { email }
            }
          }
        GQL
      },
      as: :json
    body = JSON.parse(response.body)
    assert_nil body['errors'], body.inspect
    payload = body.dig('data', 'signUp')
    assert payload['apiToken'].present?
    assert_equal [], payload['errors']
    assert_equal 'new@example.com', payload.dig('user', 'email')
  end

  test 'cannot update another users task' do
    other = User.create!(
      email: 'other@example.com',
      password: 'password12',
      password_confirmation: 'password12'
    )

    post '/graphql',
      params: {
        query: <<~GQL,
          mutation {
            updateTask(id: "#{@task.id}", title: "hacked") {
              task { id }
              errors
            }
          }
        GQL
      },
      headers: { 'Authorization' => "Bearer #{other.api_token}" },
      as: :json

    body = JSON.parse(response.body)
    assert_nil body['errors']
    payload = body.dig('data', 'updateTask')
    assert_nil payload['task']
    assert_includes payload['errors'], 'Task not found'
  end

  test 'task query without bearer returns graphql error' do
    post '/graphql',
      params: { query: "{ task(id: \"#{@task.id}\") { id } }" },
      as: :json
    body = JSON.parse(response.body)
    assert body['errors'].present?
    assert_includes body.dig('errors', 0, 'message'), 'Authentication required'
  end

  test 'task query with bearer returns task when owned' do
    post '/graphql',
      params: { query: "{ task(id: \"#{@task.id}\") { id title } }" },
      headers: { 'Authorization' => "Bearer #{@user.api_token}" },
      as: :json
    body = JSON.parse(response.body)
    assert_nil body['errors']
    assert_equal @task.id.to_s, body.dig('data', 'task', 'id')
    assert_equal 'Owned task', body.dig('data', 'task', 'title')
  end

  test 'task query returns null when id belongs to another user' do
    other = User.create!(
      email: 'peer@example.com',
      password: 'password12',
      password_confirmation: 'password12'
    )
    post '/graphql',
      params: { query: "{ task(id: \"#{@task.id}\") { id } }" },
      headers: { 'Authorization' => "Bearer #{other.api_token}" },
      as: :json
    body = JSON.parse(response.body)
    assert_nil body['errors']
    assert_nil body.dig('data', 'task')
  end

  test 'invalid bearer treated as unauthenticated for tasks' do
    post '/graphql',
      params: { query: '{ tasks { id } }' },
      headers: { 'Authorization' => 'Bearer not-a-real-token' },
      as: :json
    body = JSON.parse(response.body)
    assert_includes body.dig('errors', 0, 'message'), 'Authentication required'
  end

  test 'create_task without bearer returns top level graphql error' do
    post '/graphql',
      params: {
        query: <<~GQL
          mutation {
            createTask(title: "Nope") {
              task { id }
              errors
            }
          }
        GQL
      },
      as: :json
    body = JSON.parse(response.body)
    assert body['errors'].present?
    assert_includes body.dig('errors', 0, 'message'), 'Authentication required'
  end

  test 'create_task with bearer persists task for user' do
    post '/graphql',
      params: {
        query: <<~GQL
          mutation {
            createTask(title: "Fresh", status: pending) {
              task { id title }
              errors
            }
          }
        GQL
      },
      headers: { 'Authorization' => "Bearer #{@user.api_token}" },
      as: :json
    body = JSON.parse(response.body)
    assert_nil body['errors'], body.inspect
    payload = body.dig('data', 'createTask')
    assert_equal [], payload['errors']
    assert_equal 'Fresh', payload.dig('task', 'title')
    created = @user.tasks.find(payload.dig('task', 'id'))
    assert_equal 'Fresh', created.title
  end

  test 'sign_in wrong password returns mutation errors' do
    post '/graphql',
      params: {
        query: <<~GQL
          mutation {
            signIn(email: "owner@example.com", password: "wrongpassword") {
              apiToken
              errors
              user { id }
            }
          }
        GQL
      },
      as: :json
    body = JSON.parse(response.body)
    assert_nil body['errors']
    payload = body.dig('data', 'signIn')
    assert_nil payload['apiToken']
    assert_nil payload['user']
    assert_includes payload['errors'], 'Invalid email or password'
  end

  test 'sign_in returns token for valid credentials' do
    post '/graphql',
      params: {
        query: <<~GQL
          mutation {
            signIn(email: "owner@example.com", password: "password12") {
              apiToken
              errors
              user { email }
            }
          }
        GQL
      },
      as: :json
    body = JSON.parse(response.body)
    assert_nil body['errors']
    payload = body.dig('data', 'signIn')
    assert_equal @user.api_token, payload['apiToken']
    assert_equal [], payload['errors']
    assert_equal 'owner@example.com', payload.dig('user', 'email')
  end

  test 'sign_up duplicate email returns field errors' do
    post '/graphql',
      params: {
        query: <<~GQL
          mutation {
            signUp(email: "owner@example.com", password: "password12") {
              apiToken
              errors
              user { id }
            }
          }
        GQL
      },
      as: :json
    body = JSON.parse(response.body)
    assert_nil body['errors']
    payload = body.dig('data', 'signUp')
    assert_nil payload['apiToken']
    assert_nil payload['user']
    assert payload['errors'].any? { |e| e.include?('Email') }
  end

  test 'me without bearer returns graphql error' do
    post '/graphql',
      params: { query: '{ me { id email } }' },
      as: :json
    body = JSON.parse(response.body)
    assert body['errors'].present?
    assert_includes body.dig('errors', 0, 'message'), 'Authentication required'
  end

  test 'me with valid bearer returns current user' do
    post '/graphql',
      params: { query: '{ me { id email } }' },
      headers: { 'Authorization' => "Bearer #{@user.api_token}" },
      as: :json
    body = JSON.parse(response.body)
    assert_nil body['errors']
    assert_equal @user.id.to_s, body.dig('data', 'me', 'id')
    assert_equal 'owner@example.com', body.dig('data', 'me', 'email')
  end

  test 'delete_task cannot destroy another users task' do
    other = User.create!(
      email: 'deleter@example.com',
      password: 'password12',
      password_confirmation: 'password12'
    )
    post '/graphql',
      params: {
        query: <<~GQL
          mutation {
            deleteTask(id: "#{@task.id}") {
              success
              errors
            }
          }
        GQL
      },
      headers: { 'Authorization' => "Bearer #{other.api_token}" },
      as: :json
    body = JSON.parse(response.body)
    assert_nil body['errors']
    payload = body.dig('data', 'deleteTask')
    assert_equal false, payload['success']
    assert_includes payload['errors'], 'Task not found'
    assert Task.exists?(@task.id)
  end
end
