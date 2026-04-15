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

This is especially relevant for arithmetic libraries that rely on floating-point operators. In the current U50 flow, the repository provides a generation path for pre-built floating-point IP cores under `core/u50/`. At the moment, the helper script targets the U50 part `xcu50-fsvh2104-2-e` and generates the single-precision operators expected by the current `Float32` flow, including:

- `fp_add32`
- `fp_sub32`
- `fp_mult32`
- `fp_div32`
- `fp_sqrt32`
- `fp_fma32`
- `fp_exp32`

More generally, this pre-generated core flow should be thought of as a reusable mechanism for vendor-backed arithmetic or utility blocks. Today it is used for 32-bit floating-point operators, and it can be extended later for other families of cores as needed, such as 64-bit floating-point operators or other platform-specific IP-backed modules.

## Generating the U50 Core Set

If your design depends on these pre-generated cores, generate them first:

```bash
cd core
bash gen-u50.sh
```

This script removes the existing `u50/` directory and launches Vivado in batch mode with `synth-fp-u50.tcl`. The generated IP is placed under `core/u50/`.

After a successful run, you should expect a directory structure similar to:

```text
core/
  u50/
    fp_add32/
    fp_sub32/
    fp_mult32/
    fp_div32/
    fp_sqrt32/
    fp_fma32/
    fp_exp32/
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

This repository includes `core/fp_import.tcl`, which provides an `addFpCores` helper for importing the generated floating-point IP cores into the current project. Its intended use is in a packaging flow where RTL is added first and the generated `.xci` files are imported before compile-order update and IP packaging.

## Notes

- The current U50 generation helper is focused on the floating-point cores used by the existing 32-bit floating-point library flow.
- The same general mechanism can be reused for future pre-generated core families.
- Good candidates for future extensions include:
  - 64-bit floating-point operator cores
  - conversion operators between floating-point and fixed-point formats
  - CORDIC-style math cores
  - other reusable arithmetic or utility IP needed by platform-specific hardware flows

## Summary

`bluelibrary` is meant to be more than a collection of BSV source files. It is also a place to keep the supporting generation and integration flow needed for practical AMD FPGA development.

If a module depends on pre-generated vendor IP, generate the required cores first, then make sure those generated cores are imported into the packaging or synthesis flow that consumes them.
