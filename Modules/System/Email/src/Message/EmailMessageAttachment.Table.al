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
            ObsoleteState = Removed;
            ObsoleteReason = 'Field has been replaced with the media field, Data.';
            ObsoleteTag = '18.1';
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

        field(8; Length; Integer)
        {
            DataClassification = SystemMetadata;
        }

        field(9; Data; Media)
        {
            DataClassification = CustomerContent;
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