defmodule TcpPing.Acceptor do
  use Supervisor

  def start_client do
    Supervisor.start_child(__MODULE__, [])
  end

  def start_link(port) do
    Supervisor.start_link(__MODULE__, [port: port], [name: __MODULE__])
  end

  def init([port: port]) do
    {:ok, lsock} = :gen_tcp.listen(port, [:binary, {:active, :once}])
    workers = [
      worker(TcpPing, [lsock])
    ]

    supervise(workers, [strategy: :simple_one_for_one])
  end
end
