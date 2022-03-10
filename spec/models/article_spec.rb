# == Schema Information
#
# Table name: articles
#
#  id         :bigint           not null, primary key
#  body       :text
#  title      :string
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
  context "必要な情報が揃っている場合" do
    let(:article) { build(:article) }

    it "記事が投稿できる" do
      expect(article).to be_valid
    end
  end

  context "bodyのみ入力している場合" do
    let(:article) { build(:article, title: nil) }

    it "エラーが発生する" do
      expect(article).not_to be_valid
    end
  end

  context "title がない場合" do
    let(:article) { build(:article, body: nil) }

    it "エラーが発生する" do
      expect(article).not_to be_valid
    end
  end
end
