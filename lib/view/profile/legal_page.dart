import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:valuemate/view_models/services/contorller/terms_policy/terms_and_policy.dart';

class LegalPageView extends StatelessWidget {
  final bool isTerms;
  LegalPageView({super.key, required this.isTerms});

  final TermsAndPolicyController controller =
      Get.put(TermsAndPolicyController());

  @override
  Widget build(BuildContext context) {
    isTerms ? controller.fetchTerms() : controller.fetchPolicy();

    return Scaffold(
      appBar: AppBar(
        title: Text(isTerms ? 'Terms & Conditions' : 'Privacy Policy'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.error.value.isNotEmpty) {
          return Center(child: Text('Error: ${controller.error.value}'));
        } else if (controller.legalModel.value == null) {
          return const Center(child: Text('No content available.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Html(
            data: controller.legalModel.value!.content,
            style: {
              "*": Style(
                color: Theme.of(context).iconTheme.color, // Change this to any color you prefer

              ),
            },
          ),
        );
      }),
    );
  }
}
