namespace Microsoft.API.FinancialManagement;

using System.Security.AccessControl;

permissionsetextension 30303 "D365 READ - Reports Finance" extends "D365 READ"
{
    IncludedPermissionSets = "API Reports Finance - Objects";
}
