-- top.vhd
library ieee;
use ieee.std_logic_1164.all;
use work.aux_package.all;

entity top is
    port (
        clk, rst, ena : in std_logic;
        TBactive : in std_logic;
        ITCM_tb_wr, DTCM_tb_wr : in std_logic;
        ITCM_tb_in, DTCM_tb_in : in std_logic_vector(15 downto 0);
        ITCM_tb_addr_in, DTCM_tb_addr_in_tb, DTCM_tb_addr_out : in std_logic_vector(5 downto 0);
        done : out std_logic;
        DTCM_tb_out : out std_logic_vector(15 downto 0);
        IOpin : inout std_logic_vector(15 downto 0)
    );
end top;

architecture struct of top is
    signal OPC_s : std_logic_vector(3 downto 0); 
    signal C_s, Z_s, N_s : std_logic;
    signal PCin_s, IRin_s, RFin_s, RFout_s : std_logic;
    signal Imm1_in_s, Imm2_in_s, Ain_s, Cin_s, Cout_s : std_logic;
    signal DTCM_out_s, DTCM_addr_in_s, DTCM_wr_s : std_logic;
    signal RFaddr_wr_s, RFaddr_rd_s : std_logic_vector(1 downto 0);
    signal PCsel_s : std_logic_vector(1 downto 0);
    signal ALUFN_s : std_logic_vector(2 downto 0);

begin

    CU: ControlUnit port map (
        clk => clk, rst => rst, ena => ena,
        OPC => OPC_s,
        Cflag => C_s, Zflag => Z_s, Nflag => N_s,
        PCin => PCin_s, PCsel => PCsel_s, IRin => IRin_s,
        RFaddr_wr => RFaddr_wr_s, RFaddr_rd => RFaddr_rd_s,
        RFin => RFin_s, RFout => RFout_s,
        Imm1_in => Imm1_in_s, Imm2_in => Imm2_in_s,
        Ain => Ain_s, ALUFN => ALUFN_s,
        Cin => Cin_s, Cout => Cout_s,
        DTCM_out => DTCM_out_s, DTCM_addr_in => DTCM_addr_in_s, DTCM_wr => DTCM_wr_s,
        done => done
    );

    DP: DataPath port map (
        clk => clk, rst => rst,
        PCin => PCin_s, PCsel => PCsel_s, IRin => IRin_s,
        RFaddr_wr => RFaddr_wr_s, RFaddr_rd => RFaddr_rd_s,
        RFin => RFin_s, RFout => RFout_s,
        Imm1_in => Imm1_in_s, Imm2_in => Imm2_in_s,
        Ain => Ain_s, ALUFN => ALUFN_s,
        Cin => Cin_s, Cout => Cout_s,
        DTCM_out => DTCM_out_s, DTCM_addr_in => DTCM_addr_in_s, DTCM_wr => DTCM_wr_s,
        ITCM_tb_wr => ITCM_tb_wr, DTCM_tb_wr => DTCM_tb_wr, TBactive => TBactive,
        ITCM_tb_in => ITCM_tb_in, DTCM_tb_in => DTCM_tb_in,
        ITCM_tb_addr_in => ITCM_tb_addr_in, 
        DTCM_tb_addr_in_tb => DTCM_tb_addr_in_tb, 
        DTCM_tb_addr_out => DTCM_tb_addr_out,
        OPC_out => OPC_s,
        Cflag => C_s, Zflag => Z_s, Nflag => N_s,
        DTCM_tb_out => DTCM_tb_out,
        IOpin => IOpin
    );

end struct;