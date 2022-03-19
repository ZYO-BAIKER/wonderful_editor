require "rails_helper"

RSpec.describe "Api::V1::Auth::Sessions", type: :request do
  describe "POST /api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }
    let!(:user) { create(:user) }

    context "登録済のuser情報でログインする場合" do
      let(:params) { attributes_for(:user, email: user.email, password: user.password) }

      it "ログインする" do
        subject
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["token-type"]).to be_present
        expect(response.status).to eq 200
      end
    end

    context "emailが違う" do
      let(:params) { attributes_for(:user, email: "hh1", password: user.password) }

      it "ログインできない" do
        subject
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "Invalid login credentials. Please try again."

        header = response.header
        expect(response).to have_http_status(:unauthorized)
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(header["uid"]).to be_blank
        expect(header["token-type"]).to be_blank
      end
    end

    context "passwordが無い" do
      let(:params) { attributes_for(:user, email: user.email, password: nil) }

      it "ログインできない" do
        subject
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "Invalid login credentials. Please try again."

        header = response.header
        expect(response).to have_http_status(:unauthorized)
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(header["uid"]).to be_blank
        expect(header["token-type"]).to be_blank
      end
    end
  end

  describe "DELETE /api/v1/auth/sign_out" do
    subject { delete(destroy_api_v1_user_session_path, params: headers) }
    let(:user) { create(:user) }

    context "適切なパラメーターを送信したとき" do
      let(:headers) { user.create_new_auth_token }

      it "ログアウトできる" do
        subject
        expect(headers["access-token"]).to be_present
        expect(headers["token-type"]).to be_present
        expect(headers["client"]).to be_present
        expect(headers["expiry"]).to be_present
        expect(headers["uid"]).to be_present
      end
    end

    context "不適切なパラメーターを送信したとき" do
      let(:headers) { { "access-token" => "faf", "token-type" => "tere", "client" => "faaaed", "expiry" => "gea", "uid" => "erw" } }

      it "ログアウトできない" do
        subject
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "User was not found or was not logged in."
        expect(response.status).to eq 404
      end
    end
  end
end
