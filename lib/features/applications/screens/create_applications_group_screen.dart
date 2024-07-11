import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:minimum/features/applications/blocs/applications_manager/applications_manager_cubit.dart';
import 'package:minimum/features/applications/widgets/application_avatar.dart';
import 'package:minimum/features/applications/widgets/application_icon.dart';
import 'package:minimum/features/applications/widgets/applications_group_icon.dart';
import 'package:minimum/features/applications/widgets/entry_widget.dart';
import 'package:minimum/features/applications/widgets/grid_entry.dart';
import 'package:minimum/features/applications/widgets/sliver_applications.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/main.dart';
import 'package:minimum/models/application.dart';
import 'package:minimum/routes.dart';
import 'package:minimum/widgets/warning_container.dart';

class CreateApplicationsGroupScreenArguments {
  final void Function(
    String title,
    String? description,
    Set<String> packages,
  ) onConfirm;

  CreateApplicationsGroupScreenArguments({required this.onConfirm});

  static CreateApplicationsGroupScreenArguments of(BuildContext context) {
    return ModalRoute.of(context)!.arguments();
  }
}

class CreateApplicationsGroupScreen extends StatefulWidget {
  static final String route = '$CreateApplicationsGroupScreen';

  const CreateApplicationsGroupScreen({super.key});

  @override
  CreateApplicationsGroupScreenState createState() =>
      CreateApplicationsGroupScreenState();
}

class CreateApplicationsGroupScreenState
    extends State<CreateApplicationsGroupScreen> {
  late final arguments = CreateApplicationsGroupScreenArguments.of(context);
  final packages = ValueNotifier<Set<String>>({});

  @override
  void dispose() {
    packages.dispose();
    super.dispose();
  }

  void _onConfirm(BuildContext context) async {
    final packages = this.packages.value;
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return _ConfirmationBottomSheet(
          packages: packages,
          onConfirm: (title, description) {
            Navigator.pop(context);
            arguments.onConfirm(title, description, packages);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final translation = Translations.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: ValueListenableBuilder(
          valueListenable: packages,
          builder: (context, packages, child) {
            final isEnabled = packages.length >= 2;

            return AnimatedScale(
              duration: kThemeAnimationDuration,
              scale: isEnabled ? 1 : 0,
              child: FloatingActionButton.extended(
                onPressed: isEnabled
                    ? () {
                        _onConfirm(context);
                      }
                    : null,
                label: Text(translation.confirm),
                icon: const Icon(
                  Icons.save,
                ),
              ),
            );
          }),
      body: _GroupManager(
        initial: packages.value,
        onChange: (packages) {
          this.packages.value = packages;
        },
      ),
    );
  }
}

class _GroupManager extends StatefulWidget {
  final Set<String> initial;
  final void Function(Set<String> packages) onChange;

  const _GroupManager({
    super.key,
    this.initial = const {},
    required this.onChange,
  });

  @override
  State<_GroupManager> createState() => _GroupManagerState();
}

class _GroupManagerState extends State<_GroupManager> {
  late final Set<String> group = widget.initial;

  // Group scroll controller
  final scroll = ScrollController();

  Timer? _debounce;

  void debounce(
    void Function() callback, [
    Duration duration = const Duration(milliseconds: 400),
  ]) {
    if (_debounce?.isActive == true) {
      _debounce?.cancel();
    }
    _debounce = Timer(duration, callback);
  }

  void clearSelected() {
    if (group.isNotEmpty) {
      setState(() {
        group.clear();
      });
    }
  }

  void addSelected(String package) {
    group.add(package);
    debounce(() {
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.fastOutSlowIn,
        );
      });
    });
  }

  void removeSelected(String package) {
    if (group.remove(package)) {}
    debounce(() {
      setState(() {});
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    widget.onChange(Set.from(group));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translation = Translations.of(context);
    final theme = Theme.of(context);
    return BlocBuilder(
      bloc: dependencies<ApplicationsManagerCubit>(),
      builder: (context, state) {
        if (state is! ApplicationsManagerFetchSuccess) {
          return const SizedBox.shrink();
        }

        final group = this.group.toList();
        final unselected = <Application>[];
        final selected = <Application>[];

        for (final application in state.applications) {
          if (group.contains(application.package)) {
            selected.add(application);
          } else {
            unselected.add(application);
          }
        }
        selected.sort((a, b) {
          return group.indexOf(a.package).compareTo(group.indexOf(b.package));
        });
        unselected.sort((a, b) {
          return a.label.toLowerCase().compareTo(b.label.toLowerCase());
        });

        return Column(children: [
          Expanded(
            child: _Card(
                child: CustomScrollView(
              controller: scroll,
              slivers: [
                SliverAppBar.medium(
                  leading: const BackButton(),
                  title: Text(translation.added),
                  actions: [
                    IconButton(
                      onPressed: clearSelected,
                      icon: const Icon(
                        Icons.clear_all,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                if (selected.isNotEmpty)
                  _SliverList(
                    isGroup: true,
                    applications: selected,
                    onTap: (application) {
                      removeSelected(application.package);
                    },
                  )
                else
                  SliverFillRemaining(
                    child: WarningContainer(
                      icon: Icons.apps_outage,
                      message: translation.noApplicationsAddedOnGroup,
                      color: theme.colorScheme.onSurface,
                    ),
                  )
              ],
            )),
          ),
          const Divider(height: 0),
          Flexible(
            child: _Card(
                child: CustomScrollView(
              slivers: [
                SliverPadding(
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      translation.applications,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                ),
                if (unselected.isNotEmpty)
                  _SliverList(
                    applications: unselected,
                    onTap: (application) {
                      addSelected(application.package);
                    },
                  )
                else
                  SliverFillRemaining(
                    child: WarningContainer(
                      icon: Icons.apps_outage,
                      message: translation.allApplicationsAddedOnGroup,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
              ],
            )),
          ),
        ]);
      },
    );
  }
}

class _SliverList extends StatelessWidget {
  final List<Application> applications;
  final void Function(Application application) onTap;
  final bool isGroup;

  const _SliverList({
    required this.applications,
    required this.onTap,
    this.isGroup = false,
  });

  @override
  Widget build(BuildContext context) {
    const delegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      childAspectRatio: 1,
    );
    return SliverPadding(
      padding: isGroup
          ? const EdgeInsets.only(bottom: 24)
          : const EdgeInsets.only(bottom: 56 + 16),
      sliver: SliverApplications(
        layout: SliverApplicationsGridLayout(
          delegate: delegate,
          children: applications.map(
            (application) {
              return GridEntry(
                key: ValueKey(application.package),
                arguments: EntryWidgetArguments(
                  icon: _ApplicationAvatar(
                    application: application,
                    isSelected: isGroup,
                  ),
                  label: application.label,
                  onTap: () {
                    onTap(application);
                  },
                  onLongTap: () {},
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }
}

class _ApplicationAvatar extends StatelessWidget {
  final Application application;
  final bool isSelected;

  const _ApplicationAvatar({
    required this.application,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        isSelected ? theme.colorScheme.onTertiary : theme.colorScheme.onPrimary;
    final background =
        isSelected ? theme.colorScheme.tertiary : theme.colorScheme.primary;
    return Stack(
      alignment: Alignment.center,
      children: [
        ApplicationIcon(package: application.package),
        Align(
          alignment: Alignment.topRight * 2,
          child: ApplicationTag(
            foreground: foreground,
            background: background,
            icon: isSelected ? Icons.remove_circle : Icons.add_circle,
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: child,
    );
  }
}

class _ConfirmationBottomSheet extends StatefulWidget {
  final String? title;
  final String? description;
  final Set<String> packages;
  final void Function(String title, String? description) onConfirm;

  const _ConfirmationBottomSheet({
    super.key,
    this.title,
    this.description,
    required this.packages,
    required this.onConfirm,
  });

  @override
  State<_ConfirmationBottomSheet> createState() =>
      _ConfirmationBottomSheetState();
}

class _ConfirmationBottomSheetState extends State<_ConfirmationBottomSheet> {
  final form = GlobalKey<FormState>();
  late final title = TextEditingController(text: widget.title);
  late final description = TextEditingController(text: widget.description);

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translation = Translations.of(context);
    const inputDecoration = InputDecoration(
      border: OutlineInputBorder(),
    );
    final content = Form(
      key: form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: ApplicationsGroupIcon(packages: widget.packages),
            title: Text(translation.confirmGroup),
            subtitle: Text(
              translation.containNThing(
                count: widget.packages.length,
                thing: translation.applications.toLowerCase(),
              ),
            ),
            trailing: IconButton(
              onPressed: () {
                if (form.currentState?.validate() == true) {
                  Navigator.pop(context);
                  final description = this.description.text;
                  widget.onConfirm(
                    title.text,
                    description.isEmpty ? null : description,
                  );
                }
              },
              icon: const Icon(Icons.save),
            ),
          ),
          const Divider(height: 0),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextFormField(
              autofocus: true,
              controller: title,
              decoration: inputDecoration.copyWith(
                labelText: translation.title,
                hintText: translation.typeGroupName,
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textCapitalization: TextCapitalization.sentences,
              validator: (value) {
                if (value?.isEmpty == true) {
                  return translation.groupNameRequired;
                }

                return null;
              },
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextFormField(
              controller: description,
              decoration: inputDecoration.copyWith(
                labelText: translation.description,
                hintText: translation.addDescriptionOptional,
              ),
              maxLines: 3,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );

    return Padding(
      padding: MediaQuery.viewInsetsOf(context),
      child: content,
    );
  }
}
