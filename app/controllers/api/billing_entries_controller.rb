module Api
  class BillingEntriesController < BaseController
    def index
      authorize BillingEntry
      billing_entries = policy_scope(BillingEntry)
      render json: billing_entries
    end

    def show
      billing_entry = BillingEntry.find(params[:id])
      authorize billing_entry
      render json: billing_entry
    end

    def create
      authorize BillingEntry
      billing_entry = BillingEntry.new(bill_params)

      if billing_entry.save
        render json: billing_entry, status: :created
      else
        render json: { errors: billing_entry.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      billing_entry = BillingEntry.find(params[:id])
      authorize billing_entry

      if billing_entry.update(bill_params)
        render json: billing_entry, status: :ok
      else
        render json: { errors: billing_entry.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      provider = Provider.find(params[:id])
      authorize provider
      provider.destroy
      head :no_content
    end

    private

    def bill_params
      params.require(:billing_entry).permit([ :date_issued, :billing_period_start, :billing_period_end ])
    end
  end
end
