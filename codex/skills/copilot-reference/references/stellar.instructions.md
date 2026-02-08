---
applyTo: '**/*.php'
---
# PHP Project Coding Standards

## Assumptions

**This instruction file assumes a specific project structure.** Before following these guidelines:

1. **Verify the directory structure exists** (e.g., `src/Controllers`, `src/Game`, `src/Security`, `template/`, `public/`)
2. **If the structure doesn't match**, treat this as general PHP guidance only and adapt paths to the actual project layout
3. **For greenfield projects**, you may create this structure if appropriate for the project scope
4. **For existing projects**, always respect the current architecture and don't force restructuring

## General Standards
- Use **PHP 8+** syntax and features to leverage modern capabilities like union types, attributes, and JIT compilation.
- Follow **PSR-1** and **PSR-12** coding standards for PHP.
- Use procedural code for simple scripts and OOP for controllers and core logic.
- Organize code by feature:
  - Controllers in `src/Controllers`
  - Game logic in `src/Game`
  - Security in `src/Security`
  - Templates in `template/`
- Use clear, descriptive variable and function names in English.
- Indent with **tabs** in PHP files, **2 spaces** for CSS/JS.
- Use **Unix line endings (LF)**.

## Security
- Always sanitize user input using PHP built-in functions or custom sanitization.
- Use **prepared statements** for all database queries.
- Implement **CSRF protection** for forms and API endpoints (`src/Security/CSRFProtection.php`).
- Store sensitive configuration in `config/security.php` and never expose it publicly.
- Use **password_hash()** and **password_verify()** for secure password storage.
- Implement **Content Security Policy (CSP)** headers to mitigate XSS attacks.

## Database
- Use **MySQL** with tables defined in `config/database.sql`.
- Use **PDO** for database access.
- Keep database credentials in `config/config.php`, outside web root.
- Use **dotenv** files (via `vlucas/phpdotenv`) for managing environment-specific configurations securely.

## File Structure
- Place all public-facing files in `public/`.
- Store assets (CSS, JS, images) in `public/assets/`.
- Use `template/pages/` for page templates and `template/includes/` for reusable components.
- Organize code under the project root directory following a consistent structure.

## HTML/CSS/JS
- Use **semantic HTML5** in templates.
- Link CSS and JS from `public/assets/`.
- Use **external stylesheets and scripts**, avoid inline styles/scripts.
- Use `csrf.js` for CSRF token handling in AJAX requests.

## Error Handling
- Use custom error pages (`public/403.php`, `public/404.php`, `public/500.php`).
- Log errors securely, do not expose stack traces to users.
- Use `try-catch` blocks for exception handling and log errors using a library like **Monolog**.

## Version Control
- Exclude sensitive files and environment-specific configs in `.gitignore`.
- Commit only necessary code and assets.

## Comments & Documentation
- Use **PHPDoc** for functions, classes, and methods.
- Add comments for complex logic.
- Keep `README.md` up to date with setup and usage instructions.
- Generate API documentation using tools like **phpDocumentor**.

## PHP Testing
- Use **PHPUnit** for unit and integration testing.
- Place test files in a `tests/` directory at the project root.
- Follow the naming convention: `*Test.php` (e.g., `GameFunctionsTest.php`).
- Mirror the source directory structure in tests (e.g., `tests/Controllers/`, `tests/Game/`).
- Use descriptive test method names with `test` prefix (e.g., `testValidateUserInput()`).
- Group related tests using `@group` annotations for easy test filtering.
- Test both positive and negative scenarios (valid inputs and edge cases).
- Mock external dependencies (database, API calls) using PHPUnit's mocking framework.
- Use data providers for testing multiple input scenarios.
- Aim for high code coverage but focus on critical business logic.
- Include setup and teardown methods for test data preparation and cleanup.
- Use assertions like `assertEquals()`, `assertTrue()`, `assertNull()`, `expectException()`.
- Write integration tests for controller methods that interact with multiple components.
- Test security features thoroughly, including CSRF protection and input sanitization.
- Use **integration testing frameworks** like Behat for behavior-driven development (BDD).

## Modern PHP Practices
- Use **Composer** for dependency management and autoloading.
- Encourage the use of **typed properties**, **arrow functions**, and **match expressions** for cleaner and more concise code.
- Use tools like **PHPStan** or **Psalm** for static code analysis to catch potential issues early.
- Enforce PSR-12 coding standards automatically using **PHP-CS-Fixer** or **PHP_CodeSniffer**.

## Standards Already Set
- Use controller classes for business logic.
- Use includes for navigation, header, and footer.
- Use template pages for rendering views.
- Use asset folders for static resources.