defmodule QuestionMachine.ClientHandler do
  use GenServer
  require Logger
  import QuestionMachine.Packet

  def start_link(socket, opts \\ []) do
    Logger.debug("new connection")
    GenServer.start_link(__MODULE__, socket, opts)
  end

  def init(socket) do
    {:ok, %{socket: socket}}
  end

  def send(pid, data) do
    GenServer.cast(pid, {:send, data})
  end

  def handle_info({:tcp, socket, packet}, state) do
    # process the incoming data and then send a response
    response =
      packet
      |> :erlang.binary_to_term()
      |> process_packet_data()
      |> :erlang.term_to_binary()

    :gen_tcp.send(socket, response)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, _state) do
    Process.exit(self(), :normal)
  end
end
