---
name: no-sensitive-commits
description: Reminds Claude never to include sensitive personal information in git commit messages
---

# No Sensitive Information in Commit Messages

When writing git commit messages, NEVER include:

- **Full names** of people (team members, clients, customers, etc.)
- **Phone numbers**
- **Email addresses**
- **Physical addresses**
- **Any other personally identifiable information (PII)**

## How to write commit messages instead

Describe *what* changed and *why*, not *who* it is about:

| Instead of... | Use... |
|---|---|
| "Update Kermit Frog's photo" | "Update team member photo" |
| "Fix Jane Doe's bio" | "Update team member bio" |
| "Add contact for 555-321-1234" | "Add contact phone number" |
| "Add john@example.com to footer" | "Add contact email to footer" |

This protects personal privacy and keeps sensitive data out of version control history, which is difficult to fully erase once pushed to a remote.
