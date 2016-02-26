require 'spec_helper'
require 'support/controllers/controller_helpers'

describe Authenticate::UsersController, type: :controller do
  it { is_expected.to be_a Authenticate::Controller }

  describe 'get to #new' do
    context 'not signed in' do
      it 'renders form' do
        get :new
        expect(response).to be_success
        expect(response).to render_template(:new)
      end
      it 'defaults email field to the value provided in the query string' do
        get :new, user: { email: 'dude@example.com' }
        expect(assigns(:user).email).to eq 'dude@example.com'
        expect(response).to be_success
        expect(response).to render_template(:new)
      end
    end
    context 'signed in' do
      it 'redirects user to the redirect_url' do
        sign_in
        get :new
        expect(response).to redirect_to Authenticate.configuration.redirect_url
      end
    end
  end
  describe 'post to #create' do
    context 'not signed in' do
      context 'with valid attributes' do
        let(:user_attributes) { attributes_for(:user) }
        subject { post :create, user: user_attributes }

        it 'creates user' do
          expect{ subject }.to change{ User.count }.by(1)
        end

        it 'assigned user' do
          subject
          expect(assigns(:user)).to be_present
        end

        it 'redirects to the redirect_url' do
          subject
          expect(response).to redirect_to Authenticate.configuration.redirect_url
        end
      end

      context 'with valid attributes and a session return cookie' do
        before do
          @request.cookies[:authenticate_return_to] = '/url_in_the_session'
        end
        let(:user_attributes) { attributes_for(:user) }
        subject { post :create, user: user_attributes }

        it 'creates user' do
          expect{ subject }.to change{ User.count }.by(1)
        end

        it 'assigned user' do
          subject
          expect(assigns(:user)).to be_present
        end

        it 'redirects to the redirect_url' do
          subject
          expect(response).to redirect_to '/url_in_the_session'
        end
      end

    end
    context 'signed in' do
      it 'redirects to redirect_url' do
        sign_in
        post :create, user: {}
        expect(response).to redirect_to Authenticate.configuration.redirect_url
      end
    end
  end

end
