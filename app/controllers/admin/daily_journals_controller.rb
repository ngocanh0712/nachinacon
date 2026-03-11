# frozen_string_literal: true

module Admin
  class DailyJournalsController < BaseController
    before_action :set_daily_journal, only: %i[edit update destroy]

    def index
      @daily_journals = DailyJournal.ordered
    end

    def new
      @daily_journal = DailyJournal.new(date: Date.today)
    end

    def create
      @daily_journal = DailyJournal.new(daily_journal_params)

      if @daily_journal.save
        flash[:notice] = 'Nhật ký đã được tạo thành công!'
        redirect_to admin_daily_journals_path
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @daily_journal.update(daily_journal_params)
        flash[:notice] = 'Nhật ký đã được cập nhật!'
        redirect_to admin_daily_journals_path
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @daily_journal.destroy
      flash[:notice] = 'Nhật ký đã được xoá.'
      redirect_to admin_daily_journals_path
    end

    private

    def set_daily_journal
      @daily_journal = DailyJournal.find(params[:id])
    end

    def daily_journal_params
      params.require(:daily_journal).permit(:date, :mood, :sleep_hours, :eat_note, :activity_note, :note)
    end
  end
end
