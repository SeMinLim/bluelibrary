# bluelibrary

An extended collection of high-performance **Bluespec SystemVerilog (BSV)** and **Verilog** libraries tailored for modern AMD FPGA architectures.

## About This Repository

The standard Bluespec library is powerful, but it does not always provide direct access to vendor-specific hardware features or reusable wrappers for platform-oriented implementation flows.

`bluelibrary` collects custom BSV modules, Verilog helpers, and vendor-backed wrappers that are intended to be practical building blocks for AMD FPGA development. The goal is to keep the libraries easy to integrate while still exposing hardware features that are often needed in real accelerator designs.

## Repository Layout

- `bsv/`  
  Bluespec packages and drop-in hardware-oriented library modules

- `verilog/`  
  Supporting Verilog implementations and wrappers

- `core/`  
  Scripts and generated vendor IP used by hardware build flows

## Pre-generated Vendor IP Cores

Some modules in this repository depend on **vendor IP cores that must be generated before hardware builds**.

This pre-generated core flow should be thought of as a reusable mechanism for vendor-backed arithmetic or utility blocks. Today it is used for 32-bit and 64-bit floating-point operators, and it can be extended later for other families of cores as needed, such as other platform-specific IP-backed modules.

## Generating the U50 Core Set

If your design depends on these pre-generated cores, generate them first:

```bash
cd core
bash gen-u50.sh
```

## When You Should Run Core Generation

Run the core-generation step when:

- you are building hardware that depends on vendor-backed arithmetic modules
- you cloned the repository into a fresh environment
- generated IP artifacts were removed by cleanup
- your packaging or XO build flow expects `.xci` files to already exist

In other words, if your design uses modules backed by generated vendor IP, treat core generation as a required setup step before synthesis or packaging.

## Importing Generated Cores into a Build Flow

Generating the cores is only the first step. If your Vivado or Vitis packaging flow expects these IP blocks, the generated `.xci` files must also be imported into the active project.

For example, this repository includes `core/fp_import.tcl`, which provides an `addFpCores` helper for importing the generated floating-point IP cores into the current project. Its intended use is in a packaging flow where RTL is added first and the generated `.xci` files are imported before compile-order update and IP packaging.

## Notes

