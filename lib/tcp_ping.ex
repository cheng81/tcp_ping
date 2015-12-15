defmodule TcpPing do
  use GenServer

  def start_link(listen_socket) do
    GenServer.start_link(__MODULE__, %{socket: listen_socket})
  end

  def init(state) do
    GenServer.cast(self(), :accept)
    {:ok, state}
  end

  def handle_cast(:accept, %{socket: socket} = state) do
    {:ok, accept_socket} = :gen_tcp.accept(socket)
    TcpPing.Acceptor.start_client
    {:noreply, %{state | socket: accept_socket}}
  end

  def handle_info({:tcp, _sock, "ping\r\n"}, %{socket: socket} = state) do
    reply(socket, "pong\r\n")
    {:noreply, state}
  end

  def handle_info({:tcp, _sock, msg}, %{socket: socket} = state) do
    IO.inspect msg
    reply(socket, msg)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _}, state) do
    {:stop, :normal, state}
  end

  defp reply(sock, msg) do
    :gen_tcp.send(sock, msg)
    :inet.setopts(sock, active: :once)
    :ok
  end

  # def server() do
  #   port = Application.get_env(:tcp_ping, :port)
  #   {:ok, lsock} = :gen_tcp.listen(port, [:binary, {:active, false}])
  #   {:ok, sock} = :gen_tcp.accept(lsock)
  #   case do_recv(sock) do
  #     {:ok, bin} ->
  #       IO.puts "Server got #{bin}"
  #       :ok = :gen_tcp.send(sock, bin)
  #       :gen_tcp.close(sock)
  #     :closed ->
  #       :ok
  #   end
  # end
  #
  # def do_recv(sock) do
  #   case :gen_tcp.recv(sock, 0) do
  #     {:ok, b} -> {:ok, b}
  #     {:error, :closed} -> :closed
  #   end
  # end
end
