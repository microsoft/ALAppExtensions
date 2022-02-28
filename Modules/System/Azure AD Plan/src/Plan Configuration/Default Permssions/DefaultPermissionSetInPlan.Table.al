// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 9016 "Default Permission Set In Plan"
{
    Caption = 'Default Permission Set in License';
    Access = Internal;
    TableType = Temporary;

    fields
    {
        field(2; "Plan ID"; Guid)
        {
            DataClassification = SystemMetadata;
            Caption = 'Plan ID';
            TableRelation = Plan."Plan ID";
        }
        field(3; "Role ID"; Code[20])
        {
            DataClassification = SystemMetadata; // since defaults are not user-defined
            Caption = 'Permission Set';
            TableRelation = "Aggregate Permission Set"."Role ID";
        }
        field(4; "Role Name"; Text[30])
        {
            CalcFormula = Lookup("Permission Set".Name Where("Role ID" = Field("Role ID")));
            Caption = 'Name';
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
            FieldClass = FlowField;
        }
        field(7; Scope; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Scope';
            OptionCaption = 'System,Tenant';
            OptionMembers = System,Tenant;
        }
    }

    keys
    {
        key(UniqueKey; "Plan ID", "Role ID", Scope, "App ID")
        {
            Clustered = true;
        }
    }
}