defmodule QuestionMachine.Server do
  use GenServer
  require Logger
  alias QuestionMachine.ClientHandler
  import QuestionMachine.Packet

  def start_link(_) do
    host = Application.get_env(:server, :ip, "127.0.0.1")
    port = Application.get_env(:server, :port, 8888)
    GenServer.start_link(__MODULE__, [host, port], [])
  end

  def init(state) do
    # the session table will allow keeping track of question sessions
    :ets.new(:sessions, [:set, :public, :named_table, read_concurrency: true])

    # firing off into a continue in order to keep the listen from blocking startup
    {:ok, state, {:continue, :start}}
  end

  def handle_continue(:start, [_listen_host, listen_port]) do
    # https://www.erlang.org/doc/man/gen_tcp.html

    listen_options = [:binary, {:packet, 0}, {:active, true}]
    {:ok, listen_socket} = :gen_tcp.listen(listen_port, listen_options)
    loop_acceptor(listen_socket)
  end

  defp loop_acceptor(listen_socket) do
    # this recurses over and over to build a child to handle the new connection.

    {:ok, socket} = :gen_tcp.accept(listen_socket)
    {:ok, pid} = DynamicSupervisor.start_child(QuestionMachine.ClientSupervisor, {ClientHandler, socket})
    :gen_tcp.controlling_process(socket, pid)
    loop_acceptor(listen_socket)
  end

  def handle_info({:tcp, socket, packet}, state) do
    data = :erlang.binary_to_term(packet)

    message = process_packet_data(data)
    response = :erlang.term_to_binary(message)

    :gen_tcp.send(socket, response)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    Logger.info("connection closed")
    {:noreply, state}
  end

  def handle_info({:tcp_error, _socket, reason}, state) do
    Logger.error("connection closed. reason: #{reason}")
    {:noreply, state}
  end
end
