// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Temporary table used to display the tree sctructure in "Email Scenario Setup".
/// </summary>
table 8907 "Email Account Scenario"
{
    Access = Internal;
    TableType = Temporary;

    fields
    {
        field(1; Scenario; Integer)
        {
            DataClassification = SystemMetadata;
        }

        field(2; Connector; Enum "Email Connector")
        {
            DataClassification = SystemMetadata;
        }

        field(3; "Account Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }

        field(4; "Display Name"; Text[2048])
        {
            DataClassification = SystemMetadata;
        }

        field(5; Default; Boolean)
        {
            DataClassification = SystemMetadata;
        }

        field(6; EntryType; Option)
        {
            DataClassification = SystemMetadata;
            OptionMembers = Account,Scenario;
        }

        field(7; Position; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; Scenario, "Account Id", Connector)
        {
            Clustered = true;
        }

        key(Position; Position)
        {

        }

        key(Name; "Display Name")
        {
            Description = 'Used for sorting by Dispay Name';
        }
    }
}