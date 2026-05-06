# Logs Directory

This directory stores application logs for debugging and security auditing.

**Log Files:**
- `YYYY-MM-DD.log` - Daily log file with all application events

**Log Entry Format:**
```
[YYYY-MM-DD HH:MM:SS] [LEVEL] Message details
```

**Log Levels:**
- `ERROR` - System errors and failures
- `WARNING` - Potential issues
- `INFO` - Informational messages (logins, uploads, etc.)

**Sensitive Data:**
Logs never contain passwords, full file contents, or private database details.
Only timestamps, usernames, action types, and error descriptions are logged.

**Security Note:**
Ensure this directory is:
- ✅ Not directly accessible via web browser
- ✅ Readable only by the web server process
- ✅ Regularly reviewed for suspicious activity
- ✅ Automatically archived after 30 days
