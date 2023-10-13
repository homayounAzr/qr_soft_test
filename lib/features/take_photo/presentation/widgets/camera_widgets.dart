import '../../domain/entities/photo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

/// Widget that return a bottom sheet, scrap data from [Photo] and show them,then pop after 3 second.
void showDetailsPopup(BuildContext context, Photo photo) {

  showModalBottomSheet(
      context:context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Name: ${photo.name}',style: const TextStyle(fontSize: 18)),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text('Dir: ${dirname(photo.directory)}',style: const TextStyle(fontSize: 18)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text('Size: ${photo.size} bytes',style: const TextStyle(fontSize: 18)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text('Date: ${DateFormat('MM/dd/yy HH:mm').format(photo.date)}',style: const TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            )
          ],
        );
      });

  Future.delayed(const Duration(seconds: 3)).then((_) {
    Navigator.of(context).pop();
  });


}
