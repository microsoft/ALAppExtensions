// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 9018 "Custom Permission Set In Plan"
{
    Caption = 'Custom Permissions In License';
    Access = Internal;
    Extensible = false;
    DataPerCompany = false;
    ReplicateData = false;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Plan ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Plan ID';
            TableRelation = Plan."Plan ID";
        }
        field(3; "Role ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Permission Set';
            TableRelation = "Aggregate Permission Set"."Role ID";
        }
        field(4; "Role Name"; Text[30])
        {
            CalcFormula = Lookup("Permission Set".Name Where("Role ID" = Field("Role ID")));
            Caption = 'Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(5; "App ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'App ID';
        }
        field(6; "App Name"; Text[250])
        {
            CalcFormula = Lookup("Published Application".Name Where(ID = Field("App ID"), "Tenant Visible" = Const(true)));
            Caption = 'Extension Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; Scope; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Scope';
            OptionCaption = 'System,Tenant';
            OptionMembers = System,Tenant;
        }
        field(8; "Company Name"; Text[30])
        {
            DataClassification = SystemMetadata;
            Caption = 'Company Name';
            TableRelation = Company;
        }
    }

    keys
    {
        key(PrimaryKey; Id)
        {
            Clustered = true;
        }

        key(UniqueKey; "Plan ID", "Role ID", "Company Name", Scope, "App ID")
        {
            Unique = true;
        }
    }

    trigger OnInsert()
    begin
        PlanConfiguration.VerifyUserHasRequiredPermissionSet(Rec."Role ID", Rec."App ID", Rec.Scope, Rec."Company Name");
    end;

    trigger OnDelete()
    begin
        PlanConfiguration.VerifyUserHasRequiredPermissionSet(Rec."Role ID", Rec."App ID", Rec.Scope, Rec."Company Name");
        PlanConfiguration.OnCustomPermissionSetChange(Rec."Plan ID", Rec."Role ID", Rec."App ID", Rec.Scope, Rec."Company Name");
    end;

    trigger OnModify()
    begin
        PlanConfiguration.VerifyUserHasRequiredPermissionSet(Rec."Role ID", Rec."App ID", Rec.Scope, Rec."Company Name");

        if (Rec."Company Name" <> xRec."Company Name") or (Rec."Role ID" <> xRec."Role ID") then
            PlanConfiguration.OnCustomPermissionSetChange(xRec."Plan ID", xRec."Role ID", xRec."App ID", xRec.Scope, xRec."Company Name");
    end;

    trigger OnRename()
    begin
        PlanConfiguration.VerifyUserHasRequiredPermissionSet(Rec."Role ID", Rec."App ID", Rec.Scope, Rec."Company Name");

        if (Rec."Company Name" <> xRec."Company Name") or (Rec."Role ID" <> xRec."Role ID") then
            PlanConfiguration.OnCustomPermissionSetChange(xRec."Plan ID", xRec."Role ID", xRec."App ID", xRec.Scope, xRec."Company Name");
    end;

    var
        PlanConfiguration: Codeunit "Plan Configuration";
}