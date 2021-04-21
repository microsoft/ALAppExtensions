// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

xmlport 1897 "C5 LedTrans"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'LedTransDocument';
            tableelement(C5LedTrans; "C5 LedTrans")
            {
                fieldelement(Account; C5LedTrans.Account) { }
                fieldelement(BudgetCode; C5LedTrans.BudgetCode) { }
                fieldelement(Department; C5LedTrans.Department) { }
                textelement(Date_Text)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(Date_Text, CopyStr(DateFormatStringTxt, 1, 20), C5LedTrans.Date_);
                    end;
                }

                fieldelement(Voucher; C5LedTrans.Voucher) { }
                fieldelement(Txt; C5LedTrans.Txt) { }
                fieldelement(AmountMST; C5LedTrans.AmountMST) { }
                fieldelement(AmountCur; C5LedTrans.AmountCur) { }
                fieldelement(Currency; C5LedTrans.Currency) { }
                fieldelement(Vat; C5LedTrans.Vat) { }
                fieldelement(VatAmount; C5LedTrans.VatAmount) { }
                fieldelement(Qty; C5LedTrans.Qty) { }
                fieldelement(TransType; C5LedTrans.TransType) { }
                textelement(DueDateText)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(DueDateText, CopyStr(DateFormatStringTxt, 1, 20), C5LedTrans.DueDate);
                    end;
                }

                fieldelement(Transaction; C5LedTrans.Transaction) { }
                fieldelement(CreatedBy; C5LedTrans.CreatedBy) { }
                fieldelement(JourNumber; C5LedTrans.JourNumber) { }
                fieldelement(Amount2; C5LedTrans.Amount2) { }
                fieldelement(LockAmount2; C5LedTrans.LockAmount2) { }
                fieldelement(Centre; C5LedTrans.Centre) { }
                fieldelement(Purpose; C5LedTrans.Purpose) { }
                fieldelement(ReconcileNo; C5LedTrans.ReconcileNo) { }
                fieldelement(VatRepCounter; C5LedTrans.VatRepCounter) { }
                fieldelement(VatPeriodRecId; C5LedTrans.VatPeriodRecId) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5LedTrans.RecId := Counter;
                    Counter += 1;
                    if Counter mod 1000 = 0 then
                        OnThousandAccountTransactionsRead();
                end;
            }
        }
    }

    var
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        DateFormatStringTxt: label 'yyyy/MM/dd', locked = true;
        Counter: Integer;

    [IntegrationEvent(false, false)]
    local procedure OnThousandAccountTransactionsRead()
    begin
    end;
}
