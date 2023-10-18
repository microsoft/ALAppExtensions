// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GST.Base;

table 18209 "Posted Settlement Entries"
{
    Caption = 'Posted Settlement Entries';

    fields
    {
        field(1; "GST Registration No."; Code[20])
        {
            Caption = 'GST Registration No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "GST Registration Nos.";
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "GST Component Code"; Code[10])
        {
            Caption = 'GST Component Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "Payment Liability"; Decimal)
        {
            Caption = 'Payment Liability';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "GST TDS Credit Available"; Decimal)
        {
            Caption = 'GST TDS Credit Available';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(9; "GST TCS Credit Available"; Decimal)
        {
            Caption = 'GST TCS Credit Available';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Net Payment Liability"; Decimal)
        {
            Caption = 'Net Payment Liability';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Credit Availed"; Decimal)
        {
            Caption = 'Credit Availed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(12; "Distributed Credit"; Decimal)
        {
            Caption = 'Distributed Credit';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "Total Credit Available"; Decimal)
        {
            Caption = 'Total Credit Available';
            DataClassification = CustomerContent;
            Editable = false;
            MinValue = 0;
        }
        field(14; "Credit Utilized"; Decimal)
        {
            Caption = 'Credit Utilized';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(15; "Payment Amount"; Decimal)
        {
            Caption = 'Payment Amount';
            DataClassification = CustomerContent;
            Editable = false;
            MinValue = 0;
        }
        field(16; Interest; Decimal)
        {
            Caption = 'Interest';
            DataClassification = CustomerContent;
            Editable = false;
            MinValue = 0;
        }
        field(17; "Interest Account No."; Code[20])
        {
            Caption = 'Interest Account No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "G/L Account" where(Blocked = const(false));
        }
        field(18; Penalty; Decimal)
        {
            Caption = 'Penalty';
            DataClassification = CustomerContent;
            Editable = false;
            MinValue = 0;
        }
        field(19; "Penalty Account No."; Code[20])
        {
            Caption = 'Penalty Account No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "G/L Account" where(Blocked = const(false));
        }
        field(20; Fees; Decimal)
        {
            Caption = 'Fees';
            DataClassification = CustomerContent;
            Editable = false;
            MinValue = 0;
        }
        field(21; "Fees Account No."; Code[20])
        {
            Caption = 'Fees Account No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "G/L Account" where(Blocked = const(false));
        }
        field(22; Others; Decimal)
        {
            Caption = 'Others';
            DataClassification = CustomerContent;
            Editable = false;
            MinValue = 0;
        }
        field(23; "Others Account No."; Code[20])
        {
            Caption = 'Others Account No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "G/L Account" where(Blocked = const(false));
        }
        field(24; "Account Type"; Enum "Settlement Account Type")
        {
            Caption = 'Account Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(25; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = if ("Account Type" = const("G/L Account")) "G/L Account"
                where(Blocked = const(false))
            else
            if ("Account Type" = const("Bank Account")) "Bank Account"
                where(Blocked = const(false));
        }
        field(26; "Location State Code"; Code[10])
        {
            Caption = 'Location State Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(27; "Surplus Credit"; Decimal)
        {
            Caption = 'Surplus Credit';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(28; "Surplus Cr. Utilized"; Decimal)
        {
            Caption = 'Surplus Cr. Utilized';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(29; "Carry Forward"; Decimal)
        {
            Caption = 'Carry Forward';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(34; "Period End Date"; Date)
        {
            Caption = 'Period End Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(35; "Bank Reference No."; Code[10])
        {
            Caption = 'Bank Reference No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(36; "Bank Reference Date"; Date)
        {
            Caption = 'Bank Reference Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(40; "GST Input Service Distribution"; Boolean)
        {
            Caption = 'GST Input Service Distribution';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(41; "Payment Liability - Rev. Chrg."; Decimal)
        {
            Caption = 'Payment Liability - Rev. Chrg.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(42; "Payment Amount - Rev. Chrg."; Decimal)
        {
            Caption = 'Payment Amount - Rev. Chrg.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(43; "UnAdjutsed Credit"; Decimal)
        {
            Caption = 'UnAdjutsed Credit';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(44; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
            AutoIncrement = true;
        }
        field(45; "Unadjutsed Liability"; Decimal)
        {
            Caption = 'Unadjutsed Liability';
            DataClassification = CustomerContent;
        }
        field(46; "Total Payment Amount"; Decimal)
        {
            Caption = 'Total Payment Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(47; "GST TDS Credit Utilized"; Decimal)
        {
            Caption = 'GST TDS Credit Utilized';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(48; "GST TCS Credit Utilized"; Decimal)
        {
            Caption = 'GST TCS Credit Utilized';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(49; "GST TDS Credit Unutilized"; Decimal)
        {
            Caption = 'GST TDS Credit Unutilized';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50; "GST TCS Credit Unutilized"; Decimal)
        {
            Caption = 'GST TCS Credit Unutilized';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(51; "GST TCS Liability"; Decimal)
        {
            Caption = 'GST TCS Liability';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(480; "Dimension Set ID"; Integer)
        {
            Caption = 'Dimension Set ID';
            DataClassification = SystemMetadata;
            Editable = false;
            TableRelation = "Dimension Set Entry";
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }
}
