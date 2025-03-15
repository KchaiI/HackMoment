document.addEventListener("DOMContentLoaded", function() {
    var calendarEl = document.getElementById("calendar");
    var calendar = new FullCalendar.Calendar(calendarEl, {
        initialView: "timeGridWeek",
        headerToolbar: {
            left: "prev,next today",
            center: "title",
            right: "timeGridWeek,timeGridDay"
        },
        slotMinTime: "08:00:00",
        slotMaxTime: "22:00:00",
        allDaySlot: false,
        events: "/events" // 🔥 サーバーから予定データを取得
    });
    calendar.render();

    // **🔥 フォーム送信時の処理**
    document.getElementById("schedule-form").addEventListener("submit", function(event) {
        event.preventDefault(); // 🔥 ページのリロードを防ぐ

        var title = document.getElementById("title").value;
        var start_time = document.getElementById("start_time").value;
        var end_time = document.getElementById("end_time").value;

        fetch("/schedules", {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                title: title,
                start_time: start_time,
                end_time: end_time
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.errors) {
                document.getElementById("message").textContent = "エラー: " + data.errors.join(", ");
            } else {
                document.getElementById("message").textContent = "スケジュールを登録しました!";
                
                // **🔥 フォームをリセット**
                document.getElementById("schedule-form").reset();
                
                // **🔥 カレンダーを更新**
                calendar.refetchEvents(); 
            }
        })
        .catch(error => {
            console.error("Error:", error);
            document.getElementById("message").textContent = "エラーが発生しました。";
        });
    });
});
