export class Config {
  static cellRows:number = 1 + 2 * 30  // 水平方向格子的数量
  static cellColumns:number = 1 + 2 * 30  // 垂直方向格子的数量
  static cellWidth:number = 24 // 格子的宽度，也就是豆豆的直径，以及蛇的每一节的直径
  static cellRadius:number = Config.cellWidth / 2 // 格子的宽度/2，也就是豆豆的半径，以及蛇的每一节的半径
  static canvasWidth:number = Config.cellWidth * Config.cellRows
  static canvasHeight:number = Config.cellWidth * Config.cellColumns

  static apiDomain:string = 'https://webabcd.pythonanywhere.com'
}