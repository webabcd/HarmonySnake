import { Config } from '../Config';
import { core, EventType } from '../Core';
import { Node } from '../model/Model';

@Component
export struct Bar {

  @Prop fps: string = ""
  @Prop score: string = ""
  @Prop level: string = ""
  @Prop eats: string = ""

  aboutToAppear(): void {

  }

  build() {
    RelativeContainer() {
      Column().width('100%').height('100%')
        .backgroundColor('367DF9')
        .borderWidth(1)
        .borderColor('#D0CD4B')
        .opacity(0.30)

      Text(this.score).fontColor(Color.White).textAlign(TextAlign.Start)
        .alignRules({
          center: {anchor: "__container__", align: VerticalAlign.Center},
          left: {anchor: "__container__", align: HorizontalAlign.Start}
        })
        .margin({left: 10})

      Row({space:10}) {
        Text(this.level).fontColor(Color.White)
        Text(this.eats).fontColor(Color.White)
        Text(this.fps).fontColor(Color.White).visibility(Visibility.None)
      }
      .alignRules({
        center: {anchor: "__container__", align: VerticalAlign.Center},
        right: {anchor: "__container__", align: HorizontalAlign.End}
      })
      .margin({right: 10})
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .height(40)
  }
}