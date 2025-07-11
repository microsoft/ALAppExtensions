// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

table 5280 "Missing Field SAF-T"
{
    DataClassification = CustomerContent;
    Caption = 'Missing Field SAF-T';
    TableType = Temporary;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.', Locked = true;
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.', Locked = true;
        }
        field(3; "Record ID"; RecordId)
        {
            Caption = 'Record ID', Locked = true;
        }
        field(4; "Group No."; Integer)
        {
            Caption = 'Group No.', Locked = true;
        }
        field(5; "Field Caption"; Text[1024])
        {
            Caption = 'Field Caption', Locked = true;
        }
    }

    keys
    {
        key(PK; "Table No.", "Field No.")
        {
            Clustered = true;
        }
        key(Group; "Table No.", "Group No.")
        {
        }
    }

}
