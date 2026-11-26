# Startup compute FP32 3D image store (translation only)

Refs [#1545](https://github.com/R0Y00/Xbox2Windows/issues/1545).
Builds on the 2D-array store lowering in
[#2744](https://github.com/R0Y00/Xbox2Windows/pull/2744).

`tools/startup/gfx2hlsl.py` lowers a compute `image_store` on
`dim:SQ_RSRC_IMG_3D` when the mask is `dmask:0xf`, the data is four full-width
VGPRs, the address is three full-width VGPRs (x, y, z) and the descriptor comes
from an unmodified fixed table offset. The address may be one contiguous range
or a non-contiguous NSA list. The translator emits
`w0[uint3(x, y, z)] = asfloat(uint4(...))` into an `RWTexture3D<float4>` under
the lane EXEC bit and writes `uav N tex3d float table P O channels 4` in the
version 2 manifest.

Still refused: partial `dmask`, `d16`, `a16`, 1D, cube and the pixel stage.

The startup runtime does not bind a volume UAV. The manifest consumer in
`src/startup_stubs/d3d12_compute_dispatch.inl` accepts only `tex2d` and `tex2da`
UAV lines and refuses a `tex3d` line with the reason "an output that is not a
raw table buffer or a 2D/2D-array float texture". This note therefore pins the
translation only. No dispatch has been run and no HLSL has been compiled by DXC
for this form.

```powershell
python -B tests/startup_compute_image_store_check.py
```

The check assembles a contiguous and an NSA program with z = 2 (middle of a
four-deep range) and z = 3 (last entry), compares the HLSL and manifest, and
requires each of four mutations (store omitted, z off by one, z dropped, bound
as a 2D array) to fail the same comparison. Pass `--llvm-mc` to also compare the
encodings with LLVM 15.
