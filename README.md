# TripMate

> 제주에서 함께할 여행 친구를 찾는 동행 매칭 앱

TripMate는 제주 여행 중 혼자 하기 아쉬운 일정이나 장소를 함께할 사람을 찾을 수 있는 모바일 앱입니다. 사용자는 제주 지역을 기준으로 동행 모임을 만들고, 원하는 조건의 모임에 참여하며, 실시간 채팅으로 여행 일정을 조율할 수 있습니다.

앱 내 서비스명은 **모행**으로, "모여서 함께 떠나는 여행"이라는 의미를 담고 있습니다.

## Demo
https://github.com/user-attachments/assets/bb1aeca8-8cd2-4518-b96f-8d599a0d3ab7


## Background

제주 여행은 렌트, 맛집, 카페, 관광지 방문처럼 함께하면 더 편하고 즐거운 일정이 많습니다. 하지만 여행지에서 즉석으로 동행을 찾기는 쉽지 않고, 기존 커뮤니티는 장소, 시간, 인원, 성별, 나이대 같은 조건을 한눈에 확인하기 어렵습니다.

TripMate는 제주 여행자들이 필요한 순간에 안전하고 간편하게 동행을 모집하고 참여할 수 있도록 만들었습니다.

## Main Features

### 제주 동행 모집

- 제목, 장소, 일정, 모집 인원, 성별, 나이대, 카테고리를 입력해 동행을 생성할 수 있습니다.
- 제주 지역만 선택할 수 있도록 장소와 지역을 검증합니다.
- 모집 조건에 맞는 사용자만 동행에 참여할 수 있습니다.

### 동행 탐색

- 현재 모집 중인 동행을 확인할 수 있습니다.
- 지역, 카테고리, 성별, 나이대 등 조건을 기준으로 동행을 필터링할 수 있습니다.
- 홈 화면에서 제주 날씨와 지역별 동행 현황을 함께 확인할 수 있습니다.

### 장소 검색과 지도

- 카카오 장소 검색 API를 이용해 제주 내 장소를 검색합니다.
- 네이버 지도 기반으로 동행 장소를 확인할 수 있습니다.
- 마이페이지에서 참여했던 동행 위치를 지도 형태로 확인할 수 있습니다.

### 실시간 채팅

- 동행에 참여하면 해당 모임의 채팅방에서 대화를 나눌 수 있습니다.
- Socket.IO를 사용해 실시간 메시지를 주고받습니다.
- 동행 참여, 나가기 등 주요 이벤트가 채팅방에 시스템 메시지로 표시됩니다.

### 알림

- 동행 참여, 수정, 나가기 등 주요 이벤트를 알림으로 받을 수 있습니다.
- Firebase Cloud Messaging을 통해 푸시 알림을 제공합니다.
- 앱 안에서 읽음 처리, 전체 읽음, 삭제가 가능한 알림함을 제공합니다.

### 사용자 안전 기능

- 부적절한 동행 또는 사용자를 신고할 수 있습니다.
- 악성 사용자를 차단할 수 있습니다.
- 차단한 사용자의 동행과 프로필은 내 화면에서 숨김 처리됩니다.
- EULA와 커뮤니티 안전 정책 동의 후 서비스를 이용할 수 있습니다.

### 마이페이지

- 내 프로필과 소개를 수정할 수 있습니다.
- 전체 참여한 동행, 내가 만든 동행, 현재 참가 중인 동행을 확인할 수 있습니다.
- 프로필 이미지 업로드를 지원합니다.

## User Flow

```text
약관 동의
  ↓
소셜 로그인
  ↓
닉네임 설정
  ↓
홈에서 제주 동행 탐색
  ↓
동행 생성 또는 참여
  ↓
채팅으로 일정 조율
  ↓
여행 후 마이페이지에서 내 동행 기록 확인
```

## Tech Stack

### Frontend

- Flutter
- Provider
- Flutter Secure Storage
- Shared Preferences
- Drift / SQLite
- Socket.IO Client
- Firebase Messaging
- Flutter Naver Map
- App Links
- Apple Sign In

### Backend

- Node.js
- Express
- TypeScript
- Prisma
- PostgreSQL
- Socket.IO
- JWT
- Firebase Admin SDK
- AWS S3

### External APIs

- Naver Login
- Apple Login
- Kakao Local API
- Naver Map SDK
- OpenWeather API
- Firebase Cloud Messaging
- AWS S3

## Architecture

