defmodule ReactorSaga.RegisterUser do
  # Here we've defined a Reactor that performs the steps needed
  #  for the user registration example.
  use Reactor

  input(:email)
  input(:password)
  input(:plan_name)

  step :register_user, MyApp.RegisterUserStep do
    argument(:email, input(:email))
    argument(:password, input(:password))
  end

  step :create_stripe_customer, MyApp.CreateStripeCustomerStep do
    argument(:email, input(:email))
  end

  step :find_stripe_plan, MyApp.FindStripePlanStep do
    argument(:plan_name, input(:plan_name))
  end

  step :create_stripe_subscription, MyApp.CreateStripeSubscriptionStep do
    argument :customer_id do
      source(result(:create_stripe_customer))
      transform(& &1.id)
    end

    argument :plan_id do
      source(result(:get_stripe_plan))
      transform(& &1.id)
    end
  end

  step :send_welcome_email, MyApp.SendWelcomeEmailStep do
    argument(:email, input(:email))
    argument(:_subscription, result(:create_stripe_subscription))
  end

  step :track_conversion, MyApp.TrackSalesforceConversionStep do
    argument(:email, input(:email))
    argument(:plan_name, input(:plan_name))
    argument(:_welcome_email, result(:send_welcome_email))
  end

  return(:register_user)
end
