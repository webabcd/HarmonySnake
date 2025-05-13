import { Config } from '../Config';
import { core, EventType } from '../Core';
import { Node } from '../model/Model';
import { Helper } from '../utils/Helper';

@Component
export struct Beans {

  context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true))
  contextAnimation: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true))

  lastAddedNode: Node | undefined
  lastAddedNodeColor: string = ''
  lastAddedNodeAnimationProgress: number = 0

  aboutToAppear(): void {
    core.on(EventType.addBean, () => {
      this.addBean(core.lastAddedBeanNode)
    })
    core.on(EventType.eatBean, () => {
      this.removeBean(core.lastRemovedBeanNode)
    })
    core.on(EventType.updateFrame, () => {
      if (this.lastAddedNodeAnimationProgress >= 1.0) {
        this.contextAnimation.clearRect(0, 0, Config.canvasWidth, Config.canvasHeight)
        this.lastAddedNode = undefined
        this.lastAddedNodeAnimationProgress = 0
      }

      if (this.lastAddedNode) {
        // this.contextAnimation.reset()
        this.contextAnimation.clearRect(0, 0, Config.canvasWidth, Config.canvasHeight)

        let scale = (5 + (1 - 5) * this.lastAddedNodeAnimationProgress)
        this.lastAddedNodeAnimationProgress += 0.03

        let linearGradient = this.contextAnimation.createLinearGradient(
          this.lastAddedNode.positionX - Config.cellRadius * scale,
          this.lastAddedNode.positionY - (Config.cellRadius + Config.cellWidth * 0.3) * scale,
          this.lastAddedNode.positionX + Config.cellRadius * scale,
          this.lastAddedNode.positionY - (Config.cellRadius + Config.cellWidth * 0.7) * scale)
        linearGradient.addColorStop(0.00, '#CAE4F9')
        linearGradient.addColorStop(0.85, this.lastAddedNodeColor)
        this.contextAnimation.fillStyle = linearGradient
        this.contextAnimation.beginPath()
        this.contextAnimation.ellipse(
          this.lastAddedNode.positionX,
          this.lastAddedNode.positionY,
          Config.cellRadius * scale,
          Config.cellRadius * scale,
          0, 0, Math.PI * 2)
        this.contextAnimation.fill()
      }
    })
  }

  build() {
    Stack() {
      Canvas(this.context).width('100%').height('100%')
        .onReady(() => {

        })
      Canvas(this.contextAnimation).width('100%').height('100%')
        .onReady(() => {

        })
    }.width('100%').height('100%')
  }

  addBean(node:Node) {
    let random = Helper.getRandomInt(0, 4)
    let color = ``
    switch (random) {
      case 0:
        color = `#4169E1`
        break
      case 1:
        color = `#228B22`
        break
      case 2:
        color = `#A020F0`
        break
      case 3:
        color = `#D2691E`
        break
      case 4:
        color = `#E647A6`
        break
      default:
        break
    }

    this.lastAddedNode = node
    this.lastAddedNodeColor = color

    this.context.strokeStyle = color
    this.context.lineWidth = 1
    let linearGradient = this.context.createLinearGradient(
      node.positionX - Config.cellRadius,
      node.positionY - Config.cellRadius + Config.cellWidth * 0.3,
      node.positionX + Config.cellRadius,
      node.positionY - Config.cellRadius + Config.cellWidth * 0.7)
    linearGradient.addColorStop(0.00, '#CAE4F9')
    linearGradient.addColorStop(0.85, color)
    this.context.fillStyle = linearGradient
    this.context.beginPath()
    this.context.ellipse(node.positionX, node.positionY, Config.cellRadius - 1, Config.cellRadius - 1, 0, 0, Math.PI * 2)
    this.context.fill()
    this.context.stroke()
  }

  removeBean(node:Node) {
    this.context.clearRect(node.cellX * Config.cellWidth, node.cellY * Config.cellWidth, Config.cellWidth, Config.cellWidth)
  }
}