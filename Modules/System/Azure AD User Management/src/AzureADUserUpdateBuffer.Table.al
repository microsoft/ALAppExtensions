// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Stores information about properties changed for users in Office 365 in-memory.
/// </summary>
#pragma warning disable AS0039
table 9010 "Azure AD User Update Buffer"
{
    Caption = 'Azure AD User Updates';
    ReplicateData = false;
    Access = Internal;
#pragma warning disable AS0034
    TableType = Temporary;
#pragma warning restore AS0034

    fields
    {
        field(1; "Authentication Object ID"; Text[80])
        {
            Caption = 'Authentication Object ID';
            Editable = false;
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(2; "Update Entity"; Enum "Azure AD User Update Entity")
        {
            Caption = 'Update Entity';
            Editable = false;
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                UserPermissions: Codeunit "User Permissions";
            begin
                if "Update Entity" <> "Update Entity"::Plan then
                    exit;

                case "Update Type" of
                    "Update Type"::New:
                        begin
                            "Needs User Review" := false;
                            "Permission Change Action" := "Permission Change Action"::Append;
                        end;
                    "Update Type"::Change:
                        begin
                            "Needs User Review" := UserPermissions.HasUserCustomPermissions("User Security ID");
                            if "Needs User Review" then
                                "Permission Change Action" := "Permission Change Action"::Select
                            else
                                "Permission Change Action" := "Permission Change Action"::Append;
                        end;
                    "Update Type"::Remove:
                        begin
                            "Needs User Review" := false;
                            "Permission Change Action" := "Permission Change Action"::"Keep Current";
                        end;
                end;
            end;
        }
        field(3; "User Security ID"; Guid)
        {
            TableRelation = User."User Security ID";
            Caption = 'User Security ID';
            Editable = false;
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(4; "Update Type"; Enum "Azure AD Update Type")
        {
            Caption = 'Update Type';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(5; "Current Value"; Text[2048])
        {
            Caption = 'Current Value';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(6; "New Value"; Text[2048])
        {
            Caption = 'New Value';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(7; "Needs User Review"; Boolean)
        {
            Caption = 'Needs User Review';
            Editable = false;
            DataClassification = SystemMetadata;
        }
        field(8; "Permission Change Action"; enum "Azure AD Permission Change Action")
        {
            Caption = 'Handle permission change';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                "Needs User Review" := ("Update Type" = "Update Type"::Change) and ("Update Entity" = "Update Entity"::Plan) and ("Permission Change Action" = "Permission Change Action"::Select);
            end;
        }
        field(9; "Display Name"; Code[50])
        {
            Caption = 'Display Name';
            Editable = false;
            DataClassification = EndUserIdentifiableInformation;
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
#pragma warning restore AS0039
