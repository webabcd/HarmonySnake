import { Config } from '../Config';
import { core, EventType } from '../Core';
import { Node, Direction } from '../model/Model';

@Component
export struct Snake {

  context: CanvasRenderingContext2D = new CanvasRenderingContext2D(new RenderingContextSettings(true))

  aboutToAppear(): void {
    core.on(EventType.updateFrame, () => {
      this.update()
    })
  }

  build() {
    Canvas(this.context).width('100%').height('100%')
      .onReady(() => {

      })
  }

  update() {
    // this.context.reset()
    this.context.clearRect(0, 0, Config.canvasWidth, Config.canvasHeight)
    for (let i = core.snakeNodes.length - 1; i >= 0; i--) {
      let node = core.snakeNodes[i]
      if (i == 0) {
        this.drawHead(node.positionX, node.positionY, node.direction)
      } else {
        this.drawBody(node.positionX, node.positionY, node.direction)
      }
    }
    /*
    core.snakeNodes.forEach((node, index) => {
      if (index == 0) {
        this.drawHead(node.positionX, node.positionY)
      } else {
        this.drawBody(node.positionX, node.positionY)
      }
    })
    */
  }

  drawHead(x:number, y:number, direction:Direction) {
    let leftEyeCenterX = 0
    let leftEyeCenterY = 0
    let rightEyeCenterX = 0
    let rightEyeCenterY = 0
    let bigEyeRadius = Config.cellRadius / 2.5
    let smallEyeRadius = Config.cellRadius / 4.2
    let endAngle = Math.PI * 2
    let gradientStartX = 0
    let gradientStartY = 0
    let gradientEndX = 0
    let gradientEndY = 0
    switch (direction) {
      case Direction.up:
        leftEyeCenterX = x - Config.cellRadius / 2 + 1
        leftEyeCenterY = y - Config.cellRadius / 2 + 2
        rightEyeCenterX = x + Config.cellRadius / 2 - 1
        rightEyeCenterY = y - Config.cellRadius / 2 + 2
        gradientStartX = x
        gradientStartY = y - Config.cellRadius
        gradientEndX = x
        gradientEndY = y + Config.cellRadius
        break
      case Direction.right:
        leftEyeCenterX = x + Config.cellRadius / 2 - 2
        leftEyeCenterY = y - Config.cellRadius / 2 + 1
        rightEyeCenterX = x + Config.cellRadius / 2 - 2
        rightEyeCenterY = y + Config.cellRadius / 2 - 1
        gradientStartX = x + Config.cellRadius
        gradientStartY = y
        gradientEndX = x - Config.cellRadius
        gradientEndY = y
        break
      case Direction.down:
        leftEyeCenterX = x - Config.cellRadius / 2 + 1
        leftEyeCenterY = y + Config.cellRadius / 2 - 2
        rightEyeCenterX = x + Config.cellRadius / 2 - 1
        rightEyeCenterY = y + Config.cellRadius / 2 - 2
        gradientStartX = x
        gradientStartY = y + Config.cellRadius
        gradientEndX = x
        gradientEndY = y - Config.cellRadius
        break
      case Direction.left:
        leftEyeCenterX = x - Config.cellRadius / 2 + 2
        leftEyeCenterY = y - Config.cellRadius / 2 + 1
        rightEyeCenterX = x - Config.cellRadius / 2 + 2
        rightEyeCenterY = y + Config.cellRadius / 2 - 1
        gradientStartX = x - Config.cellRadius
        gradientStartY = y
        gradientEndX = x + Config.cellRadius
        gradientEndY = y
        break
      default:
        break
    }

    this.context.strokeStyle = '#7497F5'
    this.context.lineWidth = 1
    let linearGradient = this.context.createLinearGradient(gradientStartX, gradientStartY, gradientEndX, gradientEndY)
    linearGradient.addColorStop(0.0, '#3457F5')
    linearGradient.addColorStop(0.10, '#CAE4F9')
    linearGradient.addColorStop(0.85, '#3457F5')
    this.context.fillStyle = linearGradient
    this.context.beginPath()
    this.context.ellipse(x, y, Config.cellRadius, Config.cellRadius, 0, 0, endAngle)
    this.context.fill()
    this.context.stroke()

    this.context.fillStyle = '#F5F2F6'
    this.context.beginPath()
    this.context.ellipse(leftEyeCenterX, leftEyeCenterY, bigEyeRadius, bigEyeRadius, 0, 0, endAngle)
    this.context.ellipse(rightEyeCenterX, rightEyeCenterY, bigEyeRadius, bigEyeRadius, 0, 0, endAngle)
    this.context.fill()

    this.context.fillStyle = '#161A1B'
    this.context.beginPath()
    this.context.ellipse(leftEyeCenterX, leftEyeCenterY, smallEyeRadius, smallEyeRadius, 0, 0, endAngle)
    this.context.ellipse(rightEyeCenterX, rightEyeCenterY, smallEyeRadius, smallEyeRadius, 0, 0, endAngle)
    this.context.fill()
  }

  drawBody(x:number, y:number, direction:Direction) {
    let gradientStartX = 0
    let gradientStartY = 0
    let gradientEndX = 0
    let gradientEndY = 0
    switch (direction) {
      case Direction.up:
        gradientStartX = x - Config.cellRadius
        gradientStartY = y - Config.cellRadius + Config.cellWidth * 0.3
        gradientEndX = x + Config.cellRadius
        gradientEndY = y - Config.cellRadius + Config.cellWidth * 0.7
        break
      case Direction.right:
        gradientStartX = x + Config.cellRadius - Config.cellWidth * 0.3
        gradientStartY = y - Config.cellRadius
        gradientEndX = x + Config.cellRadius - Config.cellWidth * 0.7
        gradientEndY = y + Config.cellRadius
        break
      case Direction.down:
        gradientStartX = x + Config.cellRadius
        gradientStartY = y + Config.cellRadius - Config.cellWidth * 0.3
        gradientEndX = x - Config.cellRadius
        gradientEndY = y + Config.cellRadius - Config.cellWidth * 0.7
        break
      case Direction.left:
        gradientStartX = x - Config.cellRadius + Config.cellWidth * 0.3
        gradientStartY = y + Config.cellRadius
        gradientEndX = x - Config.cellRadius + Config.cellWidth * 0.7
        gradientEndY = y - Config.cellRadius
        break
      default:
        break
    }

    let linearGradient = this.context.createLinearGradient(gradientStartX, gradientStartY, gradientEndX, gradientEndY)
    linearGradient.addColorStop(0.0, '#FF4500')
    linearGradient.addColorStop(0.05, '#CAE4F9')
    linearGradient.addColorStop(0.85, '#FF4500')
    this.context.fillStyle = linearGradient
    this.context.beginPath()
    this.context.ellipse(x, y, Config.cellRadius, Config.cellRadius, 0, 0, Math.PI * 2)
    this.context.fill()
  }
}