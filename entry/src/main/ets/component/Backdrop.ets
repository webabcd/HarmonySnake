import { LengthMetricsUnit } from '@kit.ArkUI';

@Component
export struct Backdrop {

  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true))
  private imageBitmap = new ImageBitmap("resources/base/media/backdrop.jpg", LengthMetricsUnit.DEFAULT)

  build() {
    Canvas(this.context).width('100%').height('100%')
      .onReady(() => {
        this.context.drawImage(this.imageBitmap, 0, 0, this.context.width, this.context.height)
      })
  }
}