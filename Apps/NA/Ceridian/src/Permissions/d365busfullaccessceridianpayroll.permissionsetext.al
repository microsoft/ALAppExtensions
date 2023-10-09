namespace Microsoft.Payroll.Ceridian;

using System.Security.AccessControl;

permissionsetextension 45740 "D365 BUS FULL ACCESS - Ceridian Payroll" extends "D365 BUS FULL ACCESS"
{
    Permissions = tabledata "MS Ceridian Payroll Setup" = RIMD;
}
