import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/AddProjectPage.dart';
import 'package:hwj_translation_flutter/MyCustomScrollBehavior.dart';
import 'package:hwj_translation_flutter/ProjectDetail.dart';
import 'package:hwj_translation_flutter/WJHttp.dart';
import 'common/theme.dart';
import 'net.dart';

void main() {
  runApp(const MyApp());
}

void setupWindow() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    WidgetsFlutterBinding.ensureInitialized();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '翻译管理系统',
      scrollBehavior: MyCustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const MyHomePage(title: 'Translation manager system'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> widgets = [];
  List<Project> projects = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchProjects();
  }

  void fetchProjects() {
    WJHttp().fetchProjectsV2().then((projectsResult) {
      if (projectsResult != null) {
        if (projectsResult.code == 200) {
          setState(() {
            projects.clear();
            projects.addAll(projectsResult.data);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: "添加项目",
        elevation: 30,
        onPressed: _toAddProjectPage,
        child: const Icon(Icons.add),
      ),
      body: buildBody(),
    );
  }

  Widget buildBody() {
    if (projects.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Container(
            margin: EdgeInsets.only(top: 50),
            child: Text(
              "Welcome to LongSe",
              style: Theme.of(context).textTheme.displayLarge,
            )),
        Expanded(
          child: ListView.builder(
            itemBuilder: (context, index) {
              var project = projects[index];
              return Container(
                margin: const EdgeInsets.only(top: 50),
                child: Center(
                  child: Stack(alignment: AlignmentDirectional(1, -1), children: [
                    GestureDetector(
                      onTap: () {
                        _toProjectDetailPage(project);
                      },
                      child: Container(
                        width: 250,
                        height: 100,
                        decoration: BoxDecoration(color: Colors.primaries[index], borderRadius: BorderRadius.circular(5)),
                        alignment: Alignment.center,
                        child: Text(
                          project.projectId,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("是否删除项目？"),
                                content: const Text("删除项目会把该项目所有数据清空！"),
                                actions: [
                                  GestureDetector(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
                                      child: const Text("取消"),
                                    ),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
                                      child: const Text(
                                        "确定",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    onTap: () {
                                      deleteProjectRemote(project);
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              );
                            });
                      },
                      child: Container(
                        margin: const EdgeInsets.all(5),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ]),
                ),
              );
            },
            itemCount: projects.length,
          ),
        ),
      ],
    );
  }

  Widget _getProjectItem(Project project) {
    return GestureDetector(
      onTap: () {
        _toProjectDetailPage(project);
      },
      child: Card(
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        child: Text(project.projectId),
      ),
    );
  }

  void _toProjectDetailPage(Project project) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProjectDetail(project)));
  }

  void _toAddProjectPage() async {
    Project? project = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddProjectPage(projects)));
    if (null != project) {
      fetchProjects();
    }
  }

  void deleteProjectRemote(Project project) {
    WJHttp().deleteProjectV2(project).then((value) {
      fetchProjects();
    });
  }
}
