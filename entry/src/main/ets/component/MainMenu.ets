import { http } from "@kit.NetworkKit"
import { BusinessError } from "@kit.BasicServicesKit"
import { CryptoJS } from '@ohos/crypto-js'
import { Helper } from "../utils/Helper"
import { Config } from "../Config"
import { promptAction, SwipeRefresher } from "@kit.ArkUI"
import { MainMenuType } from "../model/Model"
import { preferences } from "@kit.ArkData"
import { common } from "@kit.AbilityKit"

@CustomDialog
export struct MainMenu {

  controller?: CustomDialogController
  startClicked: () => void = () => {  }

  @Prop mainMenuType: MainMenuType = MainMenuType.main
  @Prop score: number = 0

  build() {
    Column() {
      if (this.mainMenuType == MainMenuType.leaderboard) {
        Leaderboard({
          backClicked: () => {
            this.mainMenuType = MainMenuType.main
          }
        })
      } else if (this.mainMenuType == MainMenuType.over) {
        Over({
          score: this.score,
          backClicked: () => {
            this.mainMenuType = MainMenuType.main
          }
        })
      } else if (this.mainMenuType == MainMenuType.main) {

        Text($r('app.string.app_name')).fontSize(48).fontColor(0x003366).height(88)

        Button('开始').margin(12).backgroundColor(0x0a59f6).fontColor(Color.White).width(200).onClick(() => {
          if (this.controller != undefined) {
            this.controller.close()
          }
          this.startClicked()
        })
        Button('排行榜').margin({ top:12, left:12, right:12, bottom: 48 }).backgroundColor(0x0a59f6).fontColor(Color.White).width(200).onClick(() => {
          this.mainMenuType = MainMenuType.leaderboard
        })
      }
    }
    .width('100%')
    .linearGradient({
      colors: [
        [0xD4EDFF, 0.0],
        [0x9FD4FF, 0.5],
        [0x6BB2FF, 1.0],
      ]
    })
  }
}

@Component
struct Over {

  @State message: string = ""
  @State requestFinished: boolean = true
  @Prop score: number = 0
  backClicked: () => void = () => {  }

  @State name:string = ""

  context = getContext(this) as common.UIAbilityContext
  dataPreferences: preferences.Preferences | null = null

  async aboutToAppear() {
    this.dataPreferences = await preferences.getPreferences(this.context, {
      name: 'myStore'
    });

    this.name = await this.dataPreferences?.get('name', `匿名${Helper.getRandomInt(100000, 999999)}`) as string;
  }

  build() {
    Column({space: 20}) {

      Row({ space: 10 }) {
        SymbolGlyph($r('sys.symbol.arrow_left')).fontSize(20).fontColor([0x003366]).onClick(() => {
          this.backClicked()
        })
        Text('游戏结束').fontSize(20).fontColor(0x003366)
        SwipeRefresher({
          content: 'loading',
          isLoading: true
        }).visibility(this.requestFinished ? Visibility.None : Visibility.Visible)
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .margin({top:20})
      .width('100%')

      Row() {
        Text("得分：")
        Text(this.score.toString())
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Row() {
        Text("姓名：")
        TextInput({text: $$this.name}).id("txtName").layoutWeight(1).enabled(this.requestFinished).onBlur(async () => {
          await this.dataPreferences?.put('name', this.name.trim());
          await this.dataPreferences?.flush()
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Text(this.message).fontSize(16).width('100%').height(64).textAlign(TextAlign.Center).visibility(this.message == "" ? Visibility.None : Visibility.Visible)

      Button('提交得分').margin({ top: 10, bottom: 20 }).enabled(this.requestFinished).onClick(async () => {

        let url = Config.apiDomain + "/api/add_score"
        let name = this.name.trim()

        if (name == "") {
          focusControl.requestFocus("txtName")
          return
        }
        await this.dataPreferences?.put('name', this.name.trim());
        await this.dataPreferences?.flush()

        this.requestFinished = false

        url += `?name=${name}`
        url += `&score=${this.score}`
        url += "&hash=" + CryptoJS.enc.Hex.stringify(CryptoJS.MD5(`${name}_${this.score}_abcXYZ123!@#`))
        let httpRequest = http.createHttp()
        httpRequest.request(
          url,
          {
            method: http.RequestMethod.GET,
            expectDataType: http.HttpDataType.STRING,
            connectTimeout: 30_000,
            readTimeout: 30_000,
          },
          (err: BusinessError, data: http.HttpResponse) => {
            if (!err) {
              promptAction.showToast({
                message: "提交成功",
                duration: 3000
              })
              this.backClicked()
            }
            this.requestFinished = true
            httpRequest.destroy()
          }
        );
      })
    }
    .width('90%')
  }
}

@Component
struct Leaderboard {

  @State message: string = ""
  @State requestFinished: boolean = false
  @State dataList: Record<string, string | number>[] = []
  backClicked: () => void = () => {  }

  async aboutToAppear(): Promise<void> {
    await this.loadScore()
  }

  async loadScore() {
    let httpRequest = http.createHttp()

    let url = Config.apiDomain + "/api/get_score"
    httpRequest.request(
      url,
      {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.STRING,
        connectTimeout: 30_000,
        readTimeout: 30_000,
      },
      (err: BusinessError, data: http.HttpResponse) => {
        if (!err) {
          try {
            this.dataList = JSON.parse(data.result as string) as Record<string, string | number>[]
          } catch (error) {
            let e = error as BusinessError
            this.message = `errCode:${e.code}, errMsg:${e.message}`
          }
        } else {
          this.message = `errCode:${err.code}, errMsg:${err.message}`
        }

        this.requestFinished = true
        httpRequest.destroy()
      }
    );
  }

  build() {
    Column() {

      Row({ space: 10 }) {
        SymbolGlyph($r('sys.symbol.arrow_left')).fontSize(20).fontColor([0x003366]).onClick(() => {
          this.backClicked()
        })
        Text('排行榜').fontSize(20).fontColor(0x003366)
        SwipeRefresher({
          content: 'loading',
          isLoading: true
        }).visibility(this.requestFinished ? Visibility.None : Visibility.Visible)
      }
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Start)
      .margin({bottom:20, top:20})
      .width('100%')

      Row({space:5}) {
        Text("排名").fontSize(16).width(40).textAlign(TextAlign.Center)
        Text("姓名").fontSize(16).layoutWeight(1).textAlign(TextAlign.Center)
        Text("得分").fontSize(16).layoutWeight(1).textAlign(TextAlign.Center)
      }
      .justifyContent(FlexAlign.SpaceAround)
      .margin({bottom:10})
      .width('100%')

      Text(this.message).fontSize(16).width('100%').height(200).textAlign(TextAlign.Center).visibility(this.message == "" ? Visibility.None : Visibility.Visible)

      List({ space: 15, }) {
        ForEach(this.dataList, (item: Record<string, string | number>, index:number) => {
          ListItem() {
            Row({space:5}) {
              Text(`${index + 1}`).fontSize(16).width(40).textAlign(TextAlign.Center)
              Text(item.name as string).fontSize(16).layoutWeight(1).textAlign(TextAlign.Center)
              Text(`${Helper.formatWithCommas(item.max_score as number)}`).fontSize(16).layoutWeight(1).textAlign(TextAlign.Center)
            }
          }
        })
      }
      .listDirection(Axis.Vertical)
      .width('100%')
      .layoutWeight(1)
      .margin({bottom: 24})
    }
    .width('90%')
  }
}