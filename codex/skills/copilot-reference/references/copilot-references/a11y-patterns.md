# Accessibility Component Patterns

Detailed component-specific accessibility patterns and examples. Reference material for [a11y.instructions.md](../a11y.instructions.md).

---

## Navigation and Menus

### Good Navigation Region Example

```html
<nav aria-label="Main navigation">
  <ul role="list">
    <li>
      <a href="/" aria-current="page">Home</a>
    </li>
    <li>
      <button
        aria-expanded="false"
        aria-controls="products-menu"
        id="products-button">
        Products
      </button>
      <ul id="products-menu" role="menu" aria-labelledby="products-button" hidden>
        <li role="none">
          <a href="/products/software" role="menuitem">Software</a>
        </li>
        <li role="none">
          <a href="/products/hardware" role="menuitem">Hardware</a>
        </li>
      </ul>
    </li>
    <li><a href="/about">About</a></li>
    <li><a href="/contact">Contact</a></li>
  </ul>
</nav>
```

---

## Tables and Grids

### Table with Column and Row Headers

```html
<table>
  <thead>
    <tr>
      <th scope="col">Name</th>
      <th scope="col">Email</th>
      <th scope="col">Role</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th scope="row">Jane Doe</th>
      <td>jane@example.com</td>
      <td>Developer</td>
    </tr>
    <tr>
      <th scope="row">John Smith</th>
      <td>john@example.com</td>
      <td>Designer</td>
    </tr>
  </tbody>
</table>
```

### Table with Just Column Headers

```html
<table>
  <caption>Product Inventory</caption>
  <thead>
    <tr>
      <th scope="col">Product</th>
      <th scope="col">Stock</th>
      <th scope="col">Price</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Widget</td>
      <td>42</td>
      <td>$19.99</td>
    </tr>
    <tr>
      <td>Gadget</td>
      <td>17</td>
      <td>$29.99</td>
    </tr>
  </tbody>
</table>
```

### Accessible Grid (Date Picker)

```html
<div role="grid" aria-labelledby="calendar-heading">
  <h2 id="calendar-heading">January 2026</h2>
  
  <div role="row">
    <span role="columnheader">Sun</span>
    <span role="columnheader">Mon</span>
    <span role="columnheader">Tue</span>
    <span role="columnheader">Wed</span>
    <span role="columnheader">Thu</span>
    <span role="columnheader">Fri</span>
    <span role="columnheader">Sat</span>
  </div>
  
  <div role="row">
    <button role="gridcell" tabindex="-1" aria-label="Sunday, January 5, 2026">5</button>
    <button role="gridcell" tabindex="-1" aria-label="Monday, January 6, 2026">6</button>
    <button role="gridcell" tabindex="0" aria-label="Tuesday, January 7, 2026" aria-current="date">7</button>
    <button role="gridcell" tabindex="-1" aria-label="Wednesday, January 8, 2026">8</button>
    <button role="gridcell" tabindex="-1" aria-label="Thursday, January 9, 2026">9</button>
    <button role="gridcell" tabindex="-1" aria-label="Friday, January 10, 2026">10</button>
    <button role="gridcell" tabindex="-1" aria-label="Saturday, January 11, 2026">11</button>
  </div>
</div>
```

---

## Forms

### Accessible Form with Validation

```html
<form>
  <div>
    <label for="username">Username <span aria-label="required">*</span></label>
    <input 
      type="text" 
      id="username" 
      name="username"
      aria-required="true"
      aria-describedby="username-help username-error"
      aria-invalid="false">
    <span id="username-help">Must be 3-20 characters</span>
    <span id="username-error" role="alert" hidden></span>
  </div>

  <div>
    <label for="email">Email <span aria-label="required">*</span></label>
    <input 
      type="email" 
      id="email" 
      name="email"
      aria-required="true"
      aria-describedby="email-error"
      aria-invalid="false">
    <span id="email-error" role="alert" hidden></span>
  </div>

  <button type="submit">Submit</button>
</form>

<script>
// On submit, if validation fails:
// 1. Set aria-invalid="true" on invalid fields
// 2. Display error messages and remove 'hidden'
// 3. Focus first invalid field
document.getElementById('username').focus();
</script>
```

---

## Skip Links

```html
<header>
  <a href="#maincontent" class="sr-only">Skip to main content</a>
  <!-- Header content -->
</header>
<nav>
  <!-- Navigation -->
</nav>
<main id="maincontent">
  <!-- Main content -->
</main>
```

```css
.sr-only:not(:focus):not(:active) {
  clip: rect(0 0 0 0);
  clip-path: inset(50%);
  height: 1px;
  overflow: hidden;
  position: absolute;
  white-space: nowrap;
  width: 1px;
}
```

---

## Graphics and Images

### Informative Image

```html
<!-- Simple informative image -->
<img src="chart.png" alt="Sales increased 25% in Q4 2025">

<!-- Complex image with extended description -->
<figure>
  <img src="org-chart.png" alt="Organization chart" aria-describedby="org-details">
  <figcaption id="org-details">
    CEO at top, reporting to 3 VPs: Engineering, Marketing, and Operations...
  </figcaption>
</figure>
```

### Decorative Image

