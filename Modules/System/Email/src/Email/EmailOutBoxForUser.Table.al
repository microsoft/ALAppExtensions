// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary></summary>
table 8891 "Email Outbox For User"
{
    Access = Internal;
    TableType = Temporary;

    fields
    {
        field(1; Id; BigInteger)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }

        field(2; "Message Id"; Guid)
        {
            DataClassification = SystemMetadata;
            TableRelation = "Email Message".Id;
        }

        field(3; "Account Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }

        field(4; Connector; Enum "Email Connector")
        {
            DataClassification = SystemMetadata;
        }

        field(5; Status; Enum "Email Status")
        {
            DataClassification = SystemMetadata;
        }

        field(6; "User Security Id"; Guid)
        {
            DataClassification = SystemMetadata; // Only in memory
        }

        field(7; "Task Scheduler Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }

        field(8; Description; Text[2048])
        {
            DataClassification = SystemMetadata; // Only in memory
        }

        field(9; "Error Message"; Text[2048])
        {
            DataClassification = SystemMetadata; // Only in memory
        }

        field(10; Sender; Code[50])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(User."User Name" where("User Security ID" = field("User Security Id")));
        }

        field(11; "Date Queued"; DateTime)
        {
            DataClassification = SystemMetadata;
        }

        field(12; "Date Failed"; DateTime)
        {
            DataClassification = SystemMetadata;
        }

        field(13; "Send From"; Text[250])
        {
            DataClassification = SystemMetadata; // Only in Memory
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(MessageStatus; "Message Id", Status)
        {
        }
    }
}