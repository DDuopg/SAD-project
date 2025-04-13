import 'package:flutter/material.dart';
import 'package:sa/Plan.dart';
import 'package:sa/api_service.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDay;  // 用來存儲選中的日期
  late DateTime _focusedDay;   // 用來存儲當前顯示的日期
  late DateTime today;
  late DateTime formatToday;
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _plans = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();  // 初始選擇當前日期
    _focusedDay = DateTime.now();   // 初始聚焦在當前日期
    today = DateTime.now();
    formatToday = DateTime(today.year, today.month, today.day);
    _fetchAndShowData(context, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1), // 設置日曆顯示的開始日期
              lastDay: DateTime.utc(2025, 12, 31), // 設置日曆顯示的結束日期
              focusedDay: _focusedDay, // 設置當前顯示的日期
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day); // 判斷選中的日期
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;  // 更新選中的日期
                  _focusedDay = focusedDay;    // 更新當前顯示的日期
                });
                _fetchAndShowSelectedData(context, selectedDay);
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;  // 當頁面改變時，更新顯示的日期
                });
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: _plans.isNotEmpty
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "Today's Plan",
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _plans.length,
                      itemBuilder: (context, Index){
                        final plan = _plans[Index];
                        return ListTile(
                          title: Text('${Index+1}. ${plan['name']}'),
                        );
                      },
                    ),
                  ),
                ],
              )
              : const Center(
                child: Text('No plans for this day'),
                ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchAndShowData(BuildContext context, DateTime _focusedDay) async{
    try{
      final plans = await _apiService.getPlanByDate(_focusedDay);
      if(plans.isNotEmpty){
        setState(() {
          _plans = plans;
        });
      }
    }catch(e){
      print('Error fetching plans: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load plans: $e')),
        );
    }
  }

  Future<void> _fetchAndShowSelectedData(BuildContext context, DateTime selectedDay) async{
    try{ 
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlanPage(
            selectedDay: selectedDay,
            onRefresh: _refreshData,  
          ),
        ),
      );
    }catch(e){
      print("Error fetching plan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load plans: $e')),
      );
    }
  }

  Future<void> _refreshData()async{
    await _fetchAndShowData(context, formatToday);
  }
}