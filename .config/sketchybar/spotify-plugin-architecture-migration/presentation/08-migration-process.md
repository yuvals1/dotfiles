# Migration Process: Step-by-Step

## Phase 1: Analysis & Understanding
```
Step 1: Deep Analysis
├── Read all 6 scripts thoroughly
├── Map data flow between components  
├── Identify state dependencies
├── Document UI requirements
└── Understand integration points

Step 2: Architecture Patterns
├── Command Pattern (smart wrapper)
├── Process Coordination (PID files)
├── Event-Driven Architecture  
├── Caching Layer (deduplication)
└── State Management (file-based)
```

## Phase 2: Preservation Strategy
```  
Step 3: UI Preservation
├── Keep items/spotify.sh unchanged
├── Document all visual elements
├── Map sketchybar item relationships
└── Preserve keyboard shortcuts

Step 4: Safe Migration
├── Move old scripts to old_plugins/
├── Keep dispatcher & youtube untouched
├── Maintain external interfaces
└── Backup all original functionality
```

## Phase 3: Implementation
```
Step 5: Core State Machine
├── Create unified spotify.sh daemon
├── Implement infinite loop pattern
├── Add command queue interface  
└── Port all features to single process

Step 6: Feature Parity
├── Basic controls ✅
├── Album artwork ✅  
├── Progress bars ✅
├── Context display ✅
├── Force-repeat ✅
├── Radio cycling ✅
```

## Phase 4: Integration & Fixes
```
Step 7: Problem Resolution
├── Multiple daemon instances → PID management
├── UI flickering → Center state checking
├── Stale data → Daemon restart capability
├── Command errors → Format corrections
└── Race conditions → Atomic operations
```