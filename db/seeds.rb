Task.create!([
  { title: 'Set up project repository', description: 'Initialize Git repo, add .gitignore and README', status: 'completed' },
  { title: 'Design database schema', description: 'Plan out the tables and relationships needed for the app', status: 'completed' },
  { title: 'Build GraphQL API', description: 'Implement queries and mutations for task management', status: 'in_progress' },
  { title: 'Create frontend components', description: 'Build React components for task list, form, and filters', status: 'in_progress' },
  { title: 'Write unit tests', description: 'Add test coverage for models and GraphQL resolvers', status: 'pending' },
  { title: 'Deploy to production', description: 'Set up CI/CD pipeline and deploy to hosting provider', status: 'pending' },
])

puts "Seeded #{Task.count} tasks"
