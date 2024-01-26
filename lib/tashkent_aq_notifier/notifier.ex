defmodule TashkentAqNotifier.Notifier do
  @locations %{us_embassy: 8881, tstu: 368_739}
  def get_notification_message do
    us_embassy_task = Task.async(fn -> fetch_from_api_for(@locations.us_embassy) end)
    tstu_task = Task.async(fn -> fetch_from_api_for(@locations.tstu) end)

    us_embassy_result = Task.await(us_embassy_task)
    tstu_result = Task.await(tstu_task)

    message =
      calculate_average_value(us_embassy_result, tstu_result)
      |> produce_message()

    sources = describe_sources(us_embassy_result, tstu_result)

    final_message = message <> sources

    spawn(fn ->
      if String.length(final_message) > 0 do
        Cachex.put(:cache, :latest_measurement, final_message, ttl: :timer.hours(8))
      end
    end)

    final_message
  end

  def fetch_from_api_for(location_id) do
    pm25_levels =
      Req.get!(
        "https://api.openaq.org/v2/locations/#{location_id}?limit=100&page=1&offset=0&sort=asc"
      )
      |> Map.get(:body)
      |> Map.get("results")
      |> List.first()
      |> Map.get("parameters")
      |> Enum.filter(fn parameter -> parameter["parameter"] == "pm25" end)
      |> List.first()

    %{
      last_updated: pm25_levels["lastUpdated"],
      pm25_value: pm25_levels["lastValue"]
    }
  end

  def produce_message(nil) do
    ""
  end

  def produce_message(average_pm25_levels) when average_pm25_levels <= 12 do
    "⏰ #{get_formated_time_now()} \n
🟢 Xush xabar! Toshkent havosi sog'lom. PM2.5 darajasi #{average_pm25_levels} µg/m³. Toza havodan rohatlaning! 🌳\n
🟢 Хорошие новости! Качество воздуха сейчас хорошее. Концентрация PM2.5 частиц составляет #{average_pm25_levels} µg/m³. Наслаждайтесь свежим воздухом! 🌳 \n
🟢 Good news! The air quality is healthy right now with a PM2.5 concentration of #{average_pm25_levels} µg/m³. Enjoy the fresh air! 🌳\n
   "
  end

  def produce_message(average_pm25_levels)
      when average_pm25_levels > 12 and average_pm25_levels <= 35.4 do
    amount_exceeds_by = (average_pm25_levels / 5) |> Float.floor(1)
    "⏰ #{get_formated_time_now()} \n
🟡 Havo sifati o'rtacha. Sog'lig'i yomon kimsalar ochiq havoda uzoq vaqt bo'lishi tavsiya etilmaydi. PM2.5 darajasi #{average_pm25_levels} µg/m³ - JSST tavsiya qilgan darajasidan #{amount_exceeds_by} barobar ko'p.\n
🟡 Качество воздуха сейчас умеренное. Людям с плохим состоянием здоровья следует ограничить долгое времяпровождение на улице. Концентрация PM2.5 частиц составляет #{average_pm25_levels} µg/m³ - превышает рекомендованное значение ВОЗ в #{amount_exceeds_by} раз.\n
🟡 The air quality is moderate at the moment. Sensitive groups may consider limiting prolonged outdoor activities. PM2.5 concentration is #{average_pm25_levels} µg/m³ - exceeds WHO recommended value #{amount_exceeds_by} times.\n
   "
  end

  def produce_message(average_pm25_levels)
      when average_pm25_levels > 35.4 and average_pm25_levels <= 55.4 do
    amount_exceeds_by = (average_pm25_levels / 5) |> Float.floor(1)
    "⏰ #{get_formated_time_now()} \n
