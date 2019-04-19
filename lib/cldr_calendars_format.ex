defmodule Cldr.Calendar.Format do
  alias Cldr.Calendar

  @default_format_module Cldr.Calendar.Formatter.HTML

  def year(year, calendar, options \\ []) do
    with {:ok, calendar} <- valid_calendar(calendar) do
      format_module = Keyword.get(options, :formatter, @default_format_module)
      range = 1..calendar.months_in_year(year)

      year
      |> months(range, calendar, format_module, options)
      |> format_module.format_year(year, options)
    end
  end

  defp months(year, range, calendar, _format_module, options) do
    for month <- range do
      month(year, month, calendar, options)
    end
  end

  def month(year, month, calendar, options \\ []) do
    format_module = Keyword.get(options, :formatter, @default_format_module)

    with %Date.Range{first: date} <- calendar.month(year, month),
         {:ok, calendar} <- valid_calendar(date.calendar) do
      month(year, month, date, calendar.calendar_base, format_module, options)
    end
  end

  def month(year, month, date, :month, format_module, options) do
    range = 0..5

    date
    |> weeks(range, year, month, format_module, options)
    |> format_module.format_month(year, month, date, options)
  end

  def month(year, _month, date, :week, format_module, options) do
    month = Cldr.Calendar.month_of_year(date)
    calendar = date.calendar

    weeks_in_month =
      date.year
      |> calendar.days_in_month(month)
      |> div(calendar.days_in_week())

    range = 0..(weeks_in_month - 1)

    date
    |> weeks(range, year, month, format_module, options)
    |> format_module.format_month(year, month, date, options)
  end

  defp weeks(date, range, year, month, format_module, options) do
    week = Calendar.week(date)

    for i <- range do
      week
      |> Calendar.plus(:weeks, i)
      |> week(year, month, date, format_module, options)
    end
  end

  defp week(week, year, month, date, format_module, options) do
    week_number = Calendar.week_of_year(week.first)

    days(week, year, month, format_module, options)
    |> format_module.format_week(year, month, date, week_number, options)
  end

  defp days(week, year, month, format_module, options) do
    for date <- week do
      format_module.format_day(date, year, month, options)
    end
  end

  defp valid_calendar(Calendar.ISO) do
    valid_calendar(Cldr.Calendar.Gregorian)
  end

  defp valid_calendar(calendar) do
    if function_exported?(calendar, :cldr_calendar_type, 0) &&
         Cldr.Calendar.Gregorian.cldr_calendar_type() == :gregorian do
      {:ok, calendar}
    else
      {:error,
       {Cldr.Calendar.UnsupportedCalendarType, "Calendar #{inspect(calendar)} is not supported"}}
    end
  end

end
