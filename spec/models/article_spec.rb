# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text             not null
#  status     :string           default("draft"), not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_articles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Article, type: :model do
  describe "正常系" do
    context "必要な情報が揃っている場合" do
      let(:article_draft) { build(:article, :draft) }
      let(:article_published) { build(:article, :published) }

      it "下書きが保存できる" do
        expect(article_draft).to be_valid
        expect(article_draft.status).to eq "draft"
      end

      it "記事が投稿できる(公開記事として保存される)" do
        expect(article_published).to be_valid
        expect(article_published.status).to eq "published"
      end
    end
  end

  describe "異常系" do
    context "bodyのみ入力している場合" do
      let(:article) { build(:article, title: nil) }

      it "エラーが発生する" do
        expect(article).not_to be_valid
        expect(article.status).to eq "draft"
      end
    end

    context "title がない場合" do
      let(:article) { build(:article, body: nil) }

      it "エラーが発生する" do
        expect(article).not_to be_valid
        expect(article.status).to eq "draft"
      end
    end
  end
end
