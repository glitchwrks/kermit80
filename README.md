KERMIT for CP/M-80
------------------

This is a work in progress for the cleanup of KERMIT-80 code, starting with the last public release, v4.11.

See `cpxmit.asm` for an example of how to implement a basic system-dependent I/O module.

Until further notice, it's probably best to use the [Official Columbia CP/M Kermit files](http://www.columbia.edu/kermit/cpm.html) -- the files contained in this repository may be broken.

A85 RESTRUCTURE BRANCH
----------------------

This branch is a work in progress, on top of a work in progress. It contains current efforts to restructure Kermit-80 to use a more typical style of depdencency INCLUDEs, instead of the mess required to get it working with LASM. A modified version of William Colley's A85 8085 cross-assembler is being used for this process.

The linkage between the main KERMIT module and the overlays remains unchanged, so restructured overlays will still MLOAD with the unmodified CPSKER.HEX file.
