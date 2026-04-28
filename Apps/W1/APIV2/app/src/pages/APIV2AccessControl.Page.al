// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.API.V2;

using System.Security.AccessControl;

page 20767 "APIV2 - Access Control"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Access Control';
    EntitySetCaption = 'Access Controls';
    EntityName = 'accessControl';
    EntitySetName = 'accessControls';
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "Access Control";
    ODataKeyFields = SystemId;
    DataAccessIntent = ReadOnly;

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
                field(roleId; Rec."Role ID")
                {
                    Caption = 'Role Id';
                }
                field(roleName; Rec."Role Name")
                {
                    Caption = 'Role Name';
                }
                field(company; Rec."Company Name")
                {
                    Caption = 'Company';
                }
                field(userName; Rec."User Name")
                {
                    Caption = 'User Name';
                }
                field(fullName; UserFullName)
                {
                    Caption = 'Full Name';
                }
                field(userLicenseType; UserLicenseType)
                {
                    Caption = 'User License Type';
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

    var
        User: Record User;
        UserFullName: Text;
        UserLicenseType: Text;

    trigger OnAfterGetRecord()
    begin
        User.SetLoadFields("Full Name", "License Type");
        if User."User Security ID" <> Rec."User Security ID" then
            if User.Get(Rec."User Security ID") then begin
                UserFullName := User."Full Name";
                UserLicenseType := Format(User."License Type");
            end else begin
                UserFullName := '';
                UserLicenseType := '';
            end;
    end;
}