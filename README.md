# Dual-Issue In-Order RISC-V Processor

Created as a self-driven project after studying basics superscalar CPU design, with guidance from a senior during debugging and review. This project implements a dual-issue, in-order RISC-V processor with an extended 5-stage pipeline in VHDL. It supports executing up to two instructions per cycle using FIFO buffering and scoreboard-based scheduling.

## Features

- Dual-issue instruction bundling
- FIFO queue between Decode and Scheduler
- Scoreboard-based dependency checking
- Branch handling with pipeline flush
- Pipeline registers at all stage boundaries

## Structure

- `CPU_Inorder/`: VHDL source files for all modules
- `InOrderProcessor.pdf`: Project reference
- `README.md`: Project summary
