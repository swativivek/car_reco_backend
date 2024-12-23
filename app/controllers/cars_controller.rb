class Api::CarsController < ApplicationController
    def index
      user = User.find(params[:user_id])
      return render json: { error: "User not found" }, status: :not_found unless user
  
      recommendations = CarRecommendationService.fetch_recommendations(user.id)
      recommended_cars = recommendations.index_by { |rec| rec[:car_id] }
  
      cars = Car.joins(:brand)
                .select('cars.*, brands.name AS brand_name, brands.id AS brand_id')
                .then { |query| filter_by_query(query, params[:query]) }
                .then { |query| filter_by_price(query, params[:price_min], params[:price_max]) }
  
      cars = cars.map do |car|
        rank_score = recommended_cars[car.id]&.dig(:rank_score)
        label = determine_label(user, car)
        {
          id: car.id,
          brand: { id: car.brand_id, name: car.brand_name },
          model: car.model_name,
          price: car.price,
          rank_score: rank_score,
          label: label
        }
      end
  
      sorted_cars = cars.sort_by { |car| [label_rank(car[:label]), -(car[:rank_score] || 0), car[:price]] }
      paginated_cars = paginate(sorted_cars, params[:page])
  
      render json: paginated_cars
    end
  
    private
  
    def filter_by_query(query, term)
      return query unless term.present?
  
      query.where('brands.name ILIKE ?', "%#{term}%")
    end
  
    def filter_by_price(query, price_min, price_max)
      query = query.where('cars.price >= ?', price_min.to_f) if price_min.present?
      query = query.where('cars.price <= ?', price_max.to_f) if price_max.present?
      query
    end
  
    def determine_label(user, car)
      brand_match = user.preferred_brands.exists?(id: car.brand_id)
      price_match = user.preferred_price_range.include?(car.price)
  
      return "perfect_match" if brand_match && price_match
      return "good_match" if brand_match
      nil
    end
  
    def label_rank(label)
      { "perfect_match" => 0, "good_match" => 1, nil => 2 }[label]
    end
  
    def paginate(collection, page, per_page = 20)
      page = page.to_i
      page = 1 if page <= 0
      collection.slice((page - 1) * per_page, per_page) || []
    end
  end
  