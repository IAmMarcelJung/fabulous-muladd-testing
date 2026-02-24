module top(input wire clk, input wire [27:0] io_in, output wire [27:0] io_out, io_oeb);
    wire rst = io_in[0];
    wire en = io_in[1];
    reg [15:0] ctr;

    // always @(posedge clk)
    //     if (en)
    //         if (rst)
    //             ctr <= 0;
    //         else
    //             ctr <= ctr + 1'b1;
    //     else
    //         ctr <= ctr;

        wire [7:0]a;
        wire [7:0]b;
        wire [19:0]c;

        wire [19:0]res;
        reg [19:0]res_r;
    assign a = io_in[9:2];
    assign b = io_in[17:10];
    assign c = {13'b0, io_in[24:18]};
    // assign res = a * b + c;

    always @(posedge clk)
        if (rst)
            res_r <= 'b0;
        else
            res_r <= res;
    //
    // MULADD muladd_inst(
    //     .A(a),
    //     .B(b),
    //     .C(c),
    //     .Q(res),
    //     .clr(1'b0)
    // );

MULADD #(.signExtension(1'b1)) muladd_inst (
    .A0(a[0]), .A1(a[1]), .A2(a[2]), .A3(a[3]), .A4(a[4]), .A5(a[5]), .A6(a[6]), .A7(a[7]),  // Connecting each bit of operand A
    .B0(b[0]), .B1(b[1]), .B2(b[2]), .B3(b[3]), .B4(b[4]), .B5(b[5]), .B6(b[6]), .B7(b[7]),  // Connecting each bit of operand B
    .C0(c[0]), .C1(c[1]), .C2(c[2]), .C3(c[3]), .C4(c[4]), .C5(c[5]), .C6(c[6]), .C7(c[7]), 
    .C8(c[8]), .C9(c[9]), .C10(c[10]), .C11(c[11]), .C12(c[12]), .C13(c[13]), .C14(c[14]), 
    .C15(c[15]), .C16(c[16]), .C17(c[17]), .C18(c[18]), .C19(c[19]),  // Connecting each bit of operand C

    .Q0(res[0]), .Q1(res[1]), .Q2(res[2]), .Q3(res[3]), .Q4(res[4]), .Q5(res[5]), .Q6(res[6]), .Q7(res[7]),
    .Q8(res[8]), .Q9(res[9]), .Q10(res[10]), .Q11(res[11]), .Q12(res[12]), .Q13(res[13]), .Q14(res[14]), .Q15(res[15]),
    .Q16(res[16]), .Q17(res[17]), .Q18(res[18]), .Q19(res[19]),  // Connecting each bit of the result Q

    .clr(1'b0)  // Clear signal set to 0
);


    assign io_out = {8'b0,res_r}; // pass thru reset for debugging
    // assign io_out = {12'b0,ctr}; // pass thru reset for debugging
    assign io_oeb = 28'b1;
endmodule
