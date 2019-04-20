require Cldr.Calendar
require Cldr.Calendar.Backend.Compiler

defmodule MyApp.Cldr do
  use Cldr,
    providers: [Cldr.Calendar, Cldr.Number],
    locales: ["en", "fr", "en-GB", "en-AU", "en-CA", "ar", "he"]
end
