# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'pages#home'
  get 'nothing_to_side_load', to: 'pages#nothing_to_side_load'
end