```html
<!-- Decorative image -->
<img src="decorative-border.png" alt="" role="presentation">

<!-- Icon with adjacent text -->
<span role="img" aria-hidden="true">✓</span>
<span>Task completed</span>
```

### SVG Graphics

```html
<!-- Informative SVG -->
<svg role="img" aria-labelledby="chart-title">
  <title id="chart-title">Revenue growth 2020-2025</title>
  <!-- SVG content -->
</svg>

<!-- Decorative SVG -->
<svg aria-hidden="true">
  <!-- SVG content -->
</svg>
```

---

## Dialogs and Modals

### Accessible Modal Dialog

```html
<button id="open-dialog">Open Dialog</button>

<div 
  role="dialog" 
  aria-modal="true" 
  aria-labelledby="dialog-title"
  aria-describedby="dialog-description"
  hidden>
  <h2 id="dialog-title">Confirm Action</h2>
  <p id="dialog-description">Are you sure you want to proceed?</p>
  
  <button id="dialog-confirm">Confirm</button>
  <button id="dialog-cancel">Cancel</button>
</div>

<script>
// When dialog opens:
// 1. Trap keyboard focus within dialog
// 2. Focus first focusable element or close button
// 3. ESC key should close dialog
// 4. Return focus to trigger button on close
</script>
```

---

## ARIA Live Regions

### Status Messages

```html
<!-- Polite announcement (waits for pause) -->
<div role="status" aria-live="polite" aria-atomic="true">
  <!-- Status messages inserted here -->
</div>

<!-- Assertive announcement (immediate) -->
<div role="alert" aria-live="assertive" aria-atomic="true">
  <!-- Error messages inserted here -->
</div>

<!-- Example usage -->
<div id="save-status" role="status" aria-live="polite">
  <!-- JavaScript updates this when save completes -->
</div>

<script>
// After save completes:
document.getElementById('save-status').textContent = 'Changes saved successfully';
</script>
```

---

## Custom Controls

### Accessible Toggle Button

```html
<button 
  type="button"
  aria-pressed="false"
  id="notifications-toggle">
  <span class="icon" aria-hidden="true">🔔</span>
  Notifications
</button>

<script>
// Toggle on click
button.addEventListener('click', function() {
  const pressed = this.getAttribute('aria-pressed') === 'true';
  this.setAttribute('aria-pressed', !pressed);
});
</script>
```

### Accessible Tabs

```html
<div>
  <div role="tablist" aria-label="Content sections">
    <button role="tab" aria-selected="true" aria-controls="panel-1" id="tab-1" tabindex="0">
      Overview
    </button>
    <button role="tab" aria-selected="false" aria-controls="panel-2" id="tab-2" tabindex="-1">
      Details
    </button>
    <button role="tab" aria-selected="false" aria-controls="panel-3" id="tab-3" tabindex="-1">
      Settings
    </button>
  </div>

  <div role="tabpanel" id="panel-1" aria-labelledby="tab-1">
    <!-- Overview content -->
  </div>
  <div role="tabpanel" id="panel-2" aria-labelledby="tab-2" hidden>
    <!-- Details content -->
  </div>
  <div role="tabpanel" id="panel-3" aria-labelledby="tab-3" hidden>
    <!-- Settings content -->
  </div>
</div>

<script>
// Arrow key navigation within tabs
// Only one tab has tabindex="0" at a time (roving tabindex)
</script>
```

---

## Keyboard Patterns

### Roving Tabindex Implementation

```javascript
// For a toolbar or menu with arrow key navigation
const items = Array.from(container.querySelectorAll('[role="menuitem"]'));
let currentIndex = 0;

function updateTabindex(newIndex) {
  items[currentIndex].tabIndex = -1;
  items[newIndex].tabIndex = 0;
  items[newIndex].focus();
  currentIndex = newIndex;
}

container.addEventListener('keydown', (e) => {
  switch(e.key) {
    case 'ArrowDown':
    case 'ArrowRight':
      e.preventDefault();
      updateTabindex((currentIndex + 1) % items.length);
      break;
    case 'ArrowUp':
    case 'ArrowLeft':
      e.preventDefault();
      updateTabindex((currentIndex - 1 + items.length) % items.length);
      break;
    case 'Home':
      e.preventDefault();
      updateTabindex(0);
      break;
    case 'End':
      e.preventDefault();
      updateTabindex(items.length - 1);
      break;
  }
});
```

---

## Focus Management

### Focus Trap for Modal

```javascript
function trapFocus(element) {
  const focusableElements = element.querySelectorAll(
    'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
  );
  const firstFocusable = focusableElements[0];
  const lastFocusable = focusableElements[focusableElements.length - 1];

  element.addEventListener('keydown', (e) => {
    if (e.key === 'Tab') {
      if (e.shiftKey && document.activeElement === firstFocusable) {
        e.preventDefault();
        lastFocusable.focus();
      } else if (!e.shiftKey && document.activeElement === lastFocusable) {
        e.preventDefault();
        firstFocusable.focus();
      }
    } else if (e.key === 'Escape') {
      closeModal();
    }
  });

  firstFocusable.focus();
}
```

---

**Last Updated**: January 18, 2026
