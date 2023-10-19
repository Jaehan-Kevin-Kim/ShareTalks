import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_talks/screens/user_profile.dart';
import 'package:share_talks/widgets/full_screen_image.dart';

final formatter = DateFormat.jm();

class MessageBubble extends StatelessWidget {
  const MessageBubble.first(
      {super.key,
      required this.userImage,
      required this.username,
      required this.message,
      required this.isMe,
      required this.userId,
      required this.notReadMemberNumber,
      required this.chatImage,
      required this.createdAt})
      : isFirstInSequence = true;

  const MessageBubble.next(
      {super.key,
      required this.message,
      required this.isMe,
      required this.notReadMemberNumber,
      required this.chatImage,
      required this.createdAt})
      : isFirstInSequence = false,
        userImage = null,
        username = null,
        userId = null;

  final bool isFirstInSequence;

  final String? userImage;
  final Timestamp createdAt;

  final String? username;
  final String message;
  final String chatImage;
  final String? userId;
  final int notReadMemberNumber;

  final bool isMe;

  void onClickAvatar() async {
    final userData = await firebaseUtils.usersData(userId!);
    Get.to(UserProfileScreen(userData: userData!));
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => UserProfileScreen(userData: widget.userData)));
  }

  void onTapImage(BuildContext context) {
    final image = Image.network(chatImage, fit: BoxFit.contain);

    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (ctx) => FullScreenImage(image: image));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget dateFormatWidget = Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (notReadMemberNumber > 0)
          Text(
            notReadMemberNumber.toString(),
            style: const TextStyle(fontSize: 10, color: Colors.redAccent),
          ),
        Text(
          formatter.format(createdAt.toDate()),
          style: const TextStyle(fontSize: 10),
        ),
        const SizedBox(
          height: 5,
        )
      ],
    );

    return Stack(
      children: [
        if (userImage != null)
          Positioned(
            top: 15,
            right: isMe ? 0 : null,
            child: GestureDetector(
              onTap: onClickAvatar,
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  userImage!,
                ),
                backgroundColor: theme.colorScheme.primary.withAlpha(180),
                radius: 23,
              ),
            ),
          ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 46),
          child: Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isMe) dateFormatWidget,
              Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (isFirstInSequence) const SizedBox(height: 18),
                  if (username != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 13,
                        right: 13,
                      ),
                      child: Text(
                        username!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                  // The "speech" box surrounding the message.
                  Container(
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.grey[300]
                          : theme.colorScheme.secondary.withAlpha(200),
                      borderRadius: BorderRadius.only(
                        topLeft: !isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                        topRight: isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                        bottomLeft: const Radius.circular(12),
                        bottomRight: const Radius.circular(12),
                      ),
                    ),
                    constraints: const BoxConstraints(maxWidth: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    // Margin around the bubble.
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),

                    child: chatImage.isEmpty
                        ? Text(
                            message,
                            style: TextStyle(
                              height: 1.3,
                              color: isMe
                                  ? Colors.black87
                                  : theme.colorScheme.onSecondary,
                            ),
                            softWrap: true,
                          )
                        : SizedBox(
                            width: 150,
                            height: 220,
                            child: GestureDetector(
                                onTap: () {
                                  onTapImage(context);
                                },
                                child: Image(image: NetworkImage(chatImage)))),
                  ),
                ],
              ),
              if (!isMe) dateFormatWidget,
            ],
          ),
        ),
      ],
    );
  }
}
