# Document Attachments External Storage for Microsoft Dynamics 365 Business Central

## Overview

The External Storage extension provides seamless integration between Microsoft Dynamics 365 Business Central and external storage systems such as Azure Blob Storage, SharePoint, and File Shares. This extension automatically manages document attachments by storing them in external storage systems while maintaining full functionality within Business Central.

## Key Features

### **Automatic Upload**
- Automatically uploads new document attachments to configured external storage
- Supports multiple storage connectors via the File Account framework
- Generates unique file names to prevent collisions
- Maintains original file metadata and associations

### **Flexible Deletion Policies**
- **Immediately**: Delete from internal storage right after external upload
- **1 Day**: Keep internally for 1 day before deletion
- **7 Days**: Keep internally for 7 days before deletion (default)
- **14 Days**: Keep internally for 14 days before deletion

### **Bulk Operations**
- Synchronize multiple files between internal and external storage
- Bulk upload to external storage
- Bulk download from external storage
- Progress tracking with detailed reporting

## Installation & Setup

### Prerequisites
- Microsoft Dynamics 365 Business Central version 27.0 or later
- File Account module configured with external storage connector
- Appropriate permissions for file operations

### Installation Steps

1. **Configure File Account**
   - Open **File Accounts** page
   - Create a new File Account with your preferred connector:
     - Azure Blob Storage
     - SharePoint
     - File Share
   - Assign the account to **External Storage** scenario

2. **Configure External Storage**
   - Open **File Accounts** page
   - Select assigned **External Storage** scenario
   - Open **Additional Scenario Setup**
   - Configure settings:
     - **Auto Upload**: Enable automatic upload of new attachments
     - **Delete After**: Set retention policy for internal storage

### Configuration Options

#### Auto Upload Settings
- **Enabled**: New document attachments are automatically uploaded to external storage
- **Disabled**: Manual upload required via actions

## Usage

### Automatic Mode
When Auto Upload is enabled:
1. User attaches a document to any Business Central record
2. System automatically uploads to external storage
3. File remains accessible through standard attachment functionality
4. Internal file is deleted based on configured retention policy

### Manual Operations

#### Individual File Operations
From **Document Attachment - External** page:
- **Upload to External Storage**: Upload selected file
- **Download from External Storage**: Download file for viewing
- **Download to Internal Storage**: Restore file to internal storage
- **Delete from External Storage**: Remove file from external storage
- **Delete from Internal Storage**: Remove file from internal storage

#### Bulk Operations
From **External Storage Synchronize** report:
- **To External Storage**: Upload multiple files to external storage
- **From External Storage**: Download multiple files from external storage
- **Delete Expired Files**: Clean up files based on retention policy

### File Access
- Files uploaded to external storage remain fully accessible through standard Business Central functionality
- Document preview, download, and management work seamlessly
- No change to end-user experience

**© 2025 Microsoft Corporation. All rights reserved.**
