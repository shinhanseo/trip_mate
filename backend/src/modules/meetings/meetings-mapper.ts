import { isValidRegion } from "./meetings-invalid";

type MeetingItem = {
  id: number;
  category: string;
  region_primary: string;
};

const jejuRegionGroup = [
  "애월/한담권",
  "협재/한림권",
  "함덕/조천권",
  "성산/우도권",
  "표선/성읍권",
  "중문/안덕권",
  "서귀포시내권",
  "제주시/공항권",
];

export function meetingMapper(meetings: MeetingItem[]) {
  const grouped = meetings.reduce<Record<string, MeetingItem[]>>(
    (acc, meeting) => {
      const key = isValidRegion(meeting.region_primary)
        ? meeting.region_primary
        : "기타 제주";

      if (!acc[key]) {
        acc[key] = [];
      }

      acc[key].push(meeting);
      return acc;
    },
    {}
  );

  return grouped;
}