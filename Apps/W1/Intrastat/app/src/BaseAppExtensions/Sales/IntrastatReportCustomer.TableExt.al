// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Sales.Customer;

tableextension 4814 "Intrastat Report Customer" extends Customer
{
    fields
    {
        field(4810; "Default Trans. Type"; Code[10])
        {
            Caption = 'Default Trans. Type';
            DataClassification = CustomerContent;
            TableRelation = "Transaction Type";
            ToolTip = 'Specifies the default transaction type for regular sales shipments and service shipments.';
        }
        field(4811; "Default Trans. Type - Return"; Code[10])
        {
            Caption = 'Default Trans. Type - Returns';
            DataClassification = CustomerContent;
            TableRelation = "Transaction Type";
            ToolTip = 'Specifies the default transaction type for sales returns and service returns.';
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