require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles (index)" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, :published, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, :published, updated_at: 2.days.ago) }
    let!(:article3) { create(:article, :published) }
    let!(:article4) { create(:article, :draft) }

    it "公開状態の記事だけが取得できる" do
      subject
      expect(response.status).to eq 200
      res = JSON.parse(response.body)
      expect(res.length).to eq 3
      expect(res.map {|re| re["id"] }).to eq [article3.id, article1.id, article2.id]
      expect(res.first.keys).to eq ["id", "title", "updated_at", "user"]
      expect(res.first["user"].keys).to eq ["id", "name", "email", "updated_at"]
    end
  end

  describe "GET /articles/:id (show)" do
    subject { get(api_v1_article_path(article_id)) } # ② subject のなかでarticle_id が呼ばれる

    context "指定した公開記事を取得する場合" do
      let(:article_id) { article.id } # ③ article_id は article.id なので article が呼ばれる。
      let(:article) { create(:article, :published) } # ④ article が FactoryBot によってランダムに作られる

      it "公開記事のレコードが取得できる" do
        subject # ① subject が呼ばれる
        res = JSON.parse(response.body)
        expect(response.status).to eq 200 # ステータスコードが 200 であること
        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["updated_at"]).to be_present
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "email", "updated_at"]
      end
    end

    context "指定した下書き記事を取得する場合" do
      let(:article_id) { article.id }
      let(:article) { create(:article, status: "draft") }

      it "エラーする" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end

    context "指定したidの公開記事が存在しないとき" do
      let(:article_id) { 14234 }
      it "記事が見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "POST /articles (create)" do
    subject { post(api_v1_articles_path, params: params, headers: headers) } # createを確認するためのテストと明確

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "公開記事として投稿する場合" do
      let(:params) { { article: attributes_for(:article, :published) } }

      it "公開記事が１つ作成される" do
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(response.status).to eq 200
      end
    end

    context "下書き記事として投稿する場合" do
      let(:params) { { article: attributes_for(:article, :draft) } }

      it "下書き記事が１つ作成される" do
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)
        res = JSON.parse(response.body)
        expect(res["status"]).to eq "draft"
        expect(response.status).to eq 200
      end
    end

    context "enumで定義してない不正なステータスで投稿する場合" do
      let(:params) { { article: attributes_for(:article, status: "dra") } }

      it "記事を更新できない" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe "PATCH(PUT) /articles/:id (update)" do
    subject { patch(api_v1_article_path(article.id), params: params, headers: headers) }

    let(:params) { { article: attributes_for(:article, status: "published") } }
    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "自分の記事のレコードを更新しようとするとき" do
      let!(:article) { create(:article, :draft, user: current_user) }
      it "記事を更新できる" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body]) &
                              change { article.reload.status }.from(article.status).to(params[:article][:status])
        expect(response).to have_http_status(:ok)
      end
    end

    context "他人の記事のレコードを更新する場合" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "記事を更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "DELETE /articles/:id (destroy)" do
    subject { delete(api_v1_article_path(article.id), headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "自分の記事を削除しようとするとき" do
      let!(:article) { create(:article, user: current_user) }

      it "特定の記事のレコードを削除" do
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end

    context "他人の記事を削除しようとするとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "削除できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              change { Article.count }.by(0)
      end
    end
  end
end
