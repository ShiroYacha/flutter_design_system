// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_screen.dart';

// **************************************************************************
// DesignGenerator
// **************************************************************************

final screensHomeScreenPage = ViewerDocumentPage(
  id: 'homeScreen',
  namespace: ['screens', 'home_screen'],
  title: 'HomeScreen',
  subtitle: null,
  description: null,
  sections: [
    ViewerSectionUnion.component(
      id: 'anatomy',
      title: 'Anatomy',
      ctorName: 'HomeScreen',
      designLink: null,
      builder: ViewerWidgetBuilder(
        build: (context, factory) => HomeScreen(
          body: factory.build(context, 'body'),
        ),
        fieldMetaDataset: const [
          FieldMetaData(
            name: 'body',
            type: Widget,
            typeName: 'Widget',
            isOptional: false,
            defaultValue: null,
            defaultValueCode: null,
            viewerInitValue: null,
            documentation: null,
          ),
        ],
      ),
      sourceCode: const ViewerSourceCode(
          location: 'package:viewer_example/screens/home_screen.dart', code: '''
/// Built from the following function 
(context, factory) => HomeScreen(body: factory.build(context, 'body'),)

/// Widget
class HomeScreen extends StatelessWidget {
  final Widget body;
  const HomeScreen({
    required this.body,
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: body,
        floatingActionButton: FloatingActionButton(
            onPressed: () {}, child: const Icon(Ionicons.add)));
  }
}

'''),
    ),
    const ViewerSectionUnion.apiDocs(
      id: 'apiDocs',
      title: 'API reference',
    ),
  ],
);