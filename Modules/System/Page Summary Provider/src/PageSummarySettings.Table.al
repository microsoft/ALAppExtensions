// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Contains settings for page summary card.
/// </summary>
table 2718 "Page Summary Settings"
{
    DataClassification = SystemMetadata;
    Caption = 'Page Summary Settings';
    DataPerCompany = false;
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; Company; Guid)
        {
            Caption = 'Company';
            DataClassification = SystemMetadata;
        }
        field(2; "Show Record summary"; Boolean)
        {
            Caption = 'Show record summary';
            Description = 'Specifies if the data returned by Page Summary Provider should include record fields or not (for security and privacy reasons).';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(Key1; Company)
        {
        }
    }

    fieldgroups
    {
    }
}
