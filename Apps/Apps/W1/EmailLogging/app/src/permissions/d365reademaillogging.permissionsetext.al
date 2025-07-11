namespace Microsoft.CRM.EmailLoggin;

using System.Security.AccessControl;

permissionsetextension 1685 "D365 READ - Email Logging" extends "D365 READ"
{
    IncludedPermissionSets = "Email Logging - Read";
}
