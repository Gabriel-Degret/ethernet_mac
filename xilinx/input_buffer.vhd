library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;

library ethernet_mac;

entity input_buffer is
	generic(
		HAS_DELAY    : boolean                := FALSE;
		IDELAY_VALUE : natural range 0 to 255 := 0
	);
	port(
		pad_i    : in  std_ulogic;
		buffer_o : out std_ulogic;

		clock_i  : in  std_ulogic
	);
end entity;

architecture spartan_6 of input_buffer is
	signal delayed : std_ulogic := '0';

	-- Force putting input Flip-Flop into IOB so it doesn't end up in a normal logic tile
	-- which would ruin the timing.
	attribute iob : string;
	attribute iob of FDRE_inst : label is "FORCE";
begin
	delay_gen : if HAS_DELAY = TRUE generate
		fixed_input_delay_inst : entity ethernet_mac.fixed_input_delay
			generic map(
				IDELAY_VALUE => IDELAY_VALUE
			)
			port map(
				pad_i     => pad_i,
				delayed_o => delayed
			);
	end generate;

	no_delay_gen : if HAS_DELAY = FALSE generate
		delayed <= pad_i;
	end generate;

	FDRE_inst : FDRE
		generic map(
			INIT => '0')                -- Initial value of register ('0' or '1')  
		port map(
			Q  => buffer_o,             -- Data output
			C  => clock_i,              -- Clock input
			CE => '1',                  -- Clock enable input
			R  => '0',                  -- Synchronous reset input
			D  => delayed               -- Data input
		);

end architecture spartan_6;
