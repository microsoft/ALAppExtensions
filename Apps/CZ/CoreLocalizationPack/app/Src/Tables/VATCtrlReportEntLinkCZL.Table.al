// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Finance.VAT.Ledger;

table 31110 "VAT Ctrl. Report Ent. Link CZL"
{
    Caption = 'VAT Control Report Entry Link';
    Permissions = tabledata "VAT Ctrl. Report Ent. Link CZL" = rimd;

    fields
    {
        field(1; "VAT Ctrl. Report No."; Code[20])
        {
            Caption = 'VAT Control Report No.';
            TableRelation = "VAT Ctrl. Report Header CZL";
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            TableRelation = "VAT Ctrl. Report Line CZL"."Line No." where("VAT Ctrl. Report No." = field("VAT Ctrl. Report No."));
            DataClassification = CustomerContent;
        }
        field(5; "VAT Entry No."; Integer)
        {
            Caption = 'VAT Entry No.';
            TableRelation = "VAT Entry"."Entry No.";
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "VAT Ctrl. Report No.", "Line No.", "VAT Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "VAT Entry No.")
        {
        }
    }
}
