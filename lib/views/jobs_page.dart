import 'package:flutter/material.dart';
import 'package:renohouz_worker/models/job.dart';
import 'package:renohouz_worker/providers/location_provider.dart';
import 'package:renohouz_worker/utils/debugger.dart';
import 'package:renohouz_worker/views/search_page.dart';
import 'package:renohouz_worker/widgets/error_item.dart';
import 'package:provider/provider.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({Key? key}) : super(key: key);

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  late LocationProvider locationProvider;
  bool locationEnabled = true;
  bool isFetching = false;
  Future? jobsFuture;
  List<Job> jobs = [];
  int? count;

  String searchText = 'Search for jobs';
  ScrollController controller = ScrollController();

  void fetch() {
    if (jobs.length >= (count ?? 1)) return;
    Debugger.log("fetch jobs");
    setState(() {
      isFetching = true;
      jobsFuture = Job.find(
        searchText,
        locationProvider.data!.latitude!,
        locationProvider.data!.longitude!,
        jobs.length,
        jobs.isEmpty ? null : jobs.last.createdAt,
      );
      jobsFuture!.then((dynamic data) {
        if (count == null) {
          count = data['count'];
          jobs.addAll(data['jobs']);
        } else {
          jobs.addAll(data);
        }
      }).whenComplete(() => setState(() => isFetching = false));
    });
  }

  Future<void> getLocation() async {
    bool enabled = await locationProvider.enableLocationService();
    if (!enabled) {
      setState(() => locationEnabled = false);
      return;
    }
    bool granted = await locationProvider.enableLocationPermission();
    if (!granted) {
      setState(() => locationEnabled = false);
      return;
    }
    setState(() {
      locationEnabled = true;
    });
    locationProvider.streamLocation();
  }

  @override
  void initState() {
    super.initState();
    locationProvider = context.read<LocationProvider>();
    locationProvider.addListener(() {
      if (locationProvider.data != null) {
        fetch();
      }
    });
    getLocation();
    controller.addListener(() {
      if (controller.offset >= (controller.position.maxScrollExtent - 36) && !isFetching) fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!locationEnabled) {
      return const Center(child: Text('Please enable location service'));
    }

    if (locationProvider.data == null) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(),
            Text('Finding jobs near you...'),
          ],
        ),
      );
    }

    return SafeArea(
      child: Column(children: [
        InkWell(
          onTap: () async {
            var result = await Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation1, animation2) => SearchPage(
                  initialText: searchText,
                ),
                transitionDuration: const Duration(seconds: 0),
              ),
            );
            if (result != null) {
              searchText = result;
              count = null;
              jobs.clear();
              fetch();
            }
          },
          child: Container(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.search_rounded),
                const SizedBox(width: 8),
                Text(searchText),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey[200],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: controller,
            itemCount: jobs.length + 1,
            itemBuilder: (context, index) {
              if (jobs.isEmpty) {
                return const Center(child: Padding(padding: EdgeInsets.all(56.0), child: Text('No jobs found')));
              }
              if (index == jobs.length) {
                return FutureBuilder(
                  future: jobsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      if (snapshot.hasData) {
                        return const SizedBox();
                      } else {
                        return ErrorItem(onRetry: fetch);
                      }
                    }
                  },
                );
              }
              return JobItem(jobs.elementAt(index));
            },
          ),
        ),
      ]),
    );
  }
}

class JobItem extends StatelessWidget {
  final Job job;
  const JobItem(this.job, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Text(job.title),
    );
  }
}
