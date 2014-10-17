json.array!(@projects) do |project|
  json.extract! project, :id, :git, :name
  json.url project_url(project, format: :json)
end
