import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:frontend/core/widgets/bottom_nav_bar.dart';
import 'package:frontend/core/widgets/gradient_button.dart';

import '../viewmodels/weather_viewmodel.dart';
import '../viewmodels/region_summary_viewmodel.dart';
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
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: const Color(0xffffffff),
        surfaceTintColor: const Color(0xffffffff),
        scrolledUnderElevation: 0,
        title: const Text(
          '모행',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '제주에서 함께할\n여행친구를 찾아보세요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: GradientButton(
                      text: "동행 모집하기",
                      leftColor: const Color(0xff35C7B5),
                      rightColor: const Color(0xffD7E76C),
                      onTap: () {
                        Navigator.pushNamed(context, '/meetingcreate');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      text: "동행 참여하기",
                      leftColor: const Color(0xff6ED0FF),
                      rightColor: const Color(0xff4CC8D1),
                      onTap: () {
                        Navigator.pushNamed(context, '/homemore');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '현재 모집중인 동행',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/homemore');
                    },
                    child: const Text(
                      '더보기 →',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color: Color(0xff7ED6C2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      JejuMapCard(
                        screenHeight: screenHeight,
                        summaries: summaries,
                      ),

                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xffE5E7EB),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 18,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: vm.isLoading
                            ? const SizedBox(
                                height: 90,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : vm.errorMessage != null
                            ? SizedBox(
                                height: 90,
                                child: Center(
                                  child: Text(
                                    vm.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              )
                            : weather == null
                            ? const SizedBox(
                                height: 90,
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
                                              '오늘의 제주 날씨',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Image.network(
                                                  'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                                                  width: 42,
                                                  height: 42,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(
                                                        Icons.cloud_outlined,
                                                        size: 36,
                                                        color: Color(
                                                          0xff7ED6C2,
                                                        ),
                                                      ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    '${weather.temp.toStringAsFixed(0)}°C ${weather.description}',
                                                    style: const TextStyle(
                                                      fontSize: 28,
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
                                      const SizedBox(width: 12),
                                      Image.asset(
                                        'assets/images/weather.png',
                                        width: 72,
                                        height: 72,
                                        fit: BoxFit.contain,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Divider(
                                    height: 1,
                                    color: Color(0xffE5E7EB),
                                  ),
                                  const SizedBox(height: 10),
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

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
