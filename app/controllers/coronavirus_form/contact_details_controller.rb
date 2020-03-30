# frozen_string_literal: true

class CoronavirusForm::ContactDetailsController < ApplicationController
  def submit
    contact_details = {
      "phone_number_calls" => sanitize(params[:phone_number_calls]&.strip).presence,
      "phone_number_texts" => sanitize(params[:phone_number_texts]&.strip).presence,
      "email" => sanitize(params[:email]&.strip).presence,
    }
    session[:contact_details] = contact_details

    invalid_fields = contact_details["email"] ? validate_email_address("email", contact_details["email"]) : []

    if invalid_fields.any?
      flash.now[:validation] = invalid_fields
      log_validation_error(invalid_fields)

      respond_to do |format|
        format.html { render controller_path, status: :unprocessable_entity }
      end
    elsif session["check_answers_seen"]
      redirect_to check_your_answers_url
    else
      redirect_to medical_conditions_url
    end
  end

private

  def previous_path
    support_address_path
  end
end
