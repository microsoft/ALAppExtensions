// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.AccessControl;

page 2149 "APIV2 - Access Control"
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
                field(userSecurityID; Rec."User Security ID")
                {
                    Caption = 'User Security ID';
                }
                field(roleID; Rec."Role ID")
                {
                    Caption = 'Role ID';
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
                field(appID; Rec."App ID")
                {
                    Caption = 'App ID';
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