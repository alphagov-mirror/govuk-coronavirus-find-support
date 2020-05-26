locale_data_fixture = {
  "group_one" => {
    "subgroup_one" => {
      "items" => [
        {
          "id" => "0001",
          "text" => "This is a row that only has text, it will appear like a paragraph",
        },
        {
          "href" => "http://test.stubbed.gov.uk",
          "id" => "0002",
          "text" => "This is a row has text and an href, it will appear as an anchor tag",
        },
        {
          "href" => "http://test.stubbed.llyw.cymru",
          "id" => "0003",
          "show_to_nations" => %w[
            Wales
          ],
          "text" => "This is a row has text, an href and group criteria, it will appear as an anchor tag if the user's answers match the criteria",
        },
      ],
      "support_and_advice" => [
        {
          "href" => "http://test.stubbed.gb.gov.uk",
          "id" => "0004",
          "show_to_nations" => %w[
            Wales
            Scotland
            England
          ],
          "text" => "This is a row has text, an href and multiple group criteria, it will appear as an anchor tag if the user's answers match the more complex criteria",
        },
      ],
    },
    "subgroup_two" => {
      "items" => [
        {
          "id" => "0005",
          "text" => "This is a row that only has text, it will appear like a paragraph",
        },
      ],
    },
  },
  "group_two" => {
    "subgroup_one" => {
      "items" => [
        {
          "id" => "0006",
          "text" => "This is a row that only has text, it will appear like a paragraph",
          "show_to_vulnerable_person" => true,
        },
      ],
    },
  },
}

RSpec.describe "ContentImporter" do
  describe "#import_results_links" do
    let(:test_csv_path) { Rails.root.join("spec/fixtures/result_links_test.csv").to_s }
    let(:output_locale) { ContentImporter.import_results_links(test_csv_path) }

    it "outputs result links nested under the correct groups" do
      expect(output_locale.keys).to eql(locale_data_fixture.keys)
    end

    it "outputs results links nested under the correct subgroups" do
      output_subgroups = output_locale.keys.map { |group_key| output_locale[group_key].keys }
      expected_subgroups = locale_data_fixture.keys.map { |group_key| locale_data_fixture[group_key].keys }

      expect(output_subgroups).to eql(expected_subgroups)
    end

    it "outputs text only items with id and text key value pairs" do
      output_item = output_locale["group_one"]["subgroup_one"]["items"].first
      expected_item = locale_data_fixture["group_one"]["subgroup_one"]["items"].first
      expect(output_item.keys).to match_array(%w[id text])
      expect(output_item.values).to eql(expected_item.values)
    end

    it "outputs hyperlink text with id, href and text key value pairs" do
      output_item = output_locale["group_one"]["subgroup_one"]["items"][1]
      expected_item = locale_data_fixture["group_one"]["subgroup_one"]["items"][1]
      expect(output_item.keys).to match_array(%w[id text href])
      expect(output_item.values).to match_array(expected_item.values)
    end

    it "outputs conditional hyperlink text with id, href, text key, national criteria value pairs" do
      output_item = output_locale["group_one"]["subgroup_one"]["items"][2]
      expect(output_item.keys).to match_array(%w[id text href show_to_nations])
      expect(output_item["show_to_nations"]).to match_array(%w[Wales])
    end

    it "outputs support and advice link as a sibling of items" do
      output_item = output_locale["group_one"]["subgroup_one"]
      expected_item = locale_data_fixture["group_one"]["subgroup_one"]
      expect(output_item.keys).to match_array(%w[items support_and_advice])
      expect(output_item["support_and_advice"]).to match_array(expected_item["support_and_advice"])
    end

    it "outputs multiple OR conditional hyperlink text with id, href, text key, national criteria value pairs" do
      output_item = output_locale["group_one"]["subgroup_one"]["support_and_advice"].first
      expect(output_item.keys).to match_array(%w[id text href show_to_nations])
      expect(output_item["show_to_nations"]).to match_array(%w[Wales Scotland England])
    end

    it "outputs a show_to_vulnerable_person true toggle if true in csv" do
      output_item = output_locale["group_two"]["subgroup_one"]["items"].first
      expect(output_item["show_to_vulnerable_person"]).to be(true)
    end

    it "should prune show_to_vulnerable_person keys that are empty" do
      output_item = output_locale["group_one"]["subgroup_two"]["items"].first
      expect(output_item["show_to_vulnerable_person"]).to be(nil)
    end
  end
end
