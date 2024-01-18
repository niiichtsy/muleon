# Registers to configure for basic functionality
Taken from [here](https://www.beyond-circuits.com/wordpress/tutorial/tutorial17).

Presented below is C code which would be used, if the SPI configurator was an AXI-Slave, and the PS was used in the project. This is not the case however (though I might change it in the future), so all the registers are configured in a predetermined sequence in the PL.

```
  //  Setup PLL
 write_adau1761(0x4000,0x0e,1);
  //  Configure PLL
  write_adau1761(0x4002,0x007d000c2301,6);
  //  Wait for PLL to lock
  while (!(read_adau1761(0x4002,6)&2));
  //  Enable clock to core
  write_adau1761(0x4000,0xf,1);
  //  delay
  for (i=0; i<1000000; i++);
  //  I2S master mode
  write_adau1761(0x4015,0x01,1);
  //  left mixer enable
  write_adau1761(0x400a,0x01,1);
  //  left 0db
  write_adau1761(0x400b,0x05,1);
  //  right mixer enable
  write_adau1761(0x400c,0x01,1);
  //  right 0db
  write_adau1761(0x400d,0x05,1);
  //  Playback left mixer unmute, enable
  write_adau1761(0x401c,0x21,1);
  //  Playback right mixer unmute, enable
  write_adau1761(0x401e,0x41,1);
  //  Enable headphone output left
  write_adau1761(0x4023,0xe7,1);
  //  Enable headphone output right
  write_adau1761(0x4024,0xe7,1);
  //  Enable line out left
  write_adau1761(0x4025,0xe7,1);
  //  Enable line out right
  write_adau1761(0x4026,0xe7,1);
  //  Enable both ADCs
  write_adau1761(0x4019,0x03,1);
  //  Enable playback both channels
  write_adau1761(0x4029,0x03,1);
  //  Enable both DACs
  write_adau1761(0x402a,0x03,1);
  //  Serial input L0,R0 to DAC L,R
  write_adau1761(0x40f2,0x01,1);
  //  Serial output ADC L,R to serial output L0,R0
  write_adau1761(0x40f3,0x01,1);
  //  Enable clocks to all engines
  write_adau1761(0x40f9,0x7f,1);
  //  Enable both clock generators
  write_adau1761(0x40fa,0x03,1);
```


Of course, the above is configured for PLL functionality. This project utilizes a clock generated directly from the mclk and the codec cofigured as slave, so a few changes are needed for the configuration:
```
  //  Setup MCLK
 write_adau1761(0x4000,0x01,1);
  //  left mixer enable
  write_adau1761(0x400a,0x01,1);
  //  left 0db
  write_adau1761(0x400b,0x05,1);
  //  right mixer enable
  write_adau1761(0x400c,0x01,1);
  //  right 0db
  write_adau1761(0x400d,0x05,1);
  //  Playback left mixer unmute, enable
  write_adau1761(0x401c,0x21,1);
  //  Playback right mixer unmute, enable
  write_adau1761(0x401e,0x41,1);
  //  Enable headphone output left
  write_adau1761(0x4023,0xe7,1);
  //  Enable headphone output right
  write_adau1761(0x4024,0xe7,1);
  //  Enable line out left
  write_adau1761(0x4025,0xe7,1);
  //  Enable line out right
  write_adau1761(0x4026,0xe7,1);
  //  Enable both ADCs
  write_adau1761(0x4019,0x03,1);
  //  Enable playback both channels
  write_adau1761(0x4029,0x03,1);
  //  Enable both DACs
  write_adau1761(0x402a,0x03,1);
  //  Serial input L0,R0 to DAC L,R
  write_adau1761(0x40f2,0x01,1);
  //  Serial output ADC L,R to serial output L0,R0
  write_adau1761(0x40f3,0x01,1);
  //  Enable clocks to all engines
  write_adau1761(0x40f9,0x7f,1);
  //  Enable both clock generators
  write_adau1761(0x40fa,0x03,1);
  ```
