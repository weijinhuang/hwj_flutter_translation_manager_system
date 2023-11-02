import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/AddProjectPage.dart';
import 'package:hwj_translation_flutter/MyCustomScrollBehavior.dart';
import 'package:hwj_translation_flutter/ProjectDetail.dart';
import 'package:hwj_translation_flutter/WJHttp.dart';
import 'DatableDemoPage.dart';
import 'DatableDemoPage2.dart';
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
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Translation manager system'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

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
    WJHttp().fetchProjects().then((projectsResult) {
      setState(() {
        projects.addAll(projectsResult.data);
      });
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
    return ListView.builder(
      itemBuilder: (context, index) {
        var project = projects[index];
        return Container(
          margin: const EdgeInsets.only(top: 50),
          child: GestureDetector(
            onTap: () {
              _toProjectDetailPage(project);
            },
            child: Center(
              child: Card(
                elevation: 10,
                shadowColor: Colors.blueAccent,
                clipBehavior: Clip.antiAlias,
                child: Container(
                  width: 100,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(left: 100, right: 100, top: 50, bottom: 50),
                  child: Text(project.projectName),
                ),
              ),
            ),
          ),
        );
      },
      itemCount: projects.length,
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
    // Navigator.of(context)
    //     .push(MaterialPageRoute(builder: (context) => DataTableDemoPage2(project)));
  }

  void _toAddProjectPage() async {
    Project project = await Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddProjectPage()));
    if (null != project) {
      fetchProjects();
    }
  }
}
