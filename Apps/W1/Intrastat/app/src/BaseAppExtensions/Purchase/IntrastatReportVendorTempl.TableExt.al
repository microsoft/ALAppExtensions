// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Purchases.Vendor;

tableextension 4827 "Intrastat Report Vendor Templ." extends "Vendor Templ."
{
    fields
    {
        field(4810; "Default Trans. Type"; Code[10])
        {
            Caption = 'Default Trans. Type';
            DataClassification = CustomerContent;
            TableRelation = "Transaction Type";
            ToolTip = 'Specifies the default transaction type for regular purchase receipts.';
        }
        field(4811; "Default Trans. Type - Return"; Code[10])
        {
            Caption = 'Default Trans. Type - Returns';
            DataClassification = CustomerContent;
            TableRelation = "Transaction Type";
            ToolTip = 'Specifies the default transaction type for purchase returns.';
        }
        field(4812; "Def. Transport Method"; Code[10])
        {
            Caption = 'Default Transport Method';
            DataClassification = CustomerContent;
            TableRelation = "Transport Method";
            ToolTip = 'Specifies the default transport method, for the purpose of reporting to Intrastat.';
        }
    }
}