// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary></summary>
table 8888 "Email Outbox"
{
    Access = Internal;

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
            DataClassification = EndUserPseudonymousIdentifiers;
        }

        field(7; "Task Scheduler Id"; Guid)
        {
            DataClassification = SystemMetadata;
        }

        field(8; Description; Text[2048])
        {
            DataClassification = CustomerContent;
        }

        field(9; "Error Message"; Text[2048])
        {
            DataClassification = CustomerContent;
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
            DataClassification = EndUserIdentifiableInformation;
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