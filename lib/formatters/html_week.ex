defmodule Cldr.Calendar.Formatter.HTML.Week do
  @behaviour Cldr.Calendar.Formatter

  alias Cldr.Calendar.Format.Options
  alias Cldr.Calendar.Formatter
  alias Cldr.Calendar.Formatter.HTML.Basic

  @default_calendar_class "cldr_calendar"
  @week_class "week"
  @week_prefix "W"

  defdelegate format_year(formatted_months, year, options), to: Formatter.HTML.Basic
  defdelegate format_day(date, year, month, options), to: Formatter.HTML.Basic

  def format_month(formatted_weeks, year, month, date, options) do
    %Options{locale: locale, backend: backend} = options

    caption = Map.get(options, :caption) || Basic.caption(year, month, date, options)
    class = Map.get(options, :class) || @default_calendar_class
    id = Map.get(options, :id, nil)

    day_names =
      date
      |> Cldr.Calendar.localize(:days_of_week, backend: backend, locale: locale)
      |> Basic.day_names(date, options)

    day_names = [Basic.day_html(" ", nil) | day_names]
    Basic.month_html(caption, id, class, day_names, formatted_weeks)
  end

  def format_week(formatted_days, _year, _month, _date, {_, week_number}, options) do
    %Options{locale: locale, backend: backend, number_system: number_system} = options

    week_number =
      week_number
      |> Cldr.Number.to_string!(backend, locale: locale, number_system: number_system)
      |> lpad

    week_indicator = Basic.day_html(@week_prefix <> week_number, @week_class)
    Basic.week_html([week_indicator | formatted_days])
  end

  defp lpad(<<x::bytes-1>>) do
    "0" <> x
  end

  defp lpad(x) do
    x
  end
end
