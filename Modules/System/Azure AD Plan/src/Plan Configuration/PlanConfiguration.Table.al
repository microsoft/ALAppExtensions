// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Azure.Identity;

table 9017 "Plan Configuration"
{
    Access = Internal;
    Extensible = false;
    DataPerCompany = false;
    ReplicateData = false;
    InherentEntitlements = rX;
    InherentPermissions = rX;

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
        field(3; Customized; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Customized';
            InitValue = false;
        }
        field(4; "Plan Name"; Text[50])
        {
            Editable = false;
            CalcFormula = lookup(Plan.Name where("Plan ID" = field("Plan ID")));
            Caption = 'Plan Name';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PrimaryKey; Id)
        {
            Clustered = true;
        }

        key(UniqueKey; "Plan ID")
        {
            Unique = true;
        }
    }
}