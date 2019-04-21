defmodule Cldr.Calendar.Formatter do
  alias Cldr.Calendar.Format.Options

  @callback format_year(
              formatted_months :: String.t(),
              year :: Date.year(),
              options :: Keyword.t() | Options.t()
            ) :: String.t()

  @callback format_month(
              formatted_weeks :: String.t(),
              year :: Date.year(),
              month :: Date.month(),
              options :: Keyword.t() | Options.t()
            ) :: String.t()

  @callback format_week(
              formatted_days :: String.t(),
              year :: Date.year(),
              month :: Date.month(),
              week :: {Date.year(), pos_integer},
              options :: Options.t()
            ) :: String.t()

  @callback format_day(
              date :: Date.t(),
              year :: Date.year(),
              month :: Date.month(),
              options :: Options.t()
            ) :: String.t()
end
