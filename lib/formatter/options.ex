defmodule Cldr.Calendar.Formatter.Options do
  defstruct [
    :calendar,
    :number_system,
    :territory,
    :locale,
    :formatter,
    :backend,
    :caption,
    :class,
    :id,
    :today,
    :day_names
  ]

  alias Cldr.Number

  @default_calendar Cldr.Calendar.Gregorian
  @default_format_module Cldr.Calendar.Formatter.HTML.Basic
  @default_calendar_class "cldr_calendar"

  def validate_options(options) do
    with {:ok, options} <- validate_calendar(options, :calendar, @default_calendar),
         {:ok, options} <- validate_backend(options, :backend, Cldr.default_backend()),
         {:ok, options} <- validate_formatter(options, :formatter, @default_format_module),
         {:ok, options} <- validate_locale(options, :locale, Cldr.get_locale()),
         {:ok, options} <- validate_territory(options, :territory, Cldr.get_locale().territory),
         {:ok, options} <- validate_number_system(options, :number_system, :default),
         {:ok, options} <- validate_today(options, :today, today()) do

      options =
        options
        |> Keyword.put_new(:class, @default_calendar_class)
        |> Keyword.put_new(:day_names, day_names(options))

      {:ok, struct(__MODULE__, options)}
    end
  end

  defp validate_calendar(options, key, default) do
    calendar = calendar_from_options(options[:calendar], default)

    if Code.ensure_loaded?(calendar) && function_exported?(calendar, :cldr_calendar_type, 0) &&
         calendar.cldr_calendar_type() == :gregorian do
      {:ok, Keyword.put(options, key, calendar)}
    else
      {:error,
       {Cldr.Calendar.UnsupportedCalendarType, "Calendar #{inspect(calendar)} is not supported"}}
    end
  end

  defp calendar_from_options(nil, default) do
    default
  end

  defp calendar_from_options(Calendar.ISO, default) do
    default
  end

  defp calendar_from_options(calendar, _default) do
    calendar
  end

  defp validate_backend(options, key, default) do
    {:ok, Keyword.put_new(options, key, default)}
  end

  defp validate_formatter(options, key, default) do
    {:ok, Keyword.put_new(options, key, default)}
  end

  defp validate_locale(options, key, default) do
    locale = Keyword.get(options, key, default)

    with {:ok, locale} <- Cldr.validate_locale(locale) do
      {:ok, Keyword.put(options, key, locale)}
    end
  end

  defp validate_territory(options, key, default) do
    territory = Keyword.get(options, key, default)

    with {:ok, territory} <- Cldr.validate_territory(territory) do
      {:ok, Keyword.put(options, key, territory)}
    end
  end

  defp validate_number_system(options, key, default) do
    locale = Keyword.get(options, :locale)
    backend = Keyword.get(options, :backend)
    number_system = Keyword.get(options, key, default)

    with {:ok, number_system} <- Number.validate_number_system(locale, number_system, backend) do
      {:ok, Keyword.put(options, key, number_system)}
    end
  end

  defp validate_today(options, key, default) do
    {:ok, Keyword.put_new(options, key, default)}
  end

  defp today() do
    Date.utc_today()
  end

  defp day_names(options) do
    {:ok, date} = Date.new(2000, 1, 1, options[:calendar])

    date
    |> Cldr.Calendar.localize(:days_of_week, backend: options[:backend], locale: options[:locale])
    |> Enum.map(fn {day, name} -> {day, encode(name)} end)
  end

  def encode(name) do
    name
  end
end
