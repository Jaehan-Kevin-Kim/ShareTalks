const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const serviceAccount = require("./share-talks-c90cb-d9e71baff5b8.json");

// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount),
// });

admin.initializeApp();

exports.myFunction = functions.firestore
  .document("messages/{groupId}/chats/{chatId}")
  .onCreate(async (snapshot, context) => {
    const chatData = snapshot.data();
    // console.log("snapshot: ", snapshot);
    // console.log("context: ", context);

    const groupId = context.params.groupId;
    // const userUid = context.auth.uid;

    // Get the FCM tokens of users in the same group
    const groupSnapshot = await admin
      .firestore()
      .collection("groups")
      .doc(groupId)
      .get();
    if (!groupSnapshot.exists) {
      console.error("Group document does not exist.");
      return null;
    }

    const membersUids = groupSnapshot
      .data()
      .members.filter((memberId) => memberId !== chatData.senderId);

    // console.log(membersUids);

    // Get Image download url in Firebase Storage
    // admin.storage();
    // const imageUrl = await admin
    //   .storage()
    //   .bucket("gs://share-talks-c90cb.appspot.com/")
    //   .file("logo.png")
    //   .getSignedUrl({
    //     action: "read",
    //     expires: "03-09-2025", // 유효 기간 설정
    //   });

    // console.log("imageUrl: ", imageUrl);

    // Construct the notification payload
    const payload = {
      notification: {
        title: chatData.senderName,
        body: chatData.text,
      },
      android: {
        notification: {
          icon: "logo",
        },
      },
    };

    // Retrive user tokens in userTokens collection
    const userTokensDocuments = await admin
      .firestore()
      .collection("userTokens")
      .get();
    const userTokens = [];

    userTokensDocuments.docs.forEach(
      (userTokenDocument) =>
        // filter((userTokenDocument) => {
        membersUids.forEach((membersUid) => {
          console.log("memberUid in for loops: ", membersUid);
          console.log(
            "userTokenDocument.id in for loops: ",
            userTokenDocument.id,
          );
          if (membersUid === userTokenDocument.id) {
            console.log(
              "userTokenDocument.data().token in for loops: ",
              userTokenDocument.data().token,
              userTokens.push(),
            );
            const token = userTokenDocument.data().token;
            userTokens.push(token);
            // return userTokenDocument.data().token;
          }
        }),
      // }),
    );
    // console.log("userTokens: ", userTokens);
    // console.log("payload: ", payload);
    // console.log("senderName: ", chatData.senderName);
    // console.log("text: ", chatData.text);

    // Send the notification to each user in the group
    const notifications = userTokens.map(async (token) => {
      try {
        // return admin.messaging().send(token, payload);
        const response = await admin.messaging().send({
          token: token,
          ...payload,
        });
        console.log("Notification sent: ", response);
      } catch (error) {
        console.error("Error sending notification: ", error);
      }
    });
    return Promise.all(notifications);
  });
