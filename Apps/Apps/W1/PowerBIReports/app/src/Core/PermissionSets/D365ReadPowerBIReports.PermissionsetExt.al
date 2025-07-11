namespace Microsoft.PowerBIReports;
using System.Security.AccessControl;

permissionsetextension 36952 "D365 READ PowerBI Reports" extends "D365 READ"
{
    IncludedPermissionSets = "PowerBi Report Basic";
}