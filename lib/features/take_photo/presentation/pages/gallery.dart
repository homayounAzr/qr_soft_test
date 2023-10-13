import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/gallery/gallery.bloc.dart';

import '../widgets/camera_widgets.dart';

/// Gallery page, show all photo in grid view list
/// By long press on each element you can see the photo info that saved in DB
class GalleryHome extends StatefulWidget {
  const GalleryHome({super.key});

  @override
  State<GalleryHome> createState() => _GalleryHomeState();
}

class _GalleryHomeState extends State<GalleryHome> with WidgetsBindingObserver {
  late GalleryBloc _galleryBloc;

  @override
  void initState() {
    super.initState();
    _galleryBloc = GalleryBloc()..add(GalleryInitialized());
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _galleryBloc,
      child: Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: const Text('gallery'),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back,size: 40,),
              onPressed: () => Navigator.of(context).pop()
          ),
        ),
        body: BlocBuilder<GalleryBloc, GalleryState>(
          builder: (context, state) {
            if (state is GalleryLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is GalleryReady) {
              return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                  itemCount: state.photos.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    final photo = state.photos[index];

                    return GestureDetector(
                      onLongPress: () => showDetailsPopup(context, photo),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Image.file(
                          File(photo.directory),
                        ),
                      ),
                    );
                  }
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
