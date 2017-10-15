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

type op_state is (FETCH1, FETCH2, DECODE, R_OP, STORE, BREAK, LOAD1, LOAD2, I_OP);
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
						else next_state <= R_OP;
					end if;
			       elsif("00"&op = X"04") then next_state <= I_OP;
			       elsif("00"&op = X"17") then next_state <= LOAD1;
			       elsif("00"&op = X"15") then next_state <= STORE;
			end if;
		when I_OP => next_state <= FETCH1;
				rf_wren <= '1';
				imm_signed <= '1';
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

	end case;
end process;

op_signal: process(op, opx)
begin

end process;

end synth;
