import 'package:flutter/cupertino.dart';
import 'package:myapp/screens/others/material_read_screen.dart';

class MaterailListScreen extends StatefulWidget {
  final Map<String, dynamic> material;
  const MaterailListScreen({super.key, required this.material});

  @override
  State<MaterailListScreen> createState() => _MaterailListScreenState();
}

class _MaterailListScreenState extends State<MaterailListScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          const CupertinoSliverNavigationBar(
            previousPageTitle: 'Home',
            largeTitle: Text('Materials'),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              for (String key in widget.material.keys)
                CupertinoListTile(
                  title: Text(key),
                  subtitle: Text(widget.material[key]),
                  onTap: () {
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (context) {
                      return MaterialReadScreen(
                        title: key,
                        content: widget.material[key],
                      );
                    }));
                  },
                  trailing: const Icon(
                    CupertinoIcons.chevron_forward,
                    color: CupertinoColors.systemGrey,
                  ),
                )
            ]),
          ),
        ],
      ),
    );
  }
}
