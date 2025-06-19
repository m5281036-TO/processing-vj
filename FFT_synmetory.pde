import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput mic;
FFT fft;
int fftSize;
int colorScheme = 0;  // 現在のカラースキーム番号（0: HSB, 1: モノクロ, 2: 反転）

void setup()
{
  size(1024, 480, P2D);
  noStroke();
  colorMode(HSB, 360, 100, 100, 100);
  
  minim = new Minim(this);
  fftSize = 512;

  mic = minim.getLineIn(Minim.MONO, fftSize);
  fft = new FFT(fftSize, mic.sampleRate());
}

void draw()
{
  background(0);
  fft.forward(mic.left);

  for (int side = 0; side < 2; side++) {
    for (int i = 0; i < fft.specSize(); i++) {
      float h = 0, s = 0, b = 0, a = 0;
      float amplitude = fft.getBand(i);
      
      // カラースキームごとの色情報設定
      switch (colorScheme) {
        case 0:  // HSBカラー（虹色）
          h = map(i, 0, fft.specSize(), 0, 180);
          s = 80;
          b = 80;
          break;
        case 1:  // グレースケール
          h = 0;
          s = 0;
          b = map(amplitude, 0, fftSize / 64.0, 0, 100);
          break;
        case 2:  // 色反転風
          h = map(i, 0, fft.specSize(), 180, 0);
          s = 100;
          b = map(amplitude, 0, fftSize / 64.0, 100, 0);
          break;
      }
      a = map(amplitude, 0, fftSize / 64.0, 0, 255);
      fill(h, s, b, a);

      float x = map(i, 0, fft.specSize(), side == 0 ? width / 2 : width, side == 0 ? 0 : width / 2);
      float w = width / float(fft.specSize()) / 2;
      rect(x, 0, w, height);
    }
  }
}

void keyPressed() {
  // 数字キー '1', '2', '3' でカラースキームを切り替える
  if (key == '1') colorScheme = 0;
  else if (key == '2') colorScheme = 1;
  else if (key == '3') colorScheme = 2;
}

void stop()
{
  mic.close();
  minim.stop();
  super.stop();
}
