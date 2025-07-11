// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

using Microsoft.Sales.Customer;

table 1860 "C5 CustTable"
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
        field(3; DEL_UserLock; Integer)
        {
            Caption = 'Lock';
        }
        field(4; Account; Code[10])
        {
            Caption = 'Account';
            TableRelation = Customer;
            ValidateTableRelation = false;
        }
        field(5; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(6; Address1; Text[50])
        {
            Caption = 'Address 1';
        }
        field(7; Address2; Text[50])
        {
            Caption = 'Address 2';
        }
        field(8; ZipCity; Text[50])
        {
            Caption = 'Zip code/City';
        }
        field(9; Country; Text[30])
        {
            Caption = 'Country/region';
        }
        field(10; Attention; Text[30])
        {
            Caption = 'Attention';
        }
        field(11; Phone; Text[20])
        {
            Caption = 'Phone';
        }
        field(12; Fax; Text[20])
        {
            Caption = 'Fax';
        }
        field(13; InvoiceAccount; Code[10])
        {
            Caption = 'Invoice a/c';
        }
        field(14; Group; Code[10])
        {
            Caption = 'Group';
        }
        field(15; FixedDiscPct; Decimal)
        {
            Caption = 'Fixed discount pct.';
        }
        field(16; Approved; Option)
        {
            Caption = 'Approved';
            OptionMembers = No,Yes;
        }
        field(17; PriceGroup; Code[10])
        {
            Caption = 'Price group';
        }
        field(18; DiscGroup; Code[10])
        {
            Caption = 'Discount group';
        }
        field(19; CashDisc; Code[10])
        {
            Caption = 'Cash discount';
        }
        field(20; ImageFile; Text[250])
        {
            Caption = 'Image';
        }
        field(21; Currency; Code[3])
        {
            Caption = 'Currency';
        }
        field(22; Language_; Option)
        {
            Caption = 'Language';
            OptionMembers = Default,Danish,English,German,French,Italian,Dutch,Icelandic;
        }
        field(23; Payment; Code[10])
        {
            Caption = 'Payment';
        }
        field(24; Delivery; Code[10])
        {
            Caption = 'Delivery';
        }
        field(25; Blocked; Option)
        {
            Caption = 'Locked';
            OptionMembers = No,Invoicing,Delivery,Yes;
        }
        field(26; SalesRep; Code[10])
        {
            Caption = 'Sales rep.';
        }
        field(27; Vat; Code[10])
        {
            Caption = 'VAT';
        }
        field(28; DEL_StatType; Option)
        {
            Caption = 'DELETEStatistics';
            OptionMembers = "Ordinary trade",Samples,"Trade-in deal","Financial leasing",Returns,Replacement,"Replace non-returns",EU,Authorities,Private,"Production on toll",Repair,"Repair (free of charge)",Leasing,"EU projects","Building materials","Misc.";
        }
        field(29; GiroNumber; Text[20])
        {
            Caption = 'FIK/Giro';
        }
        field(30; VatNumber; Text[25])
        {
            Caption = 'VAT No.';
        }
        field(31; Interest; Text[10])
        {
            Caption = 'Interest';
        }
        field(32; Department; Code[10])
        {
            Caption = 'Department';
        }
        field(33; ReminderCode; Option)
        {
            Caption = 'Max. reminder';
            OptionMembers = " ","Reminder 1","Reminder 2","Reminder 3","Reminder 4",Collection;
        }
        field(34; OnetimeCustomer; Option)
        {
            Caption = 'One-off customer';
            OptionMembers = No,Yes;
        }
        field(35; Inventory; Option)
        {
            Caption = 'Inventory';
            OptionMembers = "No change",Reserve,"Pull items","Fixed order";
        }
        field(36; EDIAddress; Text[15])
        {
            Caption = 'EDI address';
        }
        field(37; Balance; Decimal)
        {
            Caption = 'Balance';
        }
        field(38; Balance30; Decimal)
        {
            Caption = '0-30 days';
        }
        field(39; Balance60; Decimal)
        {
            Caption = '31-60 days';
        }
        field(40; Balance90; Decimal)
        {
            Caption = '61-90 days';
        }
        field(41; Balance120; Decimal)
        {
            Caption = '91-120 days';
        }
        field(42; Balance120Plus; Decimal)
        {
            Caption = 'More than 120 days';
        }
        field(43; AmountDue; Decimal)
        {
            Caption = 'Due';
        }
        field(44; CalculationDate; Date)
        {
            Caption = 'Calculated';
        }
        field(45; BalanceMax; Decimal)
        {
            Caption = 'Max. balance';
        }
        field(46; BalanceMST; Decimal)
        {
            Caption = 'Balance LCY';
        }
        field(47; SearchName; Text[30])
        {
            Caption = 'Search name';
        }
        field(48; DEL_Transport; Option)
        {
            Caption = 'DELETETransport';
            OptionMembers = " ","Ship/Ferry",Railway,Truck,Air,Entry,Installation,"Own transport";
        }
        field(49; CashPayment; Option)
        {
            Caption = 'Cash payment';
            OptionMembers = No,Yes;
        }
        field(50; PaymentMode; Text[10])
        {
            Caption = 'Paym. method';
        }
        field(51; SalesGroup; Code[10])
        {
            Caption = 'Order group';
        }
        field(52; ProjGroup; Code[10])
        {
            Caption = 'Project group';
        }
        field(53; TradeCode; Text[10])
        {
            Caption = 'Transact. type';
        }
        field(54; TransportCode; Text[10])
        {
            Caption = 'Transport';
        }
        field(55; Email; Text[80])
        {
            Caption = 'Email';
        }
        field(56; URL; Text[80])
        {
            Caption = 'Homepage';
        }
        field(57; CellPhone; Text[20])
        {
            Caption = 'Cell phone';
        }
        field(58; KrakNumber; Text[15])
        {
            Caption = 'Krak no.';
        }
        field(59; Centre; Code[10])
        {
            Caption = 'Cost centre';
        }
        field(60; Purpose; Code[10])
        {
            Caption = 'Purpose';
        }
        field(61; EanNumber; Text[14])
        {
            Caption = 'EAN';
        }
        field(62; DimAccountCode; Text[35])
        {
            Caption = 'A/c dimension';
        }
        field(63; XMLInvoice; Option)
        {
            Caption = 'OIOXML';
            OptionMembers = No,Yes;
        }
        field(64; LastInvoiceDate; Date)
        {
            Caption = 'Invoice date';
        }
        field(65; LastPaymentDate; Date)
        {
            Caption = 'Payment';
        }
        field(66; LastReminderDate; Date)
        {
            Caption = 'Reminder';
        }
        field(67; LastInterestDate; Date)
        {
            Caption = 'Last Interest Date';
        }
        field(68; LastInvoiceNumber; Text[20])
        {
            Caption = 'Invoice';
        }
        field(69; XMLImport; Option)
        {
            Caption = 'XML import';
            OptionMembers = No,Yes;
        }
        field(70; VatGroup; Code[10])
        {
            Caption = 'VAT group';
        }
        field(71; StdAccount; Option)
        {
            Caption = 'Default';
            OptionMembers = No,Yes;
        }
        field(72; VatNumberType; Text[10])
        {
            Caption = 'VAT number type';
        }
    }

    keys
    {
        key(PK; RecId)
        {
            Clustered = true;
        }
    }
}

