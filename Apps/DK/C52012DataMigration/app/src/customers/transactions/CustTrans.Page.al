// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

page 1892 "C5 CustTrans"
{
    PageType = List;
    SourceTable = "C5 CustTrans";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Customer Entries';

    layout
    {
        area(content)
        {
            repeater(General)
            {
#pragma warning disable AA0218
                field(BudgetCode; Rec.BudgetCode) { ApplicationArea = All; }
                field(Account; Rec.Account) { ApplicationArea = All; }
                field(Department; Rec.Department) { ApplicationArea = All; }
                field(Date_; Rec.Date_) { ApplicationArea = All; }
                field(InvoiceNumber; Rec.InvoiceNumber) { ApplicationArea = All; }
                field(Voucher; Rec.Voucher) { ApplicationArea = All; }
                field(Txt; Rec.Txt) { ApplicationArea = All; }
                field(TransType; Rec.TransType) { ApplicationArea = All; }
                field(AmountMST; Rec.AmountMST) { ApplicationArea = All; }
                field(AmountCur; Rec.AmountCur) { ApplicationArea = All; }
                field(Currency; Rec.Currency) { ApplicationArea = All; }
                field(Vat; Rec.Vat) { ApplicationArea = All; }
                field(VatAmount; Rec.VatAmount) { ApplicationArea = All; }
                field(Approved; Rec.Approved) { ApplicationArea = All; }
                field(ApprovedBy; Rec.ApprovedBy) { ApplicationArea = All; }
                field(CashDiscAmount; Rec.CashDiscAmount) { ApplicationArea = All; }
                field(CashDiscDate; Rec.CashDiscDate) { ApplicationArea = All; }
                field(DueDate; Rec.DueDate) { ApplicationArea = All; }
                field(Open; Rec.Open) { ApplicationArea = All; }
                field(ExchRate; Rec.ExchRate) { ApplicationArea = All; }
                field(RESERVED2; Rec.RESERVED2) { ApplicationArea = All; }
                field(RESERVED3; Rec.RESERVED3) { ApplicationArea = All; }
                field(PostedDiffAmount; Rec.PostedDiffAmount) { ApplicationArea = All; }
                field(RefRecID; Rec.RefRecID) { ApplicationArea = All; }
                field(Transaction; Rec.Transaction) { ApplicationArea = All; }
                field(ReminderCode; Rec.ReminderCode) { ApplicationArea = All; }
                field(CashDisc; Rec.CashDisc) { ApplicationArea = All; }
                field(RemindedDate; Rec.RemindedDate) { ApplicationArea = All; }
                field(ExchRateTri; Rec.ExchRateTri) { ApplicationArea = All; }
                field(PaymentId; Rec.PaymentId) { ApplicationArea = All; }
                field(Centre; Rec.Centre) { ApplicationArea = All; }
                field(Purpose; Rec.Purpose) { ApplicationArea = All; }
                field(PaymentMode; Rec.PaymentMode) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }
}
