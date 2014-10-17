json.array!(@revisions) do |revision|
  json.extract! revision, :id, :project_id, :commit_id
  json.url revision_url(revision, format: :json)
end
