defmodule Cldr.Calendar.Test.Formatter do
  @behaviour Cldr.Calendar.Formatter

  @impl true
  def format_year(formatted_months, year, options) do
    %{year: year, months: formatted_months, options: options}
  end

  @impl true
  def format_month(formatted_weeks, year, month, _options) do
    %{year: year, month: month, weeks: formatted_weeks}
  end

  @impl true
  def format_week(formatted_days, year, month, {_, week_number}, _options) do
    %{year: year, month: month, days: formatted_days, week_number: week_number}
  end

  @impl true
  def format_day(date, _year, _month, _options) do
    date
  end
end
