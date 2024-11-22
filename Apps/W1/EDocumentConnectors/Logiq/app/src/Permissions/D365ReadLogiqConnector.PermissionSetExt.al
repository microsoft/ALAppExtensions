namespace Microsoft.EServices.EDocumentConnector.Logiq;

using System.Security.AccessControl;

permissionsetextension 6380 "D365 Read - Logiq Connector" extends "D365 READ"
{
    IncludedPermissionSets = "Edit - Logiq";
}
