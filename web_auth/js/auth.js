// DOM要素
const loginForm = document.getElementById('loginForm');
const emailInput = document.getElementById('email');
const passwordInput = document.getElementById('password');
const togglePasswordBtn = document.getElementById('togglePassword');
const loginButton = document.getElementById('loginButton');
const loginButtonText = document.getElementById('loginButtonText');
const loginButtonSpinner = document.getElementById('loginButtonSpinner');
const errorMessage = document.getElementById('errorMessage');

// パスワード表示切替
togglePasswordBtn.addEventListener('click', () => {
    const type = passwordInput.type === 'password' ? 'text' : 'password';
    passwordInput.type = type;
    
    // アイコン変更
    const eyeIcon = document.getElementById('eyeIcon');
    if (type === 'text') {
        eyeIcon.innerHTML = `
            <path d="M3.98 8.223A10.477 10.477 0 001.934 10C3.226 13.338 6.244 15.5 10 15.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.45 10.45 0 0110 5.5c3.756 0 6.774 2.162 8.066 5.5a10.523 10.523 0 01-1.238 2.28m-2.855 2.855A7.966 7.966 0 0110 16.5c-3.756 0-6.774-2.162-8.066-5.5a10.523 10.523 0 011.09-1.908m12.375 1.408L3.98 3.98"/>
            <path stroke-linecap="round" stroke-linejoin="round" d="M3 3l14 14"/>
        `;
    } else {
        eyeIcon.innerHTML = `
            <path d="M10 12.5C8.61929 12.5 7.5 11.3807 7.5 10C7.5 8.61929 8.61929 7.5 10 7.5C11.3807 7.5 12.5 8.61929 12.5 10C12.5 11.3807 11.3807 12.5 10 12.5Z"/>
            <path d="M10 5C5 5 1.73 8.11 1 10C1.73 11.89 5 15 10 15C15 15 18.27 11.89 19 10C18.27 8.11 15 5 10 5Z"/>
        `;
    }
});

// エラーメッセージ表示
function showError(message) {
    errorMessage.textContent = message;
    errorMessage.style.display = 'block';
}

// エラーメッセージ非表示
function hideError() {
    errorMessage.style.display = 'none';
}

// ローディング状態切替
function setLoading(isLoading) {
    if (isLoading) {
        loginButton.disabled = true;
        loginButtonText.style.display = 'none';
        loginButtonSpinner.style.display = 'inline-block';
    } else {
        loginButton.disabled = false;
        loginButtonText.style.display = 'inline';
        loginButtonSpinner.style.display = 'none';
    }
}

// Firebaseエラーメッセージの日本語化
function getJapaneseErrorMessage(error) {
    switch (error.code) {
        case 'auth/invalid-email':
            return 'メールアドレスの形式が正しくありません';
        case 'auth/user-disabled':
            return 'このアカウントは無効化されています';
        case 'auth/user-not-found':
            return 'メールアドレスまたはパスワードが正しくありません';
        case 'auth/wrong-password':
            return 'メールアドレスまたはパスワードが正しくありません';
        case 'auth/invalid-credential':
            return 'メールアドレスまたはパスワードが正しくありません';
        case 'auth/too-many-requests':
            return 'ログイン試行回数が多すぎます。しばらく時間をおいてから再度お試しください';
        case 'auth/network-request-failed':
            return 'ネットワーク接続エラーが発生しました';
        case 'auth/operation-not-allowed':
            return 'メール/パスワード認証が有効になっていません';
        default:
            return `ログインに失敗しました: ${error.message}`;
    }
}

// ログインフォーム送信
loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    hideError();
    
    const email = emailInput.value.trim();
    const password = passwordInput.value;
    
    // バリデーション
    if (!email || !password) {
        showError('メールアドレスとパスワードを入力してください');
        return;
    }
    
    setLoading(true);
    
    try {
        // Firebase認証でログイン
        const userCredential = await auth.signInWithEmailAndPassword(email, password);
        const user = userCredential.user;
        
        console.log('✅ ログイン成功:', user.uid);
        
        // ローカルストレージにログイン情報を保存
        localStorage.setItem('isLoggedIn', 'true');
        localStorage.setItem('userEmail', user.email);
        localStorage.setItem('userId', user.uid);
        localStorage.setItem('loginTime', new Date().toISOString());
        
        // ダッシュボードにリダイレクト
        window.location.href = 'dashboard.html';
        
    } catch (error) {
        console.error('❌ ログインエラー:', error);
        showError(getJapaneseErrorMessage(error));
        setLoading(false);
    }
});

// ページ読み込み時: 既にログイン済みならダッシュボードへリダイレクト
auth.onAuthStateChanged((user) => {
    if (user) {
        console.log('✅ 既にログイン済み:', user.email);
        // ログインページを表示している場合はダッシュボードへ
        if (window.location.pathname.includes('login.html')) {
            window.location.href = 'dashboard.html';
        }
    }
});

// Enter キーでログイン
passwordInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
        loginForm.dispatchEvent(new Event('submit'));
    }
});

console.log('✅ Auth script loaded');
