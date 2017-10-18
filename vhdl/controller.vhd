library ieee;
use ieee.std_logic_1164.all;

entity controller is
    port(
        clk        : in  std_logic;
        reset_n    : in  std_logic;
        -- instruction opcode
        op         : in  std_logic_vector(5 downto 0);
        opx        : in  std_logic_vector(5 downto 0);
        -- activates branch condition
        branch_op  : out std_logic;
        -- immediate value sign extention
        imm_signed : out std_logic;
        -- instruction register enable
        ir_en      : out std_logic;
        -- PC control signals
        pc_add_imm : out std_logic;
        pc_en      : out std_logic;
        pc_sel_a   : out std_logic;
        pc_sel_imm : out std_logic;
        -- register file enable
        rf_wren    : out std_logic;
        -- multiplexers selections
        sel_addr   : out std_logic;
        sel_b      : out std_logic;
        sel_mem    : out std_logic;
        sel_pc     : out std_logic;
        sel_ra     : out std_logic;
        sel_rC     : out std_logic;
        -- write memory output
        read       : out std_logic;
        write      : out std_logic;
        -- alu op
        op_alu     : out std_logic_vector(5 downto 0)
    );
end controller;

architecture synth of controller is

type op_state is (FETCH1, FETCH2, DECODE, R_OP, STORE, BREAK, LOAD1, LOAD2, I_OP, BRANCH, CALL, JMP, I_OP_UN, SHIFT_5);
signal state, next_state : op_state;

begin

state_proc : process(clk, reset_n)
begin
	if(reset_n = '0') then
		state <= FETCH1;
	elsif(rising_edge(clk)) then
		state <= next_state;
	end if;
end process;

update_process : process(state)
begin
	branch_op  <= '0';
	imm_signed <= '0';
        ir_en      <= '0';
        pc_add_imm <= '0';
        pc_en      <= '0';
        pc_sel_a   <= '0';
        pc_sel_imm <= '0';
        rf_wren    <= '0';
        sel_addr   <= '0';
        sel_b      <= '0';
        sel_mem    <= '0';
        sel_pc     <= '0';
        sel_ra     <= '0';
        sel_rC     <= '0';
        read       <= '0';
        write      <= '0';

	next_state <= state;
	case state is
		when FETCH1 => next_state <= FETCH2;
			       read <= '1';
		when FETCH2 => next_state <= DECODE;
			       pc_en <= '1';
			       ir_en <= '1';
		when DECODE => if("00"&op = X"3A") then
					if("00"&opx = X"34") then
						 next_state <= BREAK;
						elsif(("00"&opx = X"05") or ("00"&opx = X"0D")) then next_state <= JMP;
						elsif(("00"&opx = X"12") or ("00"&opx = X"1A") or ("00"&opx = X"3A")) then next_state <= SHIFT_5;
						else next_state <= R_OP;
					end if;
			       elsif("00"&op = X"04") then next_state <= I_OP;
			       elsif("00"&op = X"17") then next_state <= LOAD1;
			       elsif("00"&op = X"15") then next_state <= STORE;
			       elsif(("00"&op = X"06") or ("00"&op = X"0E") or ("00"&op = X"16") or ("00"&op = X"1E") or ("00"&op = X"26") or ("00"&op = X"2E") or ("00"&op = X"36")) then next_state <= BRANCH;
			       elsif("00"&op = X"00") then next_state <= CALL;	
			       elsif(("00"&op = X"0C") or ("00"&op = X"14") or ("00"&op = X"1C")) then next_state <= I_OP_UN;

			end if;
		when I_OP => next_state <= FETCH1;
				rf_wren <= '1';
				imm_signed <= '1';
		when I_OP_UN => next_state <= FETCH1;
				rf_wren <= '1';
		when STORE => next_state <= FETCH1;
				sel_addr <= '1';
				-- Pas besoin sel_b
				imm_signed <= '1';
				write <= '1';
		when R_OP => next_state <= FETCH1;	
				rf_wren <= '1';
				sel_b <= '1';
				sel_rc <= '1';
		when BREAK => next_state <= BREAK;
		when LOAD1 => next_state <= LOAD2;
				imm_signed <= '1';
				sel_addr <= '1';
				-- Pas besoin de changer sel_b -> deja initialise a 0
				read <= '1';
		when LOAD2 => next_state <= FETCH1;
				sel_mem <= '1';
				rf_wren <= '1';
				-- Pas besoin de changer sel_rc
		when BRANCH =>  next_state <= FETCH1;
				sel_b <= '1';
				branch_op <= '1';
				pc_add_imm <= '1';
		when CALL => next_state <= FETCH1;
			     sel_ra <= '1';
			     -- sel_rc reste a 0
			     --sel_mem reste a 0
			     sel_pc <= '1';
			     rf_wren <= '1';
		when JMP => next_state <= FETCH1;
			    pc_en <= '1';
			    pc_sel_a <= '1';
		when SHIFT_5 => next_state <= FETCH1;
				rf_wren <= '1';
				--sel_b <= '1';
				sel_rc <= '1';
	end case;
end process;

op_signal: process(op, opx)
begin
	if("00"&op = X"3A") then
		op_alu(2 downto 0) <= opx(5 downto 3);
		case "00"&opx is 
			when X"31" => op_alu(5 downto 3) <= "000";
			when X"39" => op_alu(5 downto 3) <= "001";
			when X"08" | X"10" => op_alu(5 downto 3) <= "011";
			when X"06" | X"0E" | X"16" | X"1E" => op_alu(5 downto 3) <= "10-";
			when X"13" | X"1B" | X"3B" | X"12" | X"1A" | X"3A"=> op_alu(5 downto 3) <= "11-";
			when others => op_alu(5 downto 3) <= "---";
		end case;
	else
		op_alu(2 downto 0) <= op(5 downto 3);
		case "00"&op is
			when X"04" | X"17" | X"15" => op_alu(5 downto 3) <= "000";
			when X"06" => op_alu <= "011100";
			when X"0E" | X"16" | X"1E" | X"26" | X"2E" | X"36" => op_alu(5 downto 3) <= "011";
			when X"0C" | X"14" | X"1C" => op_alu(5 downto 3) <= "10-";
			when others => op_alu(5 downto 3) <= "---";
		end case;
	end if;
end process;

end synth;
