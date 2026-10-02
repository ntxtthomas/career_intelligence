json.extract! company, :id, :name, :location, :website, :created_at, :updated_at
json.industry company.industry&.full_name
json.url company_url(company, format: :json)
