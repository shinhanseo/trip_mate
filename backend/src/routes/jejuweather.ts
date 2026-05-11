import { Router, Response } from "express";
import axios from "axios";
import { ok, fail } from "../utils/response";

const router = Router();

type LatLon = { lat: number; lon: number };

type WeatherDto = {
  coord: LatLon;
  name: string;
  temp: number;
  feelsLike: number;
  humidity: number;
  windSpeed: number;
  main: string;
  description: string;
  icon: string;
  dt: number;
};

function buildWeatherDto(data: any): WeatherDto {
  return {
    coord: { lat: data?.coord?.lat ?? 0, lon: data?.coord?.lon ?? 0 },
    name: data?.name ?? "",
    temp: data?.main?.temp ?? 0,
    feelsLike: data?.main?.feels_like ?? 0,
    humidity: data?.main?.humidity ?? 0,
    windSpeed: data?.wind?.speed ?? 0,
    main: data?.weather?.[0]?.main ?? "",
    description: data?.weather?.[0]?.description ?? "",
    icon: data?.weather?.[0]?.icon ?? "",
    dt: data?.dt ?? 0,
  };
}

router.get("/", async (_req, res: Response) => {
  try {
    const apiKey = process.env.OPENWEATHER_API_KEY;

    if (!apiKey) {
      return fail(res, 500, "OPENWEATHER_API_KEY missing");
    }

    // 제주 시청
    const lat = 33.4996;
    const lon = 126.5312;

    const response = await axios.get(
      "https://api.openweathermap.org/data/2.5/weather",
      {
        params: {
          lat,
          lon,
          appid: apiKey,
          units: "metric",
          lang: "kr",
        },
        timeout: 8000,
      }
    );

    return ok(res, {
      item: buildWeatherDto(response.data),
    });
  } catch (err: any) {

    return fail(res, 500, "날씨 API 호출 실패");
  }
});

export default router;