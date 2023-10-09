// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

table 1894 "C5 VendTrans"
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
        field(7; Voucher; Integer)
        {
            Caption = 'Voucher';
        }
        field(8; Txt; Text[40])
        {
            Caption = 'Text';
        }
        field(9; TransType; Option)
        {
            Caption = 'Entry type';
            OptionMembers = " ",Invoice,"Credit note",Payment,Interest,Difference,Adjustment,"Cash discount","Packing slip",Project,"Secondary rounding","Journal difference","Reminder fee";
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
        field(13; Vat; Code[10])
        {
            Caption = 'VAT';
        }
        field(14; VatAmount; Decimal)
        {
            Caption = 'VAT amount';
        }
        field(15; Approved; Option)
        {
            Caption = 'Approved';
            OptionMembers = No,Yes;
        }
        field(16; ApprovedBy; Text[10])
        {
            Caption = 'Approved by';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(17; CashDiscAmount; Decimal)
        {
            Caption = 'Cash discount';
        }
        field(18; CashDiscDate; Date)
        {
            Caption = 'Cash disc. date';
        }
        field(19; DueDate; Date)
        {
            Caption = 'Due';
        }
        field(20; Open; Option)
        {
            Caption = 'Open';
            OptionMembers = No,Yes;
        }
        field(21; ExchRate; Decimal)
        {
            Caption = 'Exch. rate';
        }
        field(22; RESERVED3; Decimal)
        {
            Caption = 'RESERVED3';
        }
        field(23; RESERVED4; Decimal)
        {
            Caption = 'RESERVED4';
        }
        field(24; PostedDiffAmount; Decimal)
        {
            Caption = 'Diff. posted';
        }
        field(25; InvoiceNumber; Text[20])
        {
            Caption = 'Invoice';
        }
        field(26; RESERVED1; Option)
        {
            Caption = 'RESERVED1';
            OptionMembers = Cost,Invoice,"On account invoice";
        }
        field(27; RefRecId; Integer)
        {
            Caption = 'RefRecID';
        }
        field(28; Transaction; Integer)
        {
            Caption = 'Transaction';
        }
        field(29; RESERVED6; Option)
        {
            Caption = 'RESERVED6';
            OptionMembers = No,Yes;
        }
        field(30; PaymId; Text[20])
        {
            Caption = 'Identification';
        }
        field(31; ProcessingDate; Date)
        {
            Caption = 'Processing date';
        }
        field(32; CashDisc; Text[10])
        {
            Caption = 'Cash discount';
        }
        field(33; PaymentMode; Text[10])
        {
            Caption = 'Paym. method';
        }
        field(34; PaymSpec; Text[10])
        {
            Caption = 'Paym. spec.';
        }
        field(35; ExchRateTri; Decimal)
        {
            Caption = 'Tri rate';
        }
        field(36; Centre; Code[10])
        {
            Caption = 'Cost centre';
        }
        field(37; Purpose; Code[10])
        {
            Caption = 'Purpose';
        }
    }

    keys
    {
        key(PK; RecId)
        {
            Clustered = true;
        }
        key(AccountKey; Account) { }
    }
}

