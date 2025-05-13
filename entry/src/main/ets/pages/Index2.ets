import { LengthMetricsUnit } from '@kit.ArkUI';


// 简单的模糊算法（高斯模糊的简化版）
function applyBlur(pixels:Uint8ClampedArray, width:number, height:number, radius:number): Uint8ClampedArray {
  const newPixels = new Uint8ClampedArray(pixels);

  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      let r = 0, g = 0, b = 0, a = 0;
      let count = 0;

      for (let ky = -radius; ky <= radius; ky++) {
        for (let kx = -radius; kx <= radius; kx++) {
          const px = x + kx;
          const py = y + ky;

          if (px >= 0 && px < width && py >= 0 && py < height) {
            const index = (py * width + px) * 4;
            r += pixels[index];
            g += pixels[index + 1];
            b += pixels[index + 2];
            a += pixels[index + 3];
            count++;
          }
        }
      }

      const destIndex = (y * width + x) * 4;
      newPixels[destIndex] = r / count;
      newPixels[destIndex + 1] = g / count;
      newPixels[destIndex + 2] = b / count;
      newPixels[destIndex + 3] = a / count;
    }
  }

  return newPixels;
}

@Entry
@Component
struct Index {

  @State message: string = 'Hello World';

  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true))
  private imageBitmap = new ImageBitmap("resources/base/media/son.jpg", LengthMetricsUnit.DEFAULT)


  time = 0
  xxx() {
    this.time += 100
    // this.context.filter = 'blur(10px)'; // 设置模糊半径
    this.context.clearRect(0, 0, 300, 600)
    this.context.drawImage(this.imageBitmap, 0, 0, 300, 300)

    let imageData = this.context.getImageData(0, 0, 300, 300)
    const pixels = imageData.data;

    const newPixels = new Uint8ClampedArray(pixels);
    const width = imageData.width;
    const height = imageData.height;

    const waveStrength = 20; // 波纹强度
    const waveLength = 50;   // 波纹波长

    // 应用水波纹效果（像素偏移）
    for (let y = 0; y < height; y += 2) {
      for (let x = 0; x < width; x += 2) {
        // 基于正弦波计算位移
        const offsetX = Math.sin((x + y + this.time) / waveLength) * waveStrength;
        const offsetY = Math.cos((x + y + this.time) / waveLength) * waveStrength;

        const srcX = Math.min(width - 1, Math.floor(x + offsetX));
        const srcY = Math.min(height - 1, Math.floor(y + offsetY));

        const srcIndex = (srcY * width + srcX) * 4;
        const destIndex = (y * width + x) * 4;


        newPixels[destIndex] = pixels[srcIndex]; // R
        newPixels[destIndex + 1] = pixels[srcIndex + 1]; // G
        newPixels[destIndex + 2] = pixels[srcIndex + 2]; // B
        newPixels[destIndex + 3] = pixels[srcIndex + 3]; // A
      }
    }

    // const blurredImageData = applyBlur(new Uint8ClampedArray(newPixels), width, height, 2);

    this.context.putImageData(new ImageData(300, 300, newPixels), 0, 300)


    setTimeout(() => {
      this.xxx()
    }, 30)
  }

  build() {
    Stack() {
      Canvas(this.context).width(300).height(600).backgroundColor(Color.Transparent)
        .onReady(() => {

          this.xxx()

        })
    }
  }
}