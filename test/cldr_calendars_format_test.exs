defmodule Cldr.Calendar.Format.Test do
  use ExUnit.Case
  doctest Cldr.Calendar.Format

  setup do
    month =
      Cldr.Calendar.Format.month(2019, 4,
        formatter: Cldr.Calendar.Test.Formatter,
        caption: "My Caption",
        calendar: Cldr.Calendar.Gregorian
      )

    gregorian =
      Cldr.Calendar.Format.year(2019,
        formatter: Cldr.Calendar.Test.Formatter,
        caption: "My Caption",
        calendar: Cldr.Calendar.Gregorian
      )

    nrf =
      Cldr.Calendar.Format.year(2019,
        formatter: Cldr.Calendar.Test.Formatter,
        caption: "My Caption",
        calendar: Cldr.Calendar.NRF
      )

    {:ok, month: month, gregorian: gregorian, nrf: nrf}
  end

  test "that we return a month, weeks, and days", context do
    formatted = context[:month]
    assert formatted[:year] == 2019
    assert formatted[:month] == 4
    assert length(formatted[:weeks]) == 6
    assert hd(formatted[:weeks])[:week_number] == 14
  end

  test "we have 12 months and a caption", context do
    gregorian = context[:gregorian]

    assert length(gregorian[:months]) == 12
    assert gregorian[:options].caption == "My Caption"
  end

  test "that day names are calendar correct", context do
    gregorian = context[:gregorian]
    nrf = context[:nrf]

    assert gregorian[:options].day_names ==
             [
               {1, "Mon"},
               {2, "Tue"},
               {3, "Wed"},
               {4, "Thu"},
               {5, "Fri"},
               {6, "Sat"},
               {7, "Sun"}
             ]

    assert nrf[:options].day_names ==
             [
               {7, "Sun"},
               {1, "Mon"},
               {2, "Tue"},
               {3, "Wed"},
               {4, "Thu"},
               {5, "Fri"},
               {6, "Sat"}
             ]
  end

  test "Weeks that don't start on Monday" do
    defmodule MyApp.Calendar.US do
      @moduledoc """
      This is the same as a gregorian Calendar, but with Sunday starting the week.
      """

      use Cldr.Calendar.Base.Month, day_of_week: Cldr.Calendar.sunday(), cldr_backend: MyApp.Cldr
    end

    options = [
        formatter: Cldr.Calendar.Test.Formatter,
        caption: "My Caption",
        calendar: MyApp.Calendar.US
    ]

    first_day =
      Cldr.Calendar.Format.month(2020, 3, options)
      |> Map.get(:weeks)
      |> hd
      |> Map.get(:days)
      |> hd
      |> Cldr.Calendar.day_of_week

    assert first_day == 7
  end
end
