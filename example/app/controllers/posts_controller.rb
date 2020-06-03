class PostsController < ApplicationController
  before_action :set_post, only: [:show, :update, :destroy]

  include SoberSwag::Controller

  PostCreateParamsBody = SoberSwag.struct do
    sober_name 'PostCreateParamsBody'
    attribute :person_id, SoberSwag::Types::Params::Integer
    attribute :title, SoberSwag::Types::String
    attribute :body, SoberSwag::Types::String
  end

  PostCreate = SoberSwag.struct do
    sober_name 'PostCreate'
    attribute :post, PostCreateParamsBody
  end

  define :get, :index, '/posts/' do
    query_params do
      attribute? :view, SoberSwag::Types::String.enum('base', 'detail')
    end
    response(:ok, 'all the posts', PostBlueprint.array)
  end
  def index
    @posts = Post.all

    respond!(:ok, @posts, { view: parsed_query.view })
  end

  # GET /posts/1
  def show
    render json: @post
  end

  # POST /posts
  def create
    @post = Post.new(post_params)

    if @post.save
      render json: @post, status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  def update
    if @post.update(post_params)
      render json: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    @post.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def post_params
      params.require(:post).permit(:person_id, :title, :body)
    end
end
