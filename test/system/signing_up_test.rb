# frozen_string_literal: true

require 'application_system_test_case'

class SigningUpTest < ApplicationSystemTestCase
  test 'signing up' do
    visit root_url
    click_link 'sign up'
    fill_in 'Email', with: 'user@example.com'
    fill_in 'Password', with: 'Secret1*3*5*'
    fill_in 'Password confirmation', with: 'Secret1*3*5*'
    click_button 'Sign up'

    assert_text 'Welcome! You have signed up successfully'

    visit verify_email_url
    assert_text 'Thank you for verifying your email address'
  end

  private

  def verify_email_url
    mail = ActionMailer::Base.deliveries.last
    verify_email_url = /"(?<url>http.*email_verification.*)"/.match(mail.to_s).named_captures['url']
    verify_email_url.gsub('http://example.com/', root_url)
  end
end
