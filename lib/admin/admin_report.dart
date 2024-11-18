import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:my_luxe_house/admin/admin_dashboard.dart';
import 'package:my_luxe_house/admin/base_screen2.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<Map<String, dynamic>> allOrders = [];
  String? selectedYear;
  String? selectedBrand;
  String? selectedSerialNumber;
  List<String> years = [];
  List<String> brands = [];
  List<String> serialNumbers = [];
  Map<String, dynamic> metrics = {};

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

Future<void> fetchOrders({String? year, String? brand}) async {
  var url = Uri.parse('http://localhost:3000/orders');
  Map<String, String> queryParameters = {};
  if (year != null) queryParameters['year'] = year;
  if (brand != null) queryParameters['brand'] = brand;

  try {
    final response = await http.get(url.replace(queryParameters: queryParameters));
    if (response.statusCode == 200) {
      List<dynamic> fetchedOrders = json.decode(response.body);
      setState(() {
        allOrders = fetchedOrders.map((order) {
          DateTime addedAt = DateTime.parse(order['addedAt']);
          String year = addedAt.year.toString();
          if (!years.contains(year)) {
            years.add(year);
          }

          return {
            'orderId': order['_id'] ?? '',
            'products': (order['products'] as List).map((product) {
              return {
                'brand': product['brand'] ?? 'N/A',
                'serialNumber': product['serialNumber'] ?? 'N/A',
                'quantity': product['quantity'] ?? 0,
                'price': product['price'] ?? 0.0,
              };
            }).toList(),
            'addedAt': order['addedAt'],
          };
        }).toList();
        metrics = calculateMetrics();
        filterData(); 
      });
    } else {
      print('Failed to load orders: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching orders: $e');
  }
}

 void filterData() {
    brands.clear();
    serialNumbers.clear();
    if (selectedYear != null) {
      for (var order in allOrders) {
        DateTime addedAt = DateTime.parse(order['addedAt'] ?? DateTime.now().toString());
        if (addedAt.year.toString() == selectedYear) {
          for (var product in order['products']) {
            String brand = product['brand'] ?? 'N/A';
            String serialNumber = product['serialNumber'] ?? 'N/A';
            if (!brands.contains(brand)) {
              brands.add(brand);
            }
            if (!serialNumbers.contains(serialNumber)) {
              serialNumbers.add(serialNumber);
            }
          }
        }
      }
    }
    setState(() {
      metrics = calculateMetrics();
    });
  }

Map<String, dynamic> calculateMetrics() {
    int totalRevenue = 0;
    int orders = 0;
    Set<String> customers = {};

    for (var order in allOrders) {
      DateTime addedAt = DateTime.parse(order['addedAt'] ?? DateTime.now().toString());
      if (selectedYear == null || addedAt.year.toString() == selectedYear) {
        orders++;
        for (var product in order['products']) {
          totalRevenue += (product['quantity'] as int) * (product['price'] as int);
        }
        customers.add(order['orderId']);
      }
    }

    return {
      'totalRevenue': totalRevenue,
      'orders': orders,
      'customers': customers.length,
    };
  }

 Map<String, Map<String, int>> groupOrdersByBrandAndSerial(List<Map<String, dynamic>> orders) {
    Map<String, Map<String, int>> salesData = {};
    for (var order in orders) {
      for (var product in order['products']) {
        String brand = product['brand'] ?? 'N/A';
        String serialNumber = product['serialNumber'] ?? 'N/A';
        int quantity = product['quantity'] ?? 0;
        if (selectedBrand != null && selectedBrand != brand) continue;
        if (selectedSerialNumber != null && selectedSerialNumber != serialNumber) continue;

        if (!salesData.containsKey(brand)) {
          salesData[brand] = {};
        }

        if (!salesData[brand]!.containsKey(serialNumber)) {
          salesData[brand]![serialNumber] = 0;
        }

        salesData[brand]![serialNumber] = salesData[brand]![serialNumber]! + quantity;
      }
    }
    return salesData;
  }

  Widget buildDashboard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedYear,
                      hint: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Select Year'),
                      ),
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: FaIcon(FontAwesomeIcons.calendar),
                      ),
                      isExpanded: true,
                      underline: SizedBox(),
                      items: years.map((String year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(year),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedYear = value;
                          fetchOrders(year: selectedYear, brand: selectedBrand);
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedBrand,
                      hint: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Select Brand'),
                      ),
                      icon: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: FaIcon(FontAwesomeIcons.bagShopping),
                      ),
                      isExpanded: true,
                      underline: SizedBox(),
                      items: brands.map((String brand) {
                        return DropdownMenuItem<String>(
                          value: brand,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(brand),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBrand = value;
                          fetchOrders(year: selectedYear, brand: selectedBrand);
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildMetricCard('Total Revenue', '${metrics['totalRevenue'] ?? 0}', Colors.green),
              buildMetricCard('Orders', '${metrics['orders'] ?? 0}', Colors.blue),
              buildMetricCard('Customers', '${metrics['customers'] ?? 0}', Colors.orange),
            ],
          ),
          SizedBox(height: 16),
          SizedBox(
            height: 700,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: buildTopSellingProductsChart(),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: buildTopSellingBrandsChart(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: buildSalesTrendChart(),
          ),
          SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: buildSalesPerformanceChart(),
          ),
        ],
      ),
    );
  }

