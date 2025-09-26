# Test Quiet Mode Documentation

**Purpose**: Enable AI agents and CI/CD systems to run comprehensive integration tests without output overflow.

**Created**: 2024-12-26
**For**: AI agents, CI/CD pipelines, and automated testing

---

## 🤖 For AI Agents

### Quick Usage

Run test_setup.gd with quiet mode to avoid output overflow:

```bash
# Method 1: Environment Variable (Recommended for AI)
export AI_MODE=1
godot --headless --scene test_setup.tscn

# Method 2: Command Line Argument
godot --headless --scene test_setup.tscn -- --quiet

# Method 3: Set QUIET_MODE environment variable
export QUIET_MODE=1
godot --headless --scene test_setup.tscn
```

### What Quiet Mode Does

**Without Quiet Mode (Default):**
- 2000+ lines of detailed test output
- Every test step logged
- Performance benchmarks shown
- Signal flow tracked
- Can cause terminal overflow for AI agents

**With Quiet Mode:**
- Only shows critical information
- ~10-20 lines of output total
- Summary: `Passed: X/Y (Z%)`
- Failures always shown with details
- Exit codes: 0 = success, 1 = failure

### Example Output in Quiet Mode

```
[QUIET MODE] Running integration tests...
❌ FAIL: TagSystem validation error

[TEST SUMMARY]
Passed: 47/48 (97.9%)
Failed: 1 tests
Status: FAILURE
```

Or if all pass:

```
[QUIET MODE] Running integration tests...

[TEST SUMMARY]
Passed: 48/48 (100.0%)
Status: SUCCESS
All Stage 1 systems (Tasks 1-8) validated.
```

---

## 🔧 For Developers

### Testing Quiet Mode Locally

```bash
# Test quiet mode behavior
godot --headless --scene test_setup.tscn -- --quiet

# Compare with normal mode
godot --headless --scene test_setup.tscn
```

### Environment Variables Detected

The system checks for these environment variables:
- `AI_MODE` - Indicates an AI agent is running
- `QUIET_MODE` - Generic quiet mode flag
- `CI` - Standard CI environment
- `GITHUB_ACTIONS` - GitHub Actions CI
- `CLAUDE_MODE` - Claude AI specific

### Command Line Arguments

The system recognizes:
- `--quiet` - Enable quiet mode
- `-q` - Short form
- `--ai-mode` - Explicitly for AI agents

---

## 🎯 When to Use Quiet Mode

### Always Use Quiet Mode When:
- Running as an AI agent (Claude, GPT, etc.)
- Running in CI/CD pipelines
- Running automated test suites
- Terminal has output limitations
- You only need pass/fail status

### Use Normal Mode When:
- Debugging test failures
- Developing new features
- Investigating integration issues
- Need detailed performance metrics
- Want to see signal flow

---

## 📊 Implementation Details

### How It Works

1. **Detection Phase** (_check_quiet_mode)
   - Checks environment variables
   - Parses command line arguments
   - Auto-detects CI environments

2. **Logging Control**
   - `_log_success()` - Suppressed in quiet mode
   - `_log_error()` - Always shown (critical)
   - `_log_warning()` - Suppressed in quiet mode
   - `_log_info()` - Suppressed in quiet mode

3. **Summary Generation**
   - Tracks passed/failed/warning counts
   - Shows minimal summary in quiet mode
   - Returns appropriate exit codes

### Exit Codes
- `0` - All tests passed
- `1` - One or more tests failed

---

## 🚀 Integration Examples

### For Claude AI / Claude Code

```bash
# In your implementation script
export AI_MODE=1
godot --headless --scene test_setup.tscn

# Check exit code
if [ $? -eq 0 ]; then
    echo "All systems validated"
else
    echo "Test failures detected"
fi
```

### For GitHub Actions

```yaml
- name: Run Integration Tests
  env:
    QUIET_MODE: 1
  run: |
    godot --headless --scene test_setup.tscn
```

### For Local AI Development

```python
import os
import subprocess

# Enable quiet mode for AI
os.environ['AI_MODE'] = '1'

# Run tests
result = subprocess.run(
    ['godot', '--headless', '--scene', 'test_setup.tscn'],
    capture_output=True,
    text=True
)

# Check result
if result.returncode == 0:
    print("✅ All tests passed")
else:
    print("❌ Tests failed")
    print(result.stdout)  # Shows failure details
```

---

## 🔍 Troubleshooting

### Still Getting Too Much Output?

1. Ensure environment variable is set:
   ```bash
   echo $AI_MODE  # Should show "1"
   ```

2. Check you're using headless mode:
   ```bash
   godot --headless --scene test_setup.tscn
   ```

3. Verify quiet mode activated:
   Look for `[QUIET MODE]` in first line of output

### Need More Details for Debugging?

Temporarily disable quiet mode:
```bash
unset AI_MODE
unset QUIET_MODE
godot --headless --scene test_setup.tscn
```

---

## 📋 Summary

- **AI agents should ALWAYS use quiet mode** to prevent output overflow
- Set `AI_MODE=1` or use `--quiet` flag
- Exit codes provide pass/fail status
- Failures are always shown with details
- ~99% reduction in output volume

This makes test_setup.gd suitable for both comprehensive developer testing AND automated AI/CI usage!