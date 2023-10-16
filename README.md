# muleon
muleon is a digital multi audio effect with an I2S interface, written in Verilog and implemented using the PYNQ Z2 board. The goal of the project is to provide a universal digital effect applicator to sound provided via I2S.


## Building
To build the IP library, run:
```
make lib
```
muleon uses IPs from another one of my projects (though its IP library is entirely self-sufficient - you don't need any other repository to build the project). Check out [verilog_misc_modules](https://github.com/niiichtsy/verilog_misc_modules.git)!
