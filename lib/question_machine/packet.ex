defmodule QuestionMachine.Packet do
  def process_packet_data(%{"action" => "initialize", "props" => props}) do
    # create a new session and register it

    session_id = UUID.uuid4()

    # might as well store as much as usefully possible into ETS

    data = %{
      session_id: session_id,
      insert_time: System.monotonic_time(),
      past_responses: %{},
      props: props
    }

    :ets.insert(:sessions, {session_id, data})

    %{"status" => "ok", "session" => session_id}
  end

  def process_packet_data(%{"action" => "next_question", "session" => session_id}) do
    # fetches the next question for the session
    [{_, data}] = :ets.lookup(:sessions, session_id)

    next_question = lookup_next_question(data)

    %{
      "status" => "ok",
      "session" => session_id,
      "question" => next_question
    }
  end

  def process_packet_data(%{"action" => "respond", "session" => session_id, "id" => question_id, "response" => response}) do
    # here presumably the question and response would be stored somewhere for further usage.

    [{_, data}] = :ets.lookup(:sessions, session_id)
    answered_questions = Map.keys(data.past_responses) ++ [question_id]
    new_response = Map.merge(%{question_id => response}, data.past_responses)

    old_question = lookup_question(question_id)

    valid_response = response in old_question["responses"]

    if valid_response do
      data = Map.replace(data, :past_responses, new_response)

      # on conflict with :set ETS store type, insert replaces.
      :ets.insert(:sessions, {session_id, data})

      # need to determine whether the session is done or there's more

      allowed_questions = allowed_questions(data.props)
      remaining_questions = allowed_questions -- answered_questions

      case remaining_questions do
        [] ->
          %{
            "status" => "done",
            "session" => session_id,
            "responses" => new_response,
            "props" => data.props
          }

        [next_question_id | _] ->
          next_question = lookup_question(next_question_id)

          %{
            "status" => "ok",
            "session" => session_id,
            "question" => next_question
          }
      end
    else
      %{
        "status" => "error",
        "session" => session_id,
        "error" => "invalid response"
      }
    end
  end

  def process_packet_data(_data) do
    %{"status" => "error", "reason" => "default"}
  end

  defp lookup_next_question(data) do
    answered_questions = Map.keys(data.past_responses)
    allowed_questions = allowed_questions(data.props)
    remaining_questions = allowed_questions -- answered_questions

    [next_question_id | _] = remaining_questions

    lookup_question(next_question_id)
  end

  defp lookup_question(1) do
    %{
      "id" => 1,
      "prompt" => "How did you hear about us?",
      "responses" => [
        "Online Ad",
        "Podcast",
        "From a friend"
      ]
    }
  end

  defp lookup_question(2) do
    %{
      "id" => 2,
      "prompt" => "Why did you purchase this product today?",
      "responses" => [
        "Quality is good",
        "Price is right",
        "This is a gift",
        "Recommended by a freind"
      ]
    }
  end

  defp lookup_question(3) do
    %{
      "id" => 3,
      "prompt" => "What is your favorite podcast?",
      "responses" => [
        "All About Your Brain",
        "True Murders",
        "Space and Time"
      ]
    }
  end

  def allowed_questions(props) do
    products_purchased = Map.get(props, "products_purchased", [])
    country = Map.get(props, "country", nil)
    new_customer = Map.get(props, "new_customer", "false")

    # 1 always
    # 2 if the `"products_purchased"` property of the session includes 1, 5, or 9
    # 3 if the `"country"` session property is `"us"` **OR** the `"new_customer"` property is `"true"`

    # some questions are always allowed
    always_allowed = [1]

    # other questions have conditionals
    # it'd be nicer to programattically store the conditionals

    question_2_products_purchased = [1, 5, 9]

    question_2 =
      if true in Enum.map(question_2_products_purchased, fn x -> x in products_purchased end) do
        [2]
      else
        []
      end

    question_3 =
      if country == "us" or new_customer == "true" do
        [3]
      else
        []
      end

    always_allowed ++ question_2 ++ question_3
  end
end
