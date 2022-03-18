create_clock -period 10.000 -name clock -waveform {0.000 5.000} [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports led_out]
set_property IOSTANDARD LVCMOS25 [get_ports rst]

set_property IOSTANDARD LVCMOS33 [get_ports miso]
set_property IOSTANDARD LVCMOS33 [get_ports cs]
set_property IOSTANDARD LVCMOS33 [get_ports sclk]

set_property PACKAGE_PIN F22 [get_ports rst];  # "SW0"
set_property PACKAGE_PIN Y9 [get_ports clk];  # "GCLK"
set_property PACKAGE_PIN T22 [get_ports {led_out[0]}];  # "LD0"
set_property PACKAGE_PIN T21 [get_ports {led_out[1]}];  # "LD1"
set_property PACKAGE_PIN U22 [get_ports {led_out[2]}];  # "LD2"
set_property PACKAGE_PIN U21 [get_ports {led_out[3]}];  # "LD3"
set_property PACKAGE_PIN V22 [get_ports {led_out[4]}];  # "LD4"
set_property PACKAGE_PIN W22 [get_ports {led_out[5]}];  # "LD5"
set_property PACKAGE_PIN U19 [get_ports {led_out[6]}];  # "LD6"
set_property PACKAGE_PIN U14 [get_ports {led_out[7]}];  # "LD7"

# JA Pmod - Bank 13 
# ---------------------------------------------------------------------------- 

set_property PACKAGE_PIN Y11  [get_ports cs];  # "JA1"
#set_property PACKAGE_PIN AA11 [get_ports {JA2}];  # "JA2"
set_property PACKAGE_PIN Y10  [get_ports miso];  # "JA3"
set_property PACKAGE_PIN AA9  [get_ports sclk];  # "JA4"
#set_property PACKAGE_PIN AB11 [get_ports {JA7}];  # "JA7"
#set_property PACKAGE_PIN AB10 [get_ports {JA8}];  # "JA8"
#set_property PACKAGE_PIN AB9  [get_ports {JA9}];  # "JA9"
#set_property PACKAGE_PIN AA8  [get_ports {JA10}];  # "JA10"

#set_property PACKAGE_PIN Y11  [get_ports cs];  # "JA1"
#set_property PACKAGE_PIN AA11 [get_ports {JA2}];  # "JA2"
#set_property PACKAGE_PIN Y10  [get_ports miso];  # "JA3"
#set_property PACKAGE_PIN AA9  [get_ports sclk];  # "JA4"
#set_property PACKAGE_PIN AB11 [get_ports {JA7}];  # "JA7"
#set_property PACKAGE_PIN AB10 [get_ports {JA8}];  # "JA8"
#set_property PACKAGE_PIN AB9  [get_ports {JA9}];  # "JA9"
#set_property PACKAGE_PIN AA8  [get_ports {JA10}];  # "JA10"

#set_property PACKAGE_PIN G22 [get_ports {SW1}];  # "SW1"
#set_property PACKAGE_PIN H22 [get_ports {SW2}];  # "SW2"
#set_property PACKAGE_PIN F21 [get_ports {SW3}];  # "SW3"
#set_property PACKAGE_PIN H19 [get_ports {SW4}];  # "SW4"
#set_property PACKAGE_PIN H18 [get_ports {SW5}];  # "SW5"
#set_property PACKAGE_PIN H17 [get_ports {SW6}];  # "SW6"
#set_property PACKAGE_PIN M15 [get_ports {SW7}];  # "SW7"