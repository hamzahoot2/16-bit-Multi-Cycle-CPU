-- aux_package.vhd
library ieee;
use ieee.std_logic_1164.all;

package aux_package is
    -----------------------------------------------------------------
    -- Constants & Opcodes
    -----------------------------------------------------------------
    constant OPC_ADD  : std_logic_vector(3 downto 0) := "0000";
    constant OPC_SUB  : std_logic_vector(3 downto 0) := "0001";
    constant OPC_AND  : std_logic_vector(3 downto 0) := "0010";
    constant OPC_OR   : std_logic_vector(3 downto 0) := "0011";
    constant OPC_XOR  : std_logic_vector(3 downto 0) := "0100";
    constant OPC_JMP  : std_logic_vector(3 downto 0) := "0111";
    constant OPC_JC   : std_logic_vector(3 downto 0) := "1000";
    constant OPC_JNC  : std_logic_vector(3 downto 0) := "1001";
    constant OPC_MOV  : std_logic_vector(3 downto 0) := "1100";
    constant OPC_LD   : std_logic_vector(3 downto 0) := "1101";
    constant OPC_ST   : std_logic_vector(3 downto 0) := "1110";
    constant OPC_DONE : std_logic_vector(3 downto 0) := "1111";

    constant ALU_ADD  : std_logic_vector(2 downto 0) := "000";
    constant ALU_SUB  : std_logic_vector(2 downto 0) := "001";
    constant ALU_AND  : std_logic_vector(2 downto 0) := "010";
    constant ALU_OR   : std_logic_vector(2 downto 0) := "011";
    constant ALU_XOR  : std_logic_vector(2 downto 0) := "100";
    constant ALU_PASS : std_logic_vector(2 downto 0) := "111"; 

    -----------------------------------------------------------------
    -- Component Declarations
    -----------------------------------------------------------------
    component ControlUnit is
        port (
            clk, rst, ena : in std_logic;
            OPC : in std_logic_vector(3 downto 0); -- FIXED: Interface bloat removed
            Cflag, Zflag, Nflag : in std_logic;
            PCin, IRin, RFin, RFout, Imm1_in, Imm2_in, Ain, Cin, Cout, DTCM_out, DTCM_addr_in, DTCM_wr : out std_logic;
            RFaddr_wr, RFaddr_rd : out std_logic_vector(1 downto 0);
            PCsel : out std_logic_vector(1 downto 0);
            ALUFN : out std_logic_vector(2 downto 0);
            done : out std_logic
        );
    end component;

    component DataPath is
        port (
            clk, rst : in std_logic;
            PCin, IRin, RFin, RFout, Imm1_in, Imm2_in, Ain, Cin, Cout, DTCM_out, DTCM_addr_in, DTCM_wr : in std_logic;
            RFaddr_wr, RFaddr_rd : in std_logic_vector(1 downto 0);
            PCsel : in std_logic_vector(1 downto 0);
            ALUFN : in std_logic_vector(2 downto 0);
            ITCM_tb_wr, DTCM_tb_wr, TBactive : in std_logic;
            ITCM_tb_in, DTCM_tb_in : in std_logic_vector(15 downto 0);
            ITCM_tb_addr_in, DTCM_tb_addr_in_tb, DTCM_tb_addr_out : in std_logic_vector(5 downto 0);
            OPC_out : out std_logic_vector(3 downto 0); 
            Cflag, Zflag, Nflag : out std_logic;
            DTCM_tb_out : out std_logic_vector(15 downto 0);
            IOpin : inout std_logic_vector(15 downto 0)
        );
    end component;

    component RF is
        generic( Dwidth: integer:=16; Awidth: integer:=4);
        port( clk, rst, WregEn: in std_logic; WregData: in std_logic_vector(Dwidth-1 downto 0);
              WregAddr, RregAddr: in std_logic_vector(Awidth-1 downto 0);
              RregData: out std_logic_vector(Dwidth-1 downto 0));
    end component;

    component ProgMem is
        generic( Dwidth: integer:=16; Awidth: integer:=6; dept: integer:=64);
        port( clk, memEn: in std_logic; WmemData: in std_logic_vector(Dwidth-1 downto 0);
              WmemAddr, RmemAddr: in std_logic_vector(Awidth-1 downto 0);
              RmemData: out std_logic_vector(Dwidth-1 downto 0));
    end component;

    component dataMem is
        generic( Dwidth: integer:=16; Awidth: integer:=6; dept: integer:=64);
        port( clk, memEn: in std_logic; WmemData: in std_logic_vector(Dwidth-1 downto 0);
              WmemAddr, RmemAddr: in std_logic_vector(Awidth-1 downto 0);
              RmemData: out std_logic_vector(Dwidth-1 downto 0));
    end component;
    
    
end aux_package;