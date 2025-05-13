import display from "@ohos.display";
import { media } from "@kit.MediaKit";
import { BusinessError } from '@kit.BasicServicesKit';
import { MyLog } from "./MyLog";

export class MediaHelper {

  private static players: media.AVPlayer[] = []

  static async init(context:Context) {
    for (let i = 0; i < 4; i++) {
      let avPlayer: media.AVPlayer = await media.createAVPlayer();
      MediaHelper.players.push(avPlayer)

      let rawName = 'drop.mp3'
      if (i == 1) {
        rawName = 'eat.mp3'
      } else if (i == 2) {
        rawName = 'skin.mp3'
      } else if (i == 3) {
        rawName = 'over.mp3'
      }

      let fileDescriptor = context.resourceManager.getRawFdSync(rawName);
      let avFileDescriptor: media.AVFileDescriptor = {
        fd: fileDescriptor.fd,
        offset: fileDescriptor.offset,
        length: fileDescriptor.length
      };
      avPlayer.fdSrc = avFileDescriptor;

      avPlayer.on('stateChange', (state: string, reason: media.StateChangeReason) => {
        if (state == 'initialized') {
          avPlayer.prepare().then(() => {

          }).catch((err: BusinessError) => {

          })
        }
      })
    }
  }

  static playDrop() {
    MediaHelper.players[0].seek(0)
    MediaHelper.players[0].play()
  }

  static playEat() {
    MediaHelper.players[1].seek(0)
    MediaHelper.players[1].play()
  }

  static playSkin() {
    MediaHelper.players[2].seek(0)
    MediaHelper.players[2].play()
  }

  static playOver() {
    MediaHelper.players[3].seek(0)
    MediaHelper.players[3].play()
  }
}
