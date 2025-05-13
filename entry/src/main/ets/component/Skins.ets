import { Config } from '../Config';
import { core, EventType } from '../Core';
import { Node } from '../model/Model';

@Component
export struct Skins {

  context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true))

  aboutToAppear(): void {
    core.on(EventType.addSkin, () => {
      core.lastAddedSkinNodes.forEach((node, index) => {
        this.addSkin(node)
      })
    })
  }

  build() {
    Canvas(this.context).width('100%').height('100%')
      .onReady(() => {

      })
  }

  addSkin(node:Node) {
    let linearGradient = this.context.createLinearGradient(
      node.positionX - Config.cellRadius,
      node.positionY - Config.cellRadius + Config.cellWidth * 0.3,
      node.positionX + Config.cellRadius,
      node.positionY - Config.cellRadius + Config.cellWidth * 0.7)
    linearGradient.addColorStop(0.00, '#CAE4F9')
    linearGradient.addColorStop(0.85, '#514545')
    this.context.fillStyle = linearGradient
    this.context.beginPath()
    this.context.ellipse(node.positionX, node.positionY, Config.cellRadius, Config.cellRadius, 0, 0, Math.PI * 2)
    this.context.fill()
  }
}