// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Sales.Customer;

tableextension 4822 "Intrastat Report Cust. Templ." extends "Customer Templ."
{
    fields
    {
        field(4810; "Default Trans. Type"; Code[10])
        {
            Caption = 'Default Trans. Type';
            TableRelation = "Transaction Type";
        }
        field(4811; "Default Trans. Type - Return"; Code[10])
        {
            Caption = 'Default Trans. Type - Returns';
            TableRelation = "Transaction Type";
        }
        field(4812; "Def. Transport Method"; Code[10])
        {
            Caption = 'Default Transport Method';
            TableRelation = "Transport Method";
        }
    }
}