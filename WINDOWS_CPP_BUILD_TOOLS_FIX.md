# Windows C++ Build Tools Issue - Solutions

## Problem

When installing `nemo-toolkit[asr]` on Windows, two packages fail to compile:
- `ctc_segmentation==1.7.4`
- `texterrors<1.0.0`

**Error:**
```
error: Microsoft Visual C++ 14.0 or greater is required.
Get it with "Microsoft C++ Build Tools": https://visualstudio.microsoft.com/visual-cpp-build-tools/
```

## Root Cause

These packages contain C/C++ extensions that must be compiled during installation. Windows doesn't include a C compiler by default, unlike Linux/macOS.

## Solutions (Choose One)

### Solution 1: Install Microsoft C++ Build Tools (Recommended)

**Pros:** Official solution, works for all packages
**Cons:** Large download (~7GB), requires admin rights

**Steps:**

1. Download Visual Studio Build Tools:
   https://visualstudio.microsoft.com/visual-cpp-build-tools/

2. Run the installer

3. Select "Desktop development with C++"

4. Install (requires ~7GB disk space)

5. Restart your terminal

6. Re-run the installation:
   ```cmd
   install_windows_corporate.bat
   ```

### Solution 2: Use Pre-Built Wheels from Unofficial Repository

**Pros:** No compiler needed, faster
**Cons:** Unofficial source, may not have latest versions

**Steps:**

1. Download pre-built wheels from Christoph Gohlke's repository:
   - Visit: https://github.com/cgohlke/win_amd64-cpython
   - Or: https://www.lfd.uci.edu/~gohlke/pythonlibs/

2. Install the wheels manually:
   ```cmd
   pip install path\to\downloaded\ctc_segmentation-1.7.4-cp311-cp311-win_amd64.whl --trusted-host nexuspro
   pip install path\to\downloaded\texterrors-0.5.1-cp311-cp311-win_amd64.whl --trusted-host nexuspro
   ```

3. Then continue with NeMo installation:
   ```cmd
   pip install -r requirements_stage2_nemo.txt --trusted-host nexuspro
   ```

### Solution 3: Install via Conda (Alternative)

**Pros:** Pre-compiled binaries included
**Cons:** Requires Conda/Miniconda

**Steps:**

1. Install Miniconda:
   https://docs.conda.io/en/latest/miniconda.html

2. Create environment:
   ```cmd
   conda create -n nemo python=3.11
   conda activate nemo
   ```

3. Install PyTorch CPU:
   ```cmd
   conda install pytorch torchvision torchaudio cpuonly -c pytorch
   ```

4. Install NeMo:
   ```cmd
   pip install nemo-toolkit[asr]==2.5.3
   ```

### Solution 4: Skip CTC Segmentation (Limited Functionality)

**Pros:** No compiler needed
**Cons:** ⚠️ Missing CTC segmentation features

**NOT RECOMMENDED** - CTC segmentation is used by NeMo for alignment tasks.

## Which Solution Should You Choose?

| Scenario | Recommended Solution |
|----------|---------------------|
| **Production/Enterprise** | Solution 1 (Build Tools) |
| **Quick testing** | Solution 2 (Pre-built wheels) |
| **Already using Conda** | Solution 3 (Conda) |
| **Limited disk space** | Solution 2 (Pre-built wheels) |

## Verification

After installation, verify with:

```cmd
python -c "import ctc_segmentation; print('CTC Segmentation OK')"
python -c "import texterrors; print('Texterrors OK')"
python test_import.py
```

## Additional Notes

### Why This Happens on Windows

- **Linux/macOS**: Include GCC/Clang compilers by default
- **Windows**: Requires separate Visual Studio Build Tools installation
- **Package maintainers**: Often don't provide pre-built Windows wheels for all packages

### Affected Packages in NeMo

From NeMo's dependencies, these require compilation on Windows:
1. `ctc_segmentation==1.7.4` ✗ (REQUIRED)
2. `texterrors<1.0.0` ✗ (REQUIRED)
3. `kaldi-python-io` ✗ (Optional)
4. Most others have pre-built wheels ✓

### Corporate Network Considerations

If using Solution 1 (Build Tools):
- May require IT approval for installation
- Requires administrator privileges
- Large download may take time on corporate networks

If using Solution 2 (Pre-built wheels):
- Can be installed without admin rights
- Wheels can be cached internally
- Faster for bulk installations

## Troubleshooting

### "cl.exe not found" after installing Build Tools

- Restart your terminal/PowerShell
- Run: `where cl.exe` to verify installation
- If not found, re-run Build Tools installer and ensure "C++ build tools" is selected

### Pre-built wheels not available for Python 3.11

- Check if wheels exist for your Python version
- Consider using Python 3.10 instead (more wheel availability)
- Or use Solution 1 (Build Tools) which works with any version

### Conda installation conflicts with pip

- Always use the same package manager within an environment
- Don't mix conda and pip if possible
- If you must mix, install conda packages first, then pip

## References

- Visual Studio Build Tools: https://visualstudio.microsoft.com/visual-cpp-build-tools/
- Python Build Tools Wiki: https://wiki.python.org/moin/WindowsCompilers
- Unofficial Windows Wheels: https://github.com/cgohlke/win_amd64-cpython
