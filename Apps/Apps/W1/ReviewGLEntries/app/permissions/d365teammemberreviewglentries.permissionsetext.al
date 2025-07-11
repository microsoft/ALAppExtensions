namespace Microsoft.Finance.GeneralLedger.Review;

using System.Security.AccessControl;

permissionsetextension 22213 "D365 TEAM MEMBER - Review G/L Entries" extends "D365 TEAM MEMBER"
{
    IncludedPermissionSets = "Review G/L Entries - Read";
}
