namespace Microsoft.Finance.GeneralLedger.Review;

using System.Security.AccessControl;

permissionsetextension 22214 "D365 READ - Review G/L Entries" extends "D365 READ"
{
    IncludedPermissionSets = "Review G/L Entries - Read";
}
