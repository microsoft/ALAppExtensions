// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

xmlport 1890 "C5 InvenTrans"
{
    Direction = Import;
    Format = VariableText;
    FormatEvaluate = XML;


    schema
    {
        textelement(root)
        {
            MinOccurs = Zero;
            XmlName = 'InvenTransDocument';
            tableelement(C5InvenTrans; "C5 InvenTrans")
            {
                fieldelement(ItemNumber; C5InvenTrans.ItemNumber) { }
                fieldelement(BudgetCode; C5InvenTrans.BudgetCode) { }
                fieldelement(InvenLocation; C5InvenTrans.InvenLocation) { }
                textelement(Date_Text)
                {
                    trigger OnAfterAssignVariable()
                    begin
                        C5HelperFunctions.TryConvertFromStringDate(Date_Text, CopyStr(DateFormatStringTxt, 1, 20), C5InvenTrans.Date_);
                    end;
                }

                fieldelement(Qty; C5InvenTrans.Qty) { }
                fieldelement(DutyAmount; C5InvenTrans.DutyAmount) { }
                fieldelement(Discount; C5InvenTrans.Discount) { }
                fieldelement(AmountMST; C5InvenTrans.AmountMST) { }
                fieldelement(AmountCur; C5InvenTrans.AmountCur) { }
                fieldelement(Currency; C5InvenTrans.Currency) { }
                fieldelement(Voucher; C5InvenTrans.Voucher) { }
                fieldelement(InvoiceNumber; C5InvenTrans.InvoiceNumber) { }
                fieldelement(Module; C5InvenTrans.Module) { }
                fieldelement(Number; C5InvenTrans.Number) { }
                fieldelement(Account; C5InvenTrans.Account) { }
                fieldelement(Department; C5InvenTrans.Department) { }
                fieldelement(Employee; C5InvenTrans.Employee) { }
                fieldelement(Txt; C5InvenTrans.Txt) { }
                fieldelement(InOutflow; C5InvenTrans.InOutflow) { }
                fieldelement(CostAmount; C5InvenTrans.CostAmount) { }
                fieldelement(SerialNumber; C5InvenTrans.SerialNumber) { }
                fieldelement(SettledQty; C5InvenTrans.SettledQty) { }
                fieldelement(SettledAmount; C5InvenTrans.SettledAmount) { }
                fieldelement(InvestTax; C5InvenTrans.InvestTax) { }
                fieldelement(PostedDiffAmount; C5InvenTrans.PostedDiffAmount) { }
                fieldelement(Open; C5InvenTrans.Open) { }
                fieldelement(InvenTransType; C5InvenTrans.InvenTransType) { }
                fieldelement(RefRecId; C5InvenTrans.RefRecId) { }
                fieldelement(Transaction; C5InvenTrans.Transaction) { }
                fieldelement(InvenStatus; C5InvenTrans.InvenStatus) { }
                fieldelement(PackingSlip; C5InvenTrans.PackingSlip) { }
                fieldelement(InvenItemGroup; C5InvenTrans.InvenItemGroup) { }
                fieldelement(CustVendGroup; C5InvenTrans.CustVendGroup) { }
                fieldelement(DiscAmount; C5InvenTrans.DiscAmount) { }
                fieldelement(LedgerAccount; C5InvenTrans.LedgerAccount) { }
                fieldelement(CostType; C5InvenTrans.CostType) { }
                fieldelement(CommissionAmount; C5InvenTrans.CommissionAmount) { }
                fieldelement(CommissionSettled; C5InvenTrans.CommissionSettled) { }
                fieldelement(Vat; C5InvenTrans.Vat) { }
                fieldelement(ProjCostPLPosted; C5InvenTrans.ProjCostPLPosted) { }
                fieldelement(ProjCostPLAcc; C5InvenTrans.ProjCostPLAcc) { }
                fieldelement(COGSAccount; C5InvenTrans.COGSAccount) { }
                fieldelement(InventoryAcc; C5InvenTrans.InventoryAcc) { }
                fieldelement(ProfitLossAmount; C5InvenTrans.ProfitLossAmount) { }
                fieldelement(DEL_DutyCode; C5InvenTrans.DEL_DutyCode) { }
                fieldelement(ExchRate; C5InvenTrans.ExchRate) { }
                fieldelement(ExchRateTri; C5InvenTrans.ExchRateTri) { }
                fieldelement(DELETED; C5InvenTrans.DELETED) { }
                fieldelement(Centre; C5InvenTrans.Centre) { }
                fieldelement(Purpose; C5InvenTrans.Purpose) { }
                fieldelement(LineNumber; C5InvenTrans.LineNumber) { }
                fieldelement(ReversedQty; C5InvenTrans.ReversedQty) { }
                fieldelement(ReversedAmount; C5InvenTrans.ReversedAmount) { }
                fieldelement(TmpFunction; C5InvenTrans.TmpFunction) { }
                fieldelement(CollectNumber; C5InvenTrans.CollectNumber) { }
                fieldelement(SkipSettle; C5InvenTrans.SkipSettle) { }

                trigger OnBeforeInsertRecord();
                begin
                    C5InvenTrans.RecId := Counter;
                    Counter += 1;
                    if Counter mod 1000 = 0 then
                        OnThousandItemTransactionsRead();
                end;
            }
        }
    }

    var
        C5HelperFunctions: Codeunit "C5 Helper Functions";
        DateFormatStringTxt: label 'yyyy/MM/dd', locked = true;
        Counter: Integer;

    [IntegrationEvent(false, false)]
    local procedure OnThousandItemTransactionsRead()
    begin
    end;
}

