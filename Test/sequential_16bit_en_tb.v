`timescale 1ps/1ps
module sequential_16bit_en_tb;
    wire [27:0] I_top;
    wire [27:0] T_top;
    reg [27:0] O_top = 0;
    wire [55:0] A_cfg, B_cfg;

    reg CLK = 1'b0;
    reg resetn = 1'b1;
    reg SelfWriteStrobe = 1'b0;
    reg [31:0] SelfWriteData = 1'b0;
    reg Rx = 1'b1;
    wire ComActive;
    wire ReceiveLED;
    reg s_clk = 1'b0;
    reg s_data = 1'b0;

    // Instantiate both the fabric and the reference DUT
    eFPGA_top top_i (
        .I_top(I_top),
        .T_top(T_top),
        .O_top(O_top),
        .A_config_C(A_cfg), .B_config_C(B_cfg),
        .CLK(CLK), .resetn(resetn),
        .SelfWriteStrobe(SelfWriteStrobe), .SelfWriteData(SelfWriteData),
        .Rx(Rx),
        .ComActive(ComActive),
        .ReceiveLED(ReceiveLED),
        .s_clk(s_clk),
        .s_data(s_data)
    );

    wire [19:0]mul_result;
    integer mul_result_int;

    // wire [27:0] I_top_gold, oeb_gold, T_top_gold;
    // top dut_i (
    //     .clk(CLK),
    //     .io_out(I_top_gold),
    //     .io_oeb(oeb_gold),
    //     .io_in(O_top)
    // );

    // assign T_top_gold = ~oeb_gold;

    assign mul_result = I_top[19:0];

    localparam MAX_BITBYTES = 16384;
    reg [7:0] bitstream[0:MAX_BITBYTES-1];

    always #5000 CLK = (CLK === 1'b0);

    integer i;
    reg have_errors = 1'b0;

    reg [2047:0] bitstream_hex_arg; // 256 bytes for characters
    reg [2047:0] output_waveform_arg; // 256 bytes for characters
    reg [7:0]a, b;
    reg [6:0]c;
    initial begin


`ifndef EMULATION

        if ($value$plusargs("bitstream_hex=%s", bitstream_hex_arg)) begin
            $readmemh(bitstream_hex_arg, bitstream);
            $display("Read bitstream hex from %s", bitstream_hex_arg);
        end else begin
            $display("Error: No bitstream provided as $plusargs bitstream_hex.");
            $fatal;
        end


        #100;
        resetn = 1'b0;
        #10000;
        resetn = 1'b1;
        #10000;
        repeat (20) @(posedge CLK);
        #2500;
        for (i = 0; i < MAX_BITBYTES; i = i + 4) begin
            SelfWriteData <= {bitstream[i], bitstream[i+1], bitstream[i+2], bitstream[i+3]};
            repeat (2) @(posedge CLK);
            SelfWriteStrobe <= 1'b1;
            @(posedge CLK);
            SelfWriteStrobe <= 1'b0;
            repeat (2) @(posedge CLK);
        end
`endif
        repeat (100) @(posedge CLK);

        if ($value$plusargs("output_waveform=%s", output_waveform_arg)) begin
            $dumpfile(output_waveform_arg);
            $dumpvars(0, sequential_16bit_en_tb);
            $display("Output waveform set to %s", output_waveform_arg);
        end
        // Enable and reset the counter
        O_top = 28'b0000_0000_0000_0000_0000_0000_0011;
        repeat (5) @(posedge CLK);
        // Deassert reset while keeping the counter enabled
        O_top = 28'b0000_0000_0000_0000_0000_0000_0010;
        add_mul_test(8'd10, 8'd5, 8'd5, 55);
        add_mul_test(8'd20, 8'd5, 8'd5, 105);
        add_mul_test(8'd128, 8'd2, 8'd0, 256);
        add_mul_test(8'd255, 8'd255, 8'd0, 65025);
        add_mul_test(8'd255, 8'd254, 8'd0, 64770);
        add_mul_test(8'b10000000, 8'd5, 8'd0, -640);
        add_mul_test(8'b11111111, 8'd5, 8'd0, -5);

        if (have_errors)
            $fatal;
        else
            $finish;
    end

    task add_mul_test;
        input [7:0] a;    // 8-bit input a
        input [7:0] b;    // 8-bit input b
        input [6:0] c;    // 7-bit input c
        input integer expected_result;

        begin
            O_top[9:2]   = a;   // Assign 'a' to bits 9 to 2 of O_top
            O_top[17:10] = b;   // Assign 'b' to bits 17 to 10 of O_top
            O_top[24:18] = c;   // Assign 'c' to bits 24 to 18 of O_top
            repeat (5) @(posedge CLK);
            mul_result_int = {{12{mul_result[19]}},mul_result};
        $display("mul_result = %d expected_result = %d", mul_result_int, expected_result);
        if (mul_result_int !== expected_result)
            have_errors = 1'b1;
        end
    endtask

endmodule



module clk_buf(input A, output X);
assign X = A;
endmodule

module break_comb_loop(input A, output X);
assign X = A;
endmodule
