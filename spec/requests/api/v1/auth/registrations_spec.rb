require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST /api/v1/auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "適切なパラメーターを送信したとき" do
      let(:params) { attributes_for(:user) }

      it "ユーザーのレコードが1つ作成される" do
        expect { subject }.to change { User.count }.by(1)
        res = JSON.parse(response.body)["data"]
        expect(res["name"]).to eq params[:name]
        expect(res["email"]).to eq params[:email]
        expect(response.status).to eq 200
      end

      it "header 情報を取得することができる" do
        subject
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["expiry"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["token-type"]).to be_present
      end
    end

    context "nameが無い" do
      let(:params) { attributes_for(:user, name: nil) }

      it "エラーする" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(res["errors"]["name"]).to include "can't be blank"
      end
    end

    context "emailが無い" do
      let(:params) { attributes_for(:user, email: nil) }

      it "エラーする" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(res["errors"]["email"]).to include "can't be blank"
      end
    end

    context "passwordが無い" do
      let(:params) { attributes_for(:user, password: nil) }

      it "エラーする" do
        expect { subject }.to change { User.count }.by(0)
        res = JSON.parse(response.body)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(res["errors"]["password"]).to include "can't be blank"
      end
    end
  end
end
