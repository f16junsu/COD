`define PERIOD1 100
`define READ_DELAY 30 // delay before memory data is ready
`define WRITE_DELAY 30 // delay in writing to memory
`define MEMORY_SIZE 256 // size of memory is 2^8 words (reduced size)
`define WORD_SIZE 16 // instead of 2^16 words to reduce memory
`define LINE_SIZE 64 // 64 bits for a single cache line
`define TAG_SIZE 12 // 12 bits for tag

`define NUM_TEST 56
`define TESTID_SIZE 5

`define IDLE 16'hbfff