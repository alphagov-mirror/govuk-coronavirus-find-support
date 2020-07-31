RSpec.describe "start" do
  describe "GET /start" do
    it "redirects to the first question" do
      get start_path
      expect(response).to redirect_to need_help_with_path
    end

    it "preserves query parameters" do
      get start_path, params: { foo: "123" }

      expect(response).to redirect_to need_help_with_path(foo: "123")
    end
  end
end
