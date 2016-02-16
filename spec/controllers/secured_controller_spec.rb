require 'spec_helper'


# Matcher that asserts user was denied access.
RSpec::Matchers.define :deny_access do
  match do |controller|
    redirects_to_sign_in?(controller) && sets_flash?(controller)
  end
  def redirects_to_sign_in? controller
    expect(controller).to redirect_to(controller.sign_in_url)
  end
  def sets_flash? controller
    controller.flash[:notice].match /sign in to continue/
  end
end


class SecuredAppsController < ActionController::Base
  include Authenticate::Controller

  before_action :require_authentication, only: :show

  def new
    head :ok
  end

  def show
    head :ok
  end
end


describe SecuredAppsController, type: :controller do
  before do
    Rails.application.routes.draw do
      resource :secured_app, only: [:new, :show]
      get '/sign_in' => 'authenticate/sessions#new', as: 'sign_in'
    end
  end

  after do
    Rails.application.reload_routes!
  end

  context 'with authenticated user' do
    before { sign_in }

    it 'allows access to new' do
      get :new
      expect(subject).to_not deny_access
    end

    it 'allows access to show' do
      get :show
      expect(subject).to_not deny_access
    end
  end

  context 'with an unauthenticated visitor' do
    it 'allows access to new' do
      get :new
      expect(subject).to_not deny_access
    end

    it 'denies access to show' do
      get :show
      expect(subject).to deny_access
    end
  end
end
