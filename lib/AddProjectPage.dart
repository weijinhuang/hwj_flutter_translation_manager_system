import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/WJHttp.dart';
import 'package:hwj_translation_flutter/net.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({Key? key}) : super(key: key);

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  Project project = Project("", "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "添加新项目",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextFormField(
              autofocus: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30))), filled: false, hintText: "请输入项目id", labelText: "项目id"),
              onChanged: (value) {
                project.projectId = value;
              },
            ),
            Container(
              margin: const EdgeInsets.only(top: 100),
              padding: const EdgeInsets.only(left: 30, top: 10, right: 30, bottom: 10),
              decoration: const BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.all(Radius.circular(30))),
              child: TextButton(
                  onPressed: () {
                    _saveProjectToServer();
                  },
                  child: const Text(
                    "确认",
                    style: TextStyle(color: Colors.white),
                  )),
            )
          ],
        ),
      ),
    );
  }

  void _saveProjectToServer() {
    print("_saveProjectToServer");
    WJHttp().addProject(project).then((value) {
      if (value.code == 200) {
        print("success");
        Navigator.pop(context, project);
      } else {
        return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(content: Text(value.msg), actions: [
                GestureDetector(
                  child: const Text("好的"),
                  onTap: () {
                    Navigator.pop(context);
                  },
                )
              ]);
            });
      }
    });
  }
}
