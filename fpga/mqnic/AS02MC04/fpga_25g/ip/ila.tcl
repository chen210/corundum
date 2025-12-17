# 1. 创建 ILA IP
create_ip -name ila -vendor xilinx.com -library ip -module_name ila_0

# 2. 配置位宽
# Probe 0 (Data): 256 bit
# Probe 1 (Keep): 8 bit
# Probe 2 (Valid): 1 bit
# Probe 3 (Ready): 1 bit
# Probe 4 (User): 75 bit (取 RQ=66 和 RC=75 中的最大值)
# Probe 5 (Last): 1 bit
set_property -dict [list \
    CONFIG.C_PROBE0_WIDTH {256} \
    CONFIG.C_PROBE1_WIDTH {8} \
    CONFIG.C_PROBE2_WIDTH {1} \
    CONFIG.C_PROBE3_WIDTH {1} \
    CONFIG.C_PROBE4_WIDTH {75} \
    CONFIG.C_PROBE5_WIDTH {1} \
    CONFIG.C_DATA_DEPTH {4096} \
    CONFIG.C_NUM_OF_PROBES {6} \
    CONFIG.C_EN_STRG_QUAL {1} \
    CONFIG.C_INPUT_PIPE_STAGES {2} \
    CONFIG.C_ADV_TRIGGER {true} \
] [get_ips ila_0]

# 3. 生成 IP
generate_target {instantiation_template} [get_files ila_0.xci]
generate_target all [get_files ila_0.xci]