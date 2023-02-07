
# generate verilog to store strings, null-terminated
# plus package for indices
# want to infer BRAM: https://old.reddit.com/r/yosys/comments/5aqzyr/can_i_write_behavioral_verilog_that_infers_ice40/
# ice40 4k BRAM can be arranged as 512x8b

directory = {}
directory['hello_world'] = 'Hello world!'
directory['startup_message'] = '~~~Welcome to Slowworm USB~~~'

index = 0
indexing = {}

with open('strings.v','w') as f:
    f.write('''
module strings(
    input               clk,
    input               rd,
    input       [8:0]   raddr,
    input               wr,
    input       [8:0]   waddr,
    input       [7:0]   din,
    output reg  [7:0]   dout
);

    reg [7:0] ram [511:0];

    always @(posedge clk) begin
        if (rd)
            dout <= ram[raddr];
        if (wr)
            ram[waddr] <= din;
    end

    initial begin
''')
    for key, value in directory.items():
        indexing[key] = index
        for char in value:
            f.write('        ram[' + str(index) +'] = 8\'d' + str(ord(char)) + '; // ' + char + '\n')
            index = index + 1
        f.write('        ram[' + str(index) +'] = 8\'d0;\n')
        index = index + 1
    for ii in range(index,512):
        f.write('        ram[' + str(ii) +'] = 8\'d0;\n')
    f.write('    end\n')
    f.write('endmodule\n')

if (index >= 512):
    print('Warning: exceeded single BRAM capacity')
else:
    print('Using ' + str(index) + ' bytes out of 512')

with open('pkg_strings.sv','w') as fp:
    fp.write('package pkg_strings;\n')
    for key, value in indexing.items():
        fp.write('    parameter S_' + key + ' = 9\'d' + str(value) + ';\n')
    fp.write('endpackage\n')
