module Api::V1
  # base_api_controller を継承
  class ArticlesController < BaseApiController
    def index
      articles = Article.order(updated_at: :desc)
      render json: articles, each_serializer: Api::V1::ArticlePreviewSerializer
    end

    def show
      article = Article.find(params[:id])
      render json: article, serializer: Api::V1::ArticleSerializer
    end

    def create
      article = current_user.articles.create!(article_params)
      # json として値を返す
      render json: article, serializer: Api::V1::ArticleSerializer
    end

    def update
      article = current_user.articles.find(params[:id])
      article.update!(article_params)
      # json として値を返す
      render json: article, serializer: Api::V1::ArticleSerializer
    end

    def destroy
      article = current_user.articles.find(params[:id])
      article.destroy!
    end

    private

      # Only allow a list of trusted parameters through.
      def article_params
        params.permit(:title, :body)
      end
  end
end
