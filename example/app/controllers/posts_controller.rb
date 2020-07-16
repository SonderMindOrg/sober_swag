##
# Example controller for posts.
class PostsController < ApplicationController
  before_action :set_post, only: %i[show update destroy]

  include SoberSwag::Controller

  PostCreateParamsBody = SoberSwag.input_object do
    identifier 'PostCreateParamsBody'
    attribute :person_id, SoberSwag::Types::Params::Integer.meta(description: 'Unique ID obtained from a person')
    attribute :title, SoberSwag::Types::String.meta(description: 'Short title of a post')
    attribute :body, SoberSwag::Types::String.meta(description: 'Post body in markdown format')
  end

  PostCreate = SoberSwag.input_object do
    identifier 'PostCreate'
    attribute :post, PostCreateParamsBody
  end

  PostUpdateParamsBody = SoberSwag.input_object do
    identifier 'PostUpdateParamsBody'
    attribute? :person_id, SoberSwag::Types::Params::Integer
    attribute? :title, SoberSwag::Types::String
    attribute? :body, SoberSwag::Types::String
  end

  PostUpdate = SoberSwag.input_object do
    identifier 'PostUpdate'
    attribute :post, PostUpdateParamsBody
  end

  ViewTypes = SoberSwag::Types::String.enum('base', 'detail')

  ShowPath = SoberSwag.input_object do
    identifier 'ShowPersonPathParams'
    attribute :id, Types::Params::Integer
  end

  define :get, :index, '/posts/' do
    query_params do
      attribute? :view, ViewTypes
    end
    response(:ok, 'all the posts', PostOutputObject.array)
  end
  def index
    @posts = Post.all

    respond!(:ok, @posts.includes(:person), serializer_opts: { view: parsed_query.view })
  end

  define :get, :show, '/posts/{id}' do
    path_params(ShowPath)
    query_params { attribute? :view, ViewTypes }
    response(:ok, 'the requested post', PostOutputObject)
  end
  def show
    respond!(:ok, @post, serializer_opts: { view: parsed_query.view })
  end

  define :post, :create, '/posts/' do
    request_body(PostCreate)
    response(:created, 'the created post', PostOutputObject)
  end
  def create
    @post = Post.new(parsed_body.post.to_h)

    if @post.save
      respond! :created, @post, rails_opts: { location: @post }
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  define :patch, :update, '/posts/{id}' do
    path_params(ShowPath)
    request_body(PostUpdate)
    response(:ok, 'the post updated', PostOutputObject.view(:base))
  end
  def update
    if @post.update(parsed_body.post.to_h)
      respond!(:ok, @post)
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  define :delete, :destroy, '/posts/{id}' do
    path_params(ShowPath)
    response(:ok, 'the post deleted', PostOutputObject.view(:base))
  end
  def destroy
    @post.destroy
    respond!(:ok, @post)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(parsed_path.id)
  end
end
