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
        field(1; "Table No."; Integer) { }
        field(2; "Field No."; Integer) { }
        field(3; "Record ID"; RecordId) { }
        field(4; "Group No."; Integer) { }
        field(5; "Field Caption"; Text[1024]) { }
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
