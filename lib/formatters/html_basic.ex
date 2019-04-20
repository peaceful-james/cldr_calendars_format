defmodule Cldr.Calendar.Formatter.HTML.Basic do
  @behaviour Cldr.Calendar.Formatter

  @default_calendar_class "cldr_calendar"

  alias Cldr.Calendar.Format.Options

  def format_year(formatted_months, year, _options) do
    year_html(year, formatted_months)
  end

  def format_month(formatted_weeks, year, month, date, options) do
    %Options{locale: locale, backend: backend} = options
    caption = Map.get(options, :caption) || caption(year, month, date, options)
    class = Map.get(options, :class) || @default_calendar_class
    id = Map.get(options, :id, nil)

    day_names =
      date
      |> Cldr.Calendar.localize(:days_of_week, backend: backend, locale: locale)
      |> day_names(date, options)

    month_html(caption, id, class, day_names, formatted_weeks)
  end

  def format_week(formatted_days, _year, _month, _date, _week_number, _options) do
    week_html(formatted_days)
  end

  def format_day(date, year, month, options) do
    format_day(date, year, month, date.calendar.calendar_base, options)
  end

  def format_day(date, _year, month, :month, options) do
    %Options{number_system: number_system, locale: locale, backend: backend} = options
    class = if date.month == month, do: "in_month", else: "outside_month"
    class = class_from_date(class, date, options)
    formatted_day = Cldr.Number.to_string!(date.day, backend, locale: locale, number_system: number_system)
    day_html(formatted_day, class)
  end

  # TODO check option :today and set today if the date is the same
  def format_day(date, _year, _month, :week, options) do
    class = class_from_date("in_month", date, options)
    {:ok, date} = Date.convert(date, Cldr.Calendar.Gregorian)
    day_html(date.day, class)
  end

  defp class_from_date(default, date, options) do
    %Options{territory: territory, backend: backend, today: today} = options

    day_type =
      if Cldr.Calendar.weekend?(date, territory: territory, backend: backend) do
        "weekend"
      else
        "weekday"
      end

    today =
      if Date.compare(date, today) == :eq do
        "today"
      else
        nil
      end

    [default, day_type, today]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(", ")
  end

  def caption(year, _month, date, _options) do
    month_name = Cldr.Calendar.localize(date, :month, format: :wide)
    month_name <> " " <> to_string(year)
  end

  def day_names(day_names, date, options) do
    %Options{territory: territory} = options
    days = Enum.map(Cldr.Calendar.week(date), &Cldr.Calendar.day_of_week/1)
    weekdays = Cldr.Calendar.weekdays(territory)

    days
    |> Enum.zip(day_names)
    |> Enum.map(fn {day, name} ->
      class = day_name_class(day in weekdays, "day_name")
      day_html(name, class)
    end)
  end

  defp day_name_class(true, default) do
    "#{default}, weekday"
  end

  defp day_name_class(false, default) do
    "#{default}, weekend"
  end

  require EEx
  EEx.function_from_file(:def, :day_html, "priv/template/day.eex", [:day, :class])
  EEx.function_from_file(:def, :week_html, "priv/template/week.eex", [:days])
  EEx.function_from_file(:def, :year_html, "priv/template/year.eex", [:year, :months])

  EEx.function_from_file(:def, :month_html, "priv/template/month.eex", [
    :caption,
    :id,
    :class,
    :day_names,
    :weeks
  ])
end
