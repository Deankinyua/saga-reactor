defmodule ReactorSaga.CreateStripeSubscriptionStep do
  use Reactor.Step

  @impl true
  def run(arguments, context, options) do
    # IO.puts "subscription created"
    Stripe.Subscription.create(arguments.stripe_customer_id,
      items: [plan: arguments.stripe_plan_id]
    )
  end

  @impl true
  def compensate(%{code: :network_error}, arguments, context, options) do
    :retry
  end

  def compensate(error, arguments, context, options) do
    :ok
  end

  # *Lastly, we define undo/4 to delete the subscription if the Reactor asks us to undo our
  # * work - which it will do if a step later in the workflow fails.

  @impl true
  def undo(subscription, arguments, context, options) do
    case Stripe.Subscription.delete(subscription) do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
