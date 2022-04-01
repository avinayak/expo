Mix.install([
  {:benchee, "~> 1.1"},
  {:gettext, "~> 0.19.1"},
  {:expo, path: Path.dirname(Path.dirname(__ENV__.file))}
])

po_content = File.read!(Path.join(Path.dirname(__ENV__.file), "default.po"))

{:ok, gettext_translations} = Gettext.PO.parse_string(po_content)
{:ok, expo_translations} = Expo.Parser.Po.parse(po_content)

Benchee.run(
  %{
    "Gettext.PO.dump" => fn ->
      Gettext.PO.dump(gettext_translations)
    end,
    "Expo.Composer.Po.compose" => fn ->
      Expo.Composer.Po.compose(expo_translations)
    end,
    "Expo.Composer.Mo.compose" => fn ->
      Expo.Composer.Mo.compose(expo_translations)
    end
  },
  time: 10,
  memory_time: 2
)
