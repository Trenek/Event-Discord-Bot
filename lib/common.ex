defmodule Common do
  def date_to_string(date), do: DateTime.to_iso8601(date, :extended, 7200) |> String.replace("T", " ")
end
