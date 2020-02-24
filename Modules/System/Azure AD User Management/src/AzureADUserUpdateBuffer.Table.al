// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Stores information about properties changed for users in Office 365 in-memory.
/// </summary>
table 9010 "Azure AD User Update Buffer"
{
    Caption = 'Azure AD User Updates';
    DataPerCompany = false;
    ReplicateData = false;
    Access = Internal;
    DataClassification = EndUserIdentifiableInformation;

    fields
    {
        field(1; "Authentication Object ID"; Text[80])
        {
            Caption = 'Authentication Object ID';
            Editable = false;
        }
        field(2; "Update Entity"; Enum "Azure AD User Update Entity")
        {
            Caption = 'Update Entity';
            Editable = false;

            trigger OnValidate()
            var
                UserPermissions: Codeunit "User Permissions";
            begin
                if "Update Entity" = "Update Entity"::Plan then begin
                    "Needs User Review" := UserPermissions.HasUserCustomPermissions("User Security ID");
                    if not "Needs User Review" then
                        "Permission Change Action" := "Permission Change Action"::Append;
                end;
            end;
        }
        field(3; "User Security ID"; Guid)
        {
            TableRelation = User."User Security ID";
            Caption = 'User Security ID';
            Editable = false;
        }
        field(4; "Update Type"; Enum "Azure AD Update Type")
        {
            Caption = 'Update Type';
            Editable = false;
        }
        field(5; "Current Value"; Text[2048])
        {
            Caption = 'Current Value';
            Editable = false;
        }
        field(6; "New Value"; Text[2048])
        {
            Caption = 'New Value';
            Editable = false;
        }
        field(7; "Needs User Review"; Boolean)
        {
            Caption = 'Needs User Review';
            Editable = false;
        }
        field(8; "Permission Change Action"; enum "Azure AD Permission Change Action")
        {
            Caption = 'Handle permission change';

            trigger OnValidate()
            begin
                "Needs User Review" := ("Update Type" = "Update Type"::Change) and ("Update Entity" = "Update Entity"::Plan) and ("Permission Change Action" = "Permission Change Action"::Select);
            end;
        }
        field(9; "Display Name"; Code[50])
        {
            Caption = 'Display Name';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Authentication Object ID", "Update Entity")
        {
            Clustered = true;
        }
    }
}