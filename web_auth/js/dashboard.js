// Firestoreインスタンス
const db = firebase.firestore();

// 認証状態チェック
auth.onAuthStateChanged(async (user) => {
    if (!user) {
        // ログインしていない場合はログインページへリダイレクト
        console.log('❌ 未ログイン - ログインページへリダイレクト');
        window.location.href = 'login.html';
        return;
    }
    
    console.log('✅ ログイン済み:', user.email);
    
    // ユーザー情報を表示
    displayUserInfo(user);
    
    // 統計データを読み込み
    await loadStatistics();
    
    // アクティビティを表示
    displayActivity();
});

// ユーザー情報表示
function displayUserInfo(user) {
    const userEmailElement = document.getElementById('userEmail');
    const welcomeNameElement = document.getElementById('welcomeName');
    
    if (userEmailElement) {
        userEmailElement.textContent = user.email;
    }
    
    if (welcomeNameElement) {
        // メールアドレスから名前を取得（@の前）
        const name = user.email.split('@')[0];
        welcomeNameElement.textContent = name;
    }
    
    // ログイン時刻を表示
    const loginTimeElement = document.getElementById('loginTime');
    const activityTimeElement = document.getElementById('activityTime');
    
    const loginTime = localStorage.getItem('loginTime');
    if (loginTime) {
        const formattedTime = formatDateTime(new Date(loginTime));
        if (loginTimeElement) {
            loginTimeElement.textContent = formattedTime;
        }
        if (activityTimeElement) {
            activityTimeElement.textContent = formattedTime;
        }
    }
}

// 統計データ読み込み
async function loadStatistics() {
    try {
        // ユーザー数を取得
        const usersSnapshot = await db.collection('users').get();
        const userCount = usersSnapshot.size;
        document.getElementById('userCount').textContent = userCount.toLocaleString();
        
        // 予約数を取得
        const bookingsSnapshot = await db.collection('bookings').get();
        const bookingCount = bookingsSnapshot.size;
        document.getElementById('bookingCount').textContent = bookingCount.toLocaleString();
        
        // スタッフ数を取得
        const staffSnapshot = await db.collection('staff').get();
        const staffCount = staffSnapshot.size;
        document.getElementById('staffCount').textContent = staffCount.toLocaleString();
        
        // 総売上を計算
        let totalRevenue = 0;
        bookingsSnapshot.forEach((doc) => {
            const booking = doc.data();
            if (booking.status === 'completed' && booking.price) {
                totalRevenue += booking.price;
            }
        });
        document.getElementById('revenue').textContent = `¥${totalRevenue.toLocaleString()}`;
        
        console.log('✅ 統計データ読み込み完了');
    } catch (error) {
        console.error('❌ 統計データ読み込みエラー:', error);
        // エラー時はダミーデータを表示
        document.getElementById('userCount').textContent = '0';
        document.getElementById('bookingCount').textContent = '0';
        document.getElementById('staffCount').textContent = '0';
        document.getElementById('revenue').textContent = '¥0';
    }
}

// アクティビティ表示
function displayActivity() {
    // 現在はログイン情報のみ表示
    // 将来的には最近の予約、メッセージなどを表示
}

// 日時フォーマット
function formatDateTime(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    
    return `${year}年${month}月${day}日 ${hours}:${minutes}`;
}

// ログアウトボタン
const logoutButton = document.getElementById('logoutButton');
if (logoutButton) {
    logoutButton.addEventListener('click', async () => {
        if (confirm('ログアウトしますか？')) {
            try {
                await auth.signOut();
                
                // ローカルストレージをクリア
                localStorage.removeItem('isLoggedIn');
                localStorage.removeItem('userEmail');
                localStorage.removeItem('userId');
                localStorage.removeItem('loginTime');
                
                console.log('✅ ログアウト成功');
                
                // ログインページへリダイレクト
                window.location.href = 'login.html';
            } catch (error) {
                console.error('❌ ログアウトエラー:', error);
                alert('ログアウトに失敗しました');
            }
        }
    });
}

console.log('✅ Dashboard script loaded');
