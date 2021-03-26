// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 1991 "Checklist Item"
{
    Access = Internal;

    fields
    {
        field(1; Code; Code[300])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
            TableRelation = "Guided Experience Item".Code;
        }
        field(2; "Completion Requirements"; Enum "Checklist Completion Requirements")
        {
            Caption = 'Completion Requirements';
            DataClassification = SystemMetadata;
        }
        field(3; "Order ID"; Integer)
        {
            Caption = 'Order ID';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
        key(Key2; "Order ID")
        {

        }
    }
}