// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

table 1892 "C5 CustTrans"
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
        field(3; BudgetCode; Option)
        {
            Caption = 'Budget code';
            OptionMembers = Actual,Budget,"Rev. 1","Rev. 2","Rev. 3","Rev. 4","Rev. 5","Rev. 6";
        }
        field(4; Account; Code[10])
        {
            Caption = 'Account';
        }
        field(5; Department; Code[10])
        {
            Caption = 'Department';
        }
        field(6; Date_; Date)
        {
            Caption = 'Date';
        }
        field(7; InvoiceNumber; Text[20])
        {
            Caption = 'Invoice';
        }
        field(8; Voucher; Integer)
        {
            Caption = 'Voucher';
        }
        field(9; Txt; Text[40])
        {
            Caption = 'Text';
        }
        field(10; TransType; Option)
        {
            Caption = 'Entry type';
            OptionMembers = " ",Invoice,"Credit note",Payment,Interest,Difference,Adjustment,"Cash discount","Packing slip",Project,"Secondary rounding","Journal difference","Reminder fee";
        }
        field(11; AmountMST; Decimal)
        {
            Caption = 'Amount in LCY';
        }
        field(12; AmountCur; Decimal)
        {
            Caption = 'Amount in currency';
        }
        field(13; Currency; Code[3])
        {
            Caption = 'Currency';
        }
        field(14; Vat; Code[10])
        {
            Caption = 'VAT';
        }
        field(15; VatAmount; Decimal)
        {
            Caption = 'VAT amount';
        }
        field(16; Approved; Option)
        {
            Caption = 'Approved';
            OptionMembers = No,Yes;
        }
        field(17; ApprovedBy; Text[10])
        {
            Caption = 'Approved by';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(18; CashDiscAmount; Decimal)
        {
            Caption = 'Cash discount';
        }
        field(19; CashDiscDate; Date)
        {
            Caption = 'Cash disc. date';
        }
        field(20; DueDate; Date)
        {
            Caption = 'Due';
        }
        field(21; Open; Option)
        {
            Caption = 'Open';
            OptionMembers = No,Yes;
        }
        field(22; ExchRate; Decimal)
        {
            Caption = 'Exch. rate';
        }
        field(23; RESERVED2; Decimal)
        {
            Caption = 'RESERVED2';
        }
        field(24; RESERVED3; Decimal)
        {
            Caption = 'RESERVED3';
        }
        field(25; PostedDiffAmount; Decimal)
        {
            Caption = 'Diff. posted';
        }
        field(26; RefRecID; Integer)
        {
            Caption = 'RefRecID';
        }
        field(27; Transaction; Integer)
        {
            Caption = 'Transaction';
        }
        field(28; ReminderCode; Option)
        {
            Caption = 'Reminder code';
            OptionMembers = " ","Reminder 1","Reminder 2","Reminder 3","Reminder 4",Collection;
        }
        field(29; CashDisc; Text[10])
        {
            Caption = 'Cash discount';
        }
        field(30; RemindedDate; Date)
        {
            Caption = 'Reminder date';
        }
        field(31; ExchRateTri; Decimal)
        {
            Caption = 'Tri rate';
        }
        field(32; PaymentId; Text[30])
        {
            Caption = 'Payment ID';
        }
        field(33; Centre; Code[10])
        {
            Caption = 'Cost centre';
        }
        field(34; Purpose; Code[10])
        {
            Caption = 'Purpose';
        }
        field(35; PaymentMode; Text[10])
        {
            Caption = 'Paym. method';
        }
    }

    keys
    {
        key(PK; RecId)
        {
            Clustered = true;
        }
        key(AccounttKey; Account) { }
    }
}