🟠 Nosog'lom. Sog'lig'i nozik kimsalar uchun xavfli. PM2.5 darajasi #{average_pm25_levels} µg/m³ - JSST tavsiya qilgan darajasidan #{(average_pm25_levels / 5) |> Float.floor(1)} barobar ko'p.\n
🟠 Вредное для людей с плохим здоровьем. Людям с заболеваниями следует ограничить на улице. Концентрация PM2.5 частиц составляет #{average_pm25_levels} µg/m³ - превышает рекомендованное значение ВОЗ в #{amount_exceeds_by} раз.\n
🟠 Unhealthy for Sensitive Groups. Sensitive groups must stay inside. PM2.5 concentration is #{average_pm25_levels} µg/m³ - exceeds WHO recommended value #{amount_exceeds_by} times.\n
   "
  end

  def produce_message(average_pm25_levels)
      when average_pm25_levels > 55.4 and average_pm25_levels <= 150.4 do
    amount_exceeds_by = (average_pm25_levels / 5) |> Float.floor(1)
    "⏰ #{get_formated_time_now()} \n
🔴 Zararli. Tashqarida ko'p vaqt o'tkazish xavfli. PM2.5 darajasi #{average_pm25_levels} µg/m³ - JSST tavsiya qilgan darajasidan #{(average_pm25_levels / 5) |> Float.floor(1)} barobar ko'p.\n
🔴 Вредно. Всем следует ограничить долгое времяпровождение на улице. Концентрация PM2.5 частиц составляет #{average_pm25_levels} µg/m³ - превышает рекомендованное значение ВОЗ в #{amount_exceeds_by} раз.\n
🔴 Unhealthy. Everyone else should limit prolonged extertion. PM2.5 concentration is #{average_pm25_levels} µg/m³ - exceeds WHO recommended value #{amount_exceeds_by} times.\n
"
  end

  def produce_message(average_pm25_levels)
      when average_pm25_levels > 150.4 do
    amount_exceeds_by = (average_pm25_levels / 5) |> Float.floor(1)
    "⏰ #{get_formated_time_now()} \n
💀 O'ta zararli. Kimsalar ochiq havodagi barcha faoliyatlar cheklanishi lozim. PM2.5 darajasi #{average_pm25_levels} µg/m³ - JSST tavsiya qilgan darajasidan #{(average_pm25_levels / 5) |> Float.floor(1)} barobar ko'p.\n
💀 Очень вредное. Избегайте времяпровождение на улице. Концентрация PM2.5 частиц составляет #{average_pm25_levels} µg/m³ - превышает рекомендованное значение ВОЗ в #{amount_exceeds_by} раз.\n
💀 Hazardous. Everyone else should avoid prolonged exertion. PM2.5 concentration is #{average_pm25_levels} µg/m³ - exceeds WHO recommended value #{amount_exceeds_by} times.\n
"
  end

  defp describe_sources(us_embassy, tstu) when us_embassy.pm25_value > 0 or tstu.pm25_value > 0 do
    msg = "Manbalar | Источники | Sources:\n"

    msg =
      case us_embassy.pm25_value > 0 do
        true ->
          msg <>
            "AQSH Elchixonasi | Посольство США | US Embassy: #{us_embassy.pm25_value} µg/m³, #{us_embassy.last_updated |> format_datetime()}\n"

        false ->
          msg
      end

    msg =
      case tstu.pm25_value > 0 do
        true ->
          msg <>
            "TDTU | ТГТУ | TSTU: #{tstu.pm25_value} µg/m³, #{tstu.last_updated |> format_datetime()}"

        false ->
          msg
      end

    msg
  end

  defp describe_sources(_, _) do
    ""
  end

  defp format_datetime(datetime_iso) do
    {:ok, utc_time, _} = DateTime.from_iso8601(datetime_iso)

    utc_time
    |> DateTime.add(5, :hour)
    |> Calendar.strftime("%H:%M %0d.%0m.%Y")
  end

  def get_formated_time_now() do
    DateTime.utc_now()
    |> DateTime.add(5, :hour)
    |> Calendar.strftime("%H:%M")
  end

  defp calculate_average_value(source_1, source_2)
       when source_1.pm25_value > 0 and source_2.pm25_value > 0 do
    (source_1.pm25_value + source_2.pm25_value) / 2
  end

  defp calculate_average_value(source_1, source_2)
       when source_1.pm25_value < 0 and source_2.pm25_value > 0 do
    source_2.pm25_value
  end

  defp calculate_average_value(source_1, source_2)
       when source_2.pm25_value < 0 and source_1.pm25_value > 0 do
    source_1.pm25_value
  end

  defp calculate_average_value(_source_1, _source_2) do
    nil
  end
end
