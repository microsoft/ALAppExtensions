// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 8890 "Sent Email For User"
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

        field(5; "User Security Id"; Guid)
        {
            DataClassification = SystemMetadata; // Only in memory
        }

        field(6; Description; Text[2048])
        {
            DataClassification = SystemMetadata; // Only in memory
        }

        field(7; "Date Time Sent"; DateTime)
        {
            DataClassification = SystemMetadata;
        }

        field(10; Sender; Code[50])
        {
            FieldClass = FlowField;
            CalcFormula = Lookup(User."User Name" where("User Security ID" = field("User Security Id")));
        }
        field(13; "Sent From"; Text[250])
        {
            DataClassification = SystemMetadata; // Only in memory
        }
    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(Message; "Message Id")
        {
        }
    }
}