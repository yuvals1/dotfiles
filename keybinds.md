# Keyboard Shortcuts

This document tracks all custom keyboard shortcuts configured across different applications.

## Command Key Combinations

| Key Combination         | Context      | Action                            | Description                              |
| ----------------------- | ------------ | --------------------------------- | ---------------------------------------- |
| `cmd+a`                 | Kitty        | Select all                        | vim: ggVG                                |
| `cmd+c`                 | Kitty        | Copy staged diff                  | gitsigns: hs                             |
| `cmd+e`                 | Kitty        | Reload file                       | vim: :e!                                 |
| `cmd+t`                 | Kitty        | New tmux window                   | Creates new tmux window                  |
| `cmd+p`                 | Kitty        | Tmux menu                         | Opens tmux menu                          |
| `cmd+y`                 | Kitty        | Split tmux vertically right       | Vertical split to the right              |
| `cmd+u`                 | Kitty        | Split tmux horizontally           | Horizontal split                         |
| `cmd+x`                 | Kitty        | Kill tmux pane                    | Closes current pane                      |
| `cmd+x`                 | Chrome       | Close tab + reopen last           | Special Chrome behavior                  |
| `cmd+z`                 | Kitty        | Toggle tmux zoom                  | Zoom/unzoom current pane                 |
| `cmd+h`                 | Kitty        | Navigate tmux pane left           | Move to left pane                        |
| `cmd+j`                 | Kitty        | Navigate tmux pane down           | Move to down pane                        |
| `cmd+k`                 | Kitty        | Navigate tmux pane up             | Move to up pane                          |
| `cmd+l`                 | Kitty        | Navigate tmux pane right          | Move to right pane                       |
| `cmd+q`                 | Kitty        | Quit vim                          | vim: :q                                  |
| `cmd+d`                 | Kitty        | Force quit vim                    | vim: :q!                                 |
| `cmd+d`                 | Chrome       | Cut                               | Remapped to cmd+x                        |
| `cmd+w`                 | Kitty        | Write vim buffer                  | vim: :w                                  |
| `cmd+,`                 | Kitty        | Live grep                         | Telescope live_grep                      |
| `cmd+m`                 | Kitty        | Smart open                        | Telescope smart_open                     |
| `cmd+o`                 | Kitty        | Tmux jump                         | Tmux jumpkey/hop                         |
| `cmd+.`                 | Kitty        | Trouble diagnostics (current)     | Current buffer diagnostics               |
| `cmd+r`                 | Kitty        | Git restore                       | Restore buffer to last commit            |
| `cmd+[`                 | Kitty        | Previous tmux window              | Navigate to previous window              |
| `cmd+[`                 | Chrome       | Previous tab                      | Remapped to cmd+shift+[                  |
| `cmd+]`                 | Kitty        | Next tmux window                  | Navigate to next window                  |
| `cmd+]`                 | Chrome       | Next tab                          | Remapped to cmd+shift+]                  |
| `cmd+0`                 | Kitty        | Select tmux window 0              | Switch to window 0                       |
| `cmd+1`                 | Kitty        | Select tmux window 1              | Switch to window 1                       |
| `cmd+2`                 | Kitty        | Select tmux window 2              | Switch to window 2                       |
| `cmd+3`                 | Kitty        | Select tmux window 3              | Switch to window 3                       |
| `cmd+4`                 | Kitty        | Select tmux window 4              | Switch to window 4                       |
| `cmd+5`                 | Kitty        | Select tmux window 5              | Switch to window 5                       |
| `cmd+6`                 | Kitty        | Select tmux window 6              | Switch to window 6                       |
| `cmd+7`                 | Kitty        | Select tmux window 7              | Switch to window 7                       |
| `cmd+8`                 | Kitty        | Select tmux window 8              | Switch to window 8                       |
| `cmd+9`                 | Kitty        | Select tmux window 9              | Switch to window 9                       |
| `cmd+;`                 | Kitty        | View tmux sessions                | List all tmux sessions                   |
| `cmd+i`                 | Global       | Inspect element                   | Triggers F12                             |
| `cmd+shift+;`           | Kitty        | Split tmux horizontally           | Horizontal split (alternative)           |
| `cmd+shift+y`           | Kitty        | Split tmux vertically left        | Vertical split to the left               |
| `cmd+shift+.`           | Kitty        | Trouble diagnostics (all)         | All buffers diagnostics                  |
| `cmd+shift+d`           | Global       | Insert date                       | DD/MM/YYYY format                        |
| `cmd+shift+s`           | Global       | Insert datetime                   | DD/MM/YYYY HH:MM format                  |
| `cmd+shift+u`           | Global       | Generate UUID                     | Inserts random UUID                      |
| `cmd+b`                 | -            | **Available**                     | Reserved by Karabiner for navigation     |
| `cmd+f`                 | Chrome       | Click at (2494, 645)              | Chrome-specific click position           |
| `cmd+f`                 | System/Kitty | Find / **Available**              | Standard macOS find (non-Chrome/Kitty)   |
| `cmd+g`                 | Chrome       | Click at (1442, 605)              | Right-center position (Chrome only)      |
| `cmd+n`                 | System       | New                               | Standard macOS new window/document       |
| `cmd+s`                 | Chrome       | Click at (2470, 644)              | Chrome-specific click position           |
| `cmd+s`                 | System       | Save                              | Standard macOS save (non-Chrome)         |
| `cmd+v`                 | System       | Paste                             | Standard macOS paste                     |
| `cmd+space`             | System       | Spotlight                         | Standard macOS Spotlight search          |
| `cmd+tab`               | System       | App Switcher                      | Standard macOS app switcher              |
| `cmd+shift+z`           | System       | Redo                              | Standard macOS redo                      |
| `cmd+/`                 | Global       | Click at (1074, 605)              | Left-center position                     |
| `cmd+shift+/`           | Global       | Click at (1442, 605)              | Right-center position                    |
| `cmd+shift+a`           | Global       | Speak clipboard (175 wpm)         | Text-to-speech normal speed              |
| `cmd+shift+f`           | Global       | Speak clipboard (250 wpm)         | Text-to-speech fastest speed             |
| `cmd+shift+x`           | Global       | Stop speaking                     | Stops text-to-speech                     |
| `cmd+shift+q`           | Global       | Click at (1377, 149)              | Position 1                               |
| `cmd+shift+r`           | Global       | Reload Hammerspoon                | Reloads Hammerspoon config               |
| `cmd+shift+P`           | Global       | Show mouse position               | Displays current mouse coordinates       |
| `cmd+shift+C`           | Global       | Click at current position         | Test click function                      |
| `alt+N`                 | Global       | Toggle work pomodoro              | Start/stop work timer                    |
| `alt+M`                 | Global       | Toggle break pomodoro             | Start/stop break timer                   |
| `cmd+shift+[others]`    | -            | **Available**                     | Except a,d,f,q,r,s,u,x,y,;,.,z,P,C,/    |
| `cmd+option+[any key]`  | -            | **Available**                     | -                                        |
| `cmd+control+[any key]` | -            | **Available**                     | -                                        |

