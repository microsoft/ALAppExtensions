namespace Microsoft.SubscriptionBilling;

using System.Security.AccessControl;

permissionsetextension 8051 "Sub. Billing D365 Setup" extends "D365 SETUP"
{
    IncludedPermissionSets = "Sub. Billing Admin";
}