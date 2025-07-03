# UI/UX Customization Guide

## 🎨 Custom Themes

### Creating Your Own Theme
1. Copy either `ui/dark_theme.qss` or `ui/light_theme.qss`
2. Rename it to `ui/custom_theme.qss`
3. Modify the color values to match your brand
4. Update the theme selection logic in `main.py`

### Color Customization
```css
/* Primary Colors */
--primary-bg: #your-color-here;
--secondary-bg: #your-color-here;
--accent-color: #your-color-here;

/* Text Colors */
--text-primary: #your-color-here;
--text-secondary: #your-color-here;
--text-muted: #your-color-here;
```

## 🖼️ Visual Customization

### Changing Border Radius
Update the `border-radius` values in your theme file:
```css
QFrame {
    border-radius: 16px; /* Adjust this value */
}

QPushButton {
    border-radius: 12px; /* Adjust this value */
}
```

### Adjusting Spacing
Modify padding and margins in the theme files:
```css
QFrame {
    padding: 20px; /* Internal spacing */
    margin: 8px;   /* External spacing */
}
```

### Custom Gradients
Create your own gradient effects:
```css
QPushButton {
    background: qlineargradient(x1:0, y1:0, x2:1, y2:1, 
                               stop:0 #start-color, 
                               stop:1 #end-color);
}
```

## 🔧 Layout Customization

### Sidebar Width
Adjust the sidebar width in `main.py`:
```python
# In __init__ method
self.left_panel.setMaximumWidth(400)  # Wider sidebar
self.left_panel.setMinimumWidth(350)  # Wider sidebar

# In resizeEvent method
if window_width < 1200:
    self.left_panel.setMaximumWidth(300)  # Compact mode
    self.left_panel.setMinimumWidth(250)  # Compact mode
```

### Window Sizing
Modify the default window size:
```python
# In __init__ method
self.setMinimumSize(1600, 1000)  # Larger minimum
self.resize(1800, 1200)          # Larger default
```

## 🎯 Task Card Customization

### Card Appearance
```css
#TaskWidget {
    min-height: 120px;           /* Taller cards */
    padding: 24px;               /* More padding */
    border-radius: 20px;         /* Rounder corners */
    border: 2px solid #color;    /* Thicker borders */
}
```

### Typography
```css
#TaskTitle {
    font-size: 18px;             /* Larger titles */
    font-weight: 700;            /* Bolder text */
    margin-bottom: 12px;         /* More spacing */
}

#TaskNotes {
    font-size: 15px;             /* Larger notes */
    line-height: 1.6;            /* Better readability */
}
```

## 🌈 Advanced Styling

### Glassmorphism Effects
```css
QFrame {
    background: rgba(255, 255, 255, 0.1);
    backdrop-filter: blur(20px);
    border: 1px solid rgba(255, 255, 255, 0.2);
}
```

### Hover Animations
```css
QPushButton:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.2);
    transition: all 0.3s ease;
}
```

### Custom Scrollbars
```css
QScrollBar:vertical {
    width: 16px;                 /* Wider scrollbar */
    background: transparent;
    border-radius: 8px;
}

QScrollBar::handle:vertical {
    background: #your-color;
    border-radius: 8px;
    min-height: 40px;
}
```

## 📱 Responsive Design Tips

### Breakpoints
```python
def update_responsive_layout(self):
    window_width = self.width()
    
    if window_width < 1200:
        # Mobile/tablet layout
        self.apply_compact_layout()
    elif window_width < 1600:
        # Desktop layout
        self.apply_normal_layout()
    else:
        # Large desktop layout
        self.apply_expanded_layout()
```

### Adaptive Typography
```css
/* For smaller screens */
@media (max-width: 1200px) {
    #TaskTitle {
        font-size: 14px;
    }
    
    #TaskNotes {
        font-size: 12px;
    }
}
```

## 🎨 Brand Integration

### Logo Integration
```python
# Add your logo to the sidebar
logo_label = QLabel()
logo_pixmap = QPixmap("assets/your-logo.png")
logo_label.setPixmap(logo_pixmap.scaled(200, 60, Qt.AspectRatioMode.KeepAspectRatio))
left_panel_layout.addWidget(logo_label)
```

### Brand Colors
```css
/* Use your brand colors */
#AddTaskButton {
    background: qlineargradient(x1:0, y1:0, x2:1, y2:1, 
                               stop:0 #your-brand-color-1, 
                               stop:1 #your-brand-color-2);
}
```

