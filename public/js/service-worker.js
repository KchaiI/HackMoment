// public/service-worker.js

self.addEventListener('push', function(event) {
  // サーバー側から送られる payload(JSON)を取得
  if (event.data) {
    const data = event.data.json();

    event.waitUntil(
      self.registration.showNotification(data.title, {
        body: data.body,
        // iconなどを指定したい場合はここに書く
      })
    );
  }
});

// 通知クリック時の挙動 (必要に応じて)
self.addEventListener('notificationclick', function(event) {
  event.notification.close();
  event.waitUntil(
    // 指定のURLを開くなど
    clients.openWindow('/')
  );
});
