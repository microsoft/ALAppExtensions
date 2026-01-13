namespace Microsoft.Payroll.Ceridian;

using System.Security.AccessControl;

permissionsetextension 16465 "D365 READ - Ceridian Payroll" extends "D365 READ"
{
    Permissions = tabledata "MS Ceridian Payroll Setup" = R;
}
