module Api
  class ProvidersController < BaseController

    def index
      authorize Provider
      providers = policy_scope(Provider)
      render json: providers
    end

    def show
      provider = Provider.find(params[:id])
      authorize provider
      render json: provider
    end

    def create
      authorize Provider
      provider = Provider.new(provider_params)

      if provider.save
        render json: provider, status: :created
      else
        render json: { errors: provider.errors }, status: :unprocessable_entity
      end
    end

    def update
      provider = Provider.find(params[:id])
      authorize provider

      if provider.update(provider_params)
        render json: provider, status: :ok
      else
        render json: { errors: provider.errors }, status: :unprocessable_entity
      end
    end

    def destroy
      provider = Provider.find(params[:id])
      authorize provider
      provider.destroy
      head :no_content
    end

    private

    def provider_params
      params.require(:provider).permit(:name, :address, :phone)
    end
  end
end
