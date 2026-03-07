// Firebase設定
const firebaseConfig = {
    apiKey: "AIzaSyDemoKeyForWebPlatform123456789",
    authDomain: "staff-finder-demo.firebaseapp.com",
    projectId: "staff-finder-demo",
    storageBucket: "staff-finder-demo.appspot.com",
    messagingSenderId: "123456789",
    appId: "1:123456789:web:abcdef123456",
    measurementId: "G-ABCDEFGHIJ"
};

// Firebase初期化
firebase.initializeApp(firebaseConfig);

// Firebase Authenticationインスタンス
const auth = firebase.auth();

// 言語設定
auth.languageCode = 'ja';

// 永続化設定（ローカルストレージ）
auth.setPersistence(firebase.auth.Auth.Persistence.LOCAL)
    .catch((error) => {
        console.error('Persistence setting error:', error);
    });

console.log('✅ Firebase initialized successfully');
