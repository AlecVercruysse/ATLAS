# ATLAS: Audio Tracking Laser-Assisted Light Show

Arya Goutam and Alec Vercruysse

---

This work, completed as a final project for E155 at Harvey Mudd College, takes in music input via a 3.5mm audio jack, and syncs
a diffraction-grating based laser light show to respond to percussive elements in the song. Read our [final report](papers/report.pdf) for a description of 
the design and algorithm.

Due to the requirements of the project for the class, all SystemVerilog code, including that for the FFT, was written from scratch.

 - `fpga/` contains the SystemVerilog code used to interface with the PCM1808 ADC, the FFT module, and the beat tracking algorithm. It also includes the python files used to generate the twiddle and hann windowing look up tables.
 - `mcu/` contains the code for the microcontroller, which was responsible for selecting patterns, driving the servo, and controlling the relays.
 - `adc/` contains the design files for the PCB developed to interface the ADC with the development platform we used for the class
 - `papers/` contains the initial project proposal and final report
 - `sim/` contains the jupyter notebooks used to prototype different parts of the design. 