```text
Flutter App
  ├─ Provider 기반 상태 관리
  ├─ Secure Storage 토큰 저장
  ├─ Drift 로컬 채팅 데이터 관리
  └─ Socket.IO 실시간 채팅 연결

Express API Server
  ├─ JWT 인증
  ├─ Prisma ORM
  ├─ PostgreSQL
  ├─ Socket.IO 채팅 서버
  ├─ Firebase Admin 푸시 알림
  └─ AWS S3 이미지 업로드
```

## Project Structure

```text
TripMate
├── frontend
│   ├── lib
│   │   ├── app
│   │   ├── core
│   │   └── features
│   │       ├── auth
│   │       ├── chat
│   │       ├── home
│   │       ├── home_more
│   │       ├── meeting_create
│   │       ├── mypage
│   │       ├── notification
│   │       ├── report
│   │       └── splash
│   ├── android
│   └── ios
│
└── backend
    ├── prisma
    └── src
        ├── middleware
        ├── modules
        ├── routes
        ├── socket
        └── utils
```

## Database

주요 도메인은 다음과 같이 구성되어 있습니다.

- User
- UserProfile
- SocialAccount
- RefreshToken
- Meeting
- MeetingMember
- ChatRoom
- ChatRoomMember
- ChatMessage
- Notification
- UserFcmToken
- Report
- BlockedUser

## API Overview

| Domain | Description |
| --- | --- |
| Auth | 네이버 로그인, Apple 로그인, 토큰 재발급, 로그아웃 |
| User | 내 정보, 프로필 수정, 마이페이지, 유저 프로필, 차단 |
| Meeting | 동행 목록, 상세, 생성, 수정, 삭제, 참여, 나가기 |
| Chat | 채팅방 목록, 메시지 조회, 실시간 채팅 |
| Notification | 알림 목록, 읽음 처리, 삭제, FCM 토큰 등록 |
| Place | 장소 검색, 지도 위치 선택, 현재 위치 기반 지역 확인 |
| Weather | 제주 날씨 조회 |
| Upload | 프로필 이미지 업로드 |
| Report | 동행 및 사용자 신고 |

## What I Focused On

- 여행지에서 빠르게 사용할 수 있도록 간결한 동행 생성 플로우를 구성했습니다.
- 제주 지역 기반 서비스에 맞게 장소 검색과 지역 검증 로직을 구현했습니다.
- 동행 참여 이후 바로 대화가 이어질 수 있도록 Socket.IO 기반 실시간 채팅을 연결했습니다.
- 앱 심사 기준을 고려해 EULA, 신고, 차단, 사용자 숨김 처리 등 안전 기능을 반영했습니다.
- 액세스 토큰과 리프레시 토큰을 분리하고, 모바일 환경에서 안전하게 인증 상태를 유지하도록 구성했습니다.
- 동행 수정, 참여, 나가기 같은 이벤트가 앱 알림과 푸시 알림으로 이어지도록 구현했습니다.

## Getting Started

### Backend

```bash
cd backend
npm install
npx prisma generate
npm run dev
```

### Frontend

```bash
cd frontend
flutter pub get
flutter run
```

## Environment Variables

실행을 위해 `frontend/.env`, `backend/.env` 파일이 필요합니다. 실제 키와 토큰은 저장소에 포함하지 않습니다.

### Frontend

```env
BASE_URL=http://localhost:3000
NAVER_MAP_CLIENT_ID=your_naver_map_client_id
```

### Backend

```env
PORT=3000
DATABASE_URL=postgresql://user:password@localhost:5432/tripmate

SESSION_SECRET=your_session_secret

JWT_ACCESS_SECRET=your_access_secret
JWT_REFRESH_SECRET=your_refresh_secret
JWT_ACCESS_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=30d

NAVER_CLIENT_ID=your_naver_client_id
NAVER_CLIENT_SECRET=your_naver_client_secret
NAVER_REDIRECT_URI=your_naver_redirect_uri

APPLE_CLIENT_ID=your_apple_client_id
IOS_BUNDLE_ID=your_ios_bundle_id

KAKAO_REST_API_KEY=your_kakao_rest_api_key
OPENWEATHER_API_KEY=your_openweather_api_key

AWS_REGION=ap-northeast-2
AWS_ACCESS_KEY_ID=your_aws_access_key_id
AWS_SECRET_ACCESS_KEY=your_aws_secret_access_key
AWS_S3_BUCKET=your_s3_bucket

FIREBASE_SERVICE_ACCOUNT_PATH=./firebase-service-account.json
```

## Status

- iOS 배포 완료
- Android 배포 진행 중

