require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) } # indexを確認するためのテストと明確

    let!(:article1) { create(:article, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, updated_at: 2.days.ago) }
    let!(:article3) { create(:article) }

    it "記事の一覧が取得できる" do
      subject # indexを確認するためのテストと明確
      res = JSON.parse(response.body) # requests specでAPIを叩いた後に返ってくる結果（response）をJSONに変換することで、結果がArrayで受け取れる
      expect(res.length).to eq 3
      expect(response.status).to eq 200
      expect(res.map {|re| re["id"] }).to eq [article3.id, article1.id, article2.id]
      expect(res.first.keys).to eq ["id", "title", "updated_at", "user"]
      expect(res.first["user"].keys).to eq ["id", "name", "updated_at"]
    end
  end
end
