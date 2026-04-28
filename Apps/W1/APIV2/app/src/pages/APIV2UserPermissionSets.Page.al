
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.API.V2;

using System.Security.AccessControl;

page 20769 "APIV2 - User Permission Sets"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'User Permission Set';
    EntitySetCaption = 'User Permission Sets';
    EntityName = 'userPermissionSet';
    EntitySetName = 'userPermissionSets';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DataAccessIntent = ReadOnly;
    PageType = API;
    SourceTable = "User Permissions Buffer";
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
                field(userSecurityId; Rec."User Security ID")
                {
                    Caption = 'User Security Id';
                }
                field(type; Rec.Type)
                {
                    Caption = 'Type';
                }
                field(roleId; Rec."Role ID")
                {
                    Caption = 'Role Id';
                }
                field(roleName; Rec."Role Name")
                {
                    Caption = 'Role Name';
                }
                field(securityGroupCode; Rec.SecurityGroupCode)
                {
                    Caption = 'Security Group Code';
                }
                field(company; Rec."Company Name")
                {
                    Caption = 'Company';
                }
                field(scope; Rec.Scope)
                {
                    Caption = 'Scope';
                }
                field(appId; Rec."App ID")
                {
                    Caption = 'App Id';
                }
                field(appName; Rec."App Name")
                {
                    Caption = 'App Name';
                }
            }
        }
    }

    trigger OnInit()
    begin
        Rec.FillBuffer();
    end;
}
