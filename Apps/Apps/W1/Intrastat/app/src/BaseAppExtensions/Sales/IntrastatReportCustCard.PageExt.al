// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Inventory.Intrastat;

using Microsoft.Sales.Customer;

pageextension 4813 "Intrastat Report Cust. Card" extends "Customer Card"
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
                }
                field("Default Trans. Type - Return"; Rec."Default Trans. Type - Return")
                {
                    ApplicationArea = All;
                }
                field("Def. Transport Method"; Rec."Def. Transport Method")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}