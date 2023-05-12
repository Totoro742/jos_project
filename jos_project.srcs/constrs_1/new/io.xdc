# Clock Source - Bank 13
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN Y9 [get_ports {clk}];  # "GCLK"

# ----------------------------------------------------------------------------
# JA Pmod - Bank 13
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN Y11  [get_ports {cs}];  # "JA1"
set_property PACKAGE_PIN AA11 [get_ports {datain0}];  # "JA2"
set_property PACKAGE_PIN Y10  [get_ports {datain1}];  # "JA3"
set_property PACKAGE_PIN AA9  [get_ports {sclk}];  # "JA4"
set_property PACKAGE_PIN R16 [get_ports {enable}];  # "BTND"
# ----------------------------------------------------------------------------
# OLED Display - Bank 13
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN U10  [get_ports {OLED_DC}];  # "OLED-DC"
set_property PACKAGE_PIN U9   [get_ports {OLED_RES}];  # "OLED-RES"
set_property PACKAGE_PIN AB12 [get_ports {OLED_SCLK}];  # "OLED-SCLK"
set_property PACKAGE_PIN AA12 [get_ports {OLED_SDIN}];  # "OLED-SDIN"
set_property PACKAGE_PIN U11  [get_ports {OLED_VBAT}];  # "OLED-VBAT"
set_property PACKAGE_PIN U12  [get_ports {OLED_VDD}];  # "OLED-VDD"


# ----------------------------------------------------------------------------
# User LEDs - Bank 33
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN T22 [get_ports {leds[0]}];  # "LD0"
set_property PACKAGE_PIN T21 [get_ports {leds[1]}];  # "LD1"
set_property PACKAGE_PIN U22 [get_ports {leds[2]}];  # "LD2"
set_property PACKAGE_PIN U21 [get_ports {leds[3]}];  # "LD3"
set_property PACKAGE_PIN V22 [get_ports {leds[4]}];  # "LD4"
set_property PACKAGE_PIN W22 [get_ports {leds[5]}];  # "LD5"
set_property PACKAGE_PIN U19 [get_ports {leds[6]}];  # "LD6"
set_property PACKAGE_PIN U14 [get_ports {leds[7]}];  # "LD7"

set_property PACKAGE_PIN P16 [get_ports {rst}];  # "BTNC"

# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];

# Note that the bank voltage for IO Bank 13 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];


set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];