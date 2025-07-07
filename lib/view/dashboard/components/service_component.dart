import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:valuemate/models/constant_model/constant_model.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ServiceComponent extends StatelessWidget {
  final double? width;
  final Company serviceData;
  

  const ServiceComponent({
    this.width,
   
    Key? key, required this.serviceData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

 

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: context.cardColor,
        boxShadow: [
          BoxShadow(
            color: context.theme.dividerColor.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                    color: context.theme.highlightColor,
                    image: DecorationImage(
                      image: NetworkImage(serviceData.file ?? 'https://via.placeholder.com/300x200'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
               
               
                // Positioned(
                //   bottom: 8,
                //   right: 8,
                //   child: Container(
                //     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                //     decoration: BoxDecoration(
                //       color: context.theme.primaryColor,
                //       borderRadius: BorderRadius.circular(24),
                //       border: Border.all(color: context.theme.cardColor, width: 2),
                //     ),
                //     child: Text(
                //       '\$${serviceData.}',
                //       style: TextStyle(
                //         color: context.theme.textTheme.bodySmall?.color,
                //         fontSize: 14,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Marquee(
                  directionMarguee: DirectionMarguee.oneDirection,
                  child: Text(
                    serviceData.name, 
                    style: boldTextStyle(color: context.iconColor),
                  )
                ),
            
                // Row(
                //   children: [
                //     Expanded(
                //       child: Text(
                //         serviceData['city'] as String,
                //         style:secondaryTextStyle(size: 12, ),
                        
                //         maxLines: 1,
                //         overflow: TextOverflow.ellipsis,
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


