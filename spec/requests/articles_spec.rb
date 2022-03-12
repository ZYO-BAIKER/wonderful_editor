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
      expect(res.first.keys).to eq ["id", "title", "body", "updated_at", "user"]
      expect(res.first["user"].keys).to eq ["id", "name", "updated_at"]
    end
  end

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) } # ② subject のなかでarticle_id が呼ばれる。

    context "指定したidのユーザーが存在する場合" do
      let(:article_id) { article.id } # ③ article_id は article.id なので article が呼ばれる。
      let(:article) { create(:article) } # ④ article が FactoryBot によってランダムに作られる。

      it "特定のユーザーのレコードが取得できる" do
        subject # ① it のなかで subject が呼ばれる。
        res = JSON.parse(response.body)

        expect(response.status).to eq 200 # ステータスコードが 200 であること
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["updated_at"]).to be_present
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "updated_at"]
      end
    end

    context "指定したidのユーザーが存在しないとき" do
      let(:article_id) { 14234 } # ③ article_id 14234 が呼ばれる。
      it "ユーザーが見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
