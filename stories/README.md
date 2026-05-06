# Daily Progress & Stories Micro-Blogging System

Complete implementation guide for integrating a dynamic, database-driven story system into your cinematic HTML portfolio.

## 📋 Overview

This system enables you to:
- **Public**: Display daily progress updates in a beautiful glassmorphic feed
- **Admin-Only**: Securely publish new stories via password-protected dashboard
- **Secure**: Uses bcrypt hashing, prepared statements, and session validation

---

## 🗂️ File Structure

```
portfolio/
├── db/
│   └── schema.sql                  # Database schema & initialization
├── config/
│   └── db.php                      # Database connection & security utilities
├── api/
│   ├── login.php                   # Admin authentication handler
│   ├── upload.php                  # Image upload & story submission
│   └── get-feed.php                # Public API for fetching stories
├── stories/
│   ├── index.php                   # Public feed page
│   ├── admin-dashboard.php         # Admin publishing interface
│   └── logout.php                  # Logout handler
└── uploads/                        # (Create this directory, make writable)
    ├── 2026/
    │   └── 05/
    │       └── (images will be stored here)
    └── .htaccess                   # Prevent script execution
```

---

## 🚀 Installation Steps

### 1. **Create the Database**

```bash
# Import the schema
mysql -u root -p < db/schema.sql
```

Or manually run the queries in `db/schema.sql` via phpMyAdmin.

### 2. **Configure Database Connection**

Edit `config/db.php` and update:

```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', 'your_password');
define('DB_NAME', 'portfolio_stories');
```

### 3. **Create Uploads Directory**

```bash
mkdir -p uploads/
chmod 755 uploads/
```

Create `.htaccess` file in `uploads/` folder:

```apache
# Prevent PHP execution in uploads
<FilesMatch "\.php$">
    Deny from all
</FilesMatch>

# Allow common image formats
<FilesMatch "\.(jpg|jpeg|png|webp|gif)$">
    Allow from all
</FilesMatch>
```

### 4. **Set Admin Password**

Generate a bcrypt hash for your admin password:

```bash
php -r "echo password_hash('your_secure_password', PASSWORD_BCRYPT);"
```

Update the `admin_users` table in `db/schema.sql` with your hash, OR run:

```sql
UPDATE admin_users 
SET password_hash = '$2y$10$...' 
WHERE username = 'admin';
```

### 5. **Create Logs Directory**

```bash
mkdir -p logs/
chmod 755 logs/
```

### 6. **Test the System**

- **View Feed**: Visit `/stories/index.php`
- **Access Admin**: Press `Ctrl+Shift+L` or triple-click the title on the feed page
- **Login**: Use username `admin` and your password
- **Publish**: Fill form on dashboard and click "Publish Story"

---

## 🔐 Security Features Explained

### **1. Bcrypt Password Hashing** (`config/db.php` & `api/login.php`)

```php
// Hashing during registration/update:
$hash = password_hash($password, PASSWORD_BCRYPT);

// Verification during login:
if (password_verify($submittedPassword, $storedHash)) {
    // Password is correct
}
```

**Why this matters:**
- One-way hashing (cannot reverse)
- Includes automatic salt generation
- Resistant to rainbow table attacks
- Uses bcrypt's adaptive algorithm (gets slower as hardware improves)

### **2. Prepared Statements** (`api/login.php` & `api/upload.php`)

```php
// ✅ SAFE: Uses prepared statement
$stmt = $pdo->prepare('
    SELECT id FROM stories 
    WHERE id = ? 
    LIMIT 1
');
$stmt->execute([$userInput]);

// ❌ DANGEROUS: Direct string interpolation
$query = "SELECT id FROM stories WHERE id = {$userInput}";
```

**Attack Prevention:**
- SQL injection: Attacker can't inject SQL code
- Data is treated as data, never as executable SQL
- PDO automatically escapes/quotes values

### **3. Session Security** (`config/db.php`)

```php
session_set_cookie_params([
    'httponly' => true,        // Prevent JavaScript access
    'secure' => true,          // HTTPS only in production
    'samesite' => 'Strict'     // CSRF protection
]);
```

### **4. File Upload Validation** (`api/upload.php`)

```php
// 1. Whitelist extension
if (!in_array($fileExtension, ALLOWED_EXTENSIONS)) { /* reject */ }

// 2. Validate MIME type
$mimeType = finfo_file(finfo_open(FILEINFO_MIME_TYPE), $filePath);
if (!array_key_exists($mimeType, ALLOWED_MIME_TYPES)) { /* reject */ }

// 3. Verify it's actually an image
$imageInfo = @getimagesize($filePath);
if ($imageInfo === false) { /* reject */ }

// 4. Use move_uploaded_file() (prevents directory traversal)
move_uploaded_file($tmpPath, $finalPath);

// 5. Unique filename (prevents overwriting)
$newName = "{$date}-{$timestamp}-{$randomId}.jpg";
```

