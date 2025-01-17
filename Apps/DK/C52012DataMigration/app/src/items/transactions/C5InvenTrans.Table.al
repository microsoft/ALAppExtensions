// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

table 1890 "C5 InvenTrans"
{
    ReplicateData = false;

    fields
    {
        field(1; RecId; Integer)
        {
            Caption = 'Row number';
        }
        field(2; LastChanged; Date)
        {
            Caption = 'Last changed';
        }
        field(3; ItemNumber; Text[20])
        {
            Caption = 'Item number';
        }
        field(4; BudgetCode; Option)
        {
            Caption = 'Budget code';
            OptionMembers = Actual,Budget,"Rev. 1","Rev. 2","Rev. 3","Rev. 4","Rev. 5","Rev. 6";
        }
        field(5; InvenLocation; Text[10])
        {
            Caption = 'Location';
        }
        field(6; Date_; Date)
        {
            Caption = 'Date';
        }
        field(7; Qty; Decimal)
        {
            Caption = 'Qty';
        }
        field(8; DutyAmount; Decimal)
        {
            Caption = 'Duty amount';
        }
        field(9; Discount; Decimal)
        {
            Caption = 'Discount';
        }
        field(10; AmountMST; Decimal)
        {
            Caption = 'Amount in LCY';
        }
        field(11; AmountCur; Decimal)
        {
            Caption = 'Amount in currency';
        }
        field(12; Currency; Code[3])
        {
            Caption = 'Currency';
        }
        field(13; Voucher; Integer)
        {
            Caption = 'Voucher';
        }
        field(14; InvoiceNumber; Text[20])
        {
            Caption = 'Invoice';
        }
        field(15; Module; Option)
        {
            Caption = 'Module';
            OptionMembers = System,GenLedger,Customer,Vendor,Inventory,Sales,Purchase,Project,General,eOrder,Payroll,"Payroll setup";
        }
        field(16; Number; Text[10])
        {
            Caption = 'Number';
        }
        field(17; Account; Text[10])
        {
            Caption = 'Account';
        }
        field(18; Department; Code[10])
        {
            Caption = 'Department';
        }
        field(19; Employee; Text[10])
        {
            Caption = 'Employee';
        }
        field(20; Txt; Text[40])
        {
            Caption = 'Text';
        }
        field(21; InOutflow; Option)
        {
            Caption = 'Movement';
            OptionMembers = " ","Inven. inflow","Inven. outflow";
        }
        field(22; CostAmount; Decimal)
        {
            Caption = 'Cost value in LCY';
        }
        field(23; SerialNumber; Code[20])
        {
            Caption = 'Serial/Batch number';
        }
        field(24; SettledQty; Decimal)
        {
            Caption = 'Settled qty';
        }
        field(25; SettledAmount; Decimal)
        {
            Caption = 'Settled amount';
        }
        field(26; InvestTax; Decimal)
        {
            Caption = 'Invest. duty';
        }
        field(27; PostedDiffAmount; Decimal)
        {
            Caption = 'Adjustment';
        }
        field(28; Open; Option)
        {
            Caption = 'Open';
            OptionMembers = No,Yes;
        }
        field(29; InvenTransType; Option)
        {
            Caption = 'Entry type';
            OptionMembers = Adjustment,"Item purchase","Item sale","BOM line",BOM,Project,Transfer;
        }
        field(30; RefRecId; Integer)
        {
            Caption = 'EntryRef';
        }
        field(31; Transaction; Integer)
        {
            Caption = 'Transaction';
        }
        field(32; InvenStatus; Option)
        {
            Caption = 'Status';
            OptionMembers = Invoice,"Packing slip","On order","Pro forma",Confirmation,Quotation,"Sub order";
        }
        field(33; PackingSlip; Text[20])
        {
            Caption = 'Packing slip';
        }
        field(34; InvenItemGroup; Code[10])
        {
            Caption = 'Item group';
        }
        field(35; CustVendGroup; Code[10])
        {
            Caption = 'Cust./Vend. Group';
        }
        field(36; DiscAmount; Decimal)
        {
            Caption = 'Disc. amount';
        }
        field(37; LedgerAccount; Text[10])
        {
            Caption = 'G/L account';
        }
        field(38; CostType; Text[10])
        {
            Caption = 'Cost type';
        }
        field(39; CommissionAmount; Decimal)
        {
            Caption = 'Commission amount';
        }
        field(40; CommissionSettled; Option)
        {
            Caption = 'Commission settled';
            OptionMembers = No,Yes;
        }
        field(41; Vat; Code[10])
        {
            Caption = 'VAT';
        }
        field(42; ProjCostPLPosted; Decimal)
        {
            Caption = 'P/L posted in project';
        }
        field(43; ProjCostPLAcc; Text[10])
        {
            Caption = 'Cost P/L a/c';
        }
        field(44; COGSAccount; Text[10])
        {
            Caption = 'COGS account';
        }
        field(45; InventoryAcc; Text[10])
        {
            Caption = 'Inventory a/c';
        }
        field(46; ProfitLossAmount; Decimal)
        {
            Caption = 'Loss/Profit';
        }
        field(47; DEL_DutyCode; Text[10])
        {
            Caption = 'DELETEDuty';
        }
        field(48; ExchRate; Decimal)
        {
            Caption = 'Exch. rate';
        }
        field(49; ExchRateTri; Decimal)
        {
            Caption = 'Tri rate';
        }
        field(50; DELETED; Decimal)
        {
            Caption = 'Deleted';
        }
        field(51; Centre; Code[10])
        {
            Caption = 'Cost centre';
        }
        field(52; Purpose; Code[10])
        {
            Caption = 'Purpose';
        }
        field(53; LineNumber; Decimal)
        {
            Caption = 'Orig linenumber';
        }
        field(54; ReversedQty; Decimal)
        {
            Caption = 'Reversed quantity';
        }
        field(55; ReversedAmount; Decimal)
        {
            Caption = 'Reversed amount';
        }
        field(56; TmpFunction; Integer)
        {
            Caption = 'Tmp function';
        }
        field(57; CollectNumber; Text[10])
        {
            Caption = 'Collective number';
        }
        field(58; SkipSettle; Option)
        {
            Caption = 'Exclude from settlement';
            OptionMembers = No,Yes;
        }
    }

    keys
    {
        key(PK; RecId)
        {
            Clustered = true;
        }
        key(ItemNumberKey; ItemNumber) { }
    }
}

