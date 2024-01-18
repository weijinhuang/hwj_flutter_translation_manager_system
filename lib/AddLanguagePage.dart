import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/net.dart';
import 'common/theme.dart';

class AddLanguagePage extends StatefulWidget {
  Project project;
  List<Language> localLanguageList = [];

  AddLanguagePage(this.project, this.localLanguageList);

  @override
  State<StatefulWidget> createState() => _AddLanguagePageState();
}

class _AddLanguagePageState extends State<AddLanguagePage> {
  List<Language> mLanguageList = [];

  String _newLanguageName = "";
  String _newLanguageDes = "";
  List<String> localLanguageNameList = [];

  int originalColor = Colors.lightBlueAccent.value;
  int unSelectedColor = Colors.white.value;
  int selectedColor = Colors.blueAccent.value;

  @override
  void initState() {
    super.initState();
    if (widget.localLanguageList.isNotEmpty) {
      for (Language language in widget.localLanguageList) {
        localLanguageNameList.add(language.languageName);
      }
    }
    mLanguageList = [
      Language("en", "英语", widget.project.projectId),
      Language("zh-CN", "中文（简体）", widget.project.projectId),
      Language("zh-TW", "中文（繁体）", widget.project.projectId),
      Language("fr", "法语", widget.project.projectId),
      Language("it", "意大利语", widget.project.projectId),
      Language("ja", "日语", widget.project.projectId),
      Language("de", "德语", widget.project.projectId),
      Language("pl", "波兰语", widget.project.projectId),
      Language("ko", "韩语", widget.project.projectId),
      Language("pt", "葡萄牙语（葡萄牙、巴西）", widget.project.projectId),
      Language("ru", "俄语", widget.project.projectId),
      Language("hr", "克罗地亚语", widget.project.projectId),
      Language("cs", "捷克语", widget.project.projectId),
      Language("es", "西班牙语", widget.project.projectId),
      Language("sv", "瑞典语", widget.project.projectId),
      Language("af", "南非荷兰语", widget.project.projectId),
      Language("sq", "阿尔巴尼亚语", widget.project.projectId),
      Language("am", "阿姆哈拉语", widget.project.projectId),
      Language("ar", "阿拉伯语", widget.project.projectId),
      Language("hy", "亚美尼亚文", widget.project.projectId),
      Language("as", "阿萨姆语", widget.project.projectId),
      Language("ay", "艾马拉语", widget.project.projectId),
      Language("az", "阿塞拜疆语", widget.project.projectId),
      Language("bm", "班巴拉语", widget.project.projectId),
      Language("eu", "巴斯克语", widget.project.projectId),
      Language("be", "白俄罗斯语", widget.project.projectId),
      Language("bn", "孟加拉文", widget.project.projectId),
      Language("bho", "博杰普尔语", widget.project.projectId),
      Language("bs", "波斯尼亚语", widget.project.projectId),
      Language("bg", "保加利亚语", widget.project.projectId),
      Language("ca", "加泰罗尼亚语", widget.project.projectId),
      Language("ceb", "宿务语", widget.project.projectId),
      Language("co", "科西嘉语", widget.project.projectId),
      Language("da", "丹麦语", widget.project.projectId),
      Language("dv", "迪维希语", widget.project.projectId),
      Language("doi", "多格来语", widget.project.projectId),
      Language("nl", "荷兰语", widget.project.projectId),
      Language("eo", "世界语", widget.project.projectId),
      Language("et", "爱沙尼亚语", widget.project.projectId),
      Language("ee", "埃维语", widget.project.projectId),
      Language("fil", "菲律宾语（塔加拉语）", widget.project.projectId),
      Language("fi", "芬兰语", widget.project.projectId),
      Language("fy", "弗里斯兰语", widget.project.projectId),
      Language("gl", "加利西亚语", widget.project.projectId),
      Language("ka", "格鲁吉亚语", widget.project.projectId),
      Language("el", "希腊文", widget.project.projectId),
      Language("gn", "瓜拉尼人", widget.project.projectId),
      Language("gu", "古吉拉特文", widget.project.projectId),
      Language("ht", "海地克里奥尔语", widget.project.projectId),
      Language("ha", "豪萨语", widget.project.projectId),
      Language("haw", "夏威夷语", widget.project.projectId),
      Language("he", "希伯来语", widget.project.projectId),
      Language("hi", "印地语", widget.project.projectId),
      Language("hmn", "苗语", widget.project.projectId),
      Language("hu", "匈牙利语", widget.project.projectId),
      Language("is", "冰岛语", widget.project.projectId),
      Language("ig", "伊博语", widget.project.projectId),
      Language("ilo", "伊洛卡诺语", widget.project.projectId),
      Language("id", "印度尼西亚语", widget.project.projectId),
      Language("ga", "爱尔兰语", widget.project.projectId),
      Language("jv", "爪哇语", widget.project.projectId),
      Language("kn", "卡纳达文", widget.project.projectId),
      Language("kk", "哈萨克语", widget.project.projectId),
      Language("km", "高棉语", widget.project.projectId),
      Language("rw", "卢旺达语", widget.project.projectId),
      Language("gom", "贡根语", widget.project.projectId),
      Language("kri", "克里奥尔语", widget.project.projectId),
      Language("ku", "库尔德语", widget.project.projectId),
      Language("ckb", "库尔德语（索拉尼）", widget.project.projectId),
      Language("ky", "吉尔吉斯语", widget.project.projectId),
      Language("lo", "老挝语", widget.project.projectId),
      Language("la", "拉丁文", widget.project.projectId),
      Language("lv", "拉脱维亚语", widget.project.projectId),
      Language("ln", "林格拉语", widget.project.projectId),
      Language("lt", "立陶宛语", widget.project.projectId),
      Language("lg", "卢干达语", widget.project.projectId),
      Language("lb", "卢森堡语", widget.project.projectId),
      Language("mk", "马其顿语", widget.project.projectId),
      Language("mai", "迈蒂利语", widget.project.projectId),
      Language("mg", "马尔加什语", widget.project.projectId),
      Language("ms", "马来语", widget.project.projectId),
      Language("ml", "马拉雅拉姆文", widget.project.projectId),
      Language("mt", "马耳他语", widget.project.projectId),
      Language("mi", "毛利语", widget.project.projectId),
      Language("mr", "马拉地语", widget.project.projectId),
      Language("mni-Mtei", "梅泰语（曼尼普尔语）", widget.project.projectId),
      Language("lus", "米佐语", widget.project.projectId),
      Language("mn", "蒙古文", widget.project.projectId),
      Language("my", "缅甸语", widget.project.projectId),
      Language("ne", "尼泊尔语", widget.project.projectId),
      Language("no", "挪威语", widget.project.projectId),
      Language("ny", "尼杨扎语（齐切瓦语）", widget.project.projectId),
      Language("or", "奥里亚语（奥里亚）", widget.project.projectId),
      Language("om", "奥罗莫语", widget.project.projectId),
      Language("ps", "普什图语", widget.project.projectId),
      Language("fa", "波斯语", widget.project.projectId),
      Language("pa", "旁遮普语", widget.project.projectId),
      Language("qu", "克丘亚语", widget.project.projectId),
      Language("ro", "罗马尼亚语", widget.project.projectId),
      Language("sm", "萨摩亚语", widget.project.projectId),
      Language("sa", "梵语", widget.project.projectId),
      Language("gd", "苏格兰盖尔语", widget.project.projectId),
      Language("nso", "塞佩蒂语", widget.project.projectId),
      Language("sr", "塞尔维亚语", widget.project.projectId),
      Language("st", "塞索托语", widget.project.projectId),
      Language("sn", "修纳语", widget.project.projectId),
      Language("sd", "信德语", widget.project.projectId),
      Language("si", "僧伽罗语", widget.project.projectId),
      Language("sk", "斯洛伐克语", widget.project.projectId),
      Language("sl", "斯洛文尼亚语", widget.project.projectId),
      Language("so", "索马里语", widget.project.projectId),
      Language("su", "巽他语", widget.project.projectId),
      Language("sw", "斯瓦希里语", widget.project.projectId),
      Language("tl", "塔加路语（菲律宾语）", widget.project.projectId),
      Language("tg", "塔吉克语", widget.project.projectId),
      Language("ta", "泰米尔语", widget.project.projectId),
      Language("tt", "鞑靼语", widget.project.projectId),
      Language("te", "泰卢固语", widget.project.projectId),
      Language("th", "泰语", widget.project.projectId),
      Language("ti", "蒂格尼亚语", widget.project.projectId),
      Language("ts", "宗加语", widget.project.projectId),
      Language("tr", "土耳其语", widget.project.projectId),
      Language("tk", "土库曼语", widget.project.projectId),
      Language("ak", "契维语（阿坎语）", widget.project.projectId),
      Language("uk", "乌克兰语", widget.project.projectId),
      Language("ur", "乌尔都语", widget.project.projectId),
      Language("ug", "维吾尔语", widget.project.projectId),
      Language("uz", "乌兹别克语", widget.project.projectId),
      Language("vi", "越南语", widget.project.projectId),
      Language("cy", "威尔士语", widget.project.projectId),
      Language("xh", "班图语", widget.project.projectId),
      Language("yi", "意第绪语", widget.project.projectId),
      Language("yo", "约鲁巴语", widget.project.projectId),
      Language("zu", "祖鲁语", widget.project.projectId)
    ];
    for (Language element in mLanguageList) {
      if (localLanguageNameList.contains(element.languageName)) {
        element.color = originalColor;
      } else {
        element.color = unSelectedColor;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 10,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: () {
              List<Language> selectedLanguageList = [];
              for (Language language in mLanguageList) {
                if (language.color == selectedColor) {
                  selectedLanguageList.add(language);
                }
              }
              if (selectedLanguageList.isNotEmpty) {
                Navigator.of(context).pop(selectedLanguageList);
              }
            },
            icon: const Icon(Icons.save),
            tooltip: "保存语言",
          ),
          const Text("        ")
        ],
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 50, bottom: 20),
            child: const Center(
                child: Text(
              "----点击选择语言----",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: GridView.builder(
                shrinkWrap: true,
                itemCount: mLanguageList.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(mainAxisSpacing: 10, crossAxisSpacing: 10, crossAxisCount: 6, childAspectRatio: 5),
                itemBuilder: (context, index) {
                  if (index == mLanguageList.length) {
                    return buildAddNewLanguageButton();
                  } else {
                    Language language = mLanguageList[index];
                    return buildCustomerLanguageItem(language);
                  }
                }),
          ),
        ],
      ),
    );
  }

  Widget buildCustomerLanguageItem(Language language) {
    Color textColor = Colors.black;
    if (language.color == unSelectedColor) {
      textColor = Colors.black;
    } else {
      textColor = Colors.white;
    }
    return GestureDetector(
      onTap: () {
        if (language.color == originalColor) {
          showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  title: Text("已有语言不能取消"),
                );
              });
        } else {
          if (language.color == selectedColor) {
            language.color = unSelectedColor;
          } else {
            language.color = selectedColor;
          }
          setState(() {});
        }
      },
      child: Card(
          elevation: 2,
          color: Color(language.color??unSelectedColor),
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: Center(
            child: Text(
              "${language.languageDes}(${language.languageName})",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor),
            ),
          )),
    );
  }

  Widget buildAddNewLanguageButton() {
    return GestureDetector(
      onTap: () async {
        var language = await showDialog(
            context: context,
            builder: (context) {
              return showAddLanguageDialog();
            });
        if (language != null) {
          setState(() {
            mLanguageList.add(language);
          });
        }
      },
      child: Card(
          elevation: 2,
          color: Color(unSelectedColor),
          shadowColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "添加自定义语言",
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
                Icon(Icons.add_circle)
              ],
            ),
          )),
    );
  }

  Widget showAddLanguageDialog() {
    return AlertDialog(
      elevation: 10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("添加新语言"),
      content: SizedBox(
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 500,
              height: 100,
              child: TextFormField(
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))), filled: false, hintText: "请输入语言id（如cn）", labelText: "语言id"),
                onChanged: (value) {
                  _newLanguageName = value;
                },
              ),
            ),
            SizedBox(
              width: 500,
              height: 200,
              child: TextFormField(
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5))), filled: false, hintText: "请输入语言名字（如中文）", labelText: "语言名字"),
                onChanged: (value) {
                  _newLanguageDes = value;
                },
              ),
            )
          ],
        ),
      ),
      actions: [
        SizedBox(
            width: 200,
            height: 30,
            child: TextButton(
                onPressed: () {
                  Navigator.pop(context, null);
                },
                child: const Text("取消"))),
        SizedBox(
            width: 200,
            height: 30,
            child: TextButton(
              onPressed: () {
                var language = Language(_newLanguageName, _newLanguageDes, widget.project.projectId);
                language.color = selectedColor;
                Navigator.pop(context, language);
              },
              child: const Text(
                "确定",
                style: TextStyle(color: Colors.blueAccent),
              ),
            )),
      ],
    );
  }
}
