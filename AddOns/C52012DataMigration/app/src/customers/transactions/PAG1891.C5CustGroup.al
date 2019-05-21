// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

page 1891 "C5 CustGroup"
{
    PageType = Card;
    SourceTable = "C5 CustGroup";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Customer Groups';

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Group;Group) { ApplicationArea=All; }
                field(GroupName;GroupName) { ApplicationArea=All; }
                field(SalesAcc;SalesAcc) { ApplicationArea=All; }
                field(COGSAcc;COGSAcc) { ApplicationArea=All; }
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