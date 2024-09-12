namespace Microsoft.SubscriptionBilling;

using System.Security.AccessControl;

permissionsetextension 8055 "Sub. Billing D365 Team Member" extends "D365 TEAM MEMBER"
{
    IncludedPermissionSets = "Sub. Billing Basic";
}