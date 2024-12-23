require 'net/http'
require 'json'

class CarRecommendationService
  BASE_URL = "https://bravado-images-production.s3.amazonaws.com/recomended_cars.json?user_id="

  def self.fetch_recommendations(user_id)
    url = URI("#{BASE_URL}#{user_id}")
    response = Net::HTTP.get_response(url)
    return [] unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body, symbolize_names: true)
  rescue StandardError
    []
  end
end
