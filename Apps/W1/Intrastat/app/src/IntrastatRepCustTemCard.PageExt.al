// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Sales.Customer;

pageextension 4817 "Intrastat Rep. Cust. Tem. Card" extends "Customer Templ. Card"
{
    layout
    {
        addafter(Shipping)
        {
            group(Intrastat)
            {
                Caption = 'Intrastat';
                field("Default Trans. Type"; Rec."Default Trans. Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default transaction type for regular sales shipments and service shipments.';
                }
                field("Default Trans. Type - Return"; Rec."Default Trans. Type - Return")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default transaction type for sales returns and service returns.';
                }
                field("Def. Transport Method"; Rec."Def. Transport Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default transport method, for the purpose of reporting to INTRASTAT.';
                }
            }
        }
    }
}