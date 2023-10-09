// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Email;

/// <summary>
/// Table used to get Email Attachments related to Email Scenario
/// </summary>
table 8911 "Email Scenario Attachments"
{
    Access = Public;
    Extensible = true;

    fields
    {
        field(1; Id; BigInteger)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }

        field(2; Scenario; Enum "Email Scenario")
        {
            DataClassification = SystemMetadata;
        }

        field(3; "Attachment Name"; Text[250])
        {
            DataClassification = CustomerContent;
        }

        field(4; "Email Attachment"; Media)
        {
            DataClassification = CustomerContent;
        }

        field(5; AttachmentDefaultStatus; Boolean)
        {
            DataClassification = SystemMetadata;
            TableRelation = "Email Attachments".AttachmentDefaultStatus;
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
        key(Scenario; Scenario, "Attachment Name")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Scenario, "Attachment Name")
        {
        }
    }
}