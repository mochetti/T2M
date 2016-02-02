//
//  Blink example
//  blink(interval, times)
//
//  Created by Thiago Mochetti on 28/01/16.
//
//

#include <T2M.h>

Led led(13);  // led pin

void setup()
{
  
}

void loop()
{
  oi.blink(500, 5);  //blink for 500 ms each time, 5 times
  delay(1000); 
}
