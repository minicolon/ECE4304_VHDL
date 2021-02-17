# Lab 2

## Description
The purpose of this lab is to understand how to deal with limited IO. First a generic decoder network is built from a base 2x4 decoder. A 5x32 decoder is generated for the board but the max output LEDs on the board is 16. To remedy this a 2x1 mux is tied to the output with each input being 16 bits from the decoder. This then requires 1 extra switch to select which half of the decoder is transmitted to the LEDs.

Demo Link:
https://youtu.be/rOxPb2XNl7Y
