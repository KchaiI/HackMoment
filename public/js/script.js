// 画像をアップロードした時に表示
document.addEventListener("DOMContentLoaded", function () {
    const imageInput = document.getElementById("image-input");
    const imagePreview = document.getElementById("image-preview");
    const imageContainer = document.getElementById("image-container");
    const resetButton = document.getElementById("reset-btn");

    let isDragging = false;
    let isResizing = false;
    let startX, startY, startWidth, startHeight, startLeft, startTop;

    // 画像アップロード時の処理
    imageInput.addEventListener("change", function () {
        const file = imageInput.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function (e) {
                imagePreview.src = e.target.result;
                imagePreview.style.display = "block";
                imageContainer.style.display = "block";
            };
            reader.readAsDataURL(file);
        }
    });

    // 画像をドラッグして移動
    imagePreview.addEventListener("mousedown", function (event) {
        isDragging = true;
        startX = event.clientX;
        startY = event.clientY;
        startLeft = imagePreview.offsetLeft;
        startTop = imagePreview.offsetTop;
        imagePreview.style.cursor = "grabbing";
    });

    document.addEventListener("mousemove", function (event) {
        if (isDragging) {
            const deltaX = event.clientX - startX;
            const deltaY = event.clientY - startY;
            imagePreview.style.left = `${startLeft + deltaX}px`;
            imagePreview.style.top = `${startTop + deltaY}px`;
        }
    });

    document.addEventListener("mouseup", function () {
        isDragging = false;
        imagePreview.style.cursor = "grab";
    });

    // 画像サイズを変更（リサイズ）
    imageContainer.addEventListener("mousedown", function (event) {
        if (event.offsetX > imageContainer.clientWidth - 10 && event.offsetY > imageContainer.clientHeight - 10) {
            isResizing = true;
            startX = event.clientX;
            startY = event.clientY;
            startWidth = imageContainer.clientWidth;
            startHeight = imageContainer.clientHeight;
        }
    });

    document.addEventListener("mousemove", function (event) {
        if (isResizing) {
            const deltaX = event.clientX - startX;
            const deltaY = event.clientY - startY;
            imageContainer.style.width = `${startWidth + deltaX}px`;
            imageContainer.style.height = `${startHeight + deltaY}px`;
        }
    });

    document.addEventListener("mouseup", function () {
        isResizing = false;
    });

    // リセットボタンを押したときの処理
    resetButton.addEventListener("click", function () {
        imageContainer.style.width = "300px";
        imageContainer.style.height = "300px";
        imagePreview.style.left = "0px";
        imagePreview.style.top = "0px";
    });
});


// 通知を許可するか確認
// function requestNotificationPermission() {
//     if ("Notification" in window) {
//         Notification.requestPermission().then(function(permission) {
//             if (permission === "granted") {
//                 console.log("通知が許可されました");
//             }
//         });
//     } else {
//         console.log("このブラウザは通知をサポートしていません");
//     }
// }

// // 初回ページ読み込み時に通知許可を求める
// document.addEventListener("DOMContentLoaded", requestNotificationPermission);


// // スケジュール通知をセット
// function scheduleNotifications(events) {
//     events.forEach(event => {
//         let startTime = new Date(event.start).getTime();
//         let now = new Date().getTime();
//         let delay = startTime - now;

//         if (delay > 0) {
//             setTimeout(() => {
//                 new Notification("予定の通知", {
//                     body: `予定の時間です: ${event.title || "無題の予定"}`,
//                     icon: "/icon.png" // 必要ならアイコンを指定
//                 });
//             }, delay);
//         }
//     });
// }

// // カレンダーのイベント取得時に通知をセット
// document.addEventListener("DOMContentLoaded", function() {
//     var calendarEl = document.getElementById("calendar");
//     var calendar = new FullCalendar.Calendar(calendarEl, {
//         initialView: "timeGridWeek",
//         events: "/events", // 🔥 サーバーから予定データを取得
//         eventDidMount: function(info) {
//             scheduleNotifications([info.event]);
//         }
//     });

//     calendar.render();
// });
