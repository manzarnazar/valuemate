import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/view/dashboard/shimmer_widget.dart';

class DashboardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          /// Slider UI
          ShimmerWidget(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 220,
                  width: context.width(),
                  color: context.cardColor,
                ),
                Positioned(
                  bottom: -24,
                  right: 16,
                  left: 16,
                  child: ShimmerWidget(
                    child: Container(
                      height: 60,
                      decoration: boxDecorationWithRoundedCorners(
                        borderRadius: radius(),
                        backgroundColor: context.cardColor,
                        border: Border.all(color: context.dividerColor),
                      ),
                      width: context.width(),
                      // decoration: boxDecorationWithRoundedCorners(backgroundColor:   context.cardColor),
                    ),
                  ),
                )
              ],
            ),
          ),
          50.height,
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerWidget(height: 20, width: context.width() * 0.25),
                ],
              ).paddingSymmetric(horizontal: 16),
              16.height,
            ],
          ),

// 5.height,

          ShimmerWidget(
            child: Row(
              children: List.generate(4, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 7),
                  height: 90,
                  decoration: boxDecorationWithRoundedCorners(
                    borderRadius: radius(),
                    backgroundColor: context.cardColor,
                    border: Border.all(color: context.dividerColor),
                  ),
                  width: 80,
                );
              }),
            ),
          ),

          20.height,

          /// Service List UI
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerWidget(height: 20, width: context.width() * 0.25),
                ],
              ).paddingSymmetric(horizontal: 16),
              16.height,
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(4, (index) {
                  return Container(
                    width: context.width() / 2 - 26,
                    decoration: boxDecorationWithRoundedCorners(
                      borderRadius: radius(),
                      backgroundColor: context.cardColor,
                      border: Border.all(color: context.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerWidget(
                            height: 140, width: context.width() / 2 - 26),
                        16.height,
                        ShimmerWidget(height: 10, width: context.width() * 0.5)
                            .paddingSymmetric(horizontal: 16),
                        16.height,
                        Row(
                          children: [
                            // ShimmerWidget(
                            //   child: Container(height: 30, width: 30, decoration: boxDecorationDefault(shape: BoxShape.circle, color: context.cardColor)),
                            // ),
                            8.width,
                            ShimmerWidget(height: 10, width: context.width())
                                .expand(),
                          ],
                        ).paddingSymmetric(horizontal: 16),
                        16.height,
                      ],
                    ),
                  );
                }),
              ).paddingSymmetric(horizontal: 16, vertical: 8)
            ],
          ),
        ],
      ),
    );
  }
}
