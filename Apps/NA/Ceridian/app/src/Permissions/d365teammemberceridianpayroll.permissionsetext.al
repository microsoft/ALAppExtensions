namespace Microsoft.Payroll.Ceridian;

using System.Security.AccessControl;

permissionsetextension 15360 "D365 TEAM MEMBER - Ceridian Payroll" extends "D365 TEAM MEMBER"
{
    Permissions = tabledata "MS Ceridian Payroll Setup" = R;
}
