import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:knocky/helpers/api.dart';
import 'package:knocky/models/rule.dart';

class ReportPostDialog extends StatefulWidget {
  const ReportPostDialog() : super();

  @override
  State<ReportPostDialog> createState() => _ReportPostDialogState();
}

const List<String> rules = <String>[];

class _ReportPostDialogState extends State<ReportPostDialog> {
  String? selectedRule = null;
  bool fetchingRules = true;
  late List<KnockoutRule>? rules;

  @override
  void initState() {
    super.initState();

    fetchRules();
  }

  Future<void> fetchRules() async {
    List<KnockoutRule>? rulesResult = await KnockoutAPI().rules();

    setState(() {
      fetchingRules = false;
      rules = rulesResult;
    });
  }

  Widget formContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        DropdownButton(
            value: selectedRule,
            hint: Text('Select rule...'),
            items: [
              ...rules!.map(
                (KnockoutRule rule) => DropdownMenuItem(
                    child: Text(rule!.title ?? 'N/A'), value: rule!.title),
              ),
            ],
            onChanged: (String? val) {
              setState(() {
                selectedRule = val!;
              });
            })
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Report post'),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400, minHeight: 100),
        child: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: fetchingRules
              ? Center(
                  child: Container(
                    child: CircularProgressIndicator(),
                    width: 50,
                    height: 50,
                  ),
                )
              : formContent(context),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false), child: Text('Cancel')),
        ElevatedButton(
            onPressed: () => Get.back(result: true), child: Text('Submit')),
      ],
    );
  }
}
