require 'spec_helper'
require 'support/controllers/controller_helpers'

# Matcher that asserts user was denied access.
RSpec::Matchers.define :deny_access do
  match do |controller|
    redirects_to_sign_in?(controller) && sets_flash?(controller)
  end

  def redirects_to_sign_in?(controller)
    expect(controller).to redirect_to(controller.sign_in_url)
  end

  def sets_flash?(controller)
    controller.flash[:notice].match(/sign in to continue/)
  end
end

# A dummy 'secured' controller to test
class DeprecatedMethodsController < ActionController::Base
  include Authenticate::Controller
  before_action :require_authentication, only: :show

  def new
    head :ok
  end

  def show
    head :ok
  end
end

describe DeprecatedMethodsController, type: :controller do
  before do
    Rails.application.routes.draw do
      resource :deprecated_methods, only: [:new, :show]
      get '/sign_in' => 'authenticate/sessions#new', as: 'sign_in'
    end
  end

  after do
    Rails.application.reload_routes!
  end

  context 'with authenticated user' do
    before { sign_in }

    it 'warns but allows access to show' do
      expect { do_get :show }.to output(/deprecated/i).to_stderr
      expect(subject).to_not deny_access
    end

    it 'warns on authenticated?' do
      expect { subject.authenticated? }.to output(/deprecated/i).to_stderr
      expect(subject.authenticated?).to be_truthy
    end
  end
end
