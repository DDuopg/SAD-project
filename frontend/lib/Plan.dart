import 'package:flutter/material.dart';
import 'package:sa/api_service.dart';

class PlanPage extends StatefulWidget{
  final DateTime selectedDay;
  final VoidCallback? onRefresh;

  const PlanPage({Key? key, required this.selectedDay, this.onRefresh}) : super(key: key);

  @override
  _PlanPageState createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage>{
  final ApiService _apiService = ApiService();
  late List<Map<String, dynamic>> _plans;
  bool _isLoading = true;
  String _formatDate(String date){
    try{
      final DateTime parsedDate = DateTime.parse(date);
      return '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}';
    }catch(e){
      return date;
    }
  }

  @override
  void initState(){
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans()async{
    try{
        final plans = await _apiService.getPlanByDate(widget.selectedDay);
        setState(() {
          _plans = plans;
          _isLoading = false;
        });
    }catch(e){
      print('Error fetching plans: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plans for ${widget.selectedDay.toLocal().toString().split(' ')[0]}'),
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _plans.isEmpty
          ? const Center(child: Text('No plans for this day'))
          : ListView.builder(
              itemCount: _plans.length,
              itemBuilder: (context, index){
                final plan = _plans[index];
                return ListTile(
                  title: Text('${index+1}. ${plan['name']}'),
                  onTap: (){
                    _showPlanDetail(context, plan);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showAddData(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddData(BuildContext context){
    DateTime? _startDate;
    DateTime? _endDate;

    final TextEditingController _name = TextEditingController();
    final TextEditingController _content = TextEditingController();
    final TextEditingController _points = TextEditingController();

    showDialog(context: context, builder: (BuildContext context){
      return StatefulBuilder(builder: (BuildContext context,  StateSetter setState){
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 10),
                const Text("Start day: "),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: ()async{
                        final date = await showDatePicker(
                          context: context, 
                          initialDate: widget.selectedDay, 
                          firstDate: DateTime.now(), 
                          lastDate: DateTime.utc(2025, 12, 31),
                        );
                        if(date != null){
                          setState(() => _startDate = date);
                        }
                      }, 
                      child: Text(_startDate == null
                        ? 'Select Date'
                        : _startDate!.toLocal().toString().split(' ')[0]),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text("End day: "),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: ()async{
                        final date = await showDatePicker(
                          context: context, 
                          initialDate: widget.selectedDay, 
                          firstDate: DateTime.now(), 
                          lastDate: DateTime.utc(2025, 12, 31),
                        );
                        if(date != null){
                          setState(() => _endDate = date);
                        }
                      }, 
                      child: Text(_endDate == null
                        ? 'Select Date'
                        : _endDate!.toLocal().toString().split(' ')[0]),
                    ),
                  ],
                ),
                TextField(
                  controller: _content,
                  decoration: const InputDecoration(labelText: 'Content'),
                  maxLines: 3,
                ),
                TextField(
                  controller: _points,
                  decoration: const InputDecoration(labelText: 'Points'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: ()async{
                
                final plan = {
                  'name': _name.text,
                  'status': "todo",
                  'startDate': _startDate?.toLocal().toString().split(' ')[0],
                  'endDate': _endDate?.toLocal().toString().split(' ')[0],
                  'content': _content.text,
                  'points': int.tryParse(_points.text) ?? 0,
                };
                try{
                  await _apiService.addPlan(plan);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Plan added successfully')),
                  );
                  Navigator.pop(context);
                  _fetchPlans();
                  if(widget.onRefresh != null){
                      widget.onRefresh!();
                    }
                }catch(e){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$e')),
                  );
                }
              }, 
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              }, 
              child: const Text('Cancel'),
            ),
          ],
        );
      },
      );
    },
    );  
  }

  void _showPlanDetail(BuildContext context, Map<String, dynamic> plan){
    final bool isTodo = plan['status'] =='todo';

    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: Text(plan['name']),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Status: ${plan['status']}'),
            Text('Start day: ${_formatDate(plan['startDate'])}'),
            Text('End day: ${_formatDate(plan['endDate'])}'),
            Text('Content: ${plan['content']}'),
            Text('Points: ${plan['points']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text('Back'),
          ),
          if(isTodo) ...[
            TextButton(
              onPressed: (){
                _showEditData(context, plan);
              }, 
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: (){
                _showDeleteData(context, plan);
              }, 
              child: const Text('Delete'),
            ),
          ]else if(plan['status'] == 'ongoing') ...[
            Text(
              'Cannot edit or delete ongoing plan',
              style: TextStyle(color: Colors.grey[600]),  
            ),
          ]else if(plan['status'] == 'expired')...[
            Text(
              'Cannot edit or delete past plan',
              style: TextStyle(color: Colors.grey[600]),  
            ),
          ]else if(plan['status'] == 'completed')...[
            Text(
              'Cannot edit or delete completed plan',
              style: TextStyle(color: Colors.grey[600]),
            ), 
          ]           
        ],    
      );
    },
    );
  }

  void _showEditData(BuildContext context, Map<String, dynamic> plan){
    final TextEditingController _name = TextEditingController(text: plan['name']);
    final TextEditingController _content = TextEditingController(text: plan['content']);
    final TextEditingController _points = TextEditingController(text: plan['points'].toString());
    DateTime? _startDate = DateTime.parse(plan['startDate']);
    DateTime? _endDate = DateTime.parse(plan['endDate']);

    showDialog(context: context, builder: (BuildContext context){
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState){
          return AlertDialog(
            title: const Text('Edit Plan'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                  
                  ),
                  const SizedBox(height: 10),
                  const Text('Start day'),
                  ElevatedButton(onPressed: ()async{
                    final date = await showDatePicker(
                      context: context, 
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime.now(), 
                      lastDate: DateTime.utc(2025, 12, 31),
                    );
                    if(date != null){
                      setState((){
                        _startDate = date;
                      });
                    }
                  }, 
                  child: Text(_startDate == null
                    ? 'Select Date'
                    : _startDate!.toLocal().toString().split(' ')[0]),
                  ),
                  const SizedBox(height: 10),
                  const Text('End day'),
                  ElevatedButton(onPressed: ()async{
                    final date = await showDatePicker(
                      context: context, 
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime.now(), 
                      lastDate: DateTime.utc(2025, 12, 31),
                    );
                    if(date != null){
                      setState((){
                        _endDate = date;
                      });
                    }
                  }, 
                  child: Text(_endDate == null
                    ? 'Select Date'
                    : _endDate!.toLocal().toString().split(' ')[0]),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _content,
                    decoration: const InputDecoration(labelText: 'Content'),
                    maxLines: 3,
                  ),
                  TextField(
                    controller: _points,
                    decoration: const InputDecoration(labelText: 'Points'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: ()async{
                  final updates = {
                    'name': _name.text,
                    'status': "todo",
                    'startDate': _startDate?.toLocal().toString().split(' ')[0],
                    'endDate': _endDate?.toLocal().toString().split(' ')[0],
                    'content': _content.text,
                    'points': int.tryParse(_points.text) ?? 0,
                  };
                  try{
                    await _apiService.updatePlan(plan['id'], updates);
                    Navigator.pop(context);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Plan Updated successfully')),
                    );
                    _fetchPlans();
                    if(widget.onRefresh != null){
                      widget.onRefresh!();
                    }
                  }catch(e){
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$e')),
                    );
                  }
                }, 
                child: const Text('Save'),
              ),
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                }, 
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
    );
  }

  void _showDeleteData(BuildContext context, Map<String, dynamic> plan){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete the plan?'),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            }, 
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: ()async{
              try{
                await _apiService.deletePlan(plan['id']);
                setState(() {
                  _plans.remove(plan);
                });
                if(widget.onRefresh != null){
                      widget.onRefresh!();
                 }
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Plan deleted successfully')),
                );
                _fetchPlans();
                if(widget.onRefresh != null){
                  widget.onRefresh!();
                }
              }catch(e){
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting plan: $e')),
                  );
              }
            }, 
            child: const Text('Delete'),
          ),
        ],
      );
    },
    );
  }
}