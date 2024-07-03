import 'package:flutter/material.dart';
import 'package:minimum/features/applications/widgets/applications_header.dart';
import 'package:minimum/features/applications/widgets/applications_search_bar.dart';
import 'package:minimum/features/applications/widgets/grid_entry.dart';
import 'package:minimum/features/applications/widgets/sliver_applications.dart';

class ApplicationsScreen extends StatelessWidget {
  static final String route = '$ApplicationsScreen';

  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ApplicationsHeader(),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                ApplicationsSearchBar(
                  onChange: (query) {},
                ),
                const Divider(height: 0),
              ],
            ),
          ),
          // Todo(remove mocked apps)
          SliverApplications(
            layout: SliverApplicationsGridLayout(
              children: List.generate(
                30,
                (index) {
                  return GridEntry(
                    icon: const Placeholder(),
                    label: 'App $index',
                    onTap: () {},
                  );
                },
              ),
              delegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
