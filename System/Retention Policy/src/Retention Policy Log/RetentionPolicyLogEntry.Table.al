// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 3905 "Retention Policy Log Entry"
{
    Extensible = false;
    Access = Internal;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(3; "Session Id"; Integer)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "User Id"; Code[50])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(User."User Name" where("User Security Id" = field(SystemCreatedBy)));
            Editable = false;
        }
        field(5; Category; Enum "Retention Policy Log Category")
        {
            DataClassification = SystemMetadata;
        }
        field(6; "Message Type"; Enum "Retention Policy Log Message Type")
        {
            DataClassification = SystemMetadata;
        }
        field(7; Message; Text[2048])
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Message Type")
        {

        }
    }
}