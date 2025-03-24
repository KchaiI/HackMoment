// public/js/crop.js
document.addEventListener('DOMContentLoaded', () => {
  // ファイル選択欄 / 画像表示欄 / 切り抜きボタン / hidden input
  const imageInput = document.getElementById('image-input');
  const cropperImage = document.getElementById('cropper-image');
  const cropBtn = document.getElementById('crop-btn');
  const croppedImageInput = document.getElementById('cropped-image');

  let cropper = null;

  // ▼ ユーザーがファイルを選択したら
  imageInput.addEventListener('change', function () {
    const file = this.files[0];
    if (!file) return;

    // FileReader で選択画像をDataURLに変換して <img> に表示
    const reader = new FileReader();
    reader.onload = function (e) {
      cropperImage.src = e.target.result;

      // 既にCropperが存在する場合は破棄 (複数回選択に対応)
      if (cropper) {
        cropper.destroy();
      }

      // ▼ Cropper 初期化
      cropper = new Cropper(cropperImage, {
        aspectRatio: 1,          // アスペクト比 (1 = 正方形)
        viewMode: 1,             // 画像の表示モード
        background: false,       // 背景マスクの有無
        autoCropArea: 1.0,       // 初期状態で埋める
        zoomable: true,          // ズーム可能
        movable: true,           // 画像ドラッグ可能
        responsive: true         // 画面サイズ変化へ対応
        // ほかオプションは公式ドキュメント参照
      });
    };
    reader.readAsDataURL(file);
  });

  // ▼ 「この位置で切り抜く」ボタン
  cropBtn.addEventListener('click', function () {
    if (!cropper) return alert("画像が選択されていません。");

    // getCroppedCanvas で最終的に 300x300 ピクセルのCanvasを取得(例)
    const canvas = cropper.getCroppedCanvas({
      width: 300,
      height: 300
    });

    // DataURL (Base64) を取得
    const base64Data = canvas.toDataURL("image/png");

    // hidden input にセット → form.submit 時に一緒に送信
    croppedImageInput.value = base64Data;

    alert("切り抜き結果をセットしました。あとは投稿ボタンを押してください。");
  });
});
