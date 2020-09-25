// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary></summary>
table 8904 "Email Message Attachment"
{
    Access = Internal;

    fields
    {
        field(1; Id; BigInteger)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }

        field(2; "Email Message Id"; Guid)
        {
            DataClassification = SystemMetadata;
            TableRelation = "Email Message".Id;
        }

        field(3; Attachment; Blob)
        {
            DataClassification = CustomerContent;
        }

        field(4; "Attachment Name"; Text[250])
        {
            DataClassification = CustomerContent;
        }

        field(5; "Content Type"; Text[250])
        {
            DataClassification = SystemMetadata;
        }

        field(6; InLine; Boolean)
        {
            DataClassification = SystemMetadata;
        }

        field(7; "Content Id"; Text[40])
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

        key(MessageId; "Email Message Id")
        {

        }
    }

}