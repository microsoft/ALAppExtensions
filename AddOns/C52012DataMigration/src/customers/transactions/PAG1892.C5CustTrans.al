// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

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
                field(BudgetCode;BudgetCode) { ApplicationArea=All; }
                field(Account;Account) { ApplicationArea=All; }
                field(Department;Department) { ApplicationArea=All; }
                field(Date_;Date_) { ApplicationArea=All; }
                field(InvoiceNumber;InvoiceNumber) { ApplicationArea=All; }
                field(Voucher;Voucher) { ApplicationArea=All; }
                field(Txt;Txt) { ApplicationArea=All; }
                field(TransType;TransType) { ApplicationArea=All; }
                field(AmountMST;AmountMST) { ApplicationArea=All; }
                field(AmountCur;AmountCur) { ApplicationArea=All; }
                field(Currency;Currency) { ApplicationArea=All; }
                field(Vat;Vat) { ApplicationArea=All; }
                field(VatAmount;VatAmount) { ApplicationArea=All; }
                field(Approved;Approved) { ApplicationArea=All; }
                field(ApprovedBy;ApprovedBy) { ApplicationArea=All; }
                field(CashDiscAmount;CashDiscAmount) { ApplicationArea=All; }
                field(CashDiscDate;CashDiscDate) { ApplicationArea=All; }
                field(DueDate;DueDate) { ApplicationArea=All; }
                field(Open;Open) { ApplicationArea=All; }
                field(ExchRate;ExchRate) { ApplicationArea=All; }
                field(RESERVED2;RESERVED2) { ApplicationArea=All; }
                field(RESERVED3;RESERVED3) { ApplicationArea=All; }
                field(PostedDiffAmount;PostedDiffAmount) { ApplicationArea=All; }
                field(RefRecID;RefRecID) { ApplicationArea=All; }
                field(Transaction;Transaction) { ApplicationArea=All; }
                field(ReminderCode;ReminderCode) { ApplicationArea=All; }
                field(CashDisc;CashDisc) { ApplicationArea=All; }
                field(RemindedDate;RemindedDate) { ApplicationArea=All; }
                field(ExchRateTri;ExchRateTri) { ApplicationArea=All; }
                field(PaymentId;PaymentId) { ApplicationArea=All; }
                field(Centre;Centre) { ApplicationArea=All; }
                field(Purpose;Purpose) { ApplicationArea=All; }
                field(PaymentMode;PaymentMode) { ApplicationArea=All; }
            }
        }
    }
}