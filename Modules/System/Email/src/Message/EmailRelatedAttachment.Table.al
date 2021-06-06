// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Temporary table that holds information about attachments related to an email.
/// </summary>
table 8910 "Email Related Attachment"
{
    Access = Public;
    TableType = Temporary;

    fields
    {
        field(1; Id; BigInteger)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Attachment Name"; Text[1024])
        {
            DataClassification = CustomerContent;
        }
        field(3; "Attachment System ID"; Guid)
        {
            DataClassification = SystemMetadata;
        }
        field(4; "Attachment Table ID"; Integer)
        {
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; Id, "Attachment Name", "Attachment System ID")
        {
            Clustered = true;
        }
    }

}