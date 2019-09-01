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
    day_names: [{1..7, String.t}]
  }

  alias Cldr.Number

  @default_calendar Cldr.Calendar.Gregorian
  @default_format_module Cldr.Calendar.Formatter.HTML.Basic
  @default_calendar_class "cldr_calendar"

  @doc false
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
  end
end
