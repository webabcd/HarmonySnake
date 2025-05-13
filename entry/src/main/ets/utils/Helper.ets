import display from "@ohos.display";

export class Helper {

  static enumToString<T extends Object>(e:T): string[] {
    let result: string[] = []
    Object.keys(e).forEach(key => {
      if (isNaN(Number(key))) {
        result.push(key)
      }
    });
    return result
  }

  static formatDate(date:Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
  }

  static getTimestampString(timestamp?:number): string {
    if (timestamp == undefined) {
      const now = new Date();
      return Helper.formatDate(now)
    } else {
      const now = new Date(timestamp);
      return Helper.formatDate(now)
    }
  }

  static getRandomInt(min: number, max: number): number {
    // Math.random() * (max - min + 1) 生成 [0, max-min+1) 的浮点数
    // Math.floor() 将其向下取整，得到 [min, max] 的整数
    return Math.floor(Math.random() * (max - min + 1)) + min;
  }

  static formatWithCommas(num: number): string {
    return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  }

  // x 为当前单元格在网格中的列索引位置
  // y 为当前单元格在网格中的行索引位置
  // columns 为网格的列数
  // 返回值为当前单元格的位置
  static xy2int(x: number, y: number, columns: number): number {
    return columns * y + x
  }

  // i 为当前单元格的位置
  // columns 为网格的列数
  // 返回值中的第 1 个元素为当前单元格在网格中的列索引位置
  // 返回值中的第 2 个元素为当前单元格在网格中的行索引位置
  static int2xy(i: number, columns: number): [number, number] {
    return [i % columns, Math.floor(i / columns)]
  }
}
