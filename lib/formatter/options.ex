defmodule Cldr.Calendar.Formatter.Options do
  @moduledoc """
  Defines and validates the options
  for a calendar formatter.

  These options are passed to the formatter
  callbacks defined in `Cldr.Calendar.Formatter`.

  The valid options are:

  * `:calendar` is an calendar module defined with
    `use Cldr.Calendar`.

  * `:backend` is any module that applied
    `use Cldr`.  The default is `Cldr.default_backend()`.

  * `:formatter` is any module implementing the
    `Cldr.Calendar.Formatter` behaviour.

  * `:locale` is any locale returned by `Cldr.validate_locale/1`.
    The default is `Cldr.get_locale()`.

  * `:number_system` is any valid number system
    for the given locale. Available number systems
    for a locale are returned by
    `Cldr.Number.System.number_systems_for(locale, backend)`.
    The default is `:default`.

  * `:territory` is any territory returned by `Cldr.validate_territory/1`
    The default is the territory defined in the `locale` struct.

  * `:caption` is a caption to be applied in any way defined
    by the `:formatter`. The default is `nil`.

  * `:class` is a class name that can be used any way
    defined by the `:formatter`.  It is most commonly
    used to apply an HTML class to an enclosing tag.

  * `:id` is an id that can be used any way
    defined by the `:formatter`.  It is most commonly
    used to apply an HTML id to an enclosing tag.

  * `:private` is for your private use in your formatter.
    For example if you wanted to pass a selected day and
    format it differently, you could provide
    `options.private = %{selected: ~D[2020-04-05]}` and
    take advantage of it while formatting the days.

  * `:today` is any `Date.t` that represents today.
    It is commonly used to allow a formatting to
    appropriately format a date that is today
    differently to other days on a calendar.

  * `:day_names` is a list of 2-tuples that
    map the day of the week to a localised day
    name that are most often used as headers
    for a month. The default is automatically
    calculated from the provided `:calendar`
    and `:locale`.

  """
  @valid_options [
    :backend,
    :calendar,
    :caption,
    :class,
    :day_names,
    :formatter,
    :id,
    :locale,
    :number_system,
    :private,
    :territory,
    :today
  ]

  defstruct @valid_options

  @typedoc """
  Formatter options

  """
  @type  t :: %__MODULE__{
    calendar: module(),
    number_system: Cldr.Number.System.system_name(),
    territory: atom() | String.t(),
    locale: Cldr.LanguageTag.t(),
    formatter: module(),
    backend: module(),
    caption: String.t | nil,
    class: String.t | nil,
    id: String.t | nil,
    today: Date.t(),
    private: any(),
    day_names: [{1..7, String.t}]
  }

  alias Cldr.Number

  @default_format_module Cldr.Calendar.Formatter.HTML.Basic
  @default_calendar_class "cldr_calendar"

  @doc false
  def validate_options(options) do
    reduce_while(@valid_options, %__MODULE__{}, fn option, options ->
      case validate_option(option, options, Keyword.get(options, option)) do
        {:ok, value} -> {:cont, Map.put(options, option, value)}
        other -> {:halt, other}
      end
    end)
  end

  def validate_option(:calendar, _options, nil) do
    {:ok, Cldr.Calendar.default_calendar()}
  end

  def validate_option(:calendar, _options, Calendar.ISO) do
    {:ok, Cldr.Calendar.default_calendar()}
  end

  def validate_option(:calendar, _options, calendar) do
    with {:ok, calendar} <- Cldr.Calendar.validate_calendar(calendar) do
      {:ok, calendar}
    end
  end

  def validate_option(:number_system, options, nil) do
    {:ok, locale} = validate_option(:locale, options, Keyword.get(options, :locale))
    {:ok, Number.System.number_system_from_locale(locale)}
  end

  def validate_option(:number_system, options, number_system) do
    {:ok, locale} = validate_option(:locale, options, Keyword.get(options, :locale))
    {:ok, backend} = validate_option(:backend, options, Keyword.get(options, :backend))

    with {:ok, number_system} <- Number.validate_number_system(locale, number_system, backend) do
      {:ok, number_system}
    end
  end

  def validate_option(:territory, options, nil) do
    {:ok, locale} = validate_option(:locale, options, Keyword.get(options, :locale))
    {:ok, Cldr.Locale.territory_from_locale(locale)}
  end

  def validate_option(:backend, _options, nil) do
    {:ok, Cldr.default_backend()}
  end

  def validate_option(:backend, _options, nil) do
    with {:ok, backend} <- Cldr.validate_backend(backend) do
      {:ok, backend}
    end
  end

  def validate_option(:formatter, _options, nil) do
    {:ok, Cldr.Calendar.Formatter.default_formatter()}
  end

  def validate_option(:formatter, options, formatter) do
    if Code.ensure_loaded?(module) && function_exported?(formatter, :format_year, 3) do
      {:ok, formatter}
    else
      {:error, Cldr.Calendar.Formatter.unknown_formatter_error(formatter)}
    end
  end

  def validate_option(:locale, options, nil) do
    {:ok, backend} = validate_option(:backend, options, Keyword.get(options, :backend))
    {:ok, backend.get_locale()}
  end

  def validate_option(:locale, options, locale) do
    {:ok, backend} = validate_option(:backend, options, Keyword.get(options, :backend))

    with {:ok, locale} <- Cldr.validate_locale(locale, backend) do
      {:ok, locale}
    end
  end

  defp validate_option(:today, options, nil) do
    {:ok, Date.utc_today}
  end

  defp validate_today(:today, options, date) do
    if is_map(date) and Map.has_key?(date, :year) and
        Map.has_key?(date, :month) and Map.has_key?(date, :day) do
          {:ok, date}
    else
      {:error, Cldr.Date.invalid_date_error(date)}
    end
  end

  defp validate_option(:class, options, nil) do
    {:ok, @default_calendar_class}
  end

  defp validate_option(:class, options, class) do
    {:ok, class}
  end

  defp validate_option(:day_names, options, nil) do
    {:ok, backend} = validate_option(:backend, options, Keyword.get(options, :backend))
    {:ok, locale} = validate_option(:calendar, options, Keyword.get(options, :calendar))
    {:ok, date} = Date.new(2000, 1, 1, Keyword.get(options, :calendar))

    {:ok, Cldr.Calendar.localize(date, :days_of_week, backend: backend, locale: locale)}
  end
end
