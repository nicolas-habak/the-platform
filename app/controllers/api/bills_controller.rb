module Api
  class BillsController < BaseController
    def index
      authorize Bill
      bills = policy_scope(Bill)
      render json: bills
    end

    def show
      bill = Bill.find(params[:id])
      authorize bill
      render json: bill
    end

    def create
      authorize Bill
      bill = Bill.new(bill_params)

      if bill.save
        render json: bill, status: :created
      else
        render json: { errors: bill.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      bill = Bill.find(params[:id])
      authorize bill

      if bill.update(bill_params)
        render json: bill, status: :ok
      else
        render json: { errors: bill.errors.full_messages }, status: :unprocessable_entity
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
      params.require(:bill).permit([ :date_issued, :billing_period_start, :billing_period_end ])
    end
  end
end
