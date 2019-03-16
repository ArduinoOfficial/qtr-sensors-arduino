#include <EEPROM.h>
#define sagyon 7
#define sagyon2 6
#define solyon 9
#define solyon2 8
#define sagmotorpwmpin 10
#define solmotorpwmpin 5

extern volatile unsigned long timer0_millis;
int tehlike = 0, deger, zemin = 0;  //zemin beyaz !!!!!!!
int sensor[8], i, sensor_normalize[8];
int sensorMax[8] = { 800, 800, 800, 800, 800, 800, 800, 800 };
int sensorMin[8] = { 80, 80, 80, 80, 80, 80, 80, 80 };
int byz_snsr = 0, sensor_bit, payda, oransal, eskioransal, hata, turev, sag, sol, poz;
int32_t pay;
int hiz, start = 0, durdur = 0, durum;
float kp = 0.0011, yol = 0.0, kd = 0.021;
int mehmet = 0, gokhan = 0, izzet = 0, doksan = 0, samil = 0, samil2 = 0, doksan2 = 0, kopru = 0, sinan = 0, bitis = 0;
int mehmetT, gokhanT, izzetT, doksanT, samilT, samil2T, doksan2T, kopruT, sinanT, bitisT;

void ana_program() {
  mehmet = 0;


  //***********************************************     MEHMET    **************************
  hiz = 70;
  yol = 0.0;
  timer0_millis = 0;
  while (mehmet == 0) {
    poz_bul();
    hareket();
  }
}

void hareket() {
  oransal = poz - 1001;

  turev = oransal - eskioransal;
  eskioransal = oransal;

  hata = hiz * (oransal * kp + turev * kd);



  if (hata < 0) {
    sag = hiz + hata;
    sol = hiz - hata / 16;
  } else {
    sol = hiz - hata;
    sag = hiz + hata / 16;
  }



  motor(sol, sag);
}


void motor(int sol, int sag) {

  if (sag > 254) sag = 254;
  if (sol > 254) sol = 254;
  if (sag < -254) sag = -254;
  if (sol < -254) sol = -254;

  if (sol < 0) {
    sol = abs(sol);
    digitalWrite(solyon, LOW);
    digitalWrite(solyon2, HIGH);
    analogWrite(solmotorpwmpin, sol);
  } else {
    digitalWrite(solyon, HIGH);
    digitalWrite(solyon2, LOW);
    analogWrite(solmotorpwmpin, sol);
  }

  if (sag < 0) {
    sag = abs(sag);
    digitalWrite(sagyon, HIGH);
    digitalWrite(sagyon2, LOW);
    analogWrite(sagmotorpwmpin, sag);
  } else {
    digitalWrite(sagyon, LOW);
    digitalWrite(sagyon2, HIGH);
    analogWrite(sagmotorpwmpin, sag);
  }
}

void poz_bul() {
  //////////////////////////////////////////////////SENSOR OKU///////////////////////////////////
  for (i = 0; i < 8; i++) sensor[i] = analogRead(i);

  byz_snsr = 0;
  for (i = 0; i < 8; i++) {
    if (sensor[i] > 400) bitSet(sensor_bit, i);
    else {
      byz_snsr++;
      bitClear(sensor_bit, i);
    }
  }

  ////////////***********************zemin beyaz ise /////////////////////////////////////////////////////////////////////
  if (zemin == 0) {
    for (i = 0; i < 8; i++) {
      if (sensor[i] < sensorMin[i]) sensor_normalize[i] = 0;
      else if (sensor[i] > sensorMax[i]) sensor_normalize[i] = 1023;
      else
        sensor_normalize[i] = (int32_t(sensor[i] - sensorMin[i]) * 1023) / (sensorMax[i] - sensorMin[i]);
    }
  }

  //***********************zemin siyahsa /////////////////////////////////////////////////////////////////////
  if (zemin == 1) {
    for (i = 0; i < 8; i++) {
      if (sensor[i] < sensorMin[i]) sensor_normalize[i] = 1023;
      else if (sensor[i] > sensorMax[i]) sensor_normalize[i] = 0;
      else {
        sensor_normalize[i] = (int32_t(sensor[i] - sensorMin[i]) * 1023) / (sensorMax[i] - sensorMin[i]);
        sensor_normalize[i] = 1023 - sensor_normalize[i];
      }
    }
  }

  //////////////////////////////////////////////////POZU BUL///////////////////////////////////////
  if (byz_snsr >= 1 && byz_snsr <= 7) {
    pay = 0;
    payda = 0;
    for (i = 0; i < 8; i++) {
      pay = pay + sensor_normalize[i] * int32_t(i * 286);
      payda = payda + sensor_normalize[i];
    }
    poz = pay / payda;
  }
}


void setup() {
  TCCR0A = _BV(COM0A1) | _BV(COM0B1) | _BV(WGM00);
  TCCR0B = _BV(CS00);  //32KHz
  pinMode(solyon, OUTPUT);
  pinMode(sagyon, OUTPUT);
  //motor(0, 0);
  Serial.begin(9600);
}
void loop() {




  //enkoder();
  ana_program();
}
