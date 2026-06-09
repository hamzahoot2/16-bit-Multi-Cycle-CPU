-- DataPath.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.aux_package.all;

entity DataPath is
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
end DataPath;

architecture struct of DataPath is
    signal PC, IR : std_logic_vector(15 downto 0);
    signal Reg_A, Reg_C, ALU_Out, Bus_Wire : std_logic_vector(15 downto 0);
    signal ADDR_Reg_Out : std_logic_vector(5 downto 0);
    signal RF_Data_Out, DTCM_Data_Out, ITCM_Data_Out : std_logic_vector(15 downto 0);
    signal RF_W_Addr, RF_R_Addr : std_logic_vector(3 downto 0);
    signal mux_memEn    : std_logic;
    signal mux_WmemData : std_logic_vector(15 downto 0);
    signal mux_WmemAddr : std_logic_vector(5 downto 0);
    signal mux_RmemAddr : std_logic_vector(5 downto 0);
    signal ALU_Sum_Temp : std_logic_vector(16 downto 0); 

    alias ra   : std_logic_vector(3 downto 0) is IR(11 downto 8);
    alias rb   : std_logic_vector(3 downto 0) is IR(7 downto 4);
    alias rc   : std_logic_vector(3 downto 0) is IR(3 downto 0);
    alias imm8 : std_logic_vector(7 downto 0) is IR(7 downto 0);
    alias imm4 : std_logic_vector(3 downto 0) is IR(3 downto 0);

begin

    OPC_out <= IR(15 downto 12); 

    RF_W_Addr <= ra when RFaddr_wr="00" else rb when RFaddr_wr="01" else rc;
    RF_R_Addr <= ra when RFaddr_rd="00" else rb when RFaddr_rd="01" else rc;

    RF_inst: RF port map(
        clk => clk, rst => rst, WregEn => RFin,
        WregData => Bus_Wire, WregAddr => RF_W_Addr, 
        RregAddr => RF_R_Addr, RregData => RF_Data_Out
    );

    process(clk, rst)        -- Flags Logic
    begin
        if rst = '1' then
            Cflag <= '0'; Zflag <= '0'; Nflag <= '0';
        elsif rising_edge(clk) then
            if Cin = '1' then
                if ALU_Out = "0000000000000000" then Zflag <= '1'; else Zflag <= '0'; end if;
                Nflag <= ALU_Out(15);
                if ALUFN = ALU_ADD then
                    Cflag <= ALU_Sum_Temp(16); -- FIXED: Taps into the combinational unified adder
                elsif ALUFN = ALU_SUB then
                    if Reg_A < Bus_Wire then Cflag <= '0'; else Cflag <= '1'; end if;
                end if;
            end if;
        end if;
    end process;

    process(clk, rst) begin     -- PC Logic
        if  rst = '1'  then PC <= (others => '0');
        elsif rising_edge(clk) then
            if PCin = '1' then
                if PCsel = "00" then PC <= PC + 1;
                elsif PCsel = "01" then PC <= PC + SXT(imm8, 16);
                else PC <= (others => '0');
                end if;
            end if;
        end if;
    end process;

    ITCM: ProgMem port map(
        clk => clk, memEn => ITCM_tb_wr, WmemData => ITCM_tb_in,
        WmemAddr => ITCM_tb_addr_in, RmemAddr => PC(5 downto 0),
        RmemData => ITCM_Data_Out
    );

    mux_memEn    <= DTCM_wr when TBactive = '0' else DTCM_tb_wr;
    mux_WmemData <= Bus_Wire when TBactive = '0' else DTCM_tb_in;
    mux_WmemAddr <= ADDR_Reg_Out when TBactive = '0' else DTCM_tb_addr_in_tb;
    mux_RmemAddr <= Bus_Wire(5 downto 0) when TBactive = '0' else DTCM_tb_addr_out;

    DTCM: dataMem port map(
        clk => clk, memEn => mux_memEn, WmemData => mux_WmemData,
        WmemAddr => mux_WmemAddr, RmemAddr => mux_RmemAddr,
        RmemData => DTCM_Data_Out
    );

    DTCM_tb_out <= DTCM_Data_Out;

    process(clk) begin   
        if rising_edge(clk) then
            if IRin='1' then IR <= ITCM_Data_Out; end if;  
            if Ain='1' then Reg_A <= Bus_Wire; end if;     
            if Cin='1' then Reg_C <= ALU_Out; end if;      
            if DTCM_addr_in='1' then ADDR_Reg_Out <= Bus_Wire(5 downto 0); end if; 
        end if;
    end process;

    process(ALUFN, Reg_A, Bus_Wire)     -- ALU
        variable sum_temp : std_logic_vector(16 downto 0);
    begin
        -- Unified addition for both Data and Flags
        sum_temp := ('0' & Reg_A) + ('0' & Bus_Wire);
        ALU_Sum_Temp <= sum_temp; 

        case ALUFN is
            when ALU_ADD => ALU_Out <= sum_temp(15 downto 0); 
            when ALU_SUB => ALU_Out <= Reg_A - Bus_Wire;
            when ALU_AND => ALU_Out <= Reg_A and Bus_Wire;
            when ALU_OR  => ALU_Out <= Reg_A or Bus_Wire;
            when ALU_XOR => ALU_Out <= Reg_A xor Bus_Wire;
            when others  => ALU_Out <= Bus_Wire; 
        end case;
    end process;

    IOpin <= RF_Data_Out    when RFout='1'      else 
             SXT(imm8, 16)  when Imm1_in='1'    else 
             SXT(imm4, 16)  when Imm2_in='1'    else 
             Reg_C          when Cout='1'       else 
             DTCM_Data_Out  when DTCM_out='1'   else 
             (others=>'Z');

    Bus_Wire <= IOpin;
end struct;