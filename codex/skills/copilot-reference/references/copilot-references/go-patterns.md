# Go Code Patterns and Examples

Detailed Go code examples and patterns. Reference material for [go.instructions.md](../go.instructions.md).

---

## Error Handling Patterns

### Basic Error Checking

```go
file, err := os.Open("config.json")
if err != nil {
    return fmt.Errorf("failed to open config: %w", err)
}
defer file.Close()
```

### Custom Error Types

```go
type ValidationError struct {
    Field string
    Value interface{}
    Msg   string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed for %s (value: %v): %s", 
        e.Field, e.Value, e.Msg)
}

// Usage
if age < 0 {
    return &ValidationError{
        Field: "age",
        Value: age,
        Msg:   "must be non-negative",
    }
}
```

### Sentinel Errors

```go
var (
    ErrNotFound     = errors.New("resource not found")
    ErrUnauthorized = errors.New("unauthorized access")
    ErrInvalidInput = errors.New("invalid input")
)

// Usage with errors.Is
if errors.Is(err, ErrNotFound) {
    return http.StatusNotFound
}
```

### Error Wrapping and Unwrapping

```go
// Wrap errors to add context
if err := db.Save(user); err != nil {
    return fmt.Errorf("failed to save user %s: %w", user.ID, err)
}

// Check wrapped errors
var validationErr *ValidationError
if errors.As(err, &validationErr) {
    log.Printf("Validation failed: %s", validationErr.Field)
}
```

---

## Struct Patterns

### Struct with Builder Pattern

```go
type Server struct {
    host    string
    port    int
    timeout time.Duration
    logger  *log.Logger
}

type ServerOption func(*Server)

func WithHost(host string) ServerOption {
    return func(s *Server) {
        s.host = host
    }
}

func WithTimeout(timeout time.Duration) ServerOption {
    return func(s *Server) {
        s.timeout = timeout
    }
}

func NewServer(opts ...ServerOption) *Server {
    s := &Server{
        host:    "localhost",
        port:    8080,
        timeout: 30 * time.Second,
        logger:  log.Default(),
    }
    
    for _, opt := range opts {
        opt(s)
    }
    
    return s
}

// Usage
server := NewServer(
    WithHost("0.0.0.0"),
    WithTimeout(60 * time.Second),
)
```

### Embedding for Composition

```go
type Engine struct {
    horsepower int
}

func (e *Engine) Start() {
    fmt.Println("Engine started")
}

type Car struct {
    Engine // Embedding
    brand  string
}

// Usage
car := Car{
    Engine: Engine{horsepower: 200},
    brand:  "Tesla",
}
car.Start() // Calls Engine.Start()
```

---

## Interface Patterns

### Accept Interfaces, Return Concrete Types

```go
// Good: Accept interface
func SaveData(w io.Writer, data []byte) error {
    _, err := w.Write(data)
    return err
}

// Good: Return concrete type
func NewBuffer() *bytes.Buffer {
    return &bytes.Buffer{}
}
```

### Small, Focused Interfaces

```go
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Writer interface {
    Write(p []byte) (n int, err error)
}

type Closer interface {
    Close() error
}

// Compose interfaces
type ReadWriteCloser interface {
    Reader
    Writer
    Closer
}
```

---

## Concurrency Patterns

### Worker Pool

```go
func worker(id int, jobs <-chan int, results chan<- int) {
    for j := range jobs {
        fmt.Printf("worker %d processing job %d\n", id, j)
        time.Sleep(time.Second)
        results <- j * 2
    }
}

func main() {
    jobs := make(chan int, 100)
    results := make(chan int, 100)

    // Start workers
    for w := 1; w <= 3; w++ {
        go worker(w, jobs, results)
    }

    // Send jobs
    for j := 1; j <= 9; j++ {
        jobs <- j
    }
    close(jobs)

    // Collect results
    for a := 1; a <= 9; a++ {
        <-results
    }
}
```

### Context for Cancellation

```go
func doWork(ctx context.Context) error {
    for {
        select {
        case <-ctx.Done():
            return ctx.Err()
        default:
            // Do work
            time.Sleep(100 * time.Millisecond)
        }
    }
}

func main() {
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()

    if err := doWork(ctx); err != nil {
        log.Printf("Work cancelled: %v", err)
    }
}
```

### sync.WaitGroup

```go
func processItems(items []string) {
    var wg sync.WaitGroup

    for _, item := range items {
        wg.Add(1)
        go func(item string) {
            defer wg.Done()
            process(item)
        }(item)
    }

    wg.Wait()
}
```

### Channel Patterns

```go
// Fan-out (multiple workers)
func fanOut(input <-chan int, workers int) []<-chan int {
    outputs := make([]<-chan int, workers)
    for i := 0; i < workers; i++ {
        outputs[i] = worker(input)
    }
    return outputs
}

// Fan-in (merge channels)
func fanIn(channels ...<-chan int) <-chan int {
    var wg sync.WaitGroup
    out := make(chan int)

    output := func(c <-chan int) {
        defer wg.Done()
        for n := range c {
            out <- n
        }
    }

    wg.Add(len(channels))
    for _, c := range channels {
        go output(c)
    }

    go func() {
        wg.Wait()
        close(out)
    }()

    return out
}
```

---

## Testing Patterns

### Table-Driven Tests

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -2, -3, -5},
        {"mixed signs", -2, 3, 1},
        {"zero", 0, 0, 0},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Add(tt.a, tt.b)
            if result != tt.expected {
                t.Errorf("Add(%d, %d) = %d; want %d", 
                    tt.a, tt.b, result, tt.expected)
            }
        })
    }
}
```

### Test Helpers

```go
func assertNoError(t *testing.T, err error) {
    t.Helper()
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
}

func assertEqual(t *testing.T, got, want interface{}) {
    t.Helper()
    if got != want {
        t.Errorf("got %v; want %v", got, want)
    }
}

// Usage
func TestSomething(t *testing.T) {
    result, err := DoSomething()
    assertNoError(t, err)
    assertEqual(t, result, "expected")
}
```

### Benchmarks

```go
func BenchmarkFibonacci(b *testing.B) {
    for i := 0; i < b.N; i++ {
        Fibonacci(20)
    }
}

func BenchmarkFibonacciMemoized(b *testing.B) {
    memo := make(map[int]int)
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        FibonacciMemoized(20, memo)
    }
}
```

---

## HTTP Handler Patterns

### Middleware Pattern

```go
type Middleware func(http.HandlerFunc) http.HandlerFunc

func LoggingMiddleware(next http.HandlerFunc) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        start := time.Now()
        next(w, r)
        log.Printf("%s %s %v", r.Method, r.URL.Path, time.Since(start))
    }
}

func AuthMiddleware(next http.HandlerFunc) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        token := r.Header.Get("Authorization")
        if token == "" {
            http.Error(w, "Unauthorized", http.StatusUnauthorized)
            return
        }
        next(w, r)
    }
}

// Chain middleware
func Chain(f http.HandlerFunc, middlewares ...Middleware) http.HandlerFunc {
    for i := len(middlewares) - 1; i >= 0; i-- {
        f = middlewares[i](f)
    }
    return f
}

// Usage
http.HandleFunc("/api/users", Chain(
    handleUsers,
    LoggingMiddleware,
    AuthMiddleware,
))
```

### HTTP Server with Graceful Shutdown

```go
func main() {
    srv := &http.Server{
        Addr:         ":8080",
        Handler:      router,
        ReadTimeout:  15 * time.Second,
        WriteTimeout: 15 * time.Second,
        IdleTimeout:  60 * time.Second,
    }

    // Start server in goroutine
    go func() {
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            log.Fatalf("Server error: %v", err)
        }
    }()

    // Wait for interrupt signal
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
    <-quit

    // Graceful shutdown
    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    if err := srv.Shutdown(ctx); err != nil {
        log.Fatalf("Server forced to shutdown: %v", err)
    }

    log.Println("Server exited gracefully")
}
```

---

## JSON Handling

### Custom JSON Marshaling

```go
type User struct {
    ID        int       `json:"id"`
    Name      string    `json:"name"`
    Email     string    `json:"email,omitempty"`
    CreatedAt time.Time `json:"created_at"`
}

func (u User) MarshalJSON() ([]byte, error) {
    type Alias User
    return json.Marshal(&struct {
        CreatedAt string `json:"created_at"`
        *Alias
    }{
        CreatedAt: u.CreatedAt.Format(time.RFC3339),
        Alias:     (*Alias)(&u),
    })
}
```

### Handling Optional Fields

```go
type UpdateRequest struct {
    Name  *string `json:"name,omitempty"`
    Email *string `json:"email,omitempty"`
    Age   *int    `json:"age,omitempty"`
}

// Usage
var req UpdateRequest
if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
    return err
}

if req.Name != nil {
    user.Name = *req.Name
}
if req.Email != nil {
    user.Email = *req.Email
}
```

---

## Common Patterns

### Singleton with sync.Once

```go
var (
    instance *Database
    once     sync.Once
)

func GetDatabase() *Database {
    once.Do(func() {
        instance = &Database{
            conn: connectToDB(),
        }
    })
    return instance
}
```

### Resource Pool

```go
type Pool struct {
    resources chan io.Closer
}

func NewPool(size int, factory func() (io.Closer, error)) (*Pool, error) {
    pool := &Pool{
        resources: make(chan io.Closer, size),
    }
    
    for i := 0; i < size; i++ {
        res, err := factory()
        if err != nil {
            return nil, err
        }
        pool.resources <- res
    }
    
    return pool, nil
}

func (p *Pool) Acquire() (io.Closer, error) {
    select {
    case r := <-p.resources:
        return r, nil
    default:
        return nil, errors.New("pool exhausted")
    }
}

func (p *Pool) Release(r io.Closer) {
    p.resources <- r
}
```

---

**Last Updated**: January 18, 2026
