defmodule Tools.Demo do
  def test do
    everything_done = fn -> IO.puts("Yeahh!") end

    producer = fn ->
      datetime = NaiveDateTime.utc_now()

      if datetime.second == 0 or datetime.second == 30 do
        :no_work
      else
        fn ->
          IO.puts(inspect(self()) <> " #{datetime}")
          :timer.sleep(2000)
        end
      end
    end

    work_id = 1
    number_of_workers = 10
    dispatcher_name = :test

    Tools.Workers.work(dispatcher_name, number_of_workers, work_id, producer, everything_done)
  end
end
