import { displaySync } from '@kit.ArkGraphics2D';
import { display } from '@kit.ArkUI';
import { Config } from './Config';
import { Direction, Node, Status } from "./model/Model";
import { Helper } from './utils/Helper';
import { MyLog } from './utils/MyLog';

class Core {

  private static core = new Core();
  public static getInstance() {
    return Core.core;
  }

  private displaySync: displaySync.DisplaySync = displaySync.create()!

  private prevFrameTimestamp: number = 0 // 纳秒
  private prevAddBeanTimestamp: number = 0 // 纳秒
  private prevFrameDidSnapped: boolean = false // 上一帧是否做了贴紧网格操作

  frameRate:number = 60 // 帧率
  displayOrientation: display.Orientation = display.Orientation.PORTRAIT
  displayWidth:number = 0 // 可视区宽
  displayHeight:number = 0 // 可视区高
  availableCells:number[] = [] // 可用的网格集合（在这个范围内生成豆豆）
  fps:number= 0

  lastAddedBeanNode: Node = new Node(0, 0) // 最近一次添加的豆豆
  lastRemovedBeanNode: Node = new Node(0, 0) // 最近一次删除的豆豆
  lastAddedSkinNodes: Node[] = [] // 最近一次蜕下的皮们

  selfLength:number = 5 // 蛇的最小长度（包括头）
  generateBenInterval:number = 1500; // 生成豆豆的间隔时间，毫秒
  shedCount:number = 0; // 当前级别下的蜕皮的次数
  levelUpByShedCount:number = 2; // 当前级别下的蜕皮的次数达到此数量则升级一次

  // 当前的级别
  level: number = 0
  // 当前的得分
  score: number = 0

  // 级别进化
  levels: number[] = [ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 ]
  // 对应的级别，每一帧，蛇的移动距离
  levelOffsets: number[] = this.levels.map(p => p * 0.5 + 1)
  // 对应的级别，池中所允许的最大豆数
  levelBeanMaxCounts: number[] =  this.levels.map(p => p * 2 + 10)
  // 对应的级别，蛇的最大长度
  levelSnakeNodeMaxCounts: number[] = this.levels.map(p => p * 2 + 8)
  // 对应的级别，每吃一个豆所增加的分数
  levelScoreIncrements: number[] = this.levels.map(p => p * 50 + 50)

  // 蛇头的后续运动方向（第1个元素代表下一步方向，第2个元素代表下下一步方向）
  directions:Direction[] = []
  // snake 由一个头和多个身体构成
  snakeNodes:Array<Node> = []
  // 豆们
  beanNodes:Array<Node> = []
  // 皮们
  skinNodes:Array<Node> = []
  // 游戏状态
  status:Status = Status.paused

  private constructor() {
    // 参数初始化
    this.reset()

    // 获取可视区的宽高
    let displayCallback_change = async () => {
      let newDisplay: display.Display = display.getDefaultDisplaySync();
      this.displayWidth = Math.ceil(px2vp(newDisplay.width))
      this.displayHeight = Math.ceil(px2vp(newDisplay.height))
      this.displayOrientation = newDisplay.orientation
    }
    display.on("change", displayCallback_change);
    displayCallback_change()

    // 监听每一帧的回调
    this.frameCallback()
  }

  // 参数初始化
  public reset() {
    this.prevFrameTimestamp = 0
    this.prevAddBeanTimestamp = 0

    this.availableCells = []
    for (let x = 1; x < Config.cellColumns - 1; x++) {
      for (let y = 1; y < Config.cellRows - 1; y++) {
        this.availableCells.push(y * Config.cellColumns + x)
      }
    }

    this.snakeNodes = []
    this.snakeNodes.push(new Node(Math.floor(Config.cellColumns / 2), Math.floor(Config.cellRows / 2), Direction.right))
    for (let i = 0; i < this.selfLength - 1; i++) {
      this.addBody()
    }
  }

  // 监听每一帧的回调
  public frameCallback() {
    let displaySyncCallback_frame = (frameInfo: displaySync.IntervalInfo) => {
      if (this.prevFrameTimestamp > 0) {
        /*
        let elapsed = frameInfo.timestamp - this.prevFrameTimestamp
        let speed = 20 // 蛇的移动速度，单位 vp/s
        this.offset = elapsed / 1_000_000_000 * speed
        */
        this.fps = 1_000_000_000 / (frameInfo.timestamp - this.prevFrameTimestamp)
      }
      this.prevFrameTimestamp = frameInfo.timestamp

      if (this.status == Status.paused) {
        return
      }

      let snapOk = this.updateSnake()
      if (snapOk) {
        this.updateBeans(frameInfo.timestamp)
        this.updateSkins()
      }

      if (this.prevFrameDidSnapped) {
        this.checkCollision()
      }
      this.prevFrameDidSnapped = snapOk
    }
    this.displaySync.setExpectedFrameRateRange({
      expected: this.frameRate,
      min: this.frameRate,
      max: this.frameRate
    })
    this.displaySync.on("frame", displaySyncCallback_frame)
    this.displaySync.start()
  }

  // 更新蛇，返回值为此次移动是否做了贴紧网格的操作
  private updateSnake():boolean {
    let snapOk = false
    // 更新蛇的每个节点
    for (let i = 0; i < this.snakeNodes.length; i++) {
      let node = this.snakeNodes[i]
      if (i == 0) { // 蛇头
        let direction = node.direction
        if (this.directions.length > 0) {
          direction = this.directions[0]
        }
        snapOk = this.updateNodePosition(node, direction, true)
      } else { // 蛇身
        let prevNode = this.snakeNodes[i - 1]
        this.updateNodePosition(node, prevNode.prevDirection, false)
        this.updateNodeDirection(node, prevNode)
      }
    }

    this.emit(EventType.updateFrame)

    return snapOk
  }

  // 更新蛇的指定节点的位置，返回值为此次移动是否做了贴紧网格的操作
  private updateNodePosition(node: Node, newDirection: Direction, isHead: boolean = false):boolean {
    let moveResult = node.move(this.levelOffsets[this.level], newDirection)
    let snapOk = moveResult[0]
    let changeDirectionOk = moveResult[1]
    if (changeDirectionOk && isHead) {
      this.directions.shift()!
    }
    return snapOk
  }

  // 更新蛇的每个节点的方向
  private updateNodeDirection(node: Node, prevNode: Node) {
    if (node.direction == prevNode.direction) {
      if (node.direction == Direction.up) {
        node.positionY = prevNode.positionY + Config.cellWidth
      } else if (node.direction == Direction.down) {
        node.positionY = prevNode.positionY - Config.cellWidth
      } else if (node.direction == Direction.left) {
        node.positionX = prevNode.positionX + Config.cellWidth
      } else if (node.direction == Direction.right) {
        node.positionX = prevNode.positionX - Config.cellWidth
      }
    }
  }

  // 更新豆豆
  private updateBeans(timestamp:number) {
    // 吃豆豆
    let headNode = this.snakeNodes[0]
    for (let i = 0; i < this.beanNodes.length; i++) {
      let beanNode = this.beanNodes[i]
      if (beanNode.cellX == headNode.cellX && beanNode.cellY == headNode.cellY) {
        this.lastRemovedBeanNode = beanNode
        this.beanNodes.splice(i, 1)

        this.score += this.levelScoreIncrements[this.level]
        this.addBody()

        this.emit(EventType.eatBean)

        break
      }
    }

    // 新增豆豆
    if (this.beanNodes.length < this.levelBeanMaxCounts[this.level] && timestamp - this.prevAddBeanTimestamp > this.generateBenInterval * 1_000_000) {
      let freeCells = this.getFreeCells()
      let cell = freeCells[Helper.getRandomInt(0, freeCells.length - 1)];
      let cellXY = Helper.int2xy(cell, Config.cellColumns)
      let node = new Node(cellXY[0], cellXY[1])
      this.beanNodes.push(node)
      this.lastAddedBeanNode = node
      this.prevAddBeanTimestamp = timestamp

      this.emit(EventType.addBean)
    }
  }

  // 获取当前可用的网格，用于生成豆豆
  private getFreeCells(): number[] {
    // 蛇头附近的单元格
    let headNearCells: number[] = []
    let headCell = this.snakeNodes[0]
    for (let  i = -5; i < 5; i++) {
      for (let j = -5; j < 5; j++) {
        let nearCell = Helper.xy2int(headCell.cellX + i, headCell.cellY + j, Config.cellColumns)
        if (nearCell >= 0 && nearCell < this.availableCells.length) {
          headNearCells.push(nearCell);
        }
      }
    }

    let freeCells = this.availableCells.filter(p => !headNearCells.includes(p))
    return freeCells
  }

  // 检查是否需要蜕皮，然后更新皮信息
  private updateSkins() {
    if (this.snakeNodes.length > this.levelSnakeNodeMaxCounts[this.level]) {
      this.lastAddedSkinNodes = []
      while (this.snakeNodes.length > this.selfLength) {
        let node = this.snakeNodes.pop()!
        this.lastAddedSkinNodes.push(node)
        this.skinNodes.push(node)

        // 从有效网格中删除此次蜕皮的节点
        const index = this.availableCells.findIndex(item => item == Helper.xy2int(node.cellX, node.cellY, Config.cellColumns));
        if (index !== -1) {
          this.availableCells.splice(index, 1);
        }
      }

      this.shedCount ++
      if (this.shedCount >= this.levelUpByShedCount) {
        this.level ++
        if (this.level >= this.levels.length) {
          this.level = this.levels.length - 1
        }
        this.shedCount = 0
      }

      this.emit(EventType.addSkin)
    }
  }

  // 检查碰撞相关
  private checkCollision() {
    let headNode = this.snakeNodes[0]
    let bodyNodes = this.snakeNodes.slice(1, this.snakeNodes.length)

    // 头与边界的碰撞检查
    if (headNode.cellX < 0 || headNode.cellY < 0 || headNode.cellX > Config.cellColumns - 1 || headNode.cellY > Config.cellRows - 1) {
      this.status = Status.paused
      this.emit(EventType.gameOver)
    }

    // 头与身体的碰撞检查
    for (const bodyNode of bodyNodes) {
      if (bodyNode.cellX == headNode.cellX && bodyNode.cellY == headNode.cellY) {
        this.status = Status.paused
        this.emit(EventType.gameOver)
        break
      }
    }

    // 头与皮的碰撞检查
    for (const skinNode of this.skinNodes) {
      if (skinNode.cellX == headNode.cellX && skinNode.cellY == headNode.cellY) {
        this.status = Status.paused
        this.emit(EventType.gameOver)
        break
      }
    }
  }

  // 添加一段身体
  private addBody() {
    let currentBody = this.snakeNodes[this.snakeNodes.length - 1]
    let cellX = currentBody.cellX
    let cellY = currentBody.cellY
    if (currentBody.direction == Direction.up) {
      cellY += 1
    } else if (currentBody.direction == Direction.down) {
      cellY -= 1
    } else if (currentBody.direction == Direction.left) {
      cellX += 1
    } else if (currentBody.direction == Direction.right) {
      cellX -= 1
    }
    this.snakeNodes.push(new Node(cellX, cellY, currentBody.direction))
  }

  // <editor-fold desc='用户互动的相关方法'>
  public setSwipeAngle(angel:number) {
    let newDirection = Direction.right
    if (angel >= -45 && angel <= 45) {
      newDirection = Direction.right
    } else if (angel >= 45 && angel <= 135) {
      newDirection = Direction.down
    } else if (angel >= 135 || angel <= -145) {
      newDirection = Direction.left
    } else if (angel >= -145 && angel <= -45) {
      newDirection = Direction.up
    }

    if (this.directions.length < 2) {
      let direction:Direction = this.snakeNodes[0].direction
      if (this.directions.length > 0) {
        direction = this.directions[0]
      }
      if (direction == newDirection)
        return;
      if (direction == Direction.up && newDirection == Direction.down)
        return;
      if (direction == Direction.down && newDirection == Direction.up)
        return;
      if (direction == Direction.left && newDirection == Direction.right)
        return;
      if (direction == Direction.right && newDirection == Direction.left)
        return;
      this.directions.push(newDirection)
    }
  }
  // </editor-fold>

  // <editor-fold desc='事件的实现'>
  private callbacks: Map<EventType, Set<Callback>> = new Map()
  on(type: EventType, callback: () => void): void {
    if (!this.callbacks.has(type)) {
      this.callbacks.set(type, new Set())
    }
    this.callbacks.get(type)?.add(callback)
  }
  off(type: EventType, callback?: () => void): void {
    if (callback) {
      this.callbacks.get(type)?.delete(callback)
    } else {
      this.callbacks.delete(type)
    }
  }
  private emit(type: EventType): void {
    let callbackList = this.callbacks.get(type)
    if (callbackList) {
      for (const callback of callbackList) {
        callback();
      }
    }
  }
  // </editor-fold>
}

type Callback = () => void
export enum EventType {
  updateFrame,
  addBean,
  eatBean,
  addSkin,
  gameOver,
}
export let core = Core.getInstance()