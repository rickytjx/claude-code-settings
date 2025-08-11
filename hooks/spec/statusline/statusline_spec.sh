#!/usr/bin/env bash
# statusline_spec.sh - Tests for the Claude Code status line

Describe 'statusline.sh'
    # Note: spec_helper.sh is automatically loaded by ShellSpec via --require spec_helper
    
    # Test setup functions
    setup_test() {
        export CLAUDE_HOOKS_DEBUG=0
        # Create temp directory for test
        TEMP_DIR=$(create_test_dir)
        cd "$TEMP_DIR" || return
        # Mock hostname
        hostname() { echo "test-host"; }
        export -f hostname
    }
    
    cleanup_test() {
        cd "$SPEC_DIR" || return
        rm -rf "$TEMP_DIR"
        unset -f hostname
    }
    
    BeforeEach 'setup_test'
    AfterEach 'cleanup_test'
    
    Describe 'basic functionality'
        It 'produces output with minimal JSON input'
            When run bash "$HOOK_DIR/statusline.sh" <<< '{}'
            The status should equal 0
            The stdout should include '['
            The stdout should include ']'
        End
        
        It 'displays model name when provided'
            When run bash "$HOOK_DIR/statusline.sh" <<< '{"model":{"display_name":"Opus"}}'
            The status should equal 0
            The stdout should include '[Opus]'
        End
        
        It 'falls back to Claude when model not provided'
            When run bash "$HOOK_DIR/statusline.sh" <<< '{}'
            The status should equal 0
            The stdout should include '[Claude]'
        End
        
        It 'displays current directory'
            When run bash "$HOOK_DIR/statusline.sh" <<< '{"workspace":{"current_dir":"/home/user/project"}}'
            The status should equal 0
            The stdout should include '~/project'
        End
    End
    
    Describe 'path formatting'
        It 'replaces home directory with ~'
            When run bash "$HOOK_DIR/statusline.sh" <<< "{\"workspace\":{\"current_dir\":\"$HOME/myproject\"}}"
            The status should equal 0
            The stdout should include '~/myproject'
        End
        
        It 'truncates long paths'
            When run bash "$HOOK_DIR/statusline.sh" <<< "{\"workspace\":{\"current_dir\":\"$HOME/very/long/path/to/project\"}}"
            The status should equal 0
            The stdout should include '~/to/project'
        End
        
        It 'handles root paths'
            When run bash "$HOOK_DIR/statusline.sh" <<< '{"workspace":{"current_dir":"/usr/local/bin"}}'
            The status should equal 0
            The stdout should include '/usr/local/bin'
        End
    End
    
    Describe 'hostname display'
        It 'shows hostname'
            When run bash "$HOOK_DIR/statusline.sh" <<< '{}'
            The status should equal 0
            The stdout should include 'test-host'
        End
    End
    
    Describe 'ANSI colors'
        It 'includes ANSI escape codes for colors'
            When run bash "$HOOK_DIR/statusline.sh" <<< '{}'
            The status should equal 0
            # Check for ANSI escape sequences
            The stdout should match pattern '*\033\[*'
        End
        
        It 'includes chevron characters'
            When run bash "$HOOK_DIR/statusline.sh" <<< '{}'
            The status should equal 0
            The stdout should include ''
        End
    End
    
    Describe 'complete status line'
        It 'generates full status line with all components'
            When run bash "$HOOK_DIR/statusline.sh" <<< "{\"model\":{\"display_name\":\"Opus\"},\"workspace\":{\"current_dir\":\"$HOME/project\"}}"
            The status should equal 0
            The stdout should include '~/project'
            The stdout should include '[Opus]'
            The stdout should include 'test-host'
            The stdout should include ''
        End
    End
End