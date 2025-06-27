// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

/// <summary>
/// E-Document Data Storage Table
/// This table stores binary data that is associated with a E-Document Log Entry.
/// </summary>
table 6125 "E-Doc. Data Storage"
{
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Data Storage"; Blob)
        {
            Caption = 'Data Storage';
            ToolTip = 'Specifies the binary data.';
        }
        field(3; "Data Storage Size"; Integer)
        {
            Caption = 'Data Storage Size';
            ToolTip = 'Specifies the size of the binary data.';
        }
        field(4; "Data Type"; Enum "E-Doc. Data Storage Blob Type")
        {
            Caption = 'Data Type';
            ToolTip = 'Specifies the type of the binary data.';
        }
        field(5; "Name"; Text[256])
        {
            Caption = 'Name';
            ToolTip = 'Specifies the name of the binary data.';
        }
        field(6; "Is Structured"; Boolean)
        {
            Caption = 'Is Structured';
            ToolTip = 'Specifies whether the binary data is structured and can be read.';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

}
