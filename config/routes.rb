# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :reservations, only: [:create]
  put 'payments/:id/charge', to: 'payments#charge', as: 'charge'
  put 'payments/:id/refund', to: 'payments#refund', as: 'refund'
end
