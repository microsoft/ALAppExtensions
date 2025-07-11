// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

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
#pragma warning disable AA0218
                field(Group; Rec.Group) { ApplicationArea = All; }
                field(GroupName; Rec.GroupName) { ApplicationArea = All; }
                field(SalesAcc; Rec.SalesAcc) { ApplicationArea = All; }
                field(COGSAcc; Rec.COGSAcc) { ApplicationArea = All; }
                field(InvoiceDisc; Rec.InvoiceDisc) { ApplicationArea = All; }
                field(FeeTaxable; Rec.FeeTaxable) { ApplicationArea = All; }
                field(FeeTaxfree; Rec.FeeTaxfree) { ApplicationArea = All; }
                field(GroupAccount; Rec.GroupAccount) { ApplicationArea = All; }
                field(CashPayment; Rec.CashPayment) { ApplicationArea = All; }
                field(LineDisc; Rec.LineDisc) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }
}
