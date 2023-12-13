// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

page 1894 "C5 VendTrans"
{
    PageType = List;
    SourceTable = "C5 VendTrans";
    DeleteAllowed = false;
    InsertAllowed = false;
    Caption = 'C5 Vendor Entries';

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
                field(RESERVED3; Rec.RESERVED3) { ApplicationArea = All; }
                field(RESERVED4; Rec.RESERVED4) { ApplicationArea = All; }
                field(PostedDiffAmount; Rec.PostedDiffAmount) { ApplicationArea = All; }
                field(InvoiceNumber; Rec.InvoiceNumber) { ApplicationArea = All; }
                field(RESERVED1; Rec.RESERVED1) { ApplicationArea = All; }
                field(RefRecId; Rec.RefRecId) { ApplicationArea = All; }
                field(Transaction; Rec.Transaction) { ApplicationArea = All; }
                field(RESERVED6; Rec.RESERVED6) { ApplicationArea = All; }
                field(PaymId; Rec.PaymId) { ApplicationArea = All; }
                field(ProcessingDate; Rec.ProcessingDate) { ApplicationArea = All; }
                field(CashDisc; Rec.CashDisc) { ApplicationArea = All; }
                field(PaymentMode; Rec.PaymentMode) { ApplicationArea = All; }
                field(PaymSpec; Rec.PaymSpec) { ApplicationArea = All; }
                field(ExchRateTri; Rec.ExchRateTri) { ApplicationArea = All; }
                field(Centre; Rec.Centre) { ApplicationArea = All; }
                field(Purpose; Rec.Purpose) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }
}
