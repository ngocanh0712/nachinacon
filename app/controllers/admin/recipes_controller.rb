# frozen_string_literal: true

module Admin
  class RecipesController < BaseController
    before_action :set_recipe, only: %i[edit update destroy]

    def index
      @recipes = Recipe.ordered
    end

    def new
      @recipe = Recipe.new
    end

    def create
      @recipe = Recipe.new(recipe_params)

      if @recipe.save
        flash[:notice] = 'Công thức nấu ăn đã được tạo thành công!'
        redirect_to admin_recipes_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @recipe.update(recipe_params)
        flash[:notice] = 'Công thức nấu ăn đã được cập nhật!'
        redirect_to admin_recipes_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @recipe.destroy
      flash[:notice] = 'Công thức nấu ăn đã được xoá.'
      redirect_to admin_recipes_path
    end

    private

    def set_recipe
      @recipe = Recipe.find(params[:id])
    end

    def recipe_params
      params.require(:recipe).permit(:title, :content, :category, :source_url, :image_url, :published, :position)
    end
  end
end