## 🔍 Accessibility Improvements

### High Contrast Mode
```css
/* Add a high contrast theme */
QMainWindow {
    background-color: #000000;
    color: #ffffff;
}

QPushButton {
    background-color: #ffffff;
    color: #000000;
    border: 2px solid #ffffff;
}
```

### Font Size Options
```python
def set_font_size(self, size):
    if size == "small":
        self.setStyleSheet(self.current_theme + "* { font-size: 10px; }")
    elif size == "large":
        self.setStyleSheet(self.current_theme + "* { font-size: 16px; }")
```

## 🚀 Performance Tips

### Optimize CSS
- Use specific selectors instead of universal ones
- Minimize the use of complex gradients
- Combine similar styles

### Efficient Updates
```python
# Batch style updates
def update_theme_colors(self, colors):
    style_updates = []
    for selector, color in colors.items():
        style_updates.append(f"{selector} {{ background-color: {color}; }}")
    
    self.setStyleSheet('\n'.join(style_updates))
```

## 📊 Testing Your Changes

### Visual Testing
1. Test both light and dark themes
2. Try different window sizes
3. Check hover states and animations
4. Verify text readability

### Cross-Platform Testing
- Test on different operating systems
- Check font rendering
- Verify color accuracy
- Test accessibility features

## 🎨 Resources

### Color Palettes
- [Coolors.co](https://coolors.co/) - Color palette generator
- [Adobe Color](https://color.adobe.com/) - Professional color tools
- [Material Design Colors](https://materialui.co/colors) - Material design palette

### Typography
- [Google Fonts](https://fonts.google.com/) - Free font library
- [Font Squirrel](https://www.fontsquirrel.com/) - Font resources
- [Inter Font](https://rsms.me/inter/) - Modern UI font (currently used)

### Design Inspiration
- [Dribbble](https://dribbble.com/) - Design inspiration
- [Behance](https://www.behance.net/) - Creative portfolios
- [UI Movement](https://uimovement.com/) - UI design patterns

---

## 🧩 Advanced UI/UX Pro Tips

### 1. Micro-Interactions
Add subtle animations for actions like task completion, button clicks, or drag-and-drop. In PyQt, you can animate widget properties (e.g., fade, scale, color transitions) using QPropertyAnimation.

### 2. Shadow and Depth
Use shadow effects for cards and modals to create a sense of depth:
```css
QFrame {
    /* ...existing code... */
    box-shadow: 0 8px 32px rgba(0,0,0,0.18);
}
```
For PyQt, use `QGraphicsDropShadowEffect` for real shadow effects.

### 3. Smooth Transitions
Add `transition` properties to QSS for hover/focus states:
```css
QPushButton, #TaskWidget {
    transition: all 0.25s cubic-bezier(0.4,0,0.2,1);
}
```

### 4. Custom Cursor
Change the cursor for interactive elements:
```css
QPushButton, #TaskWidget {
    cursor: pointer;
}
```

### 5. Accessibility (A11y)
- Ensure all icons have tooltips.
- Use high-contrast color pairs for text/background.
- Support keyboard navigation (Tab, Enter, Space).
- Add ARIA labels where possible.

### 6. User Personalization
Allow users to:
- Save their preferred theme and font size.
- Choose accent colors.
- Toggle compact/comfortable layout modes.

### 7. Mobile/Touch Support
If you plan to run on touch devices, increase hit areas and spacing, and test with touch input.

### 8. Consistent Iconography
Use a single icon set (e.g., FontAwesome, Material Icons) and keep icon sizes consistent.

### 9. Feedback for Actions
Show snackbars, toasts, or subtle popups for actions like saving, errors, or task completion.

### 10. Empty States & Loading
Design friendly empty states for lists and loading skeletons for better perceived performance.

---

## 🏆 Final Polish Checklist

- [ ] All corners are rounded and consistent.
- [ ] No sharp color clashes; all colors are harmonious.
- [ ] All interactive elements have hover/focus/active states.
- [ ] The app looks great at all window sizes.
- [ ] All text is readable and accessible.
- [ ] Animations are smooth and not distracting.
- [ ] The app feels “alive” and responsive.

---

Feel free to use these advanced tips to keep iterating toward a world-class, modern UI/UX! If you want code samples for any of these advanced features, just ask.
