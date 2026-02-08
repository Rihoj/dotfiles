---
description: 'Idiomatic Go practices following Effective Go, Code Review Comments, and Google Go Style Guide. See references/go-patterns.md for examples.'
applyTo: '**/*.go,**/go.mod,**/go.sum'
---

# Go Development Instructions

Write simple, clear, idiomatic Go code. **For detailed patterns**, see [go-patterns.md](references/go-patterns.md).

## Core Philosophy

- Favor clarity over cleverness
- Keep happy path left-aligned (minimize indentation)
- Return early to reduce nesting
- Make zero value useful
- Follow principle of least surprise

## Naming Conventions

### Packages
- Lowercase, single-word names
- No underscores, hyphens, or mixedCaps
- Singular, not plural (`http`, not `https`)
- Avoid generic names (`util`, `common`, `base`)

### Variables and Functions
- mixedCaps (camelCase)
- Exported: start with capital
- Unexported: start with lowercase
- Short names in short scopes (e.g., loop `i`)
- Avoid stuttering (`http.Server`, not `http.HTTPServer`)

### Interfaces
- `-er` suffix when possible (`Reader`, `Writer`)
- Single-method interfaces named after method
- Keep small and focused

### Constants
- MixedCaps for exported, mixedCaps for unexported
- Group related constants in blocks
- Use typed constants for type safety

## Code Style

### Formatting
- Always use `gofmt` (automatic formatting)
- Use `goimports` for import management
- Add blank lines between logical groups

### Comments
- Complete sentences starting with item name
- Package comments: "Package [name]"
- Document WHY, not WHAT (unless complex)
- Use line comments `//` (block comments rarely)

## Error Handling

### Required Patterns
- Check errors immediately: `if err != nil`
- Don't ignore with `_` without good reason (document why)
- Wrap with context: `fmt.Errorf("failed: %w", err)`
- Error as last return value
- Name error variables `err`
- Lowercase messages, no trailing punctuation

### Custom Errors
- Create types for specific errors
- Use sentinel errors (`var ErrNotFound = errors.New(...)`)
- Check with `errors.Is` and `errors.As`

## Project Structure

### Organization
- `main` packages in `cmd/`
- Reusable code in `pkg/` or `internal/`
- Use `internal/` for packages that shouldn't be imported externally
- Group related functionality in packages
- Avoid circular dependencies

### Dependencies
- Use Go modules (`go.mod`, `go.sum`)
- Keep minimal
- `go mod tidy` to clean up
- Vendor only when necessary

## Type Safety

### Guidelines
- Define types for meaning and safety
- Struct tags for JSON/XML/DB mapping
- Explicit type conversions
- Check type assertion second return value

### Pointers vs Values
- Pointers for large structs or mutation
- Values for small structs and immutability
- Be consistent within type's method set
- Consider zero value

### Interfaces
- Accept interfaces, return concrete types
- Keep small (1-3 methods ideal)
- Define near use, not implementation
- Don't export unless necessary

## Concurrency

### Goroutines
- Let caller control concurrency (don't create in libraries)
- Know how goroutines exit
- Use `sync.WaitGroup` or channels to wait
- Prevent leaks with cleanup

### Channels
- Communicate via channels, don't share memory
- Close from sender, not receiver
- Buffered when capacity known
- `select` for non-blocking operations

### Synchronization
- `sync.Mutex` for shared state (keep critical sections small)
- `sync.RWMutex` for read-heavy workloads
- Prefer channels over mutexes when possible
- `sync.Once` for one-time initialization

## Testing

### Organization
- Same package for white-box testing
- `_test` suffix package for black-box
- Files named `*_test.go`
- Place next to code

### Writing Tests
- Table-driven tests for multiple cases
- Name: `Test_functionName_scenario`
- Subtests with `t.Run`
- Test success and error cases
- Mark helpers with `t.Helper()`
- Cleanup with `t.Cleanup()`

## API Design

### HTTP Handlers
- `http.HandlerFunc` for simple handlers
- Implement `http.Handler` for stateful handlers
- Middleware for cross-cutting concerns
- Set appropriate status codes
- Handle errors gracefully

### JSON APIs
- Struct tags for marshaling control
- Validate input
- Pointers for optional fields
- `json.RawMessage` for delayed parsing

## Performance

### Memory Management
- Minimize allocations in hot paths
- Reuse objects (`sync.Pool` when appropriate)
- Value receivers for small structs
- Preallocate slices when size known
- Avoid unnecessary string conversions

### Profiling
- Use built-in `pprof` tools
- Benchmark with `testing.B`
- Profile before optimizing
- Focus on algorithmic improvements first

## Security

### Input Validation
- Validate all external input
- Strong typing to prevent invalid states
- Sanitize before SQL/shell usage
- Validate file paths from users

### Cryptography
- Use standard library crypto packages
- Don't implement own crypto
- `crypto/rand` for random numbers
- bcrypt for passwords
- TLS for network communication

## Documentation

- Document all exported symbols
- Start with symbol name
- Use examples when helpful
- Keep documentation close to code
- Update when code changes

## Tools

- `go fmt` - Format code
- `go vet` - Find suspicious constructs
- `golangci-lint` - Additional linting
- `go test` - Run tests
- `go mod` - Manage dependencies

## Common Pitfalls (Avoid)

❌ Not checking errors
❌ Ignoring race conditions
❌ Goroutine leaks
❌ Not using defer for cleanup
❌ Modifying maps concurrently
❌ Not understanding nil interfaces vs nil pointers
❌ Forgetting to close resources
❌ Unnecessary global variables
❌ Over-using empty interfaces
❌ Ignoring zero values

**See [go-patterns.md](references/go-patterns.md)** for complete examples of:
- Error handling patterns
- Struct and builder patterns
- Concurrency patterns (worker pools, context, WaitGroup)
- HTTP handler and middleware patterns
- Testing patterns (table-driven, helpers, benchmarks)
- JSON handling
- Common idioms (singleton, resource pool)
