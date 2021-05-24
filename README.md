KEY NOTES OF THE PROJECT


1. Please check the design for not having multi egde trigerred sensitivity list. Yosys threw error for instances used with always @(posedge clk or posedge rst).
2. keep the design consistent throughout with triggering with same signal or else it confuses the tool if a sequentially generated value triggers any other sequential block.
3. Remember the Yosys ccommands to be executed in order. Use the attached .lib file as it is very basic and easy to understand for the purpose.

Commands for Yosys: 
step 0.  yosys : it will start the yosys tool.
1. read_verilog <designName.v> : Reads the verilog file and converts in the format usable by yosys
2. hierarchy -check -top <moduleName> : Elaborates the design hierarchy and picks out the mentioned module for synthesis
3. proc; opt; : converts behavioural models into high level design modules like comaprators, muxs, adders etc. and optimises it.
4. fsm; opt; : Analyse and optimise the fsm in the design.
5. memory; opt; : Converts the memory component in the design to dff or dffsr based on the requirement.
6. techmap; opt; : converts the coarse grain RTL cells to fine grain logic cells like NAND, NOR, etc. [IMPORTANT: These fine grain cells are highly dependent on the .lib and constituent cells]
4. dfflibmap -liberty <libetyFile.lib> : Pass the liberty file containing the dff cell. Maps the seq components to the dff provided.
5. abc -liberty <libertyFile.lib> : Pass the liberty file containing the comb cell. Maps the comb components to the dff provided.
6. clean : cleans up the unused wires and components. Check here for the elements removed. If the tool has produced a wrong mapping, then it'll drive the output to the constant value and remove all the other components except the input pins.
7. write_verilog <filename.v> :  Dumps the generated code in a verilog file.
Step 0+. exit: exits the yosys tool and takes back to terminal.


Requirements:
Make sure Yosys is installed. 
Commands to follow if not installed
	1. sudo add-apt-repository ppa:saltmakrell/ppa
	2. sudo apt-get update 
	3. sudo apt-get install yosys
	
The Script should work fine for most of the designs in Verilog. Exceptions: Memory models, complex hierarchy, designs with false paths, multi clock designs.
Run Steps:

1. Name clock as clk and reset as rst in design.
2. Execute chmod +x script.tcl
3. ./script.tcl <DesignName.v> <libFile.lib> <name_of_top_module_in_design>

Area can be changed in the cells.lib file.
propagation delay of cells can be changed in "text.cpp" with the following statements in main():
	1. tpd["NOT"] = <Value>;
	2. tpd["NAND"] = <Value>;
	3. tpd["NOR"]=<Value>;
The flop values can be changed in "text.cpp" with the following statements in main():
	1. dff[0] =1;//tsetup
	2. dff[1] =1;//thold
	3. dff[2] =0.1;//c->q
Put the desired values here.


Some Screenshots:
  
  
  <img width="503" alt="Expected" src="https://user-images.githubusercontent.com/39923808/119357511-48269780-bcc5-11eb-9803-254c2e25f777.PNG">
  
  
<img width="367" alt="Capture" src="https://user-images.githubusercontent.com/39923808/119363966-0b11d380-bccc-11eb-9912-97b8b1a3f16d.PNG">


