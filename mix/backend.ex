require Cldr.Calendar
require Cldr.Calendar.Backend.Compiler

defmodule MyApp.Cldr do
  use Cldr,
    providers: [Cldr.Calendar, Cldr.Number],
    locales: ["en", "fr", "en-GB", "en-AU", "en-CA", "ar", "he"],
    generate_docs: false,
    precompile_number_formats: ["####"]
end
