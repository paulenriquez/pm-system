Rails.application.routes.draw do
  devise_for :users
  scope '/admin' do
    resources :users, controller: :admin_account_manager, except: [:show]
  end

  root to: 'inventory_and_sales#index'
  
  get '/dashboard', to: 'pages#dashboard', as: :dashboard

  resources :products
  resources :fuel, controller: 'products', type: 'Fuel', as: :fuels
  resources :non_fuel, controller: 'products', type: 'NonFuel', as: :non_fuels

  resources :price_updates
  resources :pump_nozzles, except: [:edit]
  resources :tanks, except: [:edit]

  scope '/inventory_and_sales' do
    scope '/async_partials' do
      get :async_overall_daily_summary, controller: :inventory_and_sales, as: :async_overall_daily_summary
      get :async_fuel_daily_summary, controller: :inventory_and_sales, as: :async_fuel_daily_summary
    end
  end
  resources :inventory_and_sales, only: [:index]

  scope '/forecasts' do
    scope '/async_partials' do
      get :async_fuel_forecasts, controller: :forecasts, as: :async_fuel_forecasts
    end
  end
  resources :forecasts, only: [:index]

  scope '/shift_inventory_updates' do
    get :load_form, controller: :shift_inventory_updates, as: :load_shift_inventory_update_form
    get :load_view, controller: :shift_inventory_updates, as: :load_shift_inventory_update_view
    
    scope '/async_partials' do
      get :async_shift_summary, controller: :shift_inventory_updates, as: :async_shift_summary
      get :async_fuel_summary, controller: :shift_inventory_updates, as: :async_fuel_summary
    end
  end
  resources :shift_inventory_updates, except: [:new, :create]

  scope '/charts' do
    get :fuel_volume_by_day, controller: :charts, as: :fuel_volume_by_day_chart
    get :day_fuel_volume_breakdown, controller: :charts, as: :day_fuel_volume_breakdown_chart
    get :fuel_volume_by_shift, controller: :charts, as: :fuel_volume_by_shift_chart
    get :shift_fuel_volume_breakdown, controller: :charts, as: :shift_fuel_volume_breakdown_chart
  end

  scope '/api' do
    scope '/tanks' do
      get '/next_alias', to: 'tanks#api_get_next_alias'
    end
  end
end