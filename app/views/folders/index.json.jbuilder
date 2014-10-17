json.array!(@folders) do |folder|
  json.extract! folder, :id, :revision_id, :name
  json.url folder_url(folder, format: :json)
end
