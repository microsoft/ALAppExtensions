// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

table 1897 "C5 LedTrans"
{
    Caption = 'C5 Ledger Entry';

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
        field(3; Account; Code[10])
        {
            Caption = 'Account';
        }
        field(4; BudgetCode; Option)
        {
            Caption = 'Budget code';
            OptionMembers = Actual,Budget,"Rev. 1","Rev. 2","Rev. 3","Rev. 4","Rev. 5","Rev. 6";
        }
        field(5; Department; Code[10])
        {
            Caption = 'Department';
        }
        field(6; Date_; Date)
        {
            Caption = 'Date';
        }
        field(7; Voucher; Integer)
        {
            Caption = 'Voucher';
        }
        field(8; Txt; Text[40])
        {
            Caption = 'Text';
        }
        field(9; AmountMST; Decimal)
        {
            Caption = 'Amount LCY';
        }
        field(10; AmountCur; Decimal)
        {
            Caption = 'Amount in cur.';
        }
        field(11; Currency; Code[3])
        {
            Caption = 'Currency';
        }
        field(12; Vat; Code[10])
        {
            Caption = 'VAT';
        }
        field(13; VatAmount; Decimal)
        {
            Caption = 'VAT amount LCY';
        }
        field(14; Qty; Decimal)
        {
            Caption = 'Qty';
        }
        field(15; TransType; Option)
        {
            Caption = 'Entry type';
            OptionMembers = " ",Invoice,"Credit note",Payment,Interest,Difference,Adjustment,"Cash discount","Packing slip",Project,"Secondary rounding","Journal difference","Reminder fee";
        }
        field(16; DueDate; Date)
        {
            Caption = 'Due';
        }
        field(17; Transaction; Integer)
        {
            Caption = 'Transaction';
        }
        field(18; CreatedBy; Integer)
        {
            Caption = 'Created by';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(19; JourNumber; Integer)
        {
            Caption = 'Journal no.';
        }
        field(20; Amount2; Decimal)
        {
            Caption = 'Amount in';
        }
        field(21; LockAmount2; Option)
        {
            Caption = 'Lock Amount 2';
            OptionMembers = No,Yes;
        }
        field(22; Centre; Code[10])
        {
            Caption = 'Cost centre';
        }
        field(23; Purpose; Code[10])
        {
            Caption = 'Purpose';
        }
        field(24; ReconcileNo; Integer)
        {
            Caption = 'Reconciliation no.';
        }
        field(25; VatRepCounter; Integer)
        {
            Caption = 'VAT report counter';
        }
        field(26; VatPeriodRecId; Integer)
        {
            Caption = 'Settlement period';
        }
    }

    keys
    {
        key(PK; RecId)
        {
            Clustered = true;
        }
        key(AcountDateTransactionKey; Account, Date_, Transaction) { }
        key(DateKey; Date_) { }
    }
}

