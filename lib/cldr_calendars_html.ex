defmodule Cldr.Calendar.HTML do
  alias Cldr.Calendar

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

  def year(year, calendar, options \\ []) do
    for month <- 1..calendar.months_in_year(year) do
      month(year, month, calendar, options)
    end
  end

  def month(date, options \\ []) do
    with {:ok, calendar} <- valid_calendar(date.calendar) do
      {caption, options} = Keyword.pop(options, :caption, caption(date, options))
      {id, options} = Keyword.pop(options, :id, nil)
      {class, options} = Keyword.pop(options, :class, @default_class)

      day_names = day_names(date, options)
      format_month(caption, id, class, day_names, date, calendar.calendar_base)
    end
  end

  def month(year, month, calendar, options \\ []) do
    with %Date.Range{first: date} <- calendar.month(year, month) do
      month(date, options)
    end
  end

  defp format_month(caption, id, class, day_names, date, :month) do
    weeks =
      date
      |> weeks(0..5)
      |> Enum.map(&format_week(&1, date.month, :month))

    month_html(caption, id, class, day_names, weeks)
  end

  defp format_month(caption, id, class, day_names, date, :week) do
    first_week_number = date.month
    month = Cldr.Calendar.month_of_year(date)

    weeks_in_month =
      div(date.calendar.days_in_month(date.year, month), date.calendar.days_in_week())

    weeks =
      date
      |> weeks(0..(weeks_in_month - 1))
      |> weeks_to_gregorian
      |> Enum.map(&Enum.to_list/1)

    week_numbers =
      for i <- first_week_number..(first_week_number + weeks_in_month - 1) do
        @week_prefix <> lpad(to_string(i))
      end

    weeks =
      week_numbers
      |> Enum.zip(weeks)
      |> Enum.map(fn {a, b} -> format_week([a | b], date.month, :week) end)

    day_names = [day_html(" ", nil) | day_names]
    month_html(caption, id, class, day_names, weeks)
  end

  defp weeks_to_gregorian(weeks) do
    Enum.map(weeks, fn %{first: first, last: last} ->
      {:ok, first} = Date.convert(first, Cldr.Calendar.Gregorian)
      {:ok, last} = Date.convert(last, Cldr.Calendar.Gregorian)
      Date.range(first, last)
    end)
  end

  defp caption(date, _options) do
    month_name = Cldr.Calendar.localize(date, :month, format: :wide)
    month_name <> " " <> to_string(date.year)
  end

  defp day_names(date, options) do
    date
    |> Cldr.Calendar.localize(:days_of_week, options)
    |> Enum.map(&day_html(&1, "day_name"))
  end

  def weeks(date, range) do
    week = Calendar.week(date)

    for i <- range do
      Calendar.plus(week, :weeks, i)
    end
  end

  defp format_week(week, month, :month) do
    week
    |> Enum.map(fn
      week when is_binary(week) ->
        day_html(week, "week_number")

      date ->
        class = if date.month == month, do: "in_month", else: "outside_month"
        day_html(date.day, class)
    end)
    |> week_html
  end

  defp format_week(week, _month, :week) do
    week
    |> Enum.map(fn
      week when is_binary(week) ->
        day_html(week, "week_number")

      date ->
        class = "in_month"
        day_html(date.day, class)
    end)
    |> week_html
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

  defp lpad(<<x::bytes-1>>) do
    "0" <> x
  end

  defp lpad(x) do
    x
  end
end
