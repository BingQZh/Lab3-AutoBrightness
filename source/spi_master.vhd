----------------------------------------------------------------------------------
-- Course: ENSC462
-- Group #: 9 
-- Engineer: Valeriya Svichkar and Bing Qiu Zhang

-- Module Name: spi_master - rtl
-- Project Name: Lab3
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spi_master is
    generic (
        clk_hz : integer; -- := 100e6; --FPGA clock
        total_bits : integer; -- := 16; --total bits tx by sensor chip
        leading_z : integer; -- := 3;
        trailing_z : integer; --  := 4;
        sclk_hz : integer); -- := 4e6); --sensor’s frequency 
    port (
        --fpga system
        clk : in std_logic;
        rst : in std_logic;

        -- slave chip
        cs : out std_logic; -- slave select: master uses this to select an available slave
                            -- cs = '1' : slave chip is idle and master can control
                            -- cs = '0' : slave chip is busy
        sclk : out std_logic; -- sclk is high when cs is '1'
        miso : in std_logic; -- data is written on falling edge of sclk and read on rising edge of sclk

        -- Internal interface when obtaining data back from slave chip
        ready : in std_logic;
        valid : out std_logic;
        data : out std_logic_vector(total_bits-leading_z-trailing_z-2 downto 0));
end spi_master;

architecture rtl of spi_master is

    constant sclk_period : time := 1 sec / sclk_hz;

    signal miso_ff1, miso_ff2, miso_ff3, valid_miso : std_logic := '0';
    type STATES is (IDLE, TRANSMISSION); -- FSM states
    signal Master_State : STATES := IDLE;

    signal temp_data : std_logic_vector(total_bits-leading_z-trailing_z-2 downto 0) := (others => '0');
    signal i : integer range 0 to total_bits-leading_z-trailing_z-1 := total_bits-leading_z-trailing_z-1;

    signal sclk_counter : integer range 0 to total_bits := 0;
    signal prev_sclk, temp_sclk : std_logic;

    function Rising_Edge_Check(FF2 : std_logic;
            FF3 : std_logic) return std_logic is
        variable result : std_logic;
    begin
        if FF3 = '1' and FF2 = '0' then
            result := '1';
        else
            result := '0';
        end if;
        return result;
    end function;

begin

    SYNCHRONIZER: process(clk)
    begin

        if rising_edge(clk) then
            if rst = '1' then
                miso_ff1 <= '0';
                miso_ff2 <= '0';
                miso_ff3 <= '0';
                valid_miso <= '0';
            else
                miso_ff1 <= miso;
                miso_ff2 <= miso_ff1;
                miso_ff3 <= miso_ff2;
                valid_miso <= miso_ff3;
            end if;
        end if;
    end process;

    MASTER_PROC: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                Master_State <= IDLE;
                data <= (others => '0');
                sclk <= '0';
                temp_sclk <= '0';
                prev_sclk <= '0';
                cs <= '1';
                temp_data <= (others => '0');
                i <= total_bits-leading_z-trailing_z-1;
                valid <= '0';
                sclk_counter <= 0;
            else
            
                case Master_State is

                    when IDLE =>
                        -- IDLE when ready is 0
                        -- in IDLE set:
                        --      sclk to high
                        --      cs to high
                        sclk <= '1';
                        temp_sclk <= '1';
                        prev_sclk <= temp_sclk;
                        cs <= '1';
                        if ready = '1' then
                            Master_State <= TRANSMISSION;
                        end if;

                    when TRANSMISSION =>
                        -- TRANSMISSION when ready pulsed

                        -- Generate sclk:
                        prev_sclk <= temp_sclk;
                        sclk <= not temp_sclk after sclk_period / 2;
                        temp_sclk <= not temp_sclk after sclk_period / 2;

                        -- set cs to low:
                        cs <= '0';

                        -- the following if statement checks if data is ready to output!
                        if i = 0 then
                            data <= temp_data;
                            i <= total_bits-leading_z-trailing_z-1;
                            valid <= '1';
                        else
                            valid <= '0';
                        end if;

                        -- read inputs when sclk rising edge
                        if Rising_Edge_Check(prev_sclk, temp_sclk) = '1' then -- rising edge of sclk
                            -- wait for leading zeros:
                            if sclk_counter < leading_z+1 then
                                sclk_counter <= sclk_counter + 1;
                            else
                                -- read data before trailing zeros
                                if sclk_counter < total_bits-trailing_z then
                                    temp_data(i-1) <= valid_miso;
                                    i <= i - 1;
                                    sclk_counter <= sclk_counter + 1;
                                else
                                    -- wait for trailing zeros
                                    if sclk_counter < total_bits then
                                        sclk_counter <= sclk_counter + 1;
                                    else
                                        -- all bits are read and return to idle!
                                        sclk_counter <= 0;
                                        sclk <= '1';
                                        Master_State <= IDLE;
                                    end if;
                                end if;
                            end if;
                        end if;

                end case;
            end if;
        end if;
    end process;

end architecture;