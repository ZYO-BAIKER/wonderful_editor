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

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) } # ② subject のなかでarticle_id が呼ばれる。

    context "指定したidの記事が存在する場合" do
      let(:article_id) { article.id } # ③ article_id は article.id なので article が呼ばれる。
      let(:article) { create(:article) } # ④ article が FactoryBot によってランダムに作られる。

      it "特定の記事のレコードが取得できる" do
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

    context "指定したidの記事が存在しないとき" do
      let(:article_id) { 14234 } # ③ article_id 14234 が呼ばれる。
      it "記事が見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "POST /articles" do
    subject { post(api_v1_articles_path, params: params) } # createを確認するためのテストと明確

    let(:params) { attributes_for(:article) }
    let(:current_user) { create(:user) }

    # stub
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) } # rubocop:disable Spec/AnyInstance

    context "適切なパラメータを送信したとき" do
      it "記事が１つ作成される" do
        expect { subject }.to change { Article.count }.by(1) # APIを叩いた前後で、Aricle.countが1増えることをチェック
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:title]
        expect(res["body"]).to eq params[:body]
        expect(response.status).to eq 200
      end
    end
  end

  describe "PATCH(PUT) /articles/:id" do
    subject { patch(api_v1_article_path(article.id), params: params[:article])}

    let(:params) { { article: { title: Faker::Lorem.word } } }
    let(:current_user) { create(:user) }

    # stub
    before { allow_any_instance_of(Api::V1::BaseApiController).to receive(:current_user).and_return(current_user) } # rubocop:disable Spec/AnyInstance
    context "自分の記事のレコードを更新しようとするとき" do
      let(:article) { create(:article, user: current_user) }
      it "記事を更新できる" do
        expect { subject }.to change {article.reload.title}.from(article.title).to(params[:article][:title])
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

end
