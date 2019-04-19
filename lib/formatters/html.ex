defmodule Cldr.Calendar.Formatter.HTML do
  @behaviour Cldr.Calendar.Formatter

  @default_calendar_class "cldr_calendar"
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

  def format_year(_formatted_months, _year, _options) do

  end

  def format_month(formatted_weeks, year, month, date, options) do
    {caption, options} = Keyword.pop(options, :caption, caption(year, month, date, options))
    {id, options} = Keyword.pop(options, :id, nil)
    {class, options} = Keyword.pop(options, :class, @default_calendar_class)

    day_names =
      date
      |> Cldr.Calendar.localize(:days_of_week)
      |> day_names(options)

    month_html(caption, id, class, day_names, formatted_weeks)
  end

  def format_week(formatted_days, _year, _month, _date, _week_number, _options) do
    week_html(formatted_days)
  end

  def format_day(date, year, month, options) do
    format_day(date, year, month, date.calendar.calendar_base, options)
  end

  def format_day(date, _year, month, :month, _options) do
    day = date.day
    class = if date.month == month, do: "in_month", else: "outside_month"
    day_html(day, class)
  end

  # TODO Localise number system. Add class for weekend or weekday
  # TODO check option :today and set today if the date is the same
  def format_day(date, _year, _month, :week, _options) do
    {:ok, date} = Date.convert(date, Cldr.Calendar.Gregorian)
    day_html(date.day, "in_month")
  end

  defp lpad(<<x::bytes-1>>) do
    "0" <> x
  end

  defp lpad(x) do
    x
  end

  defp caption(year, _month, date, _options) do
    month_name = Cldr.Calendar.localize(date, :month, format: :wide)
    month_name <> " " <> to_string(year)
  end

  defp day_names(day_names, _options) do
    Enum.map(day_names, &day_html(&1, "day_name"))
  end

end