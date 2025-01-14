defmodule Expo.Po.Composer do
  @moduledoc false

  alias Expo.Translation
  alias Expo.Translations
  alias Expo.Util

  @spec compose(translations :: Translations.t()) :: iodata()
  def compose(%Translations{
        headers: headers,
        top_comments: top_comments,
        translations: translations
      }) do
    headers
    |> Util.inject_meta_headers(top_comments, translations)
    |> dump_translations()
  end

  defp dump_translations(translations) do
    translations
    |> Enum.map(&dump_translation(&1))
    |> Enum.intersperse(?\n)
  end

  defp dump_translation(%Translation.Singular{} = t) do
    [
      dump_comments(t.comments),
      dump_extracted_comments(t.extracted_comments),
      dump_flags(t.flags),
      dump_references(t.references),
      dump_previous_msgids(t.previous_msgids),
      dump_msgctxt(t.msgctxt, t.obsolete),
      dump_kw_and_strings("msgid", t.msgid, t.obsolete),
      dump_kw_and_strings("msgstr", t.msgstr, t.obsolete)
    ]
  end

  defp dump_translation(%Translation.Plural{} = t) do
    [
      dump_comments(t.comments),
      dump_comments(t.extracted_comments),
      dump_flags(t.flags),
      dump_references(t.references),
      dump_previous_msgids(t.previous_msgids),
      dump_previous_msgids(t.previous_msgid_plurals, "msgid_plural"),
      dump_msgctxt(t.msgctxt, t.obsolete),
      dump_kw_and_strings("msgid", t.msgid, t.obsolete),
      dump_kw_and_strings("msgid_plural", t.msgid_plural, t.obsolete),
      dump_plural_msgstr(t.msgstr, t.obsolete)
    ]
  end

  defp dump_comments(comments), do: Enum.map(comments, &["#", &1, ?\n])

  defp dump_extracted_comments(comments), do: Enum.map(comments, &["#.", &1, ?\n])

  defp dump_references(references) do
    Enum.map(references, fn reference_line ->
      ["#: ", reference_line |> Enum.map(&dump_reference_file/1) |> Enum.join(", "), ?\n]
    end)
  end

  defp dump_reference_file(reference)
  defp dump_reference_file({file, line}), do: "#{file}:#{line}"
  defp dump_reference_file(file), do: file

  defp dump_flags(flags) do
    Enum.map(flags, fn flag_line ->
      ["#, ", Enum.intersperse(flag_line, ", "), ?\n]
    end)
  end

  defp dump_plural_msgstr(msgstr, obsolete) do
    Enum.map(msgstr, fn {plural_form, str} ->
      dump_kw_and_strings("msgstr[#{plural_form}]", str, obsolete)
    end)
  end

  defp dump_kw_and_strings(keyword, [first | rest], obsolete \\ false) do
    first = [
      if(obsolete, do: "#~ ", else: []),
      keyword,
      " ",
      ?",
      escape(first),
      ?",
      ?\n
    ]

    rest = Enum.map(rest, &[if(obsolete, do: "#~ ", else: []), ?", escape(&1), ?", ?\n])
    [first | rest]
  end

  defp dump_msgctxt(nil, _obsolete), do: []

  defp dump_msgctxt(string, obsolete), do: dump_kw_and_strings("msgctxt", string, obsolete)

  defp dump_previous_msgids(previous_msgids, keyword \\ "msgid") do
    Enum.map(previous_msgids, &["#| ", dump_kw_and_strings(keyword, [IO.iodata_to_binary(&1)])])
  end

  defp escape(str) do
    for <<char <- str>>, into: "", do: escape_char(char)
  end

  defp escape_char(?"), do: ~S(\")
  defp escape_char(?\n), do: ~S(\n)
  defp escape_char(?\t), do: ~S(\t)
  defp escape_char(?\r), do: ~S(\r)
  defp escape_char(char), do: <<char>>
end
