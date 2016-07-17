defmodule PSI do
  alias Experimental.GenStage
  require Logger

  def main do
    {:ok, start_date} = Date.new(2011, 1, 1)
    {:ok, url} = GenStage.start_link(PSI.UrlProducer, start_date)
    {:ok, d1} = GenStage.start_link(PSI.Downloader, [])
    {:ok, d2} = GenStage.start_link(PSI.Downloader, [])
    {:ok, d3} = GenStage.start_link(PSI.Downloader, [])
    {:ok, parser} = GenStage.start_link(PSI.Parser, [])
    {:ok, csv} = GenStage.start_link(PSI.CSVConsumer, "results.csv")

    GenStage.sync_subscribe(csv, to: parser)
    GenStage.sync_subscribe(parser, to: d1)
    GenStage.sync_subscribe(parser, to: d2)
    GenStage.sync_subscribe(parser, to: d3)
    GenStage.sync_subscribe(d1, to: url, max_demand: 5)
    GenStage.sync_subscribe(d2, to: url, max_demand: 5)
    GenStage.sync_subscribe(d3, to: url, max_demand: 5)

    Process.sleep(:infinity)
  end

  defmodule UrlProducer do
    use GenStage

    def init(start_date) do
      Logger.debug("UrlProducer.init(#{start_date})")
      {:producer, start_date}
    end

    def handle_demand(demand, date) when demand > 0 do
      Logger.debug("UrlProducer.handle_demand(#{demand}, #{date})")

      if Timex.before?(date, Timex.today) do
        [new_date | dates] = Enum.map(demand..0, fn n -> Timex.add(date, Timex.Duration.from_days(n)) end)
        urls = Enum.map(dates, fn d -> {d, Timex.format!(d, "http://www.haze.gov.sg/haze-updates/historical-psi-readings/year/{YYYY}/month/{M}/day/{D}")} end)
        {:noreply, urls, new_date}
      else
        {:noreply, [], []}
      end
    end
  end

  defmodule Downloader do
    use GenStage

    def init(state) do
      Logger.debug("Downloader.init(#{state})")
      {:producer_consumer, state}
    end

    def handle_events(events, _from, url) do
      data =
        Enum.map(events, fn {date, url} ->
          Logger.debug("#{inspect self()} #{url}")
          {:ok, %HTTPoison.Response{body: response}} = HTTPoison.get(url)
          {date, response}
        end)
      {:noreply, data, url}
    end
  end

  defmodule Parser do
    use GenStage

    def init(state) do
      {:producer_consumer, state}
    end

    def handle_events(events, _from, state) do
      parsed = Enum.flat_map(events, fn {date, html} ->
        Logger.debug("parsing: #{date}")
        html
        |> String.split("<tbody>")
        |> Enum.at(1)
        |> String.split("<tr")
        |> tl
        |> Enum.map(&parse_tr(date, &1))
      end)
      {:noreply, parsed, state}
    end

    def parse_tr(date, input) do
      with [_, time_string] <- Regex.run(~r/<span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchive.*_ctrl\d+_LblPSIDate">(.+)<\/span>/, input),
           time_parsed <- Timex.parse!(time_string, "%l%P", :strftime),
           [_, north] <- Regex.run(~r/<span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchive.*_ctrl\d+_LblPSINorth">(\d+)<\/span>/, input),
           [_, south] <- Regex.run(~r/<span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchive.*_ctrl\d+_LblPSISouth">(\d+)<\/span>/, input),
           [_, east] <- Regex.run(~r/<span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchive.*_ctrl\d+_LblPSIEast">(\d+)<\/span>/, input),
           [_, west] <- Regex.run(~r/<span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchive.*_ctrl\d+_LblPSIWest">(\d+)<\/span>/, input),
           [_, central] <- Regex.run(~r/<span id="ctl00_ContentPlaceHolderInnerMain_C002_RlvPSIArchive.*_ctrl\d+_LblPSICentral">(\d+)<\/span>/, input)
           do [
             Timex.set(time_parsed, [date: {date.year, date.month, date.day}]) |> Timex.format!("%Y-%m-%d %H:%M", :strftime),
             north,
             south,
             east,
             west,
             central,
           ]
           else
             _ ->
              #Logger.warn("Couldn't parse #{date} from #{input}")
              []
      end
    end
  end

  defmodule CSVConsumer do
    use GenStage

    def init(name) do
      file = File.stream!(name, [:append])
      {:consumer, file}
    end

    def handle_events(events, _from, file) do
      events
      |> Enum.filter(&!Enum.empty?(&1))
      |> CSV.encode
      |> Enum.into(file)
      {:noreply, [], file}
    end
  end
end
