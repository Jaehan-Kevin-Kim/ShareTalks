import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_talks/screens/navigator.dart';

class FullScreenImage extends StatefulWidget {
  final Image image;
  final bool isSendButtonRequired;
  final void Function(bool isButtonClick)? onButtonClick;

  const FullScreenImage({
    super.key,
    required this.image,
    this.isSendButtonRequired = false,
    this.onButtonClick,
  });

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  bool isSending = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 80,
          alignment: Alignment.bottomLeft,
          // color: Colors.white,
          color: Theme.of(context).colorScheme.onInverseSurface,
          child: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            iconSize: 25,
            icon: Icon(
              Icons.close,
              // color: Colors.white,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        // Stack(children: [
        //   SizedBox(
        //     width: MediaQuery.of(context).size.width,
        //     height: MediaQuery.of(context).size.height - 160,
        //     child: Image.file(
        //       image,
        //       fit: BoxFit.contain,
        //     ),
        //   ),
        //   if (isSendButtonRequired)
        //     Positioned(
        //         bottom: 30,
        //         right: 10,
        //         child: FloatingActionButton(
        //           foregroundColor: Colors.red,
        //           onPressed: () {},
        //           // elevation: ,
        //           child: const Icon(Icons.send),
        //         ))
        // ]),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height - 160,
          color: Colors.white,
          child: widget.image,
        ),
        Container(
            height: 80,
            // color: Colors.white,
            // color: Colors.white,
            color: Theme.of(context).colorScheme.onInverseSurface,
            alignment: Alignment.center,
            child: widget.isSendButtonRequired
                ? Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,

                        // border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(5)),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: TextButton(
                        onPressed: () {
                          if (widget.onButtonClick != null) {
                            widget.onButtonClick!(true);
                          }
                          setState(() {
                            isSending = true;
                          });
                          Navigator.of(context).pop();
                        },
                        child: isSending
                            ? const CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                    Text(
                                      "Send",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 17),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                  ])))
                : null)
        ///////////////
        // Container(
        //     height: 80,
        //     // padding: const EdgeInsetsDirectional.only(end: 20),
        //     color: Colors.black,
        //     alignment: Alignment.center,
        //     child:FloatingActionButton.extended(
        //             foregroundColor: Colors.red,
        //             backgroundColor: Theme.of(context).colorScheme.onPrimary,
        //             onPressed: () {},
        //             label: const Row(
        //               children: [
        //                 Text("Send"),
        //                 SizedBox(
        //                   width: 10,
        //                 ),
        //                 Icon(Icons.send)
        //               ],
        //             ),

        //             // child: const Icon(Icons.send))
        //           )
        //         : null
        //     // child: FloatingActionButton(
        //     //   onPressed: () {},
        //     //   // elevation: ,
        //     //   child: Icon(Icons.send),
        //     // )
        //     // IconButton(
        //     //   onPressed: () {},
        //     //   icon: Icon(Icons.send),
        //     //   color: Colors.black,
        //     // ),
        //     )
      ],
    );
    // );
  }
}
