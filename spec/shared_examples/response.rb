# spec/support/shared_examples/unauthorized_response.rb (or anywhere in your spec)
RSpec.shared_examples "an unauthorized response" do
  it "returns unauthorized" do
    expect(response).to have_http_status(:unauthorized)
    response_body = JSON.parse(response.body)
    expect(response_body).to include('error' => 'Unauthorized')
  end
end
