# Spotify Wrapper Tests

This directory contains test suites for the Spotify smart wrapper implementation.

## Test Files

### 1. `test_spotify_wrapper.sh` - Basic Functionality
- Response time testing
- Concurrent command handling
- Process cleanup verification
- Marker file management
- Basic smoke tests

### 2. `test_spotify_interactive.sh` - Manual Tests
- Interactive tests requiring user input
- Tests keyboard shortcuts (Alt+I, Alt+R, etc.)
- Verifies UI responsiveness
- Checks TUI protection

### 3. `test_spotify_stress.sh` - Load Testing
- 100 concurrent commands from different sources
- Rapid-fire command execution
- Simulates heavy usage patterns
- Performance benchmarking

### 4. `test_spotify_isolation.sh` - Isolation Testing
- Verifies source isolation (keyboard vs display vs radio)
- Tests command type isolation
- Validates marker file naming conventions
- Ensures proper process management

## Running the Tests

Make all test scripts executable:
```bash
chmod +x tests/*.sh
```

Run individual test suites:
```bash
./tests/test_spotify_wrapper.sh      # Basic tests
./tests/test_spotify_interactive.sh  # Manual verification
./tests/test_spotify_stress.sh       # Load testing
./tests/test_spotify_isolation.sh    # Isolation testing
```

Run all automated tests:
```bash
for test in tests/test_spotify_{wrapper,stress,isolation}.sh; do
    echo "Running $test..."
    $test
    echo
done
```

## Expected Results

All automated tests should show:
- ✓ PASS for successful tests
- ✗ FAIL for failed tests
- Response times < 100ms for individual commands
- No hanging processes after tests complete
- Clean marker directory after tests

## Troubleshooting

If tests fail:
1. Check if spotify daemon is running: `pgrep -f "spotify_player --daemon"`
2. Kill any hanging processes: `pkill -f "spotify_player.*get\|playback"`
3. Clear marker files: `rm -rf ~/.config/sketchybar/.spotify_markers/*`
4. Check wrapper logs: `tail -f /tmp/spotify_wrapper.log`