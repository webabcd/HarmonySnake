import { Backdrop, Beans, Snake, Skins, Bar } from '../component/Component';
import { Config } from '../Config';
import { core, EventType } from '../Core';
import { common } from '@kit.AbilityKit';
import { display, promptAction, window } from '@kit.ArkUI';
import { MediaHelper } from '../utils/MediaHelper';
import { MainMenu } from '../component/MainMenu';
import { MainMenuType, Status } from '../model/Model';
import { MyLog } from '../utils/MyLog';

@Entry
@Component
struct Index {

  @State translateX:number = 0
  @State translateY:number = 0
  @State barMarginTop:number = 0

  @State bar_fps:string = ''
  @State bar_score:string = ''
  @State bar_level:string = ''
  @State bar_eats:string = ''

  @State mainMenuType:MainMenuType = MainMenuType.main

  @State finalScore:number = 0
  context = getContext(this) as common.UIAbilityContext;

  aboutToAppear(): void {
    core.on(EventType.updateFrame, () => {
      this.bar_fps = `fps:${core.fps.toFixed(2)}`
      this.updateTranslateXY()
    })

    this.updateBarMessage()
    core.on(EventType.eatBean, () => {
      this.updateBarMessage()
      MediaHelper.playEat()
    })
    core.on(EventType.addSkin, () => {
      this.updateBarMessage()
      MediaHelper.playSkin()
    })
    core.on(EventType.gameOver, () => {
      MediaHelper.playOver()
      this.finalScore = core.score

      setTimeout(() => {
        this.mainMenuType = MainMenuType.over
        this.dialogController?.open()
      }, 1000)
    })
    core.on(EventType.addBean, () => {
      MediaHelper.playDrop()
    })

    this.updateBarPosition()
    this.context.windowStage.getMainWindowSync().on('windowSizeChange', () => {
      this.updateBarPosition()
    });

    this.dialogController?.open()
  }

  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: MainMenu({
      score: this.finalScore,
      mainMenuType: this.mainMenuType,
      startClicked: ()=> {
        core.reset()
        core.status = Status.playing
      },
    }),
    isModal: true,
    autoCancel: false,

  })

  updateBarMessage() {
    this.bar_score = `得分:${core.score}`
    this.bar_level = `级别:${core.level + 1}`
    this.bar_eats = `食量:${core.snakeNodes.length - core.selfLength}/${core.levelSnakeNodeMaxCounts[core.level] - core.selfLength}`
  }

  updateBarPosition() {
    this.barMarginTop = 0
    if (core.displayOrientation == display.Orientation.PORTRAIT || core.displayOrientation == display.Orientation.PORTRAIT_INVERTED) {
      let windowStage = this.context.windowStage;
      let windowClass = windowStage.getMainWindowSync();
      this.barMarginTop = px2vp(windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM).topRect.height)
      if (this.barMarginTop > 0) {
        this.barMarginTop += 5
      }
    }
  }

  updateTranslateXY() {
    let headNode = core.snakeNodes[0]
    if (headNode.positionX > Config.canvasWidth - core.displayWidth / 2) {
      this.translateX = -Config.canvasWidth + core.displayWidth
    } else if (-headNode.positionX + core.displayWidth / 2 > 0) {
      this.translateX = 0
    } else {
      this.translateX = -headNode.positionX + core.displayWidth / 2
    }

    if (headNode.positionY > Config.canvasHeight - core.displayHeight / 2) {
      this.translateY = -Config.canvasHeight + core.displayHeight
    } else if (-headNode.positionY + core.displayHeight / 2 > 0) {
      this.translateY = 0
    } else {
      this.translateY = -headNode.positionY + core.displayHeight / 2
    }
  }

  build() {
    RelativeContainer() {
      Scroll() {
        Stack() {
          Backdrop()
          Skins()
          Beans()
          Snake()
        }
        .translate({
          x: this.translateX,
          y: this.translateY,
        })
        .width(Config.canvasWidth)
        .height(Config.canvasHeight)
      }
      .width('100%')
      .height('100%')
      .enableScrollInteraction(false)
      .scrollable(ScrollDirection.None)

      Bar({
        fps: this.bar_fps,
        score: this.bar_score,
        level: this.bar_level,
        eats: this.bar_eats
      })
        .alignRules({
          top: {anchor: "__container__", align: VerticalAlign.Top}
        })
        .margin({top: this.barMarginTop})
    }
    .width('100%')
    .height('100%')
    .gesture(
      SwipeGesture({
        direction: SwipeDirection.All,
        fingers: 1
      })
        .onAction((event: GestureEvent) => {
          core.setSwipeAngle(event.angle)
        })
    )
  }
}