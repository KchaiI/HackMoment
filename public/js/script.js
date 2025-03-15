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
