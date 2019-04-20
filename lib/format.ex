defmodule Cldr.Calendar.Format do
  alias Cldr.Calendar
  alias Cldr.Calendar.Format.Options

  def year(year, options \\ [])

  def year(year, options) when is_list(options) do
    with {:ok, options} <- Options.validate_options(options) do
      year(year, options)
    end
  end

  def year(year, %Options{} = options) do
    %Options{calendar: calendar, formatter: formatter} = options
    range = 1..calendar.months_in_year(year)

    year
    |> months(range, options)
    |> formatter.format_year(year, options)
  end

  defp months(year, range, options) do
    for month <- range do
      month(year, month, options)
    end
  end

  def month(year, month, options \\ [])

  def month(year, month, options) when is_list(options) do
    with {:ok, options} <- Options.validate_options(options) do
      month(year, month, options)
    end
  end

  def month(year, month, %Options{} = options) do
    %Options{calendar: calendar} = options

    with %Date.Range{first: date} <- calendar.month(year, month) do
      month(year, month, date, calendar.calendar_base, options)
    end
  end

  defp month(year, month, date, :month, options) do
    %Options{formatter: formatter} = options
    range = 0..5

    date
    |> weeks(range, year, month, options)
    |> formatter.format_month(year, month, date, options)
  end

  defp month(year, _month, date, :week, options) do
    %Options{calendar: calendar, formatter: formatter} = options
    month = Cldr.Calendar.month_of_year(date)

    weeks_in_month =
      date.year
      |> calendar.days_in_month(month)
      |> div(calendar.days_in_week())

    range = 0..(weeks_in_month - 1)

    date
    |> weeks(range, year, month, options)
    |> formatter.format_month(year, month, date, options)
  end

  defp weeks(date, range, year, month, options) do
    week = Calendar.week(date)

    for i <- range do
      week
      |> Calendar.plus(:weeks, i)
      |> week(year, month, date, options)
    end
  end

  defp week(week, year, month, date, options) do
    %Options{formatter: formatter} = options
    week_number = Calendar.week_of_year(week.first)

    days(week, year, month, options)
    |> formatter.format_week(year, month, date, week_number, options)
  end

  defp days(week, year, month, options) do
    %Options{formatter: formatter} = options

    for date <- week do
      formatter.format_day(date, year, month, options)
    end
  end
end