Widget buildMetricCard(String title, String value, Color color) {
    final formattedValue = title == 'Total Revenue'
        ? NumberFormat.currency(symbol: '฿').format(int.tryParse(value) ?? 0)
        : value;

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              formattedValue,
              style: TextStyle(fontSize: 24, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopSellingProductsChart() {
  Map<String, Map<String, int>> salesData = groupOrdersByBrandAndSerial(allOrders);
  List<BarChartGroupData> barGroups = [];
  List<String> brands = salesData.keys.toList(); 
  int index = 0;

  salesData.forEach((brand, serials) {
    serials.forEach((serial, quantity) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: quantity.toDouble(),
              color: Colors.indigo[900],
              width: 14,
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
      index++;
    });
  });

  return Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Top Selling Products',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < brands.length) {
                          return Text(
                            brands[value.toInt()], 
                            style: TextStyle(fontSize: 12),
                          );
                        } else {
                          return SizedBox(); 
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 30),
                  ),
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    tooltipPadding: EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        'Quantity: ${NumberFormat("#,##0").format(rod.toY.round())}', 
                        TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  Widget buildTopSellingBrandsChart() {
    Map<String, Map<String, int>> salesData =
        groupOrdersByBrandAndSerial(allOrders);
    List<PieChartSectionData> pieSections = salesData.entries.map((entry) {
      int totalSales = entry.value.values.reduce((a, b) => a + b);
      return PieChartSectionData(
        value: totalSales.toDouble(),
        title: entry.key,
        color: Colors.primaries[entry.key.length % Colors.primaries.length],
      );
    }).toList();

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Top Selling Brands',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: PieChart(
                PieChartData(sections: pieSections),
              ),
            ),
          ],
        ),
      ),
    );
  }
  List<PieChartSectionData> generateBrandSections() {
    Map<String, int> brandSales = {};

    for (var order in allOrders) {
      for (var product in order['products']) {
        String brand = product['brand'] ?? 'N/A';
        int quantity = product['quantity'] ?? 0;

        if (!brandSales.containsKey(brand)) {
          brandSales[brand] = 0;
        }
        brandSales[brand] = brandSales[brand]! + quantity;
      }
    }
    return brandSales.entries.map((entry) {
      return PieChartSectionData(
        color: Colors.primaries[brandSales.keys.toList().indexOf(entry.key) %
            Colors.primaries.length],
        value: entry.value.toDouble(),
        title: entry.key,
      );
    }).toList();
  }

Widget buildSalesTrendChart() {
  List<BarChartGroupData> barGroups = [];
  Map<int, int> monthlySales = {};

  for (var order in allOrders) {
    DateTime date = DateTime.parse(order['addedAt']);
    int month = date.month;
    int quantity = order['products'][0]['quantity'] ?? 0;

    if (!monthlySales.containsKey(month)) {
      monthlySales[month] = 0;
    }
    monthlySales[month] = monthlySales[month]! + quantity;
  }

  monthlySales.forEach((month, quantity) {
    barGroups.add(
      BarChartGroupData(
        x: month,
        barRods: [
          BarChartRodData(
            toY: quantity.toDouble(),
            color: Colors.green,
            width: 12,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0],
      ),
    );
  });

  return Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Monthly Sales Trend',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 225, 
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        return Text(
                          DateFormat('MMM').format(DateTime(0, value.toInt())),
                          style: TextStyle(fontSize: 12),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: EdgeInsets.all(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${DateFormat('MMM').format(DateTime(0, group.x.toInt()))}: ${rod.toY.round()} units',
                        TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildSalesPerformanceChart() {
  Map<String, double> salesPerformance = {};

  for (var order in allOrders) {
    for (var product in order['products']) {
      String brand = product['brand'] ?? 'N/A';
      double price = product['price'] ?? 0.0;
      int quantity = product['quantity'] ?? 0;
      double totalSale = price * quantity;

      if (salesPerformance.containsKey(brand)) {
        salesPerformance[brand] = salesPerformance[brand]! + totalSale;
      } else {
        salesPerformance[brand] = totalSale;
      }
    }
  }

  List<BarChartGroupData> barGroups = salesPerformance.entries.map((entry) {
    int index = salesPerformance.keys.toList().indexOf(entry.key);
    return BarChartGroupData(
      x: index,
      barRods: [
        BarChartRodData(
          toY: entry.value,
          color: Colors.blueAccent,
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }).toList();

  return Card(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sales Performance by Brand',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 225,
            child: BarChart(
              BarChartData(
                barGroups: barGroups,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        String brand =
                            salesPerformance.keys.elementAt(value.toInt());
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            brand,
                            style: TextStyle(fontSize: 10),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                      reservedSize: 60,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipPadding: EdgeInsets.all(8),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String brand =
                          salesPerformance.keys.elementAt(group.x.toInt());
                      return BarTooltipItem(
                        '$brand: ${NumberFormat.currency(symbol: '฿').format(rod.toY.toInt())}',
                        TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'Report',
      body: Container(
        color: const Color.fromARGB(255, 238, 242, 249),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: buildDashboard(),
          ),
        ),
      ),
      drawer: AdminDrawer(),
    );
  }
}
