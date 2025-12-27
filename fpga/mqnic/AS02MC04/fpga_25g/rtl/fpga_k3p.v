// SPDX-License-Identifier: BSD-2-Clause-Views
/*
 * Copyright (c) 2019-2023 The Regents of the University of California
 */

// Language: Verilog 2001

`resetall
/*
 * 功能：这个指令用于在仿真过程中将模块和所有子模块重置为初始状态。
 * 作用域：它会影响整个设计，包括所有模块实例。
 * 常见用途：通常用于测试时，确保仿真从一个干净的状态开始
 */
`timescale 1ns / 1ps
/*
 * 语法：timescale <time_unit> / <time_precision>
 * 参数：
 * <time_unit>：指定时间单位（如1ns表示纳秒）。
 * <time_precision>：指定时间精度（如1ps表示皮秒）。
 * 作用：它设定了整个设计中时间的单位和精度。
 * 示例：1ns / 1ps 表示时间单位为纳秒，精度为皮秒
 */
`default_nettype none
/*
 * 语法：default_nettype <net_type>
 * 参数：
 * <net_type>：指定默认的网类型（如none表示无连接）。
 * 作用：它设定了模块中未明确声明的信号的默认网络类型。
 * 示例：none 表示所有未声明的信号将被视为无连接。
 */

/*
 * FPGA top-level module
 */
module fpga #
(
    // FW and board IDs
    // 声明一个名为FPGA_ID的参数，并且赋予它一个特定的32位十六进制的初始值
    parameter FPGA_ID = 32'h4A63093,
    parameter FW_ID = 32'h00000000,
    parameter FW_VER = 32'h00_00_01_00,
    parameter BOARD_ID = 32'hc001_0002,
    parameter BOARD_VER = 32'h01_00_00_00,
    parameter BUILD_DATE = 32'd1765929600,
    parameter GIT_HASH = 32'hdce357bf,
    parameter RELEASE_INFO = 32'h00000000,

    // Board configuration
    parameter TDMA_BER_ENABLE = 0,

    // Structural configuration
    parameter IF_COUNT = 2,
    parameter PORTS_PER_IF = 1,
    parameter SCHED_PER_IF = PORTS_PER_IF,
    parameter PORT_MASK = 0,

    // Clock configuration
    parameter CLK_PERIOD_NS_NUM = 4,
    parameter CLK_PERIOD_NS_DENOM = 1,

    // PTP configuration
    parameter PTP_CLOCK_PIPELINE = 0,
    parameter PTP_CLOCK_CDC_PIPELINE = 0,
    parameter PTP_PORT_CDC_PIPELINE = 0,
    parameter PTP_PEROUT_ENABLE = 1,
    parameter PTP_PEROUT_COUNT = 1,

    // Queue manager configuration
    parameter EVENT_QUEUE_OP_TABLE_SIZE = 32,
    parameter TX_QUEUE_OP_TABLE_SIZE = 32,
    parameter RX_QUEUE_OP_TABLE_SIZE = 32,
    parameter CQ_OP_TABLE_SIZE = 32,
    parameter EQN_WIDTH = 5,
    parameter TX_QUEUE_INDEX_WIDTH = 13,
    parameter RX_QUEUE_INDEX_WIDTH = 8,
    parameter CQN_WIDTH = (TX_QUEUE_INDEX_WIDTH > RX_QUEUE_INDEX_WIDTH ? TX_QUEUE_INDEX_WIDTH : RX_QUEUE_INDEX_WIDTH) + 1,
    parameter EQ_PIPELINE = 3,
    parameter TX_QUEUE_PIPELINE = 3+(TX_QUEUE_INDEX_WIDTH > 12 ? TX_QUEUE_INDEX_WIDTH-12 : 0),
    parameter RX_QUEUE_PIPELINE = 3+(RX_QUEUE_INDEX_WIDTH > 12 ? RX_QUEUE_INDEX_WIDTH-12 : 0),
    parameter CQ_PIPELINE = 3+(CQN_WIDTH > 12 ? CQN_WIDTH-12 : 0),

    // TX and RX engine configuration
    parameter TX_DESC_TABLE_SIZE = 32,
    parameter RX_DESC_TABLE_SIZE = 32,
    parameter RX_INDIR_TBL_ADDR_WIDTH = RX_QUEUE_INDEX_WIDTH > 8 ? 8 : RX_QUEUE_INDEX_WIDTH,

    // Scheduler configuration
    parameter TX_SCHEDULER_OP_TABLE_SIZE = TX_DESC_TABLE_SIZE,
    parameter TX_SCHEDULER_PIPELINE = TX_QUEUE_PIPELINE,
    parameter TDMA_INDEX_WIDTH = 6,

    // Interface configuration
    parameter PTP_TS_ENABLE = 1,
    parameter TX_CPL_FIFO_DEPTH = 32,
    parameter TX_CHECKSUM_ENABLE = 1,
    parameter RX_HASH_ENABLE = 1,
    parameter RX_CHECKSUM_ENABLE = 1,
    parameter PFC_ENABLE = 1,
    parameter LFC_ENABLE = PFC_ENABLE,
    parameter ENABLE_PADDING = 1,
    parameter ENABLE_DIC = 1,
    parameter MIN_FRAME_LENGTH = 64,
    parameter TX_FIFO_DEPTH = 32768,
    parameter RX_FIFO_DEPTH = 32768,
    parameter MAX_TX_SIZE = 9214,
    parameter MAX_RX_SIZE = 9214,
    parameter TX_RAM_SIZE = 32768,
    parameter RX_RAM_SIZE = 32768,

    // Application block configuration
    parameter APP_ID = 32'h00000000,
    parameter APP_ENABLE = 0,
    parameter APP_CTRL_ENABLE = 1,
    parameter APP_DMA_ENABLE = 1,
    parameter APP_AXIS_DIRECT_ENABLE = 1,
    parameter APP_AXIS_SYNC_ENABLE = 1,
    parameter APP_AXIS_IF_ENABLE = 1,
    parameter APP_STAT_ENABLE = 1,

    // DMA interface configuration
    parameter DMA_IMM_ENABLE = 0,
    parameter DMA_IMM_WIDTH = 32,
    parameter DMA_LEN_WIDTH = 16,
    parameter DMA_TAG_WIDTH = 16,
    parameter RAM_ADDR_WIDTH = $clog2(TX_RAM_SIZE > RX_RAM_SIZE ? TX_RAM_SIZE : RX_RAM_SIZE),
    parameter RAM_PIPELINE = 2,

    // PCIe interface configuration
    parameter AXIS_PCIE_DATA_WIDTH = 256,
    parameter PF_COUNT = 1,
    parameter VF_COUNT = 0,

    // Interrupt configuration
    parameter IRQ_INDEX_WIDTH = EQN_WIDTH,

    // AXI lite interface configuration (control)
    parameter AXIL_CTRL_DATA_WIDTH = 32,
    parameter AXIL_CTRL_ADDR_WIDTH = 24,

    // AXI lite interface configuration (application control)
    parameter AXIL_APP_CTRL_DATA_WIDTH = AXIL_CTRL_DATA_WIDTH,
    parameter AXIL_APP_CTRL_ADDR_WIDTH = 24,

    // Ethernet interface configuration
    parameter AXIS_ETH_SYNC_DATA_WIDTH_DOUBLE = 1,
    parameter AXIS_ETH_TX_PIPELINE = 0,
    parameter AXIS_ETH_TX_FIFO_PIPELINE = 2,
    parameter AXIS_ETH_TX_TS_PIPELINE = 0,
    parameter AXIS_ETH_RX_PIPELINE = 0,
    parameter AXIS_ETH_RX_FIFO_PIPELINE = 2,

    // Statistics counter subsystem
    parameter STAT_ENABLE = 1,
    parameter STAT_DMA_ENABLE = 1,
    parameter STAT_PCIE_ENABLE = 1,
    parameter STAT_INC_WIDTH = 24,
    parameter STAT_ID_WIDTH = 12
)
(
    /*
     * Clock: 100MHz LVDS
     */
    input  wire       clk_100mhz_p,
    input  wire       clk_100mhz_n,

    /*
     * GPIO
     */
    output wire       sfp_1_led,
    output wire       sfp_2_led,
    output wire [0:3] led,
    output wire       led_g,
    output wire       led_r,
    output wire       led_heart,

    /*
     * PCI express
     */
    input  wire [7:0]   pcie_rx_p,
    input  wire [7:0]   pcie_rx_n,
    output wire [7:0]   pcie_tx_p,
    output wire [7:0]   pcie_tx_n,
    input  wire         pcie_refclk_p,
    input  wire         pcie_refclk_n,
    input  wire         pcie_reset_n,

    /*
     * Ethernet: SFP28
     */
    input  wire         sfp_1_rx_p,
    input  wire         sfp_1_rx_n,
    output wire         sfp_1_tx_p,
    output wire         sfp_1_tx_n,
    input  wire         sfp_2_rx_p,
    input  wire         sfp_2_rx_n,
    output wire         sfp_2_tx_p,
    output wire         sfp_2_tx_n,
    input  wire         sfp_mgt_refclk_p,
    input  wire         sfp_mgt_refclk_n,
    output wire         sfp_1_tx_disable,
    output wire         sfp_2_tx_disable,
    input  wire         sfp_1_npres,
    input  wire         sfp_2_npres,
    input  wire         sfp_1_los,
    input  wire         sfp_2_los,

    inout  wire         sfp_1_i2c_scl,
    inout  wire         sfp_1_i2c_sda,
    inout  wire         sfp_2_i2c_scl,
    inout  wire         sfp_2_i2c_sda,

    inout  wire         eeprom_i2c_scl,
    inout  wire         eeprom_i2c_sda
);

// PTP configuration
parameter PTP_CLK_PERIOD_NS_NUM = 4;
parameter PTP_CLK_PERIOD_NS_DENOM = 1;
parameter PTP_TS_WIDTH = 96;
parameter IF_PTP_PERIOD_NS = 6'h2;
parameter IF_PTP_PERIOD_FNS = 16'h8F5C;

// Interface configuration
parameter TX_TAG_WIDTH = 16;

// PCIe interface configuration
parameter AXIS_PCIE_KEEP_WIDTH = (AXIS_PCIE_DATA_WIDTH/32);
parameter AXIS_PCIE_RC_USER_WIDTH = AXIS_PCIE_DATA_WIDTH < 512 ? 75 : 161;
parameter AXIS_PCIE_RQ_USER_WIDTH = AXIS_PCIE_DATA_WIDTH < 512 ? 62 : 137;
parameter AXIS_PCIE_CQ_USER_WIDTH = AXIS_PCIE_DATA_WIDTH < 512 ? 85 : 183;
parameter AXIS_PCIE_CC_USER_WIDTH = AXIS_PCIE_DATA_WIDTH < 512 ? 33 : 81;
parameter RC_STRADDLE = AXIS_PCIE_DATA_WIDTH >= 256;
parameter RQ_STRADDLE = AXIS_PCIE_DATA_WIDTH >= 512;
parameter CQ_STRADDLE = AXIS_PCIE_DATA_WIDTH >= 512;
parameter CC_STRADDLE = AXIS_PCIE_DATA_WIDTH >= 512;
parameter RQ_SEQ_NUM_WIDTH = 6;
parameter PCIE_TAG_COUNT = 256;

// Ethernet interface configuration
parameter XGMII_DATA_WIDTH = 64;
parameter XGMII_CTRL_WIDTH = XGMII_DATA_WIDTH/8;
parameter AXIS_ETH_DATA_WIDTH = XGMII_DATA_WIDTH;
parameter AXIS_ETH_KEEP_WIDTH = AXIS_ETH_DATA_WIDTH/8;
parameter AXIS_ETH_SYNC_DATA_WIDTH = AXIS_ETH_DATA_WIDTH*(AXIS_ETH_SYNC_DATA_WIDTH_DOUBLE ? 2 : 1);
parameter AXIS_ETH_TX_USER_WIDTH = TX_TAG_WIDTH + 1;
parameter AXIS_ETH_RX_USER_WIDTH = (PTP_TS_ENABLE ? PTP_TS_WIDTH : 0) + 1;

// Clock and reset
wire pcie_user_clk;
wire pcie_user_reset;

wire clk_156mhz_int;

wire clk_125mhz_mmcm_out;

// Internal 125 MHz clock
wire clk_125mhz_int;
wire rst_125mhz_int;

wire mmcm_rst = pcie_user_reset;
wire mmcm_locked;
wire mmcm_clkfb;

//差分转单端 (Differential to Single-Ended)
wire clk_100mhz_buffered;

IBUFGDS #(
   .DIFF_TERM("FALSE"),
   .IBUF_LOW_PWR("FALSE")   
)
clk_100mhz_ibufg_inst (
   .O   (clk_100mhz_ibufg),
   .I   (clk_100mhz_p),
   .IB  (clk_100mhz_n) 
);

// MMCM instance
// 161.13 MHz in, 125 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 800 MHz to 1600 MHz
// M = 64, D = 11 sets Fvco = 937.5 MHz (in range)
// Divide by 7.5 to get output frequency of 125 MHz
//MMCM（Mixed-Mode Clock Manager）实例化
MMCME4_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(7.5),     //设置为7.5，用来将VCO频率分配到125MHz。计算方法是937.5 ÷ 7.5 = 125MHz
    .CLKOUT0_DUTY_CYCLE(0.5),   //DUTY_CYCLE全设为0.5，这表示所有输出的时钟都是50%的占空比
    .CLKOUT0_PHASE(0),          //PHASE设置为0度，也是默认值，没有相位偏移
    .CLKOUT1_DIVIDE(1),         //DIVIDE为1，这意味着这些输出时钟与VCO频率相同，即937.5 MHz
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT1_PHASE(0),
    .CLKOUT2_DIVIDE(1),         //DIVIDE为1，这意味着这些输出时钟与VCO频率相同，即937.5 MHz
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT2_PHASE(0),
    .CLKOUT3_DIVIDE(1),         //DIVIDE为1，这意味着这些输出时钟与VCO频率相同，即937.5 MHz
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT3_PHASE(0),
    .CLKOUT4_DIVIDE(1),         //DIVIDE为1，这意味着这些输出时钟与VCO频率相同，即937.5 MHz
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT4_PHASE(0),
    .CLKOUT5_DIVIDE(1),         //DIVIDE为1，这意味着这些输出时钟与VCO频率相同，即937.5 MH
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT5_PHASE(0),
    .CLKOUT6_DIVIDE(1),         //DIVIDE为1，这意味着这些输出时钟与VCO频率相同，即937.5 MH
    .CLKOUT6_DUTY_CYCLE(0.5),
    .CLKOUT6_PHASE(0),
    .CLKFBOUT_MULT_F(6),       //说明M和D的值分别是6和1
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),         //说明M和D的值分别是6和1,VCO频率应该是（M×输入频率）除以D，也就是（6×156.25）/1
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(6.400),      //输入时钟周期的估计值，以纳秒为单位。计算一下：6.400 ns对应的频率大约是156.25 MHz（因为1/6.400≈0.0015625秒，即156.25 MHz）
    .STARTUP_WAIT("FALSE"),     //MMCM 只要一通电、有时钟输入，立刻开始工作（尝试锁定频率），不管 FPGA 其他部分有没有准备好，为了PCIe扫描
    .CLKOUT4_CASCADE("FALSE")   //是否开启级联分频，第 4 号和第 6 号计数器各管各的，互不干扰
)
clk_mmcm_inst (                 //MMCM 实例接口
    .CLKIN1(clk_156mhz_int),
    .CLKFBIN(mmcm_clkfb),
    .RST(mmcm_rst),
    .PWRDWN(1'b0),
    .CLKOUT0(clk_125mhz_mmcm_out),
    .CLKOUT0B(),
    .CLKOUT1(),
    .CLKOUT1B(),
    .CLKOUT2(),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBOUT(mmcm_clkfb),
    .CLKFBOUTB(),
    .LOCKED(mmcm_locked)
);
//将MMCM的输出时钟传递到全局缓冲，这样可以确保时钟信号在FPGA中的分布更稳定和一致。输入来自CLKOUT0，也就是125MHz的信号，经过BUFG后成为clk_125mhz_int。
BUFG
clk_125mhz_bufg_inst (
    .I(clk_125mhz_mmcm_out),
    .O(clk_125mhz_int)
);
//模块实例化，名字叫做sync_reset
sync_reset #(
    .N(4)
)
sync_reset_125mhz_inst (
    .clk(clk_125mhz_int),
    .rst(~mmcm_locked), //复位信号。这里使用了~mmcm_locked，即对mmcm_locked进行了取反操作。这意味着当mmcm_locked为低电平时，复位信号为高；当mmcm_locked为高电平时，复位信号为低。
    .out(rst_125mhz_int) //输出的同步复位信号
);

// Internal 250 MHz high-stability clock
wire clk_100mhz_bufg;

BUFG
init_clk_bufg_inst (
    .I(clk_100mhz_ibufg),
    .O(clk_100mhz_bufg)
);

wire clk_250mhz_mmcm_out;

wire clk_250mhz_int;
wire rst_250mhz_int;

wire mmcm_250mhz_rst = rst_125mhz_int;
wire mmcm_250mhz_locked;
wire mmcm_250mhz_clkfb;

// MMCM instance
// 10 MHz in, 250 MHz out
// PFD range: 10 MHz to 500 MHz
// VCO range: 800 MHz to 1600 MHz
// M = 100, D = 1 sets Fvco = 1000 MHz
// Divide by 4 to get output frequency of 250 MHz
// 混合模式时钟管理器，作用类似于 PLL（锁相环），用来调节频率
// 功能：将输入的 10 MHz 时钟，倍频到 250 MHz。
// 压控振荡器 (VCO): MMCM 内部先将频率升高。
//Fvco​=Fin​×M/D​=100MHz×10/1​=1000MHz
//
//    对应参数：.CLKFBOUT_MULT_F(100) (M) 和 .DIVCLK_DIVIDE(1) (D)
// 输出 (Output): 将 VCO 频率分频得到最终输出。
//Fout​=Fvco/O​​=1000MHz/4​=250MHz
//
//    对应参数：.CLKOUT0_DIVIDE_F(4)
MMCME4_BASE #(
    .BANDWIDTH("OPTIMIZED"),
    .CLKOUT0_DIVIDE_F(4),
    .CLKOUT0_DUTY_CYCLE(0.5),
    .CLKOUT0_PHASE(0),
    .CLKOUT1_DIVIDE(1),
    .CLKOUT1_DUTY_CYCLE(0.5),
    .CLKOUT1_PHASE(0),
    .CLKOUT2_DIVIDE(1),
    .CLKOUT2_DUTY_CYCLE(0.5),
    .CLKOUT2_PHASE(0),
    .CLKOUT3_DIVIDE(1),
    .CLKOUT3_DUTY_CYCLE(0.5),
    .CLKOUT3_PHASE(0),
    .CLKOUT4_DIVIDE(1),
    .CLKOUT4_DUTY_CYCLE(0.5),
    .CLKOUT4_PHASE(0),
    .CLKOUT5_DIVIDE(1),
    .CLKOUT5_DUTY_CYCLE(0.5),
    .CLKOUT5_PHASE(0),
    .CLKOUT6_DIVIDE(1),
    .CLKOUT6_DUTY_CYCLE(0.5),
    .CLKOUT6_PHASE(0),
    .CLKFBOUT_MULT_F(10),
    .CLKFBOUT_PHASE(0),
    .DIVCLK_DIVIDE(1),
    .REF_JITTER1(0.010),
    .CLKIN1_PERIOD(10.000),    //输入 (Input): 100 MHz (CLKIN1_PERIOD = 10.000 ns).
    .STARTUP_WAIT("FALSE"),
    .CLKOUT4_CASCADE("FALSE")
)
clk_250mhz_mmcm_inst (
    .CLKIN1(clk_100mhz_ibufg),    //输入的 100M 参考时钟
    .CLKFBIN(mmcm_250mhz_clkfb),    //.CLKFBIN / .CLKFBOUT: 反馈回路。这是 PLL 工作的核心，必须把输出反馈回输入来校准相位。
    .RST(mmcm_250mhz_rst),
    .PWRDWN(1'b0),
    .CLKOUT0(clk_250mhz_mmcm_out),
    .CLKOUT0B(),
    .CLKOUT1(),
    .CLKOUT1B(),
    .CLKOUT2(),
    .CLKOUT2B(),
    .CLKOUT3(),
    .CLKOUT3B(),
    .CLKOUT4(),
    .CLKOUT5(),
    .CLKOUT6(),
    .CLKFBOUT(mmcm_250mhz_clkfb),
    .CLKFBOUTB(),
    .LOCKED(mmcm_250mhz_locked) //“锁定”指示信号。这非常重要。当它变高电平（1）时，表示时钟频率已经稳定了，可以使用了；如果是低电平，说明时钟还在抖动，此时不能工作
);

//MMCM 输出的信号只是一个普通的电信号，驱动能力很弱。如果直接把它连到 FPGA 内部成千上万个触发器上，信号会衰减、延迟（Skew）会非常大，导致电路跑不起来
//BUFG 的作用： 它把这个时钟信号推送到 FPGA 专用的**全局时钟树（Global Clock Tree）**网络上。这个网络像是一个巨大的树根系统，能保证时钟信号几乎同
//时到达芯片的每一个角落，且驱动力极强。
//总结：凡是给逻辑使用的时钟，必须经过 BUFG。
BUFG
clk_250mhz_bufg_inst (
    .I(clk_250mhz_mmcm_out),
    .O(clk_250mhz_int)
);

//MMCM 的 .LOCKED 信号是异步的（它随时可能变高）。如果直接用它作为逻辑的复位信号，可能会在时钟边沿附近发生变化，
//导致亚稳态（Metastability），也就是电路进入未知状态。
//解决方案： 这个模块（通常由几个级联的触发器组成）把异步的 LOCKED 信号，同步到新的 250MHz 时钟域下。

//逻辑含义： “只要时钟还没稳定（Locked=0），我就一直按着复位键（Rst=1），不让电路动。等时钟稳定了（Locked=1），我在 250MHz 的节拍下安全地松开复位键。”
//
sync_reset #(
    .N(4)
)
sync_reset_250mhz_inst (
    .clk(clk_250mhz_int),
    .rst(~mmcm_250mhz_locked),
    .out(rst_250mhz_int)
);

// GPIO
wire sfp_1_npres_int;
wire sfp_2_npres_int;
wire sfp_1_los_int;
wire sfp_2_los_int;
wire sfp_i2c_scl_i;
wire sfp_i2c_scl_o;
wire sfp_i2c_scl_t;
wire sfp_1_i2c_sda_i;
wire sfp_1_i2c_sda_o;
wire sfp_1_i2c_sda_t;
wire sfp_2_i2c_sda_i;
wire sfp_2_i2c_sda_o;
wire sfp_2_i2c_sda_t;
wire eeprom_i2c_scl_i;
wire eeprom_i2c_scl_o;
wire eeprom_i2c_scl_t;
wire eeprom_i2c_sda_i;
wire eeprom_i2c_sda_o;
wire eeprom_i2c_sda_t;

reg sfp_i2c_scl_o_reg;
reg sfp_i2c_scl_t_reg;
reg sfp_1_i2c_sda_o_reg;
reg sfp_1_i2c_sda_t_reg;
reg sfp_2_i2c_sda_o_reg;
reg sfp_2_i2c_sda_t_reg;
reg eeprom_i2c_scl_o_reg;
reg eeprom_i2c_scl_t_reg;
reg eeprom_i2c_sda_o_reg;
reg eeprom_i2c_sda_t_reg;

always @(posedge pcie_user_clk) begin
    sfp_i2c_scl_o_reg <= sfp_i2c_scl_o;
    sfp_i2c_scl_t_reg <= sfp_i2c_scl_t;
    sfp_1_i2c_sda_o_reg <= sfp_1_i2c_sda_o;
    sfp_1_i2c_sda_t_reg <= sfp_1_i2c_sda_t;
    sfp_2_i2c_sda_o_reg <= sfp_2_i2c_sda_o;
    sfp_2_i2c_sda_t_reg <= sfp_2_i2c_sda_t;
    eeprom_i2c_scl_o_reg <= eeprom_i2c_scl_o;
    eeprom_i2c_scl_t_reg <= eeprom_i2c_scl_t;
    eeprom_i2c_sda_o_reg <= eeprom_i2c_sda_o;
    eeprom_i2c_sda_t_reg <= eeprom_i2c_sda_t;
end

sync_signal #(
    .WIDTH(9),
    .N(2)
)
sync_signal_inst (
    .clk(pcie_user_clk),
    .in({sfp_1_npres, sfp_2_npres, sfp_1_los, sfp_2_los,
        sfp_1_i2c_scl, sfp_1_i2c_sda, sfp_2_i2c_sda,
        eeprom_i2c_scl, eeprom_i2c_sda}),
    .out({sfp_1_npres_int, sfp_2_npres_int, sfp_1_los_int, sfp_2_los_int,
        sfp_i2c_scl_i, sfp_1_i2c_sda_i, sfp_2_i2c_sda_i,
        eeprom_i2c_scl_i, eeprom_i2c_sda_i})
);

// assign sfp_i2c_scl = sfp_i2c_scl_t_reg ? 1'bz : sfp_i2c_scl_o_reg;
assign sfp_1_i2c_scl = sfp_i2c_scl_t_reg ? 1'bz : sfp_i2c_scl_o_reg;
assign sfp_2_i2c_scl = sfp_i2c_scl_t_reg ? 1'bz : sfp_i2c_scl_o_reg;
assign sfp_1_i2c_sda = sfp_1_i2c_sda_t_reg ? 1'bz : sfp_1_i2c_sda_o_reg;
assign sfp_2_i2c_sda = sfp_2_i2c_sda_t_reg ? 1'bz : sfp_2_i2c_sda_o_reg;
assign eeprom_i2c_scl = eeprom_i2c_scl_t_reg ? 1'bz : eeprom_i2c_scl_o_reg;
assign eeprom_i2c_sda = eeprom_i2c_sda_t_reg ? 1'bz : eeprom_i2c_sda_o_reg;

// PCIe
wire pcie_sys_clk;
wire pcie_sys_clk_gt;

wire clk_100mhz_ibufg;  // 用来连接 IBUFDS 输出到 MMCM 输入
wire clk_100mhz_int;

IBUFDS_GTE4 #(
    .REFCLK_HROW_CK_SEL(2'b00)
)
ibufds_gte4_pcie_mgt_refclk_inst (
    .I             (pcie_refclk_p),
    .IB            (pcie_refclk_n),
    .CEB           (1'b0),
    .O             (pcie_sys_clk_gt),
    .ODIV2         (pcie_sys_clk)
);

wire [AXIS_PCIE_DATA_WIDTH-1:0]    axis_rq_tdata;
wire [AXIS_PCIE_KEEP_WIDTH-1:0]    axis_rq_tkeep;
wire                               axis_rq_tlast;
wire                               axis_rq_tready;
wire [AXIS_PCIE_RQ_USER_WIDTH-1:0] axis_rq_tuser;
wire                               axis_rq_tvalid;

wire [AXIS_PCIE_DATA_WIDTH-1:0]    axis_rc_tdata;
wire [AXIS_PCIE_KEEP_WIDTH-1:0]    axis_rc_tkeep;
wire                               axis_rc_tlast;
wire                               axis_rc_tready;
wire [AXIS_PCIE_RC_USER_WIDTH-1:0] axis_rc_tuser;
wire                               axis_rc_tvalid;

wire [AXIS_PCIE_DATA_WIDTH-1:0]    axis_cq_tdata;
wire [AXIS_PCIE_KEEP_WIDTH-1:0]    axis_cq_tkeep;
wire                               axis_cq_tlast;
wire                               axis_cq_tready;
wire [AXIS_PCIE_CQ_USER_WIDTH-1:0] axis_cq_tuser;
wire                               axis_cq_tvalid;

wire [AXIS_PCIE_DATA_WIDTH-1:0]    axis_cc_tdata;
wire [AXIS_PCIE_KEEP_WIDTH-1:0]    axis_cc_tkeep;
wire                               axis_cc_tlast;
wire                               axis_cc_tready;
wire [AXIS_PCIE_CC_USER_WIDTH-1:0] axis_cc_tuser;
wire                               axis_cc_tvalid;

wire [RQ_SEQ_NUM_WIDTH-1:0]        pcie_rq_seq_num0;
wire                               pcie_rq_seq_num_vld0;
wire [RQ_SEQ_NUM_WIDTH-1:0]        pcie_rq_seq_num1;
wire                               pcie_rq_seq_num_vld1;

wire [3:0] pcie_tfc_nph_av;
wire [3:0] pcie_tfc_npd_av;

wire [2:0] cfg_max_payload;
wire [2:0] cfg_max_read_req;
wire [3:0] cfg_rcb_status;

wire [9:0]  cfg_mgmt_addr;
wire [7:0]  cfg_mgmt_function_number;
wire        cfg_mgmt_write;
wire [31:0] cfg_mgmt_write_data;
wire [3:0]  cfg_mgmt_byte_enable;
wire        cfg_mgmt_read;
wire [31:0] cfg_mgmt_read_data;
wire        cfg_mgmt_read_write_done;

wire [7:0]  cfg_fc_ph;
wire [11:0] cfg_fc_pd;
wire [7:0]  cfg_fc_nph;
wire [11:0] cfg_fc_npd;
wire [7:0]  cfg_fc_cplh;
wire [11:0] cfg_fc_cpld;
wire [2:0]  cfg_fc_sel;

wire [3:0]   cfg_interrupt_msix_enable;
wire [3:0]   cfg_interrupt_msix_mask;
wire [251:0] cfg_interrupt_msix_vf_enable;
wire [251:0] cfg_interrupt_msix_vf_mask;
wire [63:0]  cfg_interrupt_msix_address;
wire [31:0]  cfg_interrupt_msix_data;
wire         cfg_interrupt_msix_int;
wire [1:0]   cfg_interrupt_msix_vec_pending;
wire         cfg_interrupt_msix_vec_pending_status;
wire         cfg_interrupt_msix_sent;
wire         cfg_interrupt_msix_fail;
wire [7:0]   cfg_interrupt_msi_function_number;

wire status_error_cor;
wire status_error_uncor;

// extra register for pcie_user_reset signal
wire pcie_user_reset_int;
(* shreg_extract = "no" *)
reg pcie_user_reset_reg_1 = 1'b1;
(* shreg_extract = "no" *)
reg pcie_user_reset_reg_2 = 1'b1;

always @(posedge pcie_user_clk) begin
    pcie_user_reset_reg_1 <= pcie_user_reset_int;
    pcie_user_reset_reg_2 <= pcie_user_reset_reg_1;
end

BUFG
pcie_user_reset_bufg_inst (
    .I(pcie_user_reset_reg_2),
    .O(pcie_user_reset)
);

// ila_0 ila_rq (
//     .clk(pcie_user_clk),
//     .trig_out(),
//     .trig_out_ack(1'b0),
//     .trig_in(1'b0),
//     .trig_in_ack(),
//     .probe0(axis_rq_tdata),
//     .probe1(axis_rq_tkeep),
//     .probe2(axis_rq_tvalid),
//     .probe3(axis_rq_tready),
//     .probe4({pcie_tfc_npd_av, pcie_tfc_nph_av, axis_rq_tuser}),
//     .probe5(axis_rq_tlast)
// );

// ila_0 ila_rc (
//     .clk(pcie_user_clk),
//     .trig_out(),
//     .trig_out_ack(1'b0),
//     .trig_in(1'b0),
//     .trig_in_ack(),
//     .probe0(axis_rc_tdata),
//     .probe1(axis_rc_tkeep),
//     .probe2(axis_rc_tvalid),
//     .probe3(axis_rc_tready),
//     .probe4(axis_rc_tuser),
//     .probe5(axis_rc_tlast)
// );

pcie4_uscale_plus_0
pcie4_uscale_plus_inst (
    .pci_exp_txn(pcie_tx_n),
    .pci_exp_txp(pcie_tx_p),
    .pci_exp_rxn(pcie_rx_n),
    .pci_exp_rxp(pcie_rx_p),
    .user_clk(pcie_user_clk),
    .user_reset(pcie_user_reset_int),
    .user_lnk_up(),

    .s_axis_rq_tdata(axis_rq_tdata),
    .s_axis_rq_tkeep(axis_rq_tkeep),
    .s_axis_rq_tlast(axis_rq_tlast),
    .s_axis_rq_tready(axis_rq_tready),
    .s_axis_rq_tuser(axis_rq_tuser),
    .s_axis_rq_tvalid(axis_rq_tvalid),

    .m_axis_rc_tdata(axis_rc_tdata),
    .m_axis_rc_tkeep(axis_rc_tkeep),
    .m_axis_rc_tlast(axis_rc_tlast),
    .m_axis_rc_tready(axis_rc_tready),
    .m_axis_rc_tuser(axis_rc_tuser),
    .m_axis_rc_tvalid(axis_rc_tvalid),

    .m_axis_cq_tdata(axis_cq_tdata),
    .m_axis_cq_tkeep(axis_cq_tkeep),
    .m_axis_cq_tlast(axis_cq_tlast),
    .m_axis_cq_tready(axis_cq_tready),
    .m_axis_cq_tuser(axis_cq_tuser),
    .m_axis_cq_tvalid(axis_cq_tvalid),

    .s_axis_cc_tdata(axis_cc_tdata),
    .s_axis_cc_tkeep(axis_cc_tkeep),
    .s_axis_cc_tlast(axis_cc_tlast),
    .s_axis_cc_tready(axis_cc_tready),
    .s_axis_cc_tuser(axis_cc_tuser),
    .s_axis_cc_tvalid(axis_cc_tvalid),

    .pcie_rq_seq_num0(pcie_rq_seq_num0),
    .pcie_rq_seq_num_vld0(pcie_rq_seq_num_vld0),
    .pcie_rq_seq_num1(pcie_rq_seq_num1),
    .pcie_rq_seq_num_vld1(pcie_rq_seq_num_vld1),
    .pcie_rq_tag0(),
    .pcie_rq_tag1(),
    .pcie_rq_tag_av(),
    .pcie_rq_tag_vld0(),
    .pcie_rq_tag_vld1(),

    .pcie_tfc_nph_av(pcie_tfc_nph_av),
    .pcie_tfc_npd_av(pcie_tfc_npd_av),

    .pcie_cq_np_req(1'b1),
    .pcie_cq_np_req_count(),

    .cfg_phy_link_down(),
    .cfg_phy_link_status(),
    .cfg_negotiated_width(),
    .cfg_current_speed(),
    .cfg_max_payload(cfg_max_payload),
    .cfg_max_read_req(cfg_max_read_req),
    .cfg_function_status(),
    .cfg_function_power_state(),
    .cfg_vf_status(),
    .cfg_vf_power_state(),
    .cfg_link_power_state(),

    .cfg_mgmt_addr(cfg_mgmt_addr),
    .cfg_mgmt_function_number(cfg_mgmt_function_number),
    .cfg_mgmt_write(cfg_mgmt_write),
    .cfg_mgmt_write_data(cfg_mgmt_write_data),
    .cfg_mgmt_byte_enable(cfg_mgmt_byte_enable),
    .cfg_mgmt_read(cfg_mgmt_read),
    .cfg_mgmt_read_data(cfg_mgmt_read_data),
    .cfg_mgmt_read_write_done(cfg_mgmt_read_write_done),
    .cfg_mgmt_debug_access(1'b0),

    .cfg_err_cor_out(),
    .cfg_err_nonfatal_out(),
    .cfg_err_fatal_out(),
    .cfg_local_error_valid(),
    .cfg_local_error_out(),
    .cfg_ltssm_state(),
    .cfg_rx_pm_state(),
    .cfg_tx_pm_state(),
    .cfg_rcb_status(cfg_rcb_status),
    .cfg_obff_enable(),
    .cfg_pl_status_change(),
    .cfg_tph_requester_enable(),
    .cfg_tph_st_mode(),
    .cfg_vf_tph_requester_enable(),
    .cfg_vf_tph_st_mode(),

    .cfg_msg_received(),
    .cfg_msg_received_data(),
    .cfg_msg_received_type(),
    .cfg_msg_transmit(1'b0),
    .cfg_msg_transmit_type(3'd0),
    .cfg_msg_transmit_data(32'd0),
    .cfg_msg_transmit_done(),

    .cfg_fc_ph(cfg_fc_ph),
    .cfg_fc_pd(cfg_fc_pd),
    .cfg_fc_nph(cfg_fc_nph),
    .cfg_fc_npd(cfg_fc_npd),
    .cfg_fc_cplh(cfg_fc_cplh),
    .cfg_fc_cpld(cfg_fc_cpld),
    .cfg_fc_sel(cfg_fc_sel),

    .cfg_dsn(64'd0),

    .cfg_power_state_change_ack(1'b1),
    .cfg_power_state_change_interrupt(),

    .cfg_err_cor_in(status_error_cor),
    .cfg_err_uncor_in(status_error_uncor),
    .cfg_flr_in_process(),
    .cfg_flr_done(4'd0),
    .cfg_vf_flr_in_process(),
    .cfg_vf_flr_func_num(8'd0),
    .cfg_vf_flr_done(8'd0),

    .cfg_link_training_enable(1'b1),

    .cfg_interrupt_int(4'd0),
    .cfg_interrupt_pending(4'd0),
    .cfg_interrupt_sent(),
    .cfg_interrupt_msix_enable(cfg_interrupt_msix_enable),
    .cfg_interrupt_msix_mask(cfg_interrupt_msix_mask),
    .cfg_interrupt_msix_vf_enable(cfg_interrupt_msix_vf_enable),
    .cfg_interrupt_msix_vf_mask(cfg_interrupt_msix_vf_mask),
    .cfg_interrupt_msix_address(cfg_interrupt_msix_address),
    .cfg_interrupt_msix_data(cfg_interrupt_msix_data),
    .cfg_interrupt_msix_int(cfg_interrupt_msix_int),
    .cfg_interrupt_msix_vec_pending(cfg_interrupt_msix_vec_pending),
    .cfg_interrupt_msix_vec_pending_status(cfg_interrupt_msix_vec_pending_status),
    .cfg_interrupt_msi_sent(cfg_interrupt_msix_sent),
    .cfg_interrupt_msi_fail(cfg_interrupt_msix_fail),
    .cfg_interrupt_msi_function_number(cfg_interrupt_msi_function_number),

    .cfg_pm_aspm_l1_entry_reject(1'b0),
    .cfg_pm_aspm_tx_l0s_entry_disable(1'b0),

    .cfg_hot_reset_out(),

    .cfg_config_space_enable(1'b1),
    .cfg_req_pm_transition_l23_ready(1'b0),
    .cfg_hot_reset_in(1'b0),

    .cfg_ds_port_number(8'd0),
    .cfg_ds_bus_number(8'd0),
    .cfg_ds_device_number(5'd0),

    .sys_clk(pcie_sys_clk),
    .sys_clk_gt(pcie_sys_clk_gt),
    .sys_reset(pcie_reset_n),

    .phy_rdy_out()
);

// XGMII 10G PHY
wire                         sfp_1_tx_clk_int;
wire                         sfp_1_tx_rst_int;
wire [XGMII_DATA_WIDTH-1:0]  sfp_1_txd_int;
wire [XGMII_CTRL_WIDTH-1:0]  sfp_1_txc_int;
wire                         sfp_1_cfg_tx_prbs31_enable_int;
wire                         sfp_1_rx_clk_int;
wire                         sfp_1_rx_rst_int;
wire [XGMII_DATA_WIDTH-1:0]  sfp_1_rxd_int;
wire [XGMII_CTRL_WIDTH-1:0]  sfp_1_rxc_int;
wire                         sfp_1_cfg_rx_prbs31_enable_int;
wire [6:0]                   sfp_1_rx_error_count_int;

wire                         sfp_2_tx_clk_int;
wire                         sfp_2_tx_rst_int;
wire [XGMII_DATA_WIDTH-1:0]  sfp_2_txd_int;
wire [XGMII_CTRL_WIDTH-1:0]  sfp_2_txc_int;
wire                         sfp_2_cfg_tx_prbs31_enable_int;
wire                         sfp_2_rx_clk_int;
wire                         sfp_2_rx_rst_int;
wire [XGMII_DATA_WIDTH-1:0]  sfp_2_rxd_int;
wire [XGMII_CTRL_WIDTH-1:0]  sfp_2_rxc_int;
wire                         sfp_2_cfg_rx_prbs31_enable_int;
wire [6:0]                   sfp_2_rx_error_count_int;

wire        sfp_drp_clk = clk_125mhz_int;
wire        sfp_drp_rst = rst_125mhz_int;
wire [23:0] sfp_drp_addr;
wire [15:0] sfp_drp_di;
wire        sfp_drp_en;
wire        sfp_drp_we;
wire [15:0] sfp_drp_do;
wire        sfp_drp_rdy;

wire sfp_1_rx_block_lock;
wire sfp_1_rx_status;
wire sfp_2_rx_block_lock;
wire sfp_2_rx_status;

wire sfp_gtpowergood;

wire sfp_mgt_refclk;
wire sfp_mgt_refclk_int;
wire sfp_mgt_refclk_bufg;

assign clk_156mhz_int = sfp_mgt_refclk_bufg;

IBUFDS_GTE4 ibufds_gte4_sfp_mgt_refclk_inst (
    .I     (sfp_mgt_refclk_p),
    .IB    (sfp_mgt_refclk_n),
    .CEB   (1'b0),
    .O     (sfp_mgt_refclk),        // 这个去驱动 GTY Transceivers
    .ODIV2 (sfp_mgt_refclk_int)     // 这个去驱动 FPGA 逻辑
);

BUFG_GT bufg_gt_sfp_mgt_refclk_inst (
    .CE      (sfp_gtpowergood),
    .CEMASK  (1'b1),
    .CLR     (1'b0),
    .CLRMASK (1'b1),
    .DIV     (3'd0),
    .I       (sfp_mgt_refclk_int),
    .O       (sfp_mgt_refclk_bufg)
);

wire sfp_rst;

sync_reset #(
    .N(4)
)
sfp_sync_reset_inst (
    .clk(sfp_mgt_refclk_bufg),
    .rst(rst_125mhz_int),
    .out(sfp_rst)
);

eth_xcvr_phy_10g_gty_quad_wrapper #(
    .COUNT(2),
    .GT_1_TX_POLARITY(1'b0),
    .GT_2_TX_POLARITY(1'b0),
    .PRBS31_ENABLE(1),
    .TX_SERDES_PIPELINE(1),
    .RX_SERDES_PIPELINE(1),
    .COUNT_125US(125000/2.56)
)
sfp_phy_quad_inst (
    .xcvr_ctrl_clk(clk_125mhz_int),
    .xcvr_ctrl_rst(sfp_rst),

    /*
     * Common
     */
    .xcvr_gtpowergood_out(sfp_gtpowergood),
    .xcvr_gtrefclk00_in(sfp_mgt_refclk),
    .xcvr_qpll0pd_in(1'b0),
    .xcvr_qpll0reset_in(1'b0),
    .xcvr_qpll0pcierate_in(3'd0),
    .xcvr_qpll0lock_out(),
    .xcvr_qpll0clk_out(),
    .xcvr_qpll0refclk_out(),
    .xcvr_gtrefclk01_in(sfp_mgt_refclk),
    .xcvr_qpll1pd_in(1'b0),
    .xcvr_qpll1reset_in(1'b0),
    .xcvr_qpll1pcierate_in(3'd0),
    .xcvr_qpll1lock_out(),
    .xcvr_qpll1clk_out(),
    .xcvr_qpll1refclk_out(),

    /*
     * DRP
     */
    .drp_clk(sfp_drp_clk),
    .drp_rst(sfp_drp_rst),
    .drp_addr(sfp_drp_addr),
    .drp_di(sfp_drp_di),
    .drp_en(sfp_drp_en),
    .drp_we(sfp_drp_we),
    .drp_do(sfp_drp_do),
    .drp_rdy(sfp_drp_rdy),

    /*
     * Serial data
     */
    .xcvr_txp({sfp_2_tx_p, sfp_1_tx_p}),
    .xcvr_txn({sfp_2_tx_n, sfp_1_tx_n}),
    .xcvr_rxp({sfp_2_rx_p, sfp_1_rx_p}),
    .xcvr_rxn({sfp_2_rx_n, sfp_1_rx_n}),

    /*
     * PHY connections
     */
    .phy_1_tx_clk(sfp_1_tx_clk_int),
    .phy_1_tx_rst(sfp_1_tx_rst_int),
    .phy_1_xgmii_txd(sfp_1_txd_int),
    .phy_1_xgmii_txc(sfp_1_txc_int),
    .phy_1_rx_clk(sfp_1_rx_clk_int),
    .phy_1_rx_rst(sfp_1_rx_rst_int),
    .phy_1_xgmii_rxd(sfp_1_rxd_int),
    .phy_1_xgmii_rxc(sfp_1_rxc_int),
    .phy_1_tx_bad_block(),
    .phy_1_rx_error_count(sfp_1_rx_error_count_int),
    .phy_1_rx_bad_block(),
    .phy_1_rx_sequence_error(),
    .phy_1_rx_block_lock(sfp_1_rx_block_lock),
    .phy_1_rx_high_ber(),
    .phy_1_rx_status(sfp_1_rx_status),
    .phy_1_cfg_tx_prbs31_enable(sfp_1_cfg_tx_prbs31_enable_int),
    .phy_1_cfg_rx_prbs31_enable(sfp_1_cfg_rx_prbs31_enable_int),

    .phy_2_tx_clk(sfp_2_tx_clk_int),
    .phy_2_tx_rst(sfp_2_tx_rst_int),
    .phy_2_xgmii_txd(sfp_2_txd_int),
    .phy_2_xgmii_txc(sfp_2_txc_int),
    .phy_2_rx_clk(sfp_2_rx_clk_int),
    .phy_2_rx_rst(sfp_2_rx_rst_int),
    .phy_2_xgmii_rxd(sfp_2_rxd_int),
    .phy_2_xgmii_rxc(sfp_2_rxc_int),
    .phy_2_tx_bad_block(),
    .phy_2_rx_error_count(sfp_2_rx_error_count_int),
    .phy_2_rx_bad_block(),
    .phy_2_rx_sequence_error(),
    .phy_2_rx_block_lock(sfp_2_rx_block_lock),
    .phy_2_rx_high_ber(),
    .phy_2_rx_status(sfp_2_rx_status),
    .phy_2_cfg_tx_prbs31_enable(sfp_2_cfg_tx_prbs31_enable_int),
    .phy_2_cfg_rx_prbs31_enable(sfp_2_cfg_rx_prbs31_enable_int)
);

wire ptp_clk;
wire ptp_rst;
wire ptp_sample_clk;

assign ptp_clk = clk_250mhz_int;
assign ptp_rst = rst_250mhz_int;
assign ptp_sample_clk = clk_125mhz_int;

// 定义一个 32位 计数器
reg [31:0] heartbeat_cnt;

// 在 pcie_user_clk 时钟域下累加
always @(posedge pcie_user_clk) begin
    if (pcie_user_reset) begin
        heartbeat_cnt <= 0;
    end else begin
        heartbeat_cnt <= heartbeat_cnt + 1;
    end
end

assign led_g = heartbeat_cnt[26]; // 250MHz下，第26位大约每0.26秒翻转一次;

assign sfp_1_led = !sfp_1_rx_status;
assign sfp_2_led = !sfp_2_rx_status;

fpga_core #(
    // FW and board IDs
    .FPGA_ID(FPGA_ID),
    .FW_ID(FW_ID),
    .FW_VER(FW_VER),
    .BOARD_ID(BOARD_ID),
    .BOARD_VER(BOARD_VER),
    .BUILD_DATE(BUILD_DATE),
    .GIT_HASH(GIT_HASH),
    .RELEASE_INFO(RELEASE_INFO),

    // Board configuration
    .TDMA_BER_ENABLE(TDMA_BER_ENABLE),
    .XCVR_DRP_INFO({8'h09, 8'h03, 8'd0, 8'd2}),

    // Structural configuration
    .IF_COUNT(IF_COUNT),
    .PORTS_PER_IF(PORTS_PER_IF),
    .SCHED_PER_IF(SCHED_PER_IF),
    .PORT_MASK(PORT_MASK),

    // Clock configuration
    .CLK_PERIOD_NS_NUM(CLK_PERIOD_NS_NUM),
    .CLK_PERIOD_NS_DENOM(CLK_PERIOD_NS_DENOM),

    // PTP configuration
    .PTP_CLK_PERIOD_NS_NUM(PTP_CLK_PERIOD_NS_NUM),
    .PTP_CLK_PERIOD_NS_DENOM(PTP_CLK_PERIOD_NS_DENOM),
    .PTP_TS_WIDTH(PTP_TS_WIDTH),
    .PTP_CLOCK_PIPELINE(PTP_CLOCK_PIPELINE),
    .PTP_CLOCK_CDC_PIPELINE(PTP_CLOCK_CDC_PIPELINE),
    .PTP_PORT_CDC_PIPELINE(PTP_PORT_CDC_PIPELINE),
    .PTP_PEROUT_ENABLE(PTP_PEROUT_ENABLE),
    .PTP_PEROUT_COUNT(PTP_PEROUT_COUNT),

    // Queue manager configuration
    .EVENT_QUEUE_OP_TABLE_SIZE(EVENT_QUEUE_OP_TABLE_SIZE),
    .TX_QUEUE_OP_TABLE_SIZE(TX_QUEUE_OP_TABLE_SIZE),
    .RX_QUEUE_OP_TABLE_SIZE(RX_QUEUE_OP_TABLE_SIZE),
    .CQ_OP_TABLE_SIZE(CQ_OP_TABLE_SIZE),
    .EQN_WIDTH(EQN_WIDTH),
    .TX_QUEUE_INDEX_WIDTH(TX_QUEUE_INDEX_WIDTH),
    .RX_QUEUE_INDEX_WIDTH(RX_QUEUE_INDEX_WIDTH),
    .CQN_WIDTH(CQN_WIDTH),
    .EQ_PIPELINE(EQ_PIPELINE),
    .TX_QUEUE_PIPELINE(TX_QUEUE_PIPELINE),
    .RX_QUEUE_PIPELINE(RX_QUEUE_PIPELINE),
    .CQ_PIPELINE(CQ_PIPELINE),

    // TX and RX engine configuration
    .TX_DESC_TABLE_SIZE(TX_DESC_TABLE_SIZE),
    .RX_DESC_TABLE_SIZE(RX_DESC_TABLE_SIZE),
    .RX_INDIR_TBL_ADDR_WIDTH(RX_INDIR_TBL_ADDR_WIDTH),

    // Scheduler configuration
    .TX_SCHEDULER_OP_TABLE_SIZE(TX_SCHEDULER_OP_TABLE_SIZE),
    .TX_SCHEDULER_PIPELINE(TX_SCHEDULER_PIPELINE),
    .TDMA_INDEX_WIDTH(TDMA_INDEX_WIDTH),

    // Interface configuration
    .PTP_TS_ENABLE(PTP_TS_ENABLE),
    .TX_CPL_FIFO_DEPTH(TX_CPL_FIFO_DEPTH),
    .TX_TAG_WIDTH(TX_TAG_WIDTH),
    .TX_CHECKSUM_ENABLE(TX_CHECKSUM_ENABLE),
    .RX_HASH_ENABLE(RX_HASH_ENABLE),
    .RX_CHECKSUM_ENABLE(RX_CHECKSUM_ENABLE),
    .PFC_ENABLE(PFC_ENABLE),
    .LFC_ENABLE(LFC_ENABLE),
    .ENABLE_PADDING(ENABLE_PADDING),
    .ENABLE_DIC(ENABLE_DIC),
    .MIN_FRAME_LENGTH(MIN_FRAME_LENGTH),
    .TX_FIFO_DEPTH(TX_FIFO_DEPTH),
    .RX_FIFO_DEPTH(RX_FIFO_DEPTH),
    .MAX_TX_SIZE(MAX_TX_SIZE),
    .MAX_RX_SIZE(MAX_RX_SIZE),
    .TX_RAM_SIZE(TX_RAM_SIZE),
    .RX_RAM_SIZE(RX_RAM_SIZE),

    // Application block configuration
    .APP_ID(APP_ID),
    .APP_ENABLE(APP_ENABLE),
    .APP_CTRL_ENABLE(APP_CTRL_ENABLE),
    .APP_DMA_ENABLE(APP_DMA_ENABLE),
    .APP_AXIS_DIRECT_ENABLE(APP_AXIS_DIRECT_ENABLE),
    .APP_AXIS_SYNC_ENABLE(APP_AXIS_SYNC_ENABLE),
    .APP_AXIS_IF_ENABLE(APP_AXIS_IF_ENABLE),
    .APP_STAT_ENABLE(APP_STAT_ENABLE),

    // DMA interface configuration
    .DMA_IMM_ENABLE(DMA_IMM_ENABLE),
    .DMA_IMM_WIDTH(DMA_IMM_WIDTH),
    .DMA_LEN_WIDTH(DMA_LEN_WIDTH),
    .DMA_TAG_WIDTH(DMA_TAG_WIDTH),
    .RAM_ADDR_WIDTH(RAM_ADDR_WIDTH),
    .RAM_PIPELINE(RAM_PIPELINE),

    // PCIe interface configuration
    .AXIS_PCIE_DATA_WIDTH(AXIS_PCIE_DATA_WIDTH),
    .AXIS_PCIE_KEEP_WIDTH(AXIS_PCIE_KEEP_WIDTH),
    .AXIS_PCIE_RC_USER_WIDTH(AXIS_PCIE_RC_USER_WIDTH),
    .AXIS_PCIE_RQ_USER_WIDTH(AXIS_PCIE_RQ_USER_WIDTH),
    .AXIS_PCIE_CQ_USER_WIDTH(AXIS_PCIE_CQ_USER_WIDTH),
    .AXIS_PCIE_CC_USER_WIDTH(AXIS_PCIE_CC_USER_WIDTH),
    .RC_STRADDLE(RC_STRADDLE),
    .RQ_STRADDLE(RQ_STRADDLE),
    .CQ_STRADDLE(CQ_STRADDLE),
    .CC_STRADDLE(CC_STRADDLE),
    .RQ_SEQ_NUM_WIDTH(RQ_SEQ_NUM_WIDTH),
    .PF_COUNT(PF_COUNT),
    .VF_COUNT(VF_COUNT),
    .PCIE_TAG_COUNT(PCIE_TAG_COUNT),

    // Interrupt configuration
    .IRQ_INDEX_WIDTH(IRQ_INDEX_WIDTH),

    // AXI lite interface configuration (control)
    .AXIL_CTRL_DATA_WIDTH(AXIL_CTRL_DATA_WIDTH),
    .AXIL_CTRL_ADDR_WIDTH(AXIL_CTRL_ADDR_WIDTH),

    // AXI lite interface configuration (application control)
    .AXIL_APP_CTRL_DATA_WIDTH(AXIL_APP_CTRL_DATA_WIDTH),
    .AXIL_APP_CTRL_ADDR_WIDTH(AXIL_APP_CTRL_ADDR_WIDTH),

    // Ethernet interface configuration
    .XGMII_DATA_WIDTH(XGMII_DATA_WIDTH),
    .XGMII_CTRL_WIDTH(XGMII_CTRL_WIDTH),
    .AXIS_ETH_DATA_WIDTH(AXIS_ETH_DATA_WIDTH),
    .AXIS_ETH_KEEP_WIDTH(AXIS_ETH_KEEP_WIDTH),
    .AXIS_ETH_SYNC_DATA_WIDTH(AXIS_ETH_SYNC_DATA_WIDTH),
    .AXIS_ETH_TX_USER_WIDTH(AXIS_ETH_TX_USER_WIDTH),
    .AXIS_ETH_RX_USER_WIDTH(AXIS_ETH_RX_USER_WIDTH),
    .AXIS_ETH_TX_PIPELINE(AXIS_ETH_TX_PIPELINE),
    .AXIS_ETH_TX_FIFO_PIPELINE(AXIS_ETH_TX_FIFO_PIPELINE),
    .AXIS_ETH_TX_TS_PIPELINE(AXIS_ETH_TX_TS_PIPELINE),
    .AXIS_ETH_RX_PIPELINE(AXIS_ETH_RX_PIPELINE),
    .AXIS_ETH_RX_FIFO_PIPELINE(AXIS_ETH_RX_FIFO_PIPELINE),

    // Statistics counter subsystem
    .STAT_ENABLE(STAT_ENABLE),
    .STAT_DMA_ENABLE(STAT_DMA_ENABLE),
    .STAT_PCIE_ENABLE(STAT_PCIE_ENABLE),
    .STAT_INC_WIDTH(STAT_INC_WIDTH),
    .STAT_ID_WIDTH(STAT_ID_WIDTH)
)
core_inst (
    /*
     * Clock: 250 MHz
     * Synchronous reset
     */
    .clk_250mhz(pcie_user_clk),
    .rst_250mhz(pcie_user_reset),

    /*
     * PTP clock
     */
    .ptp_clk(ptp_clk),
    .ptp_rst(ptp_rst),
    .ptp_sample_clk(ptp_sample_clk),

    /*
     * GPIO
     */
    //.sfp_1_led(sfp_1_led),
    //.sfp_2_led(sfp_2_led),

    /*
     * PCIe
     */
    .m_axis_rq_tdata(axis_rq_tdata),
    .m_axis_rq_tkeep(axis_rq_tkeep),
    .m_axis_rq_tlast(axis_rq_tlast),
    .m_axis_rq_tready(axis_rq_tready),
    .m_axis_rq_tuser(axis_rq_tuser),
    .m_axis_rq_tvalid(axis_rq_tvalid),

    .s_axis_rc_tdata(axis_rc_tdata),
    .s_axis_rc_tkeep(axis_rc_tkeep),
    .s_axis_rc_tlast(axis_rc_tlast),
    .s_axis_rc_tready(axis_rc_tready),
    .s_axis_rc_tuser(axis_rc_tuser),
    .s_axis_rc_tvalid(axis_rc_tvalid),

    .s_axis_cq_tdata(axis_cq_tdata),
    .s_axis_cq_tkeep(axis_cq_tkeep),
    .s_axis_cq_tlast(axis_cq_tlast),
    .s_axis_cq_tready(axis_cq_tready),
    .s_axis_cq_tuser(axis_cq_tuser),
    .s_axis_cq_tvalid(axis_cq_tvalid),

    .m_axis_cc_tdata(axis_cc_tdata),
    .m_axis_cc_tkeep(axis_cc_tkeep),
    .m_axis_cc_tlast(axis_cc_tlast),
    .m_axis_cc_tready(axis_cc_tready),
    .m_axis_cc_tuser(axis_cc_tuser),
    .m_axis_cc_tvalid(axis_cc_tvalid),

    .s_axis_rq_seq_num_0(pcie_rq_seq_num0),
    .s_axis_rq_seq_num_valid_0(pcie_rq_seq_num_vld0),
    .s_axis_rq_seq_num_1(pcie_rq_seq_num1),
    .s_axis_rq_seq_num_valid_1(pcie_rq_seq_num_vld1),

    .pcie_tfc_nph_av(pcie_tfc_nph_av),
    .pcie_tfc_npd_av(pcie_tfc_npd_av),

    .cfg_max_payload(cfg_max_payload),
    .cfg_max_read_req(cfg_max_read_req),
    .cfg_rcb_status(cfg_rcb_status),

    .cfg_mgmt_addr(cfg_mgmt_addr),
    .cfg_mgmt_function_number(cfg_mgmt_function_number),
    .cfg_mgmt_write(cfg_mgmt_write),
    .cfg_mgmt_write_data(cfg_mgmt_write_data),
    .cfg_mgmt_byte_enable(cfg_mgmt_byte_enable),
    .cfg_mgmt_read(cfg_mgmt_read),
    .cfg_mgmt_read_data(cfg_mgmt_read_data),
    .cfg_mgmt_read_write_done(cfg_mgmt_read_write_done),

    .cfg_fc_ph(cfg_fc_ph),
    .cfg_fc_pd(cfg_fc_pd),
    .cfg_fc_nph(cfg_fc_nph),
    .cfg_fc_npd(cfg_fc_npd),
    .cfg_fc_cplh(cfg_fc_cplh),
    .cfg_fc_cpld(cfg_fc_cpld),
    .cfg_fc_sel(cfg_fc_sel),

    .cfg_interrupt_msix_enable(cfg_interrupt_msix_enable),
    .cfg_interrupt_msix_mask(cfg_interrupt_msix_mask),
    .cfg_interrupt_msix_vf_enable(cfg_interrupt_msix_vf_enable),
    .cfg_interrupt_msix_vf_mask(cfg_interrupt_msix_vf_mask),
    .cfg_interrupt_msix_address(cfg_interrupt_msix_address),
    .cfg_interrupt_msix_data(cfg_interrupt_msix_data),
    .cfg_interrupt_msix_int(cfg_interrupt_msix_int),
    .cfg_interrupt_msix_vec_pending(cfg_interrupt_msix_vec_pending),
    .cfg_interrupt_msix_vec_pending_status(cfg_interrupt_msix_vec_pending_status),
    .cfg_interrupt_msix_sent(cfg_interrupt_msix_sent),
    .cfg_interrupt_msix_fail(cfg_interrupt_msix_fail),
    .cfg_interrupt_msi_function_number(cfg_interrupt_msi_function_number),

    .status_error_cor(status_error_cor),
    .status_error_uncor(status_error_uncor),

    /*
     * Ethernet: SFP+
     */
    .sfp_1_tx_clk(sfp_1_tx_clk_int),
    .sfp_1_tx_rst(sfp_1_tx_rst_int),
    .sfp_1_txd(sfp_1_txd_int),
    .sfp_1_txc(sfp_1_txc_int),
    .sfp_1_cfg_tx_prbs31_enable(sfp_1_cfg_tx_prbs31_enable_int),
    .sfp_1_rx_clk(sfp_1_rx_clk_int),
    .sfp_1_rx_rst(sfp_1_rx_rst_int),
    .sfp_1_rxd(sfp_1_rxd_int),
    .sfp_1_rxc(sfp_1_rxc_int),
    .sfp_1_cfg_rx_prbs31_enable(sfp_1_cfg_rx_prbs31_enable_int),
    .sfp_1_rx_error_count(sfp_1_rx_error_count_int),

    .sfp_1_rx_status(sfp_1_rx_status),

    .sfp_2_tx_clk(sfp_2_tx_clk_int),
    .sfp_2_tx_rst(sfp_2_tx_rst_int),
    .sfp_2_txd(sfp_2_txd_int),
    .sfp_2_txc(sfp_2_txc_int),
    .sfp_2_cfg_tx_prbs31_enable(sfp_2_cfg_tx_prbs31_enable_int),
    .sfp_2_rx_clk(sfp_2_rx_clk_int),
    .sfp_2_rx_rst(sfp_2_rx_rst_int),
    .sfp_2_rxd(sfp_2_rxd_int),
    .sfp_2_rxc(sfp_2_rxc_int),
    .sfp_2_cfg_rx_prbs31_enable(sfp_2_cfg_rx_prbs31_enable_int),
    .sfp_2_rx_error_count(sfp_2_rx_error_count_int),

    .sfp_2_rx_status(sfp_2_rx_status),

    .sfp_drp_clk(sfp_drp_clk),
    .sfp_drp_rst(sfp_drp_rst),
    .sfp_drp_addr(sfp_drp_addr),
    .sfp_drp_di(sfp_drp_di),
    .sfp_drp_en(sfp_drp_en),
    .sfp_drp_we(sfp_drp_we),
    .sfp_drp_do(sfp_drp_do),
    .sfp_drp_rdy(sfp_drp_rdy),

    .sfp_1_tx_disable(sfp_1_tx_disable),
    .sfp_2_tx_disable(sfp_2_tx_disable),
    .sfp_1_npres(sfp_1_npres_int),
    .sfp_2_npres(sfp_2_npres_int),
    .sfp_1_los(sfp_1_los_int),
    .sfp_2_los(sfp_2_los_int),

    .sfp_i2c_scl_i(sfp_i2c_scl_i),
    .sfp_i2c_scl_o(sfp_i2c_scl_o),
    .sfp_i2c_scl_t(sfp_i2c_scl_t),
    .sfp_1_i2c_sda_i(sfp_1_i2c_sda_i),
    .sfp_1_i2c_sda_o(sfp_1_i2c_sda_o),
    .sfp_1_i2c_sda_t(sfp_1_i2c_sda_t),
    .sfp_2_i2c_sda_i(sfp_2_i2c_sda_i),
    .sfp_2_i2c_sda_o(sfp_2_i2c_sda_o),
    .sfp_2_i2c_sda_t(sfp_2_i2c_sda_t),

    .eeprom_i2c_scl_i(eeprom_i2c_scl_i),
    .eeprom_i2c_scl_o(eeprom_i2c_scl_o),
    .eeprom_i2c_scl_t(eeprom_i2c_scl_t),
    .eeprom_i2c_sda_i(eeprom_i2c_sda_i),
    .eeprom_i2c_sda_o(eeprom_i2c_sda_o),
    .eeprom_i2c_sda_t(eeprom_i2c_sda_t)
);

endmodule

`resetall
