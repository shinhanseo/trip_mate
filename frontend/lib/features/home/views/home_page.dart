import 'package:flutter/material.dart';
import 'package:frontend/core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/widgets/bottom_nav_bar.dart';
import 'package:frontend/core/widgets/gradient_button.dart';

import '../viewmodels/weather_viewmodel.dart';
import '../viewmodels/region_summary_viewmodel.dart';
import '../../notification/viewmodels/notification_viewmodel.dart';
import '../../notification/widgets/notification_icon_button.dart';
import '../widgets/weather_meta_item.dart';
import '../widgets/jeju_map_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().loadWeather();
      context.read<RegionSummaryViewModel>().loadRegionSummary();
      context.read<NotificationViewModel>().loadUnreadCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final vm = context.watch<WeatherViewModel>();
    final summariesVm = context.watch<RegionSummaryViewModel>();

    final weather = vm.weather;
    final summaries = summariesVm.regionSummaries;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Image.asset(
              'assets/images/home_background.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Container(color: Colors.white.withValues(alpha: 0.18)),
          ),
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            height: 260,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.white],
                  stops: [0.0, 0.9],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '모행',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColors.brandTeal,
                              ),
                            ),
                          ),
                          const NotificationIconButton(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '제주에서 함께할\n여행친구를 찾아보세요',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '함께라서 더 특별한 제주 여행',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              text: "동행 모집하기",
                              icon: const Icon(
                                Icons.group_add_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              leftColor: AppColors.brandTeal,
                              rightColor: AppColors.brandLime,
                              onTap: () {
                                Navigator.pushNamed(context, '/meetingcreate');
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GradientButton(
                              text: "동행 참여하기",
                              icon: const Icon(
                                Icons.groups_outlined,
                                color: Colors.white,
                                size: 22,
                              ),
                              leftColor: AppColors.sky,
                              rightColor: AppColors.cyan,
                              onTap: () {
                                Navigator.pushNamed(context, '/homemore');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '현재 모집중인 동행',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                                height: 1.4,
                                color: AppColors.dark,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/homemore');
                              },
                              child: const Text(
                                '더보기 →',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                  color: AppColors.dark,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        JejuMapCard(
                          screenHeight: screenHeight * 0.78,
                          summaries: summaries,
                        ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppColors.gray200,
                              width: 1.1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.07),
                                blurRadius: 16,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: vm.isLoading
                              ? const SizedBox(
                                  height: 80,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : vm.errorMessage != null
                              ? SizedBox(
                                  height: 80,
                                  child: Center(
                                    child: Text(
                                      vm.errorMessage!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                )
                              : weather == null
                              ? const SizedBox(
                                  height: 80,
                                  child: Center(child: Text('날씨 정보가 없습니다.')),
                                )
                              : Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                '현재 제주 날씨',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Image.network(
                                                    'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                                                    width: 36,
                                                    height: 36,
                                                    fit: BoxFit.contain,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => const Icon(
                                                          Icons.cloud_outlined,
                                                          size: 32,
                                                          color: AppColors
                                                              .mintLight,
                                                        ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Expanded(
                                                    child: Text(
                                                      '${weather.temp.toStringAsFixed(0)}°C ${weather.description}',
                                                      style: const TextStyle(
                                                        fontSize: 24,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color: Colors.black,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Image.asset(
                                          'assets/images/weather.png',
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.contain,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    const Divider(
                                      height: 1,
                                      color: AppColors.gray200,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: WeatherMetaItem(
                                            label: '체감',
                                            value:
                                                '${weather.feelsLike.toStringAsFixed(0)}°C',
                                          ),
                                        ),
                                        Expanded(
                                          child: WeatherMetaItem(
                                            label: '습도',
                                            value: '${weather.humidity}%',
                                          ),
                                        ),
                                        Expanded(
                                          child: WeatherMetaItem(
                                            label: '바람',
                                            value:
                                                '${weather.windSpeed.toStringAsFixed(2)}m/s',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
