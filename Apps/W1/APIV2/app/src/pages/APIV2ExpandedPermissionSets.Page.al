// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.AccessControl;

using System.Apps;

page 20766 "APIV2 Expanded Permission Sets"
{
    APIGroup = 'auditing';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Expanded Permission Set';
    EntitySetCaption = 'Expanded Permission Sets';
    EntityName = 'expandedPermissionSet';
    EntitySetName = 'expandedPermissionSets';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DataAccessIntent = ReadOnly;
    PageType = API;
    SourceTable = "Expanded Permission";
    SourceTableView = where(Ap = filter('<> Exclude'));
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(appID; Rec."App ID")
                {
                    Caption = 'App ID';
                }
                field(appName; AppName)
                {
                    Caption = 'App Name';
                }
                field(roleID; Rec."Role ID")
                {
                    Caption = 'Role ID';
                }
                field(roleName; Rec."Role Name")
                {
                    Caption = 'Role Name';
                }
                field(objectType; Rec."Object Type")
                {
                    Caption = 'Object Type';
                }
                field(objectID; Rec."Object ID")
                {
                    Caption = 'Object ID';
                }
                field(objectName; Rec."Object Name")
                {
                    Caption = 'Object Name';
                }
                field(readPermission; Rec."Read Permission")
                {
                    Caption = 'Read Permission';
                }
                field(insertPermission; Rec."Insert Permission")
                {
                    Caption = 'Insert Permission';
                }
                field(modifyPermission; Rec."Modify Permission")
                {
                    Caption = 'Modify Permission';
                }
                field(deletePermission; Rec."Delete Permission")
                {
                    Caption = 'Delete Permission';
                }
                field(executePermission; Rec."Execute Permission")
                {
                    Caption = 'Execute Permission';
                }
                field(alObjectName; Rec."AL Object Name")
                {
                    Caption = 'AL Object Name';
                }
                field(scope; Rec.Scope)
                {
                    Caption = 'Scope';
                }
            }
        }
    }

    var
        ExtensionManagement: Codeunit "Extension Management";
        AppName: Text;

    trigger OnAfterGetRecord()
    begin
        Clear(AppName);
        if not IsNullGuid(Rec."App ID") then
            AppName := ExtensionManagement.GetAppName(Rec."App ID");
    end;
}
