demo = User.find_or_initialize_by(email: 'demo@example.com')
if demo.new_record?
  demo.password = 'password12'
  demo.password_confirmation = 'password12'
  demo.save!
end

unless demo.tasks.exists?
  demo.tasks.create!([
    { title: 'Set up project repository', description: 'Initialize Git repo, add .gitignore and README', status: 'completed' },
    { title: 'Design database schema', description: 'Plan out the tables and relationships needed for the app', status: 'completed' },
    { title: 'Build GraphQL API', description: 'Implement queries and mutations for task management', status: 'in_progress' },
    { title: 'Create frontend components', description: 'Build React components for task list, form, and filters', status: 'in_progress' },
    { title: 'Write unit tests', description: 'Add test coverage for models and GraphQL resolvers', status: 'pending' },
    { title: 'Deploy to production', description: 'Set up CI/CD pipeline and deploy to hosting provider', status: 'pending' },
  ])
end

puts "Seeded user #{demo.email} (#{demo.tasks.count} tasks). Sign in or use Authorization: Bearer #{demo.api_token}"
