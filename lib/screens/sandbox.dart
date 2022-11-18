import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:knocky/controllers/counterController.dart';

class SandboxScreen extends StatelessWidget {
  final CounterController controller = Get.put(CounterController());

  void apiTest() async {
    print('Calling api');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sandbox page'),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: apiTest,
                child: Text('Api test'),
              ),
              Obx(() => Text(controller.counter.toString())),
              Text("Sandbox Page"),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: Icon(Icons.plus_one),
      ),
    );
  }
}
