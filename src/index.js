require('./index.html');

firebase.initializeApp({
  apiKey: process.env.API_KEY,
  authDomain: process.env.AUTH_DOMAIN,
  databaseURL: process.env.DATABASE_URL,
  storageBucket: process.env.STORAGE_BUCKET,
});

const database = firebase.database();

const messagesRef = firebase
    .database()
    .ref('messages');

const Elm = require('./Main.elm');
const moundNode = document.getElementById('main');

const app = Elm.Main.embed(moundNode);

app.ports.logIn.subscribe((value) => {
  const provider = new firebase.auth.FacebookAuthProvider();

  provider.addScope('public_profile');

  return firebase.auth()
    .signInWithPopup(provider);
});

app.ports.sendMessage.subscribe((value) => {
  messagesRef
    .push({
      message: value.message,
      userId: firebase.auth().currentUser.uid,
      createdAt: Date.now(),
      coords: value.coords
    });
});

firebase.auth().onAuthStateChanged(user => {
  if (user) {
    return firebase
      .database()
      .ref(`users/${firebase.auth().currentUser.uid}`)
      .once('value')
      .then(snapshot => {
        const userSnap = snapshot.val();

        app.ports.listenLogin.send(userSnap);
      });
  } else {
    app.ports.listenLogin.send(null);
  }
});

function mapUserToMessage(currentMessage) {
  return firebase
    .database()
    .ref(`users/${currentMessage.userId}`)
    .once('value')
    .then(snapshot => {
      const userSnap = snapshot.val();
      currentMessage.name = userSnap.name;

      return currentMessage;
    });
}

messagesRef.on('value', (snapshot) => {
  const data = snapshot.val();

  if (!data) {
    return;
  }

  Promise.all(
    Object.keys(data)
      .map(key => data[key])
      .map(mapUserToMessage)
  )
    .then((messages) => {
      app.ports.listMessages.send(messages);
    })
});
