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
        margin: EdgeInsets.all(150),
        child: Column(
          children: [
            ...[
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Text(''),
                  ),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          filled: false,
                          hintText: "请输入项目名称",
                          labelText: "项目名称"),
                      onChanged: (value) {
                        project.projectId = value;
                      },
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Text(''),
                  )
                ],
              ),
              Row(
                children: [
                  const Expanded(
                    flex: 1,
                    child: Text(''),
                  ),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          filled: false,
                          hintText: "请输入项目id",
                          labelText: "项目id"),
                      onChanged: (value) {
                        project.projectName = value;
                      },
                    ),
                  ),
                  const Expanded(
                    flex: 1,
                    child: Text(''),
                  )
                ],
              ),
              Container(
                padding: const EdgeInsets.only(
                    left: 30, top: 10, right: 30, bottom: 10),
                decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                child: TextButton(
                    onPressed: () {
                      _saveProjectToServer();
                    },
                    child: const Text(
                      "确认",
                      style: TextStyle(color: Colors.white),
                    )),
              )
            ].expand(
              (element) => [
                element,
                const SizedBox(
                  height: 50,
                  width: 50,
                )
              ],
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
        print("false${value.msg}");
        Navigator.pop(context);
      }
    });
  }
}
