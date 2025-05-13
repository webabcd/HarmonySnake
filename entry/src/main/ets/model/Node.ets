import { Direction } from "./Direction";
import { MyLog } from "../utils/MyLog";
import { Helper } from "../utils/Helper";
import { Config } from "../Config";

// 一个 Node 就是一个豆，或头，或身体，或皮
// 所谓网格，就是给界面分为多个格子，蜕皮和豆必须在格子内，蛇的运动方向的交叉轴方向必须要在格子内
export class Node {
  constructor(cellX: number, cellY: number, direction: Direction = Direction.right) {
    this.cellX = cellX
    this.cellY = cellY
    this.positionX = this.cellX * Config.cellWidth + Config.cellRadius;
    this.positionY = this.cellY * Config.cellWidth + Config.cellRadius;
    this.direction = direction;
    this.prevDirection = direction;
    this.prevSnappedCell = Helper.xy2int(cellX, cellY, Config.cellColumns)
  }
  positionX:number = 0 // Node 的中心点的坐标
  positionY:number = 0
  cellX:number = 0 // Node 的所属网格，当某个 Node 在其运动方向上有一小部分进入某个网格时，则该 Node 就属于这个网格
  cellY:number = 0
  direction:Direction = Direction.right // 当前运动方向

  prevDirection:Direction = Direction.right // 上一次运动方向
  prevSnappedCell:number = 0 // 上一次贴紧的网格

  // 更新当前位置，使其贴紧网格
  snapCell() {
    this.cellX = Math.floor(this.positionX / Config.cellWidth)
    this.cellY = Math.floor(this.positionY / Config.cellWidth)
    this.positionX = this.cellX * Config.cellWidth + Config.cellRadius;
    this.positionY = this.cellY * Config.cellWidth + Config.cellRadius;

    this.prevSnappedCell = Helper.xy2int(this.cellX, this.cellY, Config.cellColumns)
  }

  // 根据指定的运动方向，计算指定的位置的所属网格，当某个 Node 在其运动方向上有一小部分进入某个网格时，则该 Node 就属于这个网格
  getCell(positionX:number, positionY:number, direction:Direction): [number, number] {
    if (direction == Direction.up) {
      positionY -= Config.cellRadius - 0.1
    } else if (direction == Direction.down) {
      positionY += Config.cellRadius - 0.1
    } else if (direction == Direction.left) {
      positionX -= Config.cellRadius - 0.1
    } else if (direction == Direction.right) {
      positionX += Config.cellRadius - 0.1
    }

    return [Math.floor(positionX / Config.cellWidth), Math.floor(positionY / Config.cellWidth)]
  }

  // 获取当前 Node 的下一步移动后的位置
  getPosition(offset:number, direction:Direction): [number, number] {
    let movedX = this.positionX
    let movedY = this.positionY
    if (this.direction == Direction.up) {
      movedY -= offset
    } else if (this.direction == Direction.down) {
      movedY += offset
    } else if (this.direction == Direction.left) {
      movedX -= offset
    } else if (this.direction == Direction.right) {
      movedX += offset
    }
    return [movedX, movedY]
  }

  // 获取当前 Node 的下一步移动后的位置和其所属单元格，当某个 Node 在其运动方向上有一小部分进入某个网格时，则该 Node 就属于这个网格
  // 返回值为移动后的 Node 的 [positionX, positionY, cellX, cellY]
  getMovedPositionAndCell(offset:number, direction:Direction): [number, number, number, number] {
    let movedPositionX = this.positionX
    let movedPositionY = this.positionY
    if (this.direction == Direction.up) {
      movedPositionY -= offset
    } else if (this.direction == Direction.down) {
      movedPositionY += offset
    } else if (this.direction == Direction.left) {
      movedPositionX -= offset
    } else if (this.direction == Direction.right) {
      movedPositionX += offset
    }

    let positionX = movedPositionX
    let positionY = movedPositionY
    if (direction == Direction.up) {
      positionY -= Config.cellRadius - 0.1
    } else if (direction == Direction.down) {
      positionY += Config.cellRadius - 0.1
    } else if (direction == Direction.left) {
      positionX -= Config.cellRadius - 0.1
    } else if (direction == Direction.right) {
      positionX += Config.cellRadius - 0.1
    }

    return [positionX, positionY, Math.floor(positionX / Config.cellWidth), Math.floor(positionY / Config.cellWidth)]
  }

  // 移动当前节点
  // 返回值为，[此次移动是否完成了贴紧网格, 此次移动是否完成了方向的变化]
  move(offset:number, newDirection:Direction):[boolean, boolean] {
    let result:[boolean, boolean] = [false, false]

    // 位置移动后，当前节点的新的位置
    let newPositionXY = this.getPosition(offset, newDirection)
    // 位置移动后，当前节点的新的所属网格
    let newCellXY = this.getCell(newPositionXY[0], newPositionXY[1], this.direction)
    let newCell = Helper.xy2int(newCellXY[0], newCellXY[1], Config.cellColumns)
    // 位置移动前，当前节点的所属网格
    let currentCell = Helper.xy2int(this.cellX, this.cellY, Config.cellColumns)
    // 所属网格发生了变化，且之前未贴紧，则现在贴紧
    if (this.prevSnappedCell != currentCell && currentCell != newCell) {
      this.snapCell()
      result[0] = true

      this.prevDirection = this.direction
      if (newDirection != this.direction) {
        this.direction = newDirection
        result[1] = true
      }
    } else {
      this.prevDirection = this.direction
      this.positionX = newPositionXY[0]
      this.positionY = newPositionXY[1]
      this.cellX = newCellXY[0]
      this.cellY = newCellXY[1]
    }

    return result
  }
}
