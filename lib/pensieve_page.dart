import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'pensieve_model.dart';

class PensievePage extends StatelessWidget {
  final String title;

  const PensievePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PensieveModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: Center(
          child: model.thoughts == null
              ? ElevatedButton(
                  onPressed: model.initStorage,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(32),
                  ),
                  child: const Icon(Icons.lock_outlined, size: 96),
                )
              : model.hasData
                  ? ListView.builder(
                      itemBuilder: (context, index) {
                        final current = model.thoughts!.elementAt(index);
                        final uuid = current.uuid!;
                        return Dismissible(
                          key: ValueKey<String>(uuid),
                          child: ThoughtWidget(
                            thought: current,
                          ),
                          onDismissed: (direction) => model.deleteOne(uuid),
                        );
                      },
                      itemCount: model.thoughts!.length,
                    )
                  : const Text('Pensieve is empty'),
        ),
      ),
      floatingActionButton: model.thoughts == null
          ? null
          : FloatingActionButton(
              onPressed: () => showThoughtDialog(context, model),
              tooltip: 'Add a thought',
              child: const Icon(Icons.add),
            ),
    );
  }

  Future<void> showThoughtDialog(BuildContext context, model) async {
    final thought = await showDialog<Thought>(
        context: context,
        builder: (context) {
          return const ThoughtInputDialog();
        });
    if (thought != null) {
      model.addThought(thought);
    }
  }
}

class ThoughtWidget extends StatelessWidget {
  final Thought thought;
  const ThoughtWidget({super.key, required this.thought});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.cloud),
            subtitle: Text(thought.what),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(thought.who),
              const SizedBox(width: 40.0),
              Text('${thought.when}'),
            ],
          ),
          Text(thought.uuid!),
        ],
      ),
    );
  }
}

class ThoughtInputDialog extends StatefulWidget {
  const ThoughtInputDialog({super.key});

  @override
  State<ThoughtInputDialog> createState() => _ThoughtInputDialogState();
}

class _ThoughtInputDialogState extends State<ThoughtInputDialog> {
  final formKey = GlobalKey<FormState>();
  String? who;
  String? what;
  DateTime? when;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Dump a new thought ...'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              onSaved: (value) => who = value,
              decoration: const InputDecoration(labelText: 'Who said'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'The name is required';
                }
                return null;
              },
            ),
            TextFormField(
              onSaved: (value) => what = value,
              decoration: const InputDecoration(
                labelText: 'What',
                hintText: 'was said',
              ),
              minLines: 1,
              maxLines: 10,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'The name is required';
                }
                return null;
              },
            ),
            InputDatePickerFormField(
              firstDate: DateTime(-20000),
              lastDate: DateTime.now(),
              onDateSaved: (value) => when = value,
              errorInvalidText:
                  'There are no known human phrases from that age.',
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
              final thought =
                  Thought(who: who!, what: what!, when: when ?? DateTime.now());
              Navigator.of(context).pop(thought);
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
