// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

table 10685 "SAF-T Export File"
{
    DataClassification = CustomerContent;
    Caption = 'SAF-T Export File';

    fields
    {
        field(1; "Export ID"; Integer)
        {
            Caption = 'Export ID';
            Editable = false;
        }
        field(2; "File No."; Integer)
        {
            Caption = 'File No.';
            Editable = false;
        }
        field(3; "SAF-T File"; Blob)
        {
            Caption = 'SAF-T File';
        }
    }

    keys
    {
        key(PK; "Export ID", "File No.")
        {
            Clustered = true;
        }
    }
}
