// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1893 "C5 VendGroup"
{
    PageType = Card;
    SourceTable = "C5 VendGroup";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Vendor Groups';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Group;Group) { ApplicationArea=All; }
                field(GroupName;GroupName) { ApplicationArea=All; }
                field(InventoryInflowAcc;InventoryInflowAcc) { ApplicationArea=All; }
                field(RESERVED1;RESERVED1) { ApplicationArea=All; }
                field(InvoiceDisc;InvoiceDisc) { ApplicationArea=All; }
                field(FeeTaxable;FeeTaxable) { ApplicationArea=All; }
                field(FeeTaxfree;FeeTaxfree) { ApplicationArea=All; }
                field(GroupAccount;GroupAccount) { ApplicationArea=All; }
                field(CashPayment;CashPayment) { ApplicationArea=All; }
                field(LineDisc;LineDisc) { ApplicationArea=All; }                
            }
        }
    }
}