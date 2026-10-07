
`ifndef PARAM_CHECKS_SVH
`define PARAM_CHECKS_SVH

// Check if parameter >= value
`define CHECK_GREATER_EQUAL(PARAM, MIN_VALUE) \
    initial begin \
        if ((PARAM) < (MIN_VALUE)) \
            $fatal(1, "Error: %s must be >= %0d. Current value = %0d", \
                    `"PARAM`", (MIN_VALUE), (PARAM)); \
    end

// Check if parameter > value
`define CHECK_GREATER_THAN(PARAM, MIN_VALUE) \
    initial begin \
        if ((PARAM) <= (MIN_VALUE)) \
            $fatal(1, "Error: %s must be > %0d. Current value = %0d", \
                    `"PARAM`", (MIN_VALUE), (PARAM)); \
    end

// Check if parameter <= value
`define CHECK_LESS_EQUAL(PARAM, MAX_VALUE) \
    initial begin \
        if ((PARAM) > (MAX_VALUE)) \
            $fatal(1, "Error: %s must be <= %0d. Current value = %0d", \
                    `"PARAM`", (MAX_VALUE), (PARAM)); \
    end

// Check if parameter < value
`define CHECK_LESS_THAN(PARAM, MAX_VALUE) \
    initial begin \
        if ((PARAM) >= (MAX_VALUE)) \
            $fatal(1, "Error: %s must be < %0d. Current value = %0d", \
                    `"PARAM`", (MAX_VALUE), (PARAM)); \
    end

// Check is parameter is power of two
`define CHECK_POWER_OF_TWO(PARAM) \
    initial begin \
        if (((PARAM) < 1) || (((PARAM) & ((PARAM) - 1)) != 0)) \
            $fatal(1, "Error: %s must be a positive power of two. Current value = %0d", \
                    `"PARAM`", (PARAM)); \
    end

// Declare a set_parameter to $clog2(compared_parameter) if compared_param > 1
//      else declare it as 1.
// Covers the unwanted case of $clog(1) = 0
`define DECLARE_CLOG2_MIN_ONE(SET_PARAM, COMP_PARAM) \
    localparam int SET_PARAM = ((COMP_PARAM) > 1) ? $clog2(COMP_PARAM) : 1;

`endif // PARAM_CHECKS_SVH


// Example call: `CHECK_GREATER_EQUAL(DEPTH, 2)
//      No need for semicolon since macro already includes it
