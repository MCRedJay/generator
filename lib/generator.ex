defmodule Generator do
  use Application.Behaviour

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Generator.Supervisor.start_link
  end

  def generate(host, bucket, password, quantity) do
    Couchie.open(:db, 10, host, bucket, password)
    1..quantity |> Enum.map(&insert/1)
  end
  
  def insert(bogus) do
    list =  1..100 |> Enum.map(&randomize(&1, 100))
    value = HashDict.new([{docid: "test"}, {bogus_level: bogus},
      {alpha: :random.uniform(1000)}, {beta: :random.uniform()*100.0}, {list: list}])
 #   value = HashDict.new([{docid: "test"}, {bogus_level: bogus},
 #     {alpha: :random.uniform(1000)}, {beta: (:random.uniform()*100.0)}, {list: list}])
    |> JSON.encode 
    Couchie.set(:db, Flaky.alpha, value)
  end
  
  def randomize(_, max) do
    :random.uniform(max)
  end
  
  def pmap(collection, fun) do
    me = self
    collection
      |>
    Enum.map(fn (elem) ->
      spawn_link fn -> send(me, {self, fun.(elem)}) end
      #spawn_link fn -> (me <- {self, fun.(elem)}) end
    end) |>
    Enum.map(fn (pid) ->
      receive do {^pid, result} -> result end
    end)
  end


end
