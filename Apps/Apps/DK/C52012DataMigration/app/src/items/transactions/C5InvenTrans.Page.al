// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

page 1890 "C5 InvenTrans"
{
    PageType = List;
    SourceTable = "C5 InvenTrans";
    DeleteAllowed = true;
    InsertAllowed = false;
    Caption = 'C5 Inventory Entries';

    layout
    {
        area(content)
        {
            repeater(General)
            {
#pragma warning disable AA0218
                field(ItemNumber; Rec.ItemNumber) { ApplicationArea = All; }
                field(BudgetCode; Rec.BudgetCode) { ApplicationArea = All; }
                field(InvenLocation; Rec.InvenLocation) { ApplicationArea = All; }
                field(Date_; Rec.Date_) { ApplicationArea = All; }
                field(Qty; Rec.Qty) { ApplicationArea = All; }
                field(DutyAmount; Rec.DutyAmount) { ApplicationArea = All; }
                field(Discount; Rec.Discount) { ApplicationArea = All; }
                field(AmountMST; Rec.AmountMST) { ApplicationArea = All; }
                field(AmountCur; Rec.AmountCur) { ApplicationArea = All; }
                field(Currency; Rec.Currency) { ApplicationArea = All; }
                field(Voucher; Rec.Voucher) { ApplicationArea = All; }
                field(InvoiceNumber; Rec.InvoiceNumber) { ApplicationArea = All; }
                field(Module; Rec.Module) { ApplicationArea = All; }
                field(Number; Rec.Number) { ApplicationArea = All; }
                field(Account; Rec.Account) { ApplicationArea = All; }
                field(Department; Rec.Department) { ApplicationArea = All; }
                field(Employee; Rec.Employee) { ApplicationArea = All; }
                field(Txt; Rec.Txt) { ApplicationArea = All; }
                field(InOutflow; Rec.InOutflow) { ApplicationArea = All; }
                field(CostAmount; Rec.CostAmount) { ApplicationArea = All; }
                field(SerialNumber; Rec.SerialNumber) { ApplicationArea = All; }
                field(SettledQty; Rec.SettledQty) { ApplicationArea = All; }
                field(SettledAmount; Rec.SettledAmount) { ApplicationArea = All; }
                field(InvestTax; Rec.InvestTax) { ApplicationArea = All; }
                field(PostedDiffAmount; Rec.PostedDiffAmount) { ApplicationArea = All; }
                field(Open; Rec.Open) { ApplicationArea = All; }
                field(InvenTransType; Rec.InvenTransType) { ApplicationArea = All; }
                field(RefRecId; Rec.RefRecId) { ApplicationArea = All; }
                field(Transaction; Rec.Transaction) { ApplicationArea = All; }
                field(InvenStatus; Rec.InvenStatus) { ApplicationArea = All; }
                field(PackingSlip; Rec.PackingSlip) { ApplicationArea = All; }
                field(InvenItemGroup; Rec.InvenItemGroup) { ApplicationArea = All; }
                field(CustVendGroup; Rec.CustVendGroup) { ApplicationArea = All; }
                field(DiscAmount; Rec.DiscAmount) { ApplicationArea = All; }
                field(LedgerAccount; Rec.LedgerAccount) { ApplicationArea = All; }
                field(CostType; Rec.CostType) { ApplicationArea = All; }
                field(CommissionAmount; Rec.CommissionAmount) { ApplicationArea = All; }
                field(CommissionSettled; Rec.CommissionSettled) { ApplicationArea = All; }
                field(Vat; Rec.Vat) { ApplicationArea = All; }
                field(ProjCostPLPosted; Rec.ProjCostPLPosted) { ApplicationArea = All; }
                field(ProjCostPLAcc; Rec.ProjCostPLAcc) { ApplicationArea = All; }
                field(COGSAccount; Rec.COGSAccount) { ApplicationArea = All; }
                field(InventoryAcc; Rec.InventoryAcc) { ApplicationArea = All; }
                field(ProfitLossAmount; Rec.ProfitLossAmount) { ApplicationArea = All; }
                field(DEL_DutyCode; Rec.DEL_DutyCode) { ApplicationArea = All; }
                field(ExchRate; Rec.ExchRate) { ApplicationArea = All; }
                field(ExchRateTri; Rec.ExchRateTri) { ApplicationArea = All; }
                field(DELETED; Rec.DELETED) { ApplicationArea = All; }
                field(Centre; Rec.Centre) { ApplicationArea = All; }
                field(Purpose; Rec.Purpose) { ApplicationArea = All; }
                field(LineNumber; Rec.LineNumber) { ApplicationArea = All; }
                field(ReversedQty; Rec.ReversedQty) { ApplicationArea = All; }
                field(ReversedAmount; Rec.ReversedAmount) { ApplicationArea = All; }
                field(TmpFunction; Rec.TmpFunction) { ApplicationArea = All; }
                field(CollectNumber; Rec.CollectNumber) { ApplicationArea = All; }
                field(SkipSettle; Rec.SkipSettle) { ApplicationArea = All; }
#pragma warning restore
            }
        }
    }
}
