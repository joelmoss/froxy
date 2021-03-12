# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'pages#home'
  get 'with_node_modules_css_import', to: 'pages#with_node_modules_css_import'
  get 'with_css_module_import', to: 'pages#with_css_module_import'
  get 'css_with_imports', to: 'pages#css_with_imports'
  get 'nothing_to_side_load', to: 'pages#nothing_to_side_load'
end
