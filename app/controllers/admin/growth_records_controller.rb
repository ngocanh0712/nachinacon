# frozen_string_literal: true

module Admin
  class GrowthRecordsController < BaseController
    before_action :set_record, only: %i[edit update destroy]

    def index
      @records = GrowthRecord.recent
    end

    def new
      @record = GrowthRecord.new(recorded_on: Date.today)
    end

    def create
      @record = GrowthRecord.new(record_params)

      if @record.save
        flash[:notice] = 'Đã thêm dữ liệu tăng trưởng!'
        redirect_to admin_growth_records_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @record.update(record_params)
        flash[:notice] = 'Đã cập nhật dữ liệu!'
        redirect_to admin_growth_records_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @record.destroy
      flash[:notice] = 'Đã xóa dữ liệu.'
      redirect_to admin_growth_records_path
    end

    private

    def set_record
      @record = GrowthRecord.find(params[:id])
    end

    def record_params
      params.require(:growth_record).permit(:recorded_on, :height_cm, :weight_kg, :notes)
    end
  end
end
