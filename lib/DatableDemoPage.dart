import 'dart:collection';
// import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:hwj_translation_flutter/WJHttp.dart';
import 'package:hwj_translation_flutter/net.dart';

import 'bean.dart';


class DataTableDemoPage extends StatefulWidget {
  DataTableDemoPage();



  @override
  State<StatefulWidget> createState() => _DataTableDemoState();
}

class _DataTableDemoState extends State<DataTableDemoPage> {
  var _sortAscending = true;
  int? _sortColumn;
  final dataModels = <DataModel>[
    DataModel( '我国',  14.1,  '亚洲'),
    DataModel( '美国', 2.42,   '北美洲'),
    DataModel( '俄罗斯', 1.43,   '欧洲'),
    DataModel( '巴西', 2.14,   '南美洲'),
    DataModel( '印度', 13.9,   '亚洲'),
    DataModel( '德国', 0.83,   '欧洲'),
    DataModel( '埃及', 1.04,   '非洲'),
    DataModel( '澳大利亚', 0.26,   '大洋洲'),
    DataModel( '印度', 13.9,   '亚洲'),
    DataModel( '德国', 0.83,   '欧洲'),
    DataModel( '埃及', 1.04,   '非洲'),
    DataModel( '澳大利亚', 0.26,   '大洋洲'),
    DataModel( '我国',  14.1,  '亚洲'),
    DataModel( '美国', 2.42,   '北美洲'),
    DataModel( '俄罗斯', 1.43,   '欧洲'),
    DataModel( '巴西', 2.14,   '南美洲'),
    DataModel( '印度', 13.9,   '亚洲'),
    DataModel( '德国', 0.83,   '欧洲'),
    DataModel( '埃及', 1.04,   '非洲'),
    DataModel( '澳大利亚', 0.26,   '大洋洲'),
    DataModel( '印度', 13.9,   '亚洲'),
    DataModel( '德国', 0.83,   '欧洲'),
    DataModel( '埃及', 1.04,   '非洲'),
    DataModel( '澳大利亚', 0.26,   '大洋洲'),
  ];
  Function(int, bool)? _sortCallback;
  @override
  void initState() {
    super.initState();
    _sortCallback = (int column, bool isAscending) {
      setState(() {
        _sortColumn = column;
        _sortAscending = isAscending;
      });
    };
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('DataTable'),
        backgroundColor: Colors.red[400]!,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            horizontalMargin: 10.0,
            showBottomBorder: true,
            sortAscending: _sortAscending,
            sortColumnIndex: _sortColumn,
            showCheckboxColumn: true,
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            columns: [
              const DataColumn(label: Text('国家')),
              DataColumn(
                label: const Text('人口（亿）'),
                numeric: true,
                onSort: _sortCallback,
              ),
              DataColumn(
                label: const Text('大洲'),
                onSort: _sortCallback,
              ),
              const DataColumn(label: Text('阐明')),
            ],
            rows: sortDataModels(),
          ),
        ),
      ),
    );
  }
  List<DataRow> sortDataModels() {
    dataModels.sort((dataModel1, dataModel2) {
      bool isAscending = _sortAscending;
      var result = 0;
      if (_sortColumn == 0) {
        result = dataModel1.nation.compareTo(dataModel2.nation);
      }
      if (_sortColumn == 1) {
        result = dataModel1.population.compareTo(dataModel2.population);
      }
      if (_sortColumn == 2) {
        result = dataModel1.continent.compareTo(dataModel2.continent);
      }
      if (isAscending) {
        return result;
      }
      return -result;
    });
    return dataModels
        .map((dataModel) => DataRow(
      onSelectChanged: (selected) {},
      cells: [
        DataCell(
          Text(dataModel.nation),
        ),
        DataCell(
          Text('${dataModel.population}'),
        ),
        DataCell(
          Text(dataModel.continent),
        ),
        const DataCell(
          Text('{"code":200,"msg":null,"data":[{"projectId":"CK","projectName":"com.longse.ck"},{"projectId":"com.wj.translation","projectName":"ç¿»è¯ç³»ç»"}]}'),
        ),
      ],
    ))
        .toList();
  }
}