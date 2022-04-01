Mix.install([
  {:benchee, "~> 1.1"},
  {:gettext, "~> 0.19.1"},
  {:expo, path: Path.dirname(Path.dirname(__ENV__.file))}
])

po_content = File.read!(Path.join(Path.dirname(__ENV__.file), "default.po"))
mo_content = File.read!(Path.join(Path.dirname(__ENV__.file), "default.mo"))

Benchee.run(
  %{
    "Gettext.PO.parse_string" => fn ->
      Gettext.PO.parse_string(po_content)
    end,
    "Expo.Parser.Po.parse" => fn ->
      Expo.Parser.Po.parse(po_content)
    end,
    "Expo.Parser.Mo.parse" => fn ->
      Expo.Parser.Mo.parse(mo_content)
    end
  },
  time: 10,
  memory_time: 2
)
