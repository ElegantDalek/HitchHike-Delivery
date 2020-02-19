#include <SoftwareSerial.h>
#include "MMA7660.h"

//acceleromoter
void accel_print();
void accel_setup();
void accel_update();
bool check_shake();
bool check_orient();
bool is_level();
MMA7660 accel;
int8_t x;
int8_t y;
int8_t z;
float ax, ay, az;

const float tamp_sens = 0.25;
//locking mechanism vars
void lock();
void unlock();
int servo = 9;          
int lock_pos = 160;
int unlock_pos = 250;

//serial communication
int sByte = 0;
int bByte = 0;

//bluetooth setup
void bluetooth_setup();

//status lights
void led_setup();
void led_off();
void led_both();
void led_green();
void led_red();
int green_l = 13;
int red_l = 11;

//SoftwareSerial BTSerial(4,5);



// the setup routine runs once when you press reset:
void setup() {
  led_setup();

  led_off();
  Serial.begin(9600);
  while(!Serial) {}
  Serial.println("connected");
 
  led_red();
  accel_setup();
  Serial.println("acc inin");
  led_green();
  bluetooth_setup();
  led_both();
  lock_setup();  
}

void accel_setup() {
  accel.init();
}

void led_setup() {
  pinMode(green_l, OUTPUT);
  pinMode(red_l, OUTPUT);
  digitalWrite(green_l, LOW);
  digitalWrite(red_l, LOW);
  led_off();
}
void led_off() {
  digitalWrite(green_l, LOW);
  digitalWrite(red_l, LOW); 
}
void led_green() {
  digitalWrite(green_l, HIGH);
  digitalWrite(red_l, LOW); 
}
void led_red() {
  digitalWrite(green_l, LOW);
  digitalWrite(red_l, HIGH); 
}

void led_both() {
  digitalWrite(green_l, HIGH);
  digitalWrite(red_l, HIGH); 
}

void bluetooth_setup() {
  String setName = String("AT+NAME=HHCooler\r\n"); //set name 'HHCooler'
  //BTSerial.begin(38400);
  led_red();
  delay(1000);
  Serial.print("AT\r\n"); //check status
  Serial.print(setName);
  
}

void lock_setup() {
  pinMode(servo, OUTPUT);
}
// the loop routine runs over and over again forever:
void loop() {
  //accel_print();
  //Serial.print(".");
  if ( Serial.available() > 0 ) {
    //led_both();
    sByte = Serial.read();
    
    //lock controls
    if (sByte == 108) lock();
    if (sByte == 117) unlock();
    Serial.println(sByte);
  }
  accel_update();
  if ( !is_level() ) {
      led_both();
      Serial.println("tamper");   
      accel_update();
      accel_print();
//      delay(50);
//      led_off();
//      delay(50);
    }  else {
      led_off();
    }

  delay(500);
}
void accel_update() {
  accel.getXYZ(&x, &y, &z);
  accel.getAcceleration(&ax, &ay, &az);
}
bool check_shake() {
  return ( x > 1 || y > 1 || z > 1 );
}

bool check_orient() {
  
}
bool is_level() {
 // Serial.print("tamp_sens: ");                                                                                                                         k k        
  //Serial.println(tamp_sens);
  return (ax < tamp_sens && ax > -tamp_sens &&
          ay < tamp_sens && ay > -tamp_sens &&
          az < -(1+tamp_sens) && az > -(1-tamp_sens) );
}
void lock() {
  analogWrite(servo, lock_pos);
  led_red();
  delay(700);
  //Serial.println("locked");
}

void unlock() {
  analogWrite(servo, unlock_pos);
  led_green();
  delay(700);
  //Serial.println("unlocked");
}


void accel_print() {
    
//    accel.getXYZ(&x, &y, &z);
//
//    Serial.print("x = ");
//    Serial.println(x);
//    Serial.print("y = ");
//    Serial.println(y);
//    Serial.print("z = ");
//    Serial.println(z);

    accel.getAcceleration(&ax, &ay, &az);
    Serial.println("accleration of X/Y/Z: ");
    Serial.print(ax);
    Serial.println(" g");
    Serial.print(ay);
    Serial.println(" g");
    Serial.print(az);
    Serial.println(" g");
    Serial.println("*************");
    delay(500);
    
}
