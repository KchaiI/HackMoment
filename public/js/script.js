// 画像をアップロードした時に表示
// document.addEventListener("DOMContentLoaded", function () {
//     const imageInput = document.getElementById("image-input");
//     const imagePreview = document.getElementById("image-preview");
//     const imageContainer = document.getElementById("image-container");
//     const resetButton = document.getElementById("reset-btn");

//     let isDragging = false;
//     let isResizing = false;
//     let startX, startY, startWidth, startHeight, startLeft, startTop;

//     // 画像アップロード時の処理
//     imageInput.addEventListener("change", function () {
//         const file = imageInput.files[0];
//         if (file) {
//             const reader = new FileReader();
//             reader.onload = function (e) {
//                 imagePreview.src = e.target.result;
//                 imagePreview.style.display = "block";
//                 imageContainer.style.display = "block";
//             };
//             reader.readAsDataURL(file);
//         }
//     });

//     // 画像をドラッグして移動
//     imagePreview.addEventListener("mousedown", function (event) {
//         isDragging = true;
//         startX = event.clientX;
//         startY = event.clientY;
//         startLeft = imagePreview.offsetLeft;
//         startTop = imagePreview.offsetTop;
//         imagePreview.style.cursor = "grabbing";
//     });

//     document.addEventListener("mousemove", function (event) {
//         if (isDragging) {
//             const deltaX = event.clientX - startX;
//             const deltaY = event.clientY - startY;
//             imagePreview.style.left = `${startLeft + deltaX}px`;
//             imagePreview.style.top = `${startTop + deltaY}px`;
//         }
//     });

//     document.addEventListener("mouseup", function () {
//         isDragging = false;
//         imagePreview.style.cursor = "grab";
//     });

//     // 画像サイズを変更（リサイズ）
//     imageContainer.addEventListener("mousedown", function (event) {
//         if (event.offsetX > imageContainer.clientWidth - 10 && event.offsetY > imageContainer.clientHeight - 10) {
//             isResizing = true;
//             startX = event.clientX;
//             startY = event.clientY;
//             startWidth = imageContainer.clientWidth;
//             startHeight = imageContainer.clientHeight;
//         }
//     });

//     document.addEventListener("mousemove", function (event) {
//         if (isResizing) {
//             const deltaX = event.clientX - startX;
//             const deltaY = event.clientY - startY;
//             imageContainer.style.width = `${startWidth + deltaX}px`;
//             imageContainer.style.height = `${startHeight + deltaY}px`;
//         }
//     });

//     document.addEventListener("mouseup", function () {
//         isResizing = false;
//     });

//     // リセットボタンを押したときの処理
//     resetButton.addEventListener("click", function () {
//         imageContainer.style.width = "300px";
//         imageContainer.style.height = "300px";
//         imagePreview.style.left = "0px";
//         imagePreview.style.top = "0px";
//     });
// });



document.addEventListener("DOMContentLoaded", async () => {
  if (!('serviceWorker' in navigator)) {
    console.log("Service Worker未対応のブラウザです。");
    return;
  }

  // 通知の権限を確認し、未許可('default')ならリクエスト
  if (Notification.permission === 'default') {
    await Notification.requestPermission();
  }

  try {
    // 1) Service Worker登録
    const registration = await navigator.serviceWorker.register('/js/service-worker.js');
    console.log("Service Worker登録完了:", registration);

    // 2) VAPID公開鍵を JS で使える形 (Uint8Array) に変換
    //   あなたがNode.jsで生成したpublic key(base64URL)を、ソース内 or 環境変数などで読み込む
    const vapidPublicKey = "BGvB08SENPxLoe7kA9PYBsvh0go3oMwSpun4eRX0n8iQsod-F5NnWrsYspdKh-B6UUTfBESaZzqhIrOQ77ZRdIc"; 
    const convertedVapidKey = urlBase64ToUint8Array(vapidPublicKey);

    // 3) プッシュ購読を行う
    const subscription = await registration.pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: convertedVapidKey
    });

    console.log("購読完了:", subscription);

    // 4) サーバーに購読情報を送信
    await fetch('/subscribe', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(subscription)
    });
    console.log("サーバー側に購読情報を登録しました。");

  } catch (err) {
    console.error("購読処理に失敗:", err);
  }
});

/**
 * Base64URL -> Uint8Array 変換用のヘルパー
 */
function urlBase64ToUint8Array(base64String) {
  const padding = '='.repeat((4 - base64String.length % 4) % 4);
  const base64  = (base64String + padding)
    .replace(/\-/g, '+')
    .replace(/_/g, '/');
  const rawData = window.atob(base64);
  const outputArray = new Uint8Array(rawData.length);
  for (let i = 0; i < rawData.length; ++i) {
    outputArray[i] = rawData.charCodeAt(i);
  }
  return outputArray;
}
