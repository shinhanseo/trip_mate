import type { PlaceItem } from './place-type';
import { getJejuRegionInfo } from './place-helper';

export function buildPlaceItem(params: {
  name: string;
  address: string;
  lat: number;
  lng: number;
  source: "keyword" | "address" | "map_pick";
  buildingName?: string;
  placeId?: string;
}): PlaceItem {
  const { regionPrimary, regionSecondary } = getJejuRegionInfo(params.address);

  return {
    ...params,
    regionPrimary,
    regionSecondary,
  };
}