# EnquireLabs Code Project

The EnquireLabs code project is an opportunity for our team to see how you
approach technical problem solving and code writing. It is not meant to be a
comprehensive examination of your programming skills; rather, a small challenge
with enough nuance to offer a glimpse into your thought process, and set a
foundation for broader discussion. After you've completed the project, we will
schedule a follow up conversation to discuss your solution.

## The Project: The Question Machine

The Question Machine is effectively a simplified version of a core feature our
product provides; it uses built-in contextual triggers to present questions to
end users (today, millions of consumers interact with questions we display each
month). You’ll be demonstrating your approach to a customer-facing
problem/solution, and delivering a basis for conversation about what could be
done to expand on the solution.

The Question Machine is a simple server that listens to requests from a client
over a TCP connection to present a series of questions, and subsequently
gather responses to those questions. Which questions are asked depends on the
properties of the client session. The goal of the project is to make the tests
in `test/question_machine_test.exs` pass using the Elixir standard library.

Messages between the clients and the Question Machine server are Erlang terms
encoded as binary. Clients should initialize a session by sending an
`initialize` message with the properties of the session:

```
%{
  "action" => "initialize",
  "props" => %{
    "country" => "us"
  }
}
```

The Question Machine responds with an identifier for the session that the
client uses to make subsequent requests:

```
%{
  "status" => "ok",
  "session" => SOME_SESSION_ID
}
```

The client could then, for example, ask for the next question like so:

```
%{
  "action" => "next_question",
  "session" => SOME_SESSION_ID
}
```

### The Questions

Below is the list of questions, their responses to be presented to the client,
and the conditions for presenting them. Clients must respond to the questions
in the order presented by the Question Machine (e.g. if question 2 is the next
question, they can't answer question 3 before question 2). A question should
only be presented if the properties of the session match the conditions of the
question. The Question Machine should only accept a response that is found in
the responses list.

#### 1: How did you hear about us?

- Online Ad
- Podcast
- From a friend

*conditions:* this question is always presented

#### 2: Why did you purchase this product today?

- Quality is great
- Price is right
- This is a gift
- Recommended by a friend

*conditions:* this question is presented if the `"products_purchased"`
property of the session includes 1, 5, or 9

#### 3: What is your favorite podcast?

- All About Your Brain
- True Murders
- Space and Time

*conditions:* this question is presented if the `"country"` session property
is `"us"` **OR** the `"new_customer"` property is `"true"`

### The Tests

The tests are found in `test/question_machine_test.exs` and can be run with
the standard `mix` task: `mix test`.

### Submitting Your Solution

Fork this repository and implement your solution. Then, add `chasselschwert`
as a `read-only` collaborator to your fork, and email `curt@enquirelabs.com`
to let us know it’s ready for review.

We hope you find this project interesting and look forward to discussing
your solution!

– EnquireLabs
