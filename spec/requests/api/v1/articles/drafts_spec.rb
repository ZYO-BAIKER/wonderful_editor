require "rails_helper"

RSpec.describe "Api::V1::Articles::Drafts", type: :request do
  let!(:current_user) { create(:user) }
  let!(:headers) { current_user.create_new_auth_token }

  describe "GET /articles/drafts (index)" do
    subject { get(api_v1_articles_drafts_path, headers: headers) }

    let!(:article1) { create(:article, :draft, user: current_user) }
    let!(:article2) { create(:article, :draft) }
    let!(:article3) { create(:article, :published, user: current_user) }

    context "自分の下書き記事を閲覧する場合" do
      it "自分が書いた下書き記事が取得できる" do
        subject
        expect(response.status).to eq 200
        res = JSON.parse(response.body)
        expect(res.length).to eq 1
        expect(res.first["id"]).to eq article1.id
        expect(res.first.keys).to eq ["id", "title", "updated_at", "user"]
        expect(res.first["user"].keys).to eq ["id", "name", "email", "updated_at"]
      end
    end
  end

  describe "GET /articles/draft/:id (show)" do
    subject { get(api_v1_articles_draft_path(article_id), headers: headers) }

    let(:article_id) { article.id }

    context "自分の特定の下書き記事を取得する場合" do
      let(:article) { create(:article, :draft, user: current_user) }

      it "選んだ下書き記事のレコードが取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(response.status).to eq 200
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["updated_at"]).to be_present
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "email", "updated_at"]
      end
    end

    context "他人の下書き記事を取得する場合" do
      let(:article) { create(:article, :draft) }

      it "エラーする" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context "指定したidの下書き記事が存在しないとき" do
      let(:article_id) { 14234 }
      it "記事が見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
