// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

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
                field(ItemNumber;ItemNumber) { ApplicationArea=All; }
                field(BudgetCode;BudgetCode) { ApplicationArea=All; }
                field(InvenLocation;InvenLocation) { ApplicationArea=All; }
                field(Date_;Date_) { ApplicationArea=All; }
                field(Qty;Qty) { ApplicationArea=All; }
                field(DutyAmount;DutyAmount) { ApplicationArea=All; }
                field(Discount;Discount) { ApplicationArea=All; }
                field(AmountMST;AmountMST) { ApplicationArea=All; }
                field(AmountCur;AmountCur) { ApplicationArea=All; }
                field(Currency;Currency) { ApplicationArea=All; }
                field(Voucher;Voucher) { ApplicationArea=All; }
                field(InvoiceNumber;InvoiceNumber) { ApplicationArea=All; }
                field(Module;Module) { ApplicationArea=All; }
                field(Number;Number) { ApplicationArea=All; }
                field(Account;Account) { ApplicationArea=All; }
                field(Department;Department) { ApplicationArea=All; }
                field(Employee;Employee) { ApplicationArea=All; }
                field(Txt;Txt) { ApplicationArea=All; }
                field(InOutflow;InOutflow) { ApplicationArea=All; }
                field(CostAmount;CostAmount) { ApplicationArea=All; }
                field(SerialNumber;SerialNumber) { ApplicationArea=All; }
                field(SettledQty;SettledQty) { ApplicationArea=All; }
                field(SettledAmount;SettledAmount) { ApplicationArea=All; }
                field(InvestTax;InvestTax) { ApplicationArea=All; }
                field(PostedDiffAmount;PostedDiffAmount) { ApplicationArea=All; }
                field(Open;Open) { ApplicationArea=All; }
                field(InvenTransType;InvenTransType) { ApplicationArea=All; }
                field(RefRecId;RefRecId) { ApplicationArea=All; }
                field(Transaction;Transaction) { ApplicationArea=All; }
                field(InvenStatus;InvenStatus) { ApplicationArea=All; }
                field(PackingSlip;PackingSlip) { ApplicationArea=All; }
                field(InvenItemGroup;InvenItemGroup) { ApplicationArea=All; }
                field(CustVendGroup;CustVendGroup) { ApplicationArea=All; }
                field(DiscAmount;DiscAmount) { ApplicationArea=All; }
                field(LedgerAccount;LedgerAccount) { ApplicationArea=All; }
                field(CostType;CostType) { ApplicationArea=All; }
                field(CommissionAmount;CommissionAmount) { ApplicationArea=All; }
                field(CommissionSettled;CommissionSettled) { ApplicationArea=All; }
                field(Vat;Vat) { ApplicationArea=All; }
                field(ProjCostPLPosted;ProjCostPLPosted) { ApplicationArea=All; }
                field(ProjCostPLAcc;ProjCostPLAcc) { ApplicationArea=All; }
                field(COGSAccount;COGSAccount) { ApplicationArea=All; }
                field(InventoryAcc;InventoryAcc) { ApplicationArea=All; }
                field(ProfitLossAmount;ProfitLossAmount) { ApplicationArea=All; }
                field(DEL_DutyCode;DEL_DutyCode) { ApplicationArea=All; }
                field(ExchRate;ExchRate) { ApplicationArea=All; }
                field(ExchRateTri;ExchRateTri) { ApplicationArea=All; }
                field(DELETED;DELETED) { ApplicationArea=All; }
                field(Centre;Centre) { ApplicationArea=All; }
                field(Purpose;Purpose) { ApplicationArea=All; }
                field(LineNumber;LineNumber) { ApplicationArea=All; }
                field(ReversedQty;ReversedQty) { ApplicationArea=All; }
                field(ReversedAmount;ReversedAmount) { ApplicationArea=All; }
                field(TmpFunction;TmpFunction) { ApplicationArea=All; }
                field(CollectNumber;CollectNumber) { ApplicationArea=All; }
                field(SkipSettle;SkipSettle) { ApplicationArea=All; }
            }
        }
    }
}