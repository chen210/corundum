# XDC constraints for the Cisco Nexus K3P-S
# part: xcku3p-ffvb676-2-e

# General configuration
# 含义：告诉 FPGA，Bank 0 的供电电压是 1.8V 或更低（如果是 2.5V/3.3V，这里通常设为 VCCO）
set_property CFGBVS GND                                      [current_design]
# 明确指定配置电压为 1.8V
# Vivado 会检查你的 IO 电平标准是否符合 1.8V 的限制
set_property CONFIG_VOLTAGE 1.8                              [current_design]
# 开启 Bitstream 压缩。
# 含义：自动去除 bit 文件中重复的 0，能显著减小文件体积（比如从 50MB 减到 20MB），
# 让烧录更快，且节省 Flash 空间。
set_property BITSTREAM.GENERAL.COMPRESS true                 [current_design]
# 未用引脚上拉。
# 含义：所有你在 Verilog 里没定义的引脚，在芯片工作时会自动连接一个上拉电阻。
# 作用：防止引脚悬空（Floating）引入噪声或导致额外的功耗。
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup               [current_design]
# 设置配置速率为 50 MHz。
set_property BITSTREAM.CONFIG.CONFIGRATE 31.9                [current_design]
set_property CONFIG_MODE SPIx4                               [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4                 [current_design]
# 过热保护。
# 含义：如果 FPGA 内部温度传感器检测到温度过高，自动停止工作以保护芯片。
set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN Enable        [current_design]

# 10 MHz TXCO
# set_property -dict {LOC D14  IOSTANDARD LVCMOS18} [get_ports clk_10mhz]
# create_clock -period 100.000 -name clk_10mhz [get_ports clk_10mhz]

# D14 cannot directly drive MMCM, so need to set CLOCK_DEDICATED_ROUTE to satisfy DRC
# set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets clk_10mhz_bufg]
# 100 MHz system clock
set_property -dict {LOC E18  IOSTANDARD LVDS} [get_ports clk_100mhz_p]
set_property -dict {LOC D18  IOSTANDARD LVDS} [get_ports clk_100mhz_n]
# 告诉 Vivado 这是一个 100MHz 时钟 (10ns 周期)
create_clock -period 10 -name clk_100mhz [get_ports clk_100mhz_p]

# LEDs
set_property -dict {LOC B12 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_1_led}]
#set_property -dict {LOC H12 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_1_led[1]}]
set_property -dict {LOC C12 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_2_led}]
#set_property -dict {LOC H13 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {sfp_2_led[1]}]

set_false_path -to [get_ports {sfp_1_led sfp_2_led}]
set_output_delay 0 [get_ports {sfp_1_led sfp_2_led}]

set_property -dict {LOC B11 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[0]}]
set_property -dict {LOC C11 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[1]}]
set_property -dict {LOC A10 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[2]}]
set_property -dict {LOC B10 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports {led[3]}]

set_property -dict {LOC A12 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports led_g]
set_property -dict {LOC A13 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports led_r]
set_property -dict {LOC B9 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12}  [get_ports led_heart]

set_false_path -to [get_ports {led[*]}]
set_output_delay 0 [get_ports {led[*]}]

# GPIO
#set_property -dict {LOC F9   IOSTANDARD LVCMOS18} [get_ports gpio[0]]
#set_property -dict {LOC F10  IOSTANDARD LVCMOS18} [get_ports gpio[1]]
#set_property -dict {LOC G9   IOSTANDARD LVCMOS18} [get_ports gpio[2]]
#set_property -dict {LOC G10  IOSTANDARD LVCMOS18} [get_ports gpio[3]]

# Config
#set_property -dict {LOC C14  IOSTANDARD LVCMOS18} [get_ports ddr_npres]

# SFP28 Interfaces
set_property -dict {LOC A4  } [get_ports sfp_1_rx_p] ;# MGTYRXP0_227 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC A3  } [get_ports sfp_1_rx_n] ;# MGTYRXN0_227 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC B1  } [get_ports sfp_2_rx_p] ;# MGTYRXP3_227 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC B2  } [get_ports sfp_2_rx_n] ;# MGTYRXN3_227 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC B7  } [get_ports sfp_1_tx_p] ;# MGTYTXP0_227 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC B6  } [get_ports sfp_1_tx_n] ;# MGTYTXN0_227 GTYE4_CHANNEL_X0Y12 / GTYE4_COMMON_X0Y3
set_property -dict {LOC D7  } [get_ports sfp_2_tx_p] ;# MGTYTXP3_227 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC D6  } [get_ports sfp_2_tx_n] ;# MGTYTXN3_227 GTYE4_CHANNEL_X0Y15 / GTYE4_COMMON_X0Y3
set_property -dict {LOC K7  } [get_ports sfp_mgt_refclk_p] ;# MGTREFCLK0P_227 from X2
set_property -dict {LOC K6  } [get_ports sfp_mgt_refclk_n] ;# MGTREFCLK0N_227 from X2
set_property -dict {LOC B14  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports sfp_1_tx_disable]; #发送禁用信号 (TX Disable)
set_property -dict {LOC F9   IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports sfp_2_tx_disable]
set_property -dict {LOC D14  IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_1_npres];             #在位检测信号 Not Present
set_property -dict {LOC E11  IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_2_npres]
set_property -dict {LOC D13  IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_1_los];               #LOS (信号丢失，高有效)
set_property -dict {LOC E10  IOSTANDARD LVCMOS18 PULLUP true} [get_ports sfp_2_los]
#set_property -dict {LOC G14  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports sfp_1_rs];         #速率选择信号 (Rate Select)
#set_property -dict {LOC H14  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12} [get_ports sfp_2_rs]
set_property -dict {LOC C13  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports sfp_1_i2c_scl]
set_property -dict {LOC C14  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports sfp_1_i2c_sda]
set_property -dict {LOC D10  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports sfp_2_i2c_scl]
set_property -dict {LOC D11  IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports sfp_2_i2c_sda]

# 161.1328125 MHz MGT reference clock
# create_clock -period 6.206 -name sfp_mgt_refclk [get_ports sfp_mgt_refclk_p]
# 修改频率为 156.25 MHz (周期 6.400 ns)
create_clock -period 6.400 -name sfp_mgt_refclk [get_ports sfp_mgt_refclk_p]

set_false_path -to [get_ports {sfp_1_tx_disable sfp_2_tx_disable}]
set_output_delay 0 [get_ports {sfp_1_tx_disable sfp_2_tx_disable}]
set_false_path -from [get_ports {sfp_1_npres sfp_2_npres sfp_1_los sfp_2_los}]
set_input_delay 0 [get_ports {sfp_1_npres sfp_2_npres sfp_1_los sfp_2_los}]

set_false_path -to [get_ports {sfp_1_i2c_sda sfp_2_i2c_sda sfp_1_i2c_scl sfp_2_i2c_scl}]
set_output_delay 0 [get_ports {sfp_1_i2c_sda sfp_2_i2c_sda sfp_1_i2c_scl sfp_2_i2c_scl}]
set_false_path -from [get_ports {sfp_1_i2c_sda sfp_2_i2c_sda sfp_1_i2c_scl sfp_2_i2c_scl}]
set_input_delay 0 [get_ports {sfp_1_i2c_sda sfp_2_i2c_sda sfp_1_i2c_scl sfp_2_i2c_scl}]

# I2C interface
set_property -dict {LOC G9 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports eeprom_i2c_scl]
set_property -dict {LOC G10 IOSTANDARD LVCMOS18 SLEW SLOW DRIVE 12 PULLUP true} [get_ports eeprom_i2c_sda]

set_false_path -to [get_ports {eeprom_i2c_sda eeprom_i2c_scl}]
set_output_delay 0 [get_ports {eeprom_i2c_sda eeprom_i2c_scl}]
set_false_path -from [get_ports {eeprom_i2c_sda eeprom_i2c_scl}]
set_input_delay 0 [get_ports {eeprom_i2c_sda eeprom_i2c_scl}]

# PCIe Interface
set_property -dict {LOC P2  } [get_ports {pcie_rx_p[0]}] ;# MGTYRXP3_225 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1
set_property -dict {LOC P1  } [get_ports {pcie_rx_n[0]}] ;# MGTYRXN3_225 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1
set_property -dict {LOC R5  } [get_ports {pcie_tx_p[0]}] ;# MGTYTXP3_225 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1
set_property -dict {LOC R4  } [get_ports {pcie_tx_n[0]}] ;# MGTYTXN3_225 GTYE4_CHANNEL_X0Y7 / GTYE4_COMMON_X0Y1
set_property -dict {LOC T2  } [get_ports {pcie_rx_p[1]}] ;# MGTYRXP2_225 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1
set_property -dict {LOC T1  } [get_ports {pcie_rx_n[1]}] ;# MGTYRXN2_225 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1
set_property -dict {LOC U5  } [get_ports {pcie_tx_p[1]}] ;# MGTYTXP2_225 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1
set_property -dict {LOC U4  } [get_ports {pcie_tx_n[1]}] ;# MGTYTXN2_225 GTYE4_CHANNEL_X0Y6 / GTYE4_COMMON_X0Y1
set_property -dict {LOC V2  } [get_ports {pcie_rx_p[2]}] ;# MGTYRXP1_225 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
set_property -dict {LOC V1  } [get_ports {pcie_rx_n[2]}] ;# MGTYRXN1_225 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
set_property -dict {LOC W5  } [get_ports {pcie_tx_p[2]}] ;# MGTYTXP1_225 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
set_property -dict {LOC W4  } [get_ports {pcie_tx_n[2]}] ;# MGTYTXN1_225 GTYE4_CHANNEL_X0Y5 / GTYE4_COMMON_X0Y1
set_property -dict {LOC Y2  } [get_ports {pcie_rx_p[3]}] ;# MGTYRXP0_225 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
set_property -dict {LOC Y1  } [get_ports {pcie_rx_n[3]}] ;# MGTYRXN0_225 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
set_property -dict {LOC AA5 } [get_ports {pcie_tx_p[3]}] ;# MGTYTXP0_225 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
set_property -dict {LOC AA4 } [get_ports {pcie_tx_n[3]}] ;# MGTYTXN0_225 GTYE4_CHANNEL_X0Y4 / GTYE4_COMMON_X0Y1
set_property -dict {LOC AB2 } [get_ports {pcie_rx_p[4]}] ;# MGTYRXP3_224 GTYE4_CHANNEL_X0Y3 / GTYE4_COMMON_X0Y0
set_property -dict {LOC AB1 } [get_ports {pcie_rx_n[4]}] ;# MGTYRXN3_224 GTYE4_CHANNEL_X0Y3 / GTYE4_COMMON_X0Y0
set_property -dict {LOC AC5 } [get_ports {pcie_tx_p[4]}] ;# MGTYTXP3_224 GTYE4_CHANNEL_X0Y3 / GTYE4_COMMON_X0Y0
set_property -dict {LOC AC4 } [get_ports {pcie_tx_n[4]}] ;# MGTYTXN3_224 GTYE4_CHANNEL_X0Y3 / GTYE4_COMMON_X0Y0
set_property -dict {LOC AD2 } [get_ports {pcie_rx_p[5]}] ;# MGTYRXP2_224 GTYE4_CHANNEL_X0Y2 / GTYE4_COMMON_X0Y0
set_property -dict {LOC AD1 } [get_ports {pcie_rx_n[5]}] ;# MGTYRXN2_224 GTYE4_CHANNEL_X0Y2 / GTYE4_COMMON_X0Y0
set_property -dict {LOC AD7 } [get_ports {pcie_tx_p[5]}] ;# MGTYTXP2_224 GTYE4_CHANNEL_X0Y2 / GTYE4_COMMON_X0Y0
set_property -dict {LOC AD6 } [get_ports {pcie_tx_n[5]}] ;# MGTYTXN2_224 GTYE4_CHANNEL_X0Y2 / GTYE4_COMMON_X0Y0
set_property -dict {LOC AE4 } [get_ports {pcie_rx_p[6]}] ;# MGTYRXP1_224 GTYE4_CHANNEL_X0Y1 / GTYE4_COMMON_X0Y0
set_property -dict {LOC AE3 } [get_ports {pcie_rx_n[6]}] ;# MGTYRXN1_224 GTYE4_CHANNEL_X0Y1 / GTYE4_COMMON_X0Y0
set_property -dict {LOC AE9 } [get_ports {pcie_tx_p[6]}] ;# MGTYTXP1_224 GTYE4_CHANNEL_X0Y1 / GTYE4_COMMON_X0Y0
set_property -dict {LOC AE8 } [get_ports {pcie_tx_n[6]}] ;# MGTYTXN1_224 GTYE4_CHANNEL_X0Y1 / GTYE4_COMMON_X0Y0
set_property -dict {LOC AF2 } [get_ports {pcie_rx_p[7]}] ;# MGTYRXP0_224 GTYE4_CHANNEL_X0Y0 / GTYE4_COMMON_X0Y0
set_property -dict {LOC AF1 } [get_ports {pcie_rx_n[7]}] ;# MGTYRXN0_224 GTYE4_CHANNEL_X0Y0 / GTYE4_COMMON_X0Y0
set_property -dict {LOC AF7 } [get_ports {pcie_tx_p[7]}] ;# MGTYTXP0_224 GTYE4_CHANNEL_X0Y0 / GTYE4_COMMON_X0Y0
set_property -dict {LOC AF6 } [get_ports {pcie_tx_n[7]}] ;# MGTYTXN0_224 GTYE4_CHANNEL_X0Y0 / GTYE4_COMMON_X0Y0
set_property -dict {LOC T7  } [get_ports pcie_refclk_p] ;# MGTREFCLK0P_225
set_property -dict {LOC T6  } [get_ports pcie_refclk_n] ;# MGTREFCLK0N_225
set_property -dict {LOC A9 IOSTANDARD LVCMOS18 PULLUP true} [get_ports pcie_reset_n]

set_false_path -from [get_ports {pcie_reset_n}]
set_input_delay 0 [get_ports {pcie_reset_n}]

# 100 MHz MGT reference clock
create_clock -period 10 -name pcie_mgt_refclk [get_ports pcie_refclk_p]
