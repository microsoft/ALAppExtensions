// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 8901 "Email Error"
{
    Extensible = false;
    Access = Internal;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }

        field(2; "Outbox Id"; BigInteger)
        {
            DataClassification = SystemMetadata;
            TableRelation = "Email Outbox".Id;
        }

        field(3; "Error Message"; Blob)
        {
            DataClassification = CustomerContent;
        }

        field(4; "Error Callstack"; Blob)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(OutboxId; "Outbox Id")
        {
        }
    }

}