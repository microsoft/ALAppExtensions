// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays a list of the plans assigned to users.
/// </summary>
table 9005 "User Plan"
{
    Caption = 'User Plan';
    DataPerCompany = false;
    ReplicateData = false;
    Access = Internal;

    fields
    {
        field(1; "User Security ID"; Guid)
        {
            Caption = 'User Security ID';
            DataClassification = EndUserPseudonymousIdentifiers;
            TableRelation = User."User Security ID";
        }
        field(2; "Plan ID"; Guid)
        {
            Caption = 'Plan ID';
            TableRelation = Plan."Plan ID";
        }
        field(10; "User Name"; Code[50])
        {
            CalcFormula = Lookup (User."User Name" WHERE("User Security ID" = FIELD("User Security ID")));
            Caption = 'User Name';
            FieldClass = FlowField;
        }
        field(11; "User Full Name"; Text[80])
        {
            CalcFormula = Lookup (User."Full Name" WHERE("User Security ID" = FIELD("User Security ID")));
            Caption = 'Full Name';
            FieldClass = FlowField;
        }
        field(12; "Plan Name"; Text[50])
        {
            CalcFormula = Lookup (Plan.Name WHERE("Plan ID" = FIELD("Plan ID")));
            Caption = 'Plan Name';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Plan ID", "User Security ID")
        {
            Clustered = true;
        }
    }
}