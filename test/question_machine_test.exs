defmodule QuestionMachineTest do
  use ExUnit.Case, async: true

  @host String.to_charlist("127.0.0.1")
  @port 8888

  setup do
    {:ok, socket: create_socket()}
  end

  test "only shows first question if no props match", %{socket: socket} do
    reply =
      send_message(socket, %{
        "action" => "initialize",
        "props" => %{}
      })

    %{"status" => "ok", "session" => session} = reply

    reply =
      send_message(socket, %{
        "action" => "next_question",
        "session" => session
      })

    assert reply == %{
             "status" => "ok",
             "session" => session,
             "question" => %{
               "id" => 1,
               "prompt" => "How did you hear about us?",
               "responses" => [
                 "Online Ad",
                 "Podcast",
                 "From a friend"
               ]
             }
           }

    reply =
      send_message(socket, %{
        "action" => "respond",
        "session" => session,
        "id" => 1,
        "response" => "Online Ad"
      })

    assert reply == %{
             "status" => "done",
             "session" => session,
             "props" => %{},
             "responses" => %{
               1 => "Online Ad"
             }
           }
  end

  test "shows first and second question if products_purchased includes 1, 5, or 9", %{
    socket: socket
  } do
    reply =
      send_message(socket, %{
        "action" => "initialize",
        "props" => %{
          "products_purchased" => [3, 5]
        }
      })

    %{"status" => "ok", "session" => session} = reply

    reply =
      send_message(socket, %{
        "action" => "next_question",
        "session" => session
      })

    assert reply == %{
             "status" => "ok",
             "session" => session,
             "question" => %{
               "id" => 1,
               "prompt" => "How did you hear about us?",
               "responses" => [
                 "Online Ad",
                 "Podcast",
                 "From a friend"
               ]
             }
           }

    reply =
      send_message(socket, %{
        "action" => "respond",
        "session" => session,
        "id" => 1,
        "response" => "Online Ad"
      })

    assert reply == %{
             "status" => "ok",
             "session" => session,
             "question" => %{
               "id" => 2,
               "prompt" => "Why did you purchase this product today?",
               "responses" => [
                 "Quality is good",
                 "Price is right",
                 "This is a gift",
                 "Recommended by a freind"
               ]
             }
           }

    response =
      send_message(socket, %{
        "action" => "respond",
        "session" => session,
        "id" => 2,
        "response" => "This is a gift"
      })

    assert response == %{
             "status" => "done",
             "session" => session,
             "props" => %{
               "products_purchased" => [3, 5]
             },
             "responses" => %{
               1 => "Online Ad",
               2 => "This is a gift"
             }
           }
  end

  test "shows first and third question if country is us", %{socket: socket} do
    reply =
      send_message(socket, %{
        "action" => "initialize",
        "props" => %{
          "country" => "us"
        }
      })

    %{"status" => "ok", "session" => session} = reply

    response =
      send_message(socket, %{
        "action" => "next_question",
        "session" => session
      })

    assert response == %{
             "status" => "ok",
             "session" => session,
             "question" => %{
               "id" => 1,
               "prompt" => "How did you hear about us?",
               "responses" => [
                 "Online Ad",
                 "Podcast",
                 "From a friend"
               ]
             }
           }

    response =
      send_message(socket, %{
        "action" => "respond",
        "session" => session,
        "id" => 1,
        "response" => "Online Ad"
      })

    assert response == %{
             "status" => "ok",
             "session" => session,
             "question" => %{
               "id" => 3,
               "prompt" => "What is your favorite podcast?",
               "responses" => [
                 "All About Your Brain",
                 "True Murders",
                 "Space and Time"
               ]
             }
           }

    response =
      send_message(socket, %{
        "action" => "respond",
        "session" => session,
        "id" => 3,
        "response" => "True Murders"
      })

    assert response == %{
             "status" => "done",
             "session" => session,
             "props" => %{
               "country" => "us"
             },
             "responses" => %{
               1 => "Online Ad",
               3 => "True Murders"
             }
           }
  end

  test "shows first and third question if new_customer is true", %{socket: socket} do
    reply =
      send_message(socket, %{
        "action" => "initialize",
        "props" => %{
          "new_customer" => "true"
        }
      })

    %{"status" => "ok", "session" => session} = reply

    response =
      send_message(socket, %{
        "action" => "next_question",
        "session" => session
      })

    assert response == %{
             "status" => "ok",
             "session" => session,
             "question" => %{
               "id" => 1,
               "prompt" => "How did you hear about us?",
               "responses" => [
                 "Online Ad",
                 "Podcast",
                 "From a friend"
               ]
             }
           }

    response =
      send_message(socket, %{
        "action" => "respond",
        "session" => session,
        "id" => 1,
        "response" => "Online Ad"
      })

    assert response == %{
             "status" => "ok",
             "session" => session,
             "question" => %{
               "id" => 3,
               "prompt" => "What is your favorite podcast?",
               "responses" => [
                 "All About Your Brain",
                 "True Murders",
                 "Space and Time"
               ]
             }
           }

    response =
      send_message(socket, %{
        "action" => "respond",
        "session" => session,
        "id" => 3,
        "response" => "True Murders"
      })

    assert response == %{
             "status" => "done",
             "session" => session,
             "props" => %{
               "new_customer" => "true"
             },
             "responses" => %{
               1 => "Online Ad",
               3 => "True Murders"
             }
           }
  end

  test "does not allow an invalid response", %{socket: socket} do
    reply =
      send_message(socket, %{
        "action" => "initialize",
        "props" => %{}
      })

    %{"status" => "ok", "session" => session} = reply

    response =
      send_message(socket, %{
        "action" => "next_question",
        "session" => session
      })

    assert response == %{
             "status" => "ok",
             "session" => session,
             "question" => %{
               "id" => 1,
               "prompt" => "How did you hear about us?",
               "responses" => [
                 "Online Ad",
                 "Podcast",
                 "From a friend"
               ]
             }
           }

    response =
      send_message(socket, %{
        "action" => "respond",
        "session" => session,
        "id" => 1,
        "response" => "Something Else"
      })

    assert response == %{
             "status" => "error",
             "session" => session,
             "error" => "invalid response"
           }
  end

  test "can resume session", %{socket: socket} do
    reply =
      send_message(socket, %{
        "action" => "initialize",
        "props" => %{
          "new_customer" => "true"
        }
      })

    %{"status" => "ok", "session" => session} = reply

    response =
      send_message(socket, %{
        "action" => "next_question",
        "session" => session
      })

    assert response == %{
             "status" => "ok",
             "session" => session,
             "question" => %{
               "id" => 1,
               "prompt" => "How did you hear about us?",
               "responses" => [
                 "Online Ad",
                 "Podcast",
                 "From a friend"
               ]
             }
           }

    response =
      send_message(socket, %{
        "action" => "respond",
        "session" => session,
        "id" => 1,
        "response" => "Online Ad"
      })

    assert response == %{
             "status" => "ok",
             "session" => session,
             "question" => %{
               "id" => 3,
               "prompt" => "What is your favorite podcast?",
               "responses" => [
                 "All About Your Brain",
                 "True Murders",
                 "Space and Time"
               ]
             }
           }

    :gen_tcp.close(socket)

    new_socket = create_socket()

    response =
      send_message(new_socket, %{
        "action" => "next_question",
        "session" => session
      })

    assert response == %{
             "status" => "ok",
             "session" => session,
             "question" => %{
               "id" => 3,
               "prompt" => "What is your favorite podcast?",
               "responses" => [
                 "All About Your Brain",
                 "True Murders",
                 "Space and Time"
               ]
             }
           }
  end

  defp send_message(socket, message) do
    :ok = :gen_tcp.send(socket, :erlang.term_to_binary(message))
    {:ok, reply} = :gen_tcp.recv(socket, 0, 1000)

    :erlang.binary_to_term(reply)
  end

  defp create_socket do
    {:ok, socket} = :gen_tcp.connect(@host, @port, [:binary, active: false])
    socket
  end
end