---

## 🎨 Customization Guide

### **Change Admin Password**

```php
// In PHP:
php -r "echo password_hash('mynewpassword', PASSWORD_BCRYPT);"

// Then update database:
UPDATE admin_users SET password_hash = '$2y$10$...' WHERE id = 1;
```

### **Adjust File Size Limit**

In `config/db.php`:

```php
define('MAX_FILE_SIZE', 10 * 1024 * 1024); // 10MB
```

### **Change Session Timeout**

In `config/db.php`:

```php
define('SESSION_TIMEOUT', 7200); // 2 hours instead of 1
```

### **Modify UI Colors**

In `stories/index.php` or `admin-dashboard.php`, edit CSS variables:

```css
:root {
    --accent-blue: #6b9eff;
    --accent-purple: #c084d5;
    /* Change these to your brand colors */
}
```

### **Add Custom Fields**

Update the database schema in `db/schema.sql`:

```sql
ALTER TABLE stories ADD COLUMN custom_field VARCHAR(255);
```

Update `api/upload.php` to handle new field:

```php
$customValue = $_POST['custom_field'] ?? '';
$stmt = $pdo->prepare('INSERT INTO stories (image_path, story_text, custom_field) VALUES (?, ?, ?)');
$stmt->execute([$imagePath, $storyText, $customValue]);
```

---

## 🐛 Troubleshooting

### **"Database connection failed"**
- Check credentials in `config/db.php`
- Verify MySQL server is running
- Ensure database name matches

### **"Upload directory error"**
- Run: `mkdir -p uploads/ && chmod 755 uploads/`
- Check web server permissions

### **"Invalid file type"**
- Ensure MIME type is in `ALLOWED_MIME_TYPES` array
- Check file isn't corrupted

### **"Session expired"**
- Default timeout is 1 hour
- Change `SESSION_TIMEOUT` in `config/db.php`

### **"CSRF token invalid"**
- Session might have expired
- Try logging in again

---

## 📊 Database Schema Reference

### **stories table**
```
id          | Primary key
image_path  | Path to uploaded image
story_text  | Story content
created_at  | Auto-generated timestamp
updated_at  | Updated timestamp
is_archived | Soft delete flag
```

### **admin_users table**
```
id              | Primary key
username        | Admin username
password_hash   | Bcrypt hash (never plain text!)
last_login      | Last login timestamp
created_at      | Account creation time
```

---

## 🔄 API Endpoints

### **GET** `/api/get-feed.php`
Fetch paginated stories
```
Query params:
- page=1
- per_page=12

Response:
{
  "success": true,
  "data": [ { id, image_path, story_text, created_at }, ... ],
  "pagination": { current_page, total_pages, ... }
}
```

### **POST** `/api/login.php`
Admin authentication
```
Body:
- username
- password
- csrf_token

Response:
{ "success": true, "redirect": "./admin-dashboard.php" }
```

### **POST** `/api/upload.php`
Submit new story (requires auth)
```
Body (multipart/form-data):
- image (file)
- story_text
- csrf_token

Response:
{ "success": true, "story_id": 123, "image_path": "..." }
```

---

## 📱 Integration with Your Portfolio

Add this link to your main portfolio page:

```html
<a href="/stories/index.php" class="portfolio-link">
    Daily Progress & Stories
</a>
```

Or embed the feed in an iframe:

```html
<iframe src="/stories/index.php" style="width: 100%; border: none; height: 800px;"></iframe>
```

---

## 🛡️ Production Checklist

- [ ] Update `DB_HOST`, `DB_USER`, `DB_PASS` with production credentials
- [ ] Set `SESSION_SECURE = true` (requires HTTPS)
- [ ] Change default admin password
- [ ] Set up automated backups for uploads/
- [ ] Configure SSL certificate
- [ ] Enable error logging (disable error_reporting display)
- [ ] Set strong `max_file_size` limit
- [ ] Regularly review logs/ folder
- [ ] Test all forms and uploads

---

## 📚 Additional Resources

- **PHP Password Hashing**: https://www.php.net/manual/en/function.password-hash.php
- **PDO Prepared Statements**: https://www.php.net/manual/en/pdo.prepared-statements.php
- **Session Security**: https://owasp.org/www-community/attacks/Session_fixation
- **OWASP File Upload**: https://owasp.org/www-community/vulnerabilities/Unrestricted_File_Upload

---

## 💬 Support

If you encounter issues:
1. Check the logs/ folder for error messages
2. Verify all files are in correct locations
3. Ensure database schema matches `db/schema.sql`
4. Test with a fresh browser (clear cookies)

---

**Happy storytelling! Your portfolio now has a powerful, secure content system.** 🚀
