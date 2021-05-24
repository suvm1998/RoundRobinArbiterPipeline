module arbiter(a, b, c, d, clk, rst, out);
wire [1:0] _00_;
wire _01_;
wire _02_;
wire _03_;
wire _04_;
wire _05_;
wire _06_;
wire _07_;
wire _08_;
wire _09_;
wire _10_;
wire _11_;
wire _12_;
wire _13_;
input a;
input b;
input c;
input clk;
wire [1:0] counter;
input d;
output out;
input rst;
NOT _14_ (.A(counter[0]),.Y(_00_[0]));
NOT _15_ (.A(counter[1]),.Y(_02_));
NOT _16_ (.A(b),.Y(_03_));
NAND _17_ (.A(counter[0]),.B(_02_),.Y(_04_));
NOR _18_ (.A(_03_),.B(_04_),.Y(_05_));
NAND _19_ (.A(counter[1]),.B(d),.Y(_06_));
NOR _20_ (.A(_00_[0]),.B(_06_),.Y(_07_));
NOR _21_ (.A(_05_),.B(_07_),.Y(_08_));
NOR _22_ (.A(_02_),.B(c),.Y(_09_));
NOR _23_ (.A(counter[1]),.B(a),.Y(_10_));
NOR _24_ (.A(_09_),.B(_10_),.Y(_11_));
NAND _25_ (.A(_00_[0]),.B(_11_),.Y(_12_));
NAND _26_ (.A(_08_),.B(_12_),.Y(_01_));
NAND _27_ (.A(_00_[0]),.B(counter[1]),.Y(_13_));
NAND _28_ (.A(_04_),.B(_13_),.Y(_00_[1]));
DFF _29_ (.C(clk),.D(_00_[0]),.Q(counter[0]));
DFF _30_ (.C(clk),.D(_00_[1]),.Q(counter[1]));
DFF _31_ (.C(clk),.D(_01_),.Q(out));
endmodule