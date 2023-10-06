namespace Microsoft.Payroll.Ceridian;

using System.Security.AccessControl;

permissionsetextension 33090 "D365 FULL ACCESS - Ceridian Payroll" extends "D365 FULL ACCESS"
{
    Permissions = tabledata "MS Ceridian Payroll Setup" = RIMD;
}
