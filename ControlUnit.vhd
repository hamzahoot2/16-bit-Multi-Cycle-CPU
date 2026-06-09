-- ControlUnit.vhd
library ieee;
use ieee.std_logic_1164.all;
use work.aux_package.all;

entity ControlUnit is
    port (
        clk, rst, ena : in std_logic;
        OPC : in std_logic_vector(3 downto 0);
        Cflag, Zflag, Nflag : in std_logic;
        PCin, IRin, RFin, RFout, Imm1_in, Imm2_in, Ain, Cin, Cout, DTCM_out, DTCM_addr_in, DTCM_wr : out std_logic;
        RFaddr_wr, RFaddr_rd : out std_logic_vector(1 downto 0);
        PCsel : out std_logic_vector(1 downto 0);
        ALUFN : out std_logic_vector(2 downto 0);
        done : out std_logic
    );
end ControlUnit;

architecture behavioral of ControlUnit is
    type state is (FETCH, DEC1, R_EX, R_WB, I_DEC2, I_AG, I_MW_WB, I_WB);
    signal pr_state, nx_state : state;
begin
    process(clk, rst) begin
        if rst = '1' then
            pr_state <= FETCH;
        elsif rising_edge(clk) then
            if ena = '1' then
                pr_state <= nx_state;
            end if;
        end if;
    end process;

    process(pr_state, OPC, Cflag) 
    begin
        -- Default assignments
        PCin <= '0'; IRin <= '0'; RFin <= '0'; RFout <= '0'; 
        Imm1_in <= '0'; Imm2_in <= '0'; Ain <= '0';
        Cin <= '0'; Cout <= '0'; DTCM_out <= '0'; 
        DTCM_addr_in <= '0'; DTCM_wr <= '0'; done <= '0';
        PCsel <= "00"; RFaddr_rd <= "00"; RFaddr_wr <= "00"; 
        ALUFN <= ALU_PASS; 
        
        nx_state <= pr_state;

        case pr_state is
            when FETCH =>
                IRin <= '1'; PCin <= '1'; 
                nx_state <= DEC1;

            when DEC1 =>
                if (OPC=OPC_ADD or OPC=OPC_SUB or OPC=OPC_AND or OPC=OPC_OR or OPC=OPC_XOR) then 
                    RFaddr_rd <= "01"; RFout <= '1'; Ain <= '1'; 
                    nx_state <= R_EX;
                elsif (OPC=OPC_LD or OPC=OPC_ST) then 
                    RFaddr_rd <= "01"; RFout <= '1'; Ain <= '1';  
                    nx_state <= I_DEC2;
                elsif OPC=OPC_JMP or (OPC=OPC_JC and Cflag='1') or (OPC=OPC_JNC and Cflag='0') then
                    PCsel <= "01"; PCin <= '1'; 
                    nx_state <= FETCH;
                elsif OPC=OPC_MOV then 
                    Imm1_in <= '1'; Cin <= '1';      
                    nx_state <= R_WB;
                elsif OPC=OPC_DONE then 
                    done <= '1'; nx_state <= FETCH;
                else 
                    nx_state <= FETCH;
                end if;

            when R_EX =>
                RFaddr_rd <= "10"; RFout <= '1';  
                if OPC=OPC_ADD then ALUFN <= ALU_ADD;
                elsif OPC=OPC_SUB then ALUFN <= ALU_SUB;
                elsif OPC=OPC_AND then ALUFN <= ALU_AND; 
                elsif OPC=OPC_OR then ALUFN <= ALU_OR;
                else ALUFN <= ALU_XOR; end if;
                Cin <= '1'; 
                nx_state <= R_WB;

            when R_WB =>
                Cout <= '1'; RFaddr_wr <= "00"; RFin <= '1'; 
                nx_state <= FETCH;

            when I_DEC2 =>
                Imm2_in <= '1'; ALUFN <= ALU_ADD; Cin <= '1'; 
                nx_state <= I_AG;

            when I_AG =>
                Cout <= '1'; DTCM_addr_in <= '1';  
                nx_state <= I_MW_WB;

            when I_MW_WB =>
                if OPC = OPC_LD then
                    Cout <= '1'; nx_state <= I_WB;
                else
                    RFaddr_rd <= "00"; RFout <= '1'; DTCM_wr <= '1'; 
                    nx_state <= FETCH;
                end if;

            when I_WB =>
                DTCM_out <= '1'; RFaddr_wr <= "00"; RFin <= '1';
                nx_state <= FETCH;
        end case;
    end process;
end behavioral;