# encoding: utf-8
# frozen_string_literal: true
module Api
  module V1
    class TimersController < Api::BaseController
      def index
        authorize! :index, Timer
        scope = current_account.timers
        scope = scope.where(date: date) if date
        scope = scope.where(date: date_range) if date_range
        scope = scope.for_project(project_uuid) if project_uuid
        scope = scope.uninvoiced if params[:uninvoiced].present?
        @timers = scope
      end

      def create
        @timer ||= current_user.timers.new timer_params
        authorize! :create, @timer
        if @timer.save
          render status: :created
        else
          Rails.logger.info "Timer Create Failed: #{@timer.errors.full_messages.to_yaml}"
          render json: ValidationError.new("timer.create", @timer.errors), status: :bad_request
        end
      end

      def update
        @timer = current_user.timers.find(params[:id])
        authorize! :update, @timer
        unless @timer.update(timer_params)
          Rails.logger.info "Timer Update Failed: #{@timer.errors.full_messages.to_yaml}"
          render json: ValidationError.new("timer.update", @timer.errors), status: :bad_request
        end
      end

      def stop
        @timer = current_user.timers.find(params[:id])
        authorize! :stop, @timer
        unless @timer.stop
          Rails.logger.info "Timer Stop Failed: #{@timer.to_yaml}"
          render json: { message: I18n.t(:"messages.timer.stop.failure") }, status: :bad_request
        end
      end

      def start
        @timer = current_user.timers.find(params[:id])
        authorize! :start, @timer
        unless @timer.start
          Rails.logger.info "Timer Start Failed: #{@timer.to_yaml}"
          render json: { message: I18n.t(:"messages.timer.start.failure") }, status: :bad_request
        end
      end

      def destroy
        @timer = current_user.timers.find(params[:id])
        authorize! :destroy, @timer
        if @timer.position.blank?
          unless @timer.destroy
            Rails.logger.info "Timer Destroy Failed: #{@timer.errors.full_messages.to_yaml}"
            render json: ValidationError.new("timer.destroy", @timer.errors), status: :bad_request
          end
        else
          Rails.logger.info "Timer Destroy Failed: Timer allready on Invoice"
          render json: { message: I18n.t(:"messages.timer.destroy.failure") }, status: :bad_request
        end
      end

      private def date
        @date ||= params[:date]
      end

      private def date_range
        return if start_date.blank? || end_date.blank?
        @date_range ||= (start_date..end_date)
      end

      private def start_date
        @start_date ||= params[:startDate]
      end

      private def end_date
        @end_date ||= params[:endDate]
      end

      private def project_uuid
        @project_uuid ||= params[:projectUuid]
      end

      private def task
        @task ||= current_account.tasks.find(params.delete(:taskUuid))
      end

      private def timer_params
        @timer_params ||= params.permit(:date, :value, :started, :note).merge(
          task_id: task.id,
          user_id: current_user.id
        )
      end
    end
  end
end
