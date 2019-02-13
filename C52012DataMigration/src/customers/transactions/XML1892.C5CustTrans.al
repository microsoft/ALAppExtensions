// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

xmlport 1892 "C5 CustTrans"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'CustTransDocument';
            tableelement(C5CustTrans; "C5 CustTrans")
            {
                fieldelement(BudgetCode; C5CustTrans.BudgetCode) { }
                fieldelement(Account; C5CustTrans.Account) { }
                fieldelement(Department; C5CustTrans.Department) { }
                textelement(Date_Text)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(Date_Text, CopyStr(DateFormatStringTxt, 1, 20), C5CustTrans.Date_);
                    end;
                }

                fieldelement(InvoiceNumber; C5CustTrans.InvoiceNumber) { }
                fieldelement(Voucher; C5CustTrans.Voucher) { }
                fieldelement(Txt; C5CustTrans.Txt) { }
                fieldelement(TransType; C5CustTrans.TransType) { }
                fieldelement(AmountMST; C5CustTrans.AmountMST) { }
                fieldelement(AmountCur; C5CustTrans.AmountCur) { }
                fieldelement(Currency; C5CustTrans.Currency) { }
                fieldelement(Vat; C5CustTrans.Vat) { }
                fieldelement(VatAmount; C5CustTrans.VatAmount) { }
                fieldelement(Approved; C5CustTrans.Approved) { }
                fieldelement(ApprovedBy; C5CustTrans.ApprovedBy) { }
                fieldelement(CashDiscAmount; C5CustTrans.CashDiscAmount) { }
                textelement(CashDiscDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(CashDiscDateText, CopyStr(DateFormatStringTxt, 1, 20), C5CustTrans.CashDiscDate);
                    end;
                }

                textelement(DueDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(DueDateText, CopyStr(DateFormatStringTxt, 1, 20), C5CustTrans.DueDate);
                    end;
                }

                fieldelement(Open; C5CustTrans.Open) { }
                fieldelement(ExchRate; C5CustTrans.ExchRate) { }
                fieldelement(RESERVED2; C5CustTrans.RESERVED2) { }
                fieldelement(RESERVED3; C5CustTrans.RESERVED3) { }
                fieldelement(PostedDiffAmount; C5CustTrans.PostedDiffAmount) { }
                fieldelement(RefRecID; C5CustTrans.RefRecID) { }
                fieldelement(Transaction; C5CustTrans.Transaction) { }
                fieldelement(ReminderCode; C5CustTrans.ReminderCode) { }
                fieldelement(CashDisc; C5CustTrans.CashDisc) { }
                textelement(RemindedDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(RemindedDateText, CopyStr(DateFormatStringTxt, 1, 20), C5CustTrans.RemindedDate);
                    end;
                }

                fieldelement(ExchRateTri; C5CustTrans.ExchRateTri) { }
                fieldelement(PaymentId; C5CustTrans.PaymentId) { }
                fieldelement(Centre; C5CustTrans.Centre) { }
                fieldelement(Purpose; C5CustTrans.Purpose) { }
                fieldelement(PaymentMode; C5CustTrans.PaymentMode) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5CustTrans.RecId := Counter;
                    Counter += 1;
                    if Counter mod 1000 = 0 then
                        OnThousandCustomerTransactionsRead();
                end;
            }
        }
    }

    var
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        DateFormatStringTxt: label 'yyyy/MM/dd', locked = true;
        Counter: Integer;

    [IntegrationEvent(false, false)]
    local procedure OnThousandCustomerTransactionsRead()
    begin
    end;
}

