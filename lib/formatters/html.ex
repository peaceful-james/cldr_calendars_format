defmodule Cldr.Calendar.Formatter.HTML do
  @behaviour Cldr.Calendar.Formatter

  @default_class "cldr_calendar"
  @week_prefix "W"

  require EEx
  EEx.function_from_file(:defp, :day_html, "priv/template/day.eex", [:day, :class])
  EEx.function_from_file(:defp, :week_html, "priv/template/week.eex", [:days])

  EEx.function_from_file(:defp, :month_html, "priv/template/month.eex", [
    :caption,
    :id,
    :class,
    :day_names,
    :weeks
  ])

  def format_year(months, year, options) do

  end

  def format_month(weeks, year, month, options) do
    # {caption, options} = Keyword.pop(options, :caption, caption(date, options))
    # {id, options} = Keyword.pop(options, :id, nil)
    # {class, options} = Keyword.pop(options, :class, @default_class)
    weeks
    |> hd
    |> Map.get(:first)
    |> Cldr.Calendar.localize(:days_of_week)
    |> day_names(options)
  end

  def format_week(days, week_number, options) do

  end

  def format_day(date, options) do

  end

  defp lpad(<<x::bytes-1>>) do
    "0" <> x
  end

  defp lpad(x) do
    x
  end

  def week_to_gregorian(%{first: first, last: last) do
    {:ok, first} = Date.convert(first, Cldr.Calendar.Gregorian)
    {:ok, last} = Date.convert(last, Cldr.Calendar.Gregorian)
    Date.range(first, last)
  end

  defp caption(date, _options) do
    month_name = Cldr.Calendar.localize(date, :month, format: :wide)
    month_name <> " " <> to_string(date.year)
  end

  defp day_names(day_names, options) do
    Enum.map(day_names, &day_html(&1, "day_name"))
  end

end