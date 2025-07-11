// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

using Microsoft.Purchases.Vendor;

table 1861 "C5 VendTable"
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
            TableRelation = Vendor;
            ValidateTableRelation = false;
            Caption = 'Account';
        }
        field(5; Name; Text[50])
        {
            Caption = 'Name';
        }
        field(6; Address1; Text[50])
        {
            Caption = 'Address';
        }
        field(7; Address2; Text[50])
        {
            Caption = 'Address';
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
        field(13; InvoiceAccount; Text[10])
        {
            Caption = 'Invoice a/c';
        }
        field(14; Group; Code[10])
        {
            Caption = 'Group';
        }
        field(15; FixedDiscPct; Decimal)
        {
            Caption = 'Fixed discount';
        }
        field(16; DiscGroup; Code[10])
        {
            Caption = 'Discount group';
        }
        field(17; CashDisc; Code[10])
        {
            Caption = 'Cash discount';
        }
        field(18; Approved; Option)
        {
            Caption = 'Approved';
            OptionMembers = No,Yes;
        }
        field(19; DEL_ExclDuty; Option)
        {
            Caption = 'Excl. duty';
            OptionMembers = No,Yes;
        }
        field(20; InclVat; Option)
        {
            Caption = 'Incl. VAT';
            OptionMembers = No,Yes;
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
        field(25; Interest; Text[10])
        {
            Caption = 'Interest';
        }
        field(26; Blocked; Option)
        {
            Caption = 'Locked';
            OptionMembers = No,Invoicing,Delivery,Yes;
        }
        field(27; Purchaser; Code[10])
        {
            Caption = 'Purchaser';
        }
        field(28; Vat; Code[10])
        {
            Caption = 'VAT';
        }
        field(29; DEL_StatType; Option)
        {
            Caption = 'DELETEStatistics';
            OptionMembers = "Ordinary trade",Samples,"Trade-in deal","Financial leasing",Returns,Replacement,"Replace non-returns",EU,Authorities,Private,"Production on toll",Repair,"Repair (free of charge)",Leasing,"EU projects","Building materials","Misc.";
        }
        field(30; ESRnumber; Text[10])
        {
            Caption = 'Nets no.';
        }
        field(31; GiroNumber; Text[20])
        {
            Caption = 'FIK/Giro';
        }
        field(32; OurAccount; Text[15])
        {
            Caption = 'Our a/c';
        }
        field(33; BankAccount; Text[15])
        {
            Caption = 'Bank a/c';
        }
        field(34; VatNumber; Text[25])
        {
            Caption = 'VAT No.';
        }
        field(35; Department; Code[10])
        {
            Caption = 'Department';
        }
        field(36; OnetimeSupplier; Option)
        {
            Caption = 'One-off vendor';
            OptionMembers = No,Yes;
        }
        field(37; ImageFile; Text[250])
        {
            Caption = 'Image';
        }
        field(38; Inventory; Option)
        {
            Caption = 'Inventory';
            OptionMembers = "No change",Ordered,Received,"Fixed purchase";
        }
        field(39; EDIAddress; Text[15])
        {
            Caption = 'EDI address';
        }
        field(40; Balance; Decimal)
        {
            Caption = 'Balance';
        }
        field(41; Balance30; Decimal)
        {
            Caption = '0-30 days';
        }
        field(42; Balance60; Decimal)
        {
            Caption = '31-60 days';
        }
        field(43; Balance90; Decimal)
        {
            Caption = '61-90 days';
        }
        field(44; Balance120; Decimal)
        {
            Caption = '91-120 days';
        }
        field(45; Balance120Plus; Decimal)
        {
            Caption = 'More than 120 days';
        }
        field(46; AmountDue; Decimal)
        {
            Caption = 'Due';
        }
        field(47; CalculationDate; Date)
        {
            Caption = 'Calculated';
        }
        field(48; BalanceMax; Decimal)
        {
            Caption = 'Max. balance';
        }
        field(49; BalanceMST; Decimal)
        {
            Caption = 'Balance LCY';
        }
        field(50; SearchName; Text[30])
        {
            Caption = 'Search name';
        }
        field(51; DEL_Transport; Option)
        {
            Caption = 'DELETETransport';
            OptionMembers = " ","Ship/Ferry",Railway,Truck,Air,Entry,Installation,"Own transport";
        }
        field(52; CashPayment; Option)
        {
            Caption = 'Cash payment';
            OptionMembers = No,Yes;
        }
        field(53; PaymentMode; Text[10])
        {
            Caption = 'Paym. method';
        }
        field(54; PaymSpec; Text[10])
        {
            Caption = 'Paym. spec.';
        }
        field(55; Telex; Text[20])
        {
            Caption = 'Telex';
        }
        field(56; PaymId; Text[20])
        {
            Caption = 'PaymID';
        }
        field(57; PurchGroup; Code[10])
        {
            Caption = 'Purchase group';
        }
        field(58; TradeCode; Text[10])
        {
            Caption = 'Transact. type';
        }
        field(59; TransportCode; Code[10])
        {
            Caption = 'Transport';
        }
        field(60; Email; Text[80])
        {
            Caption = 'Email';
        }
        field(61; URL; Text[80])
        {
            Caption = 'Homepage';
        }
        field(62; CellPhone; Text[20])
        {
            Caption = 'Cell phone';
        }
        field(63; KrakNumber; Text[15])
        {
            Caption = 'Krak no.';
        }
        field(64; Centre; Code[10])
        {
            Caption = 'Cost centre';
        }
        field(65; Purpose; Code[10])
        {
            Caption = 'Purpose';
        }
        field(66; LastInvoiceDate; Date)
        {
            Caption = 'Invoice date';
        }
        field(67; LastPaymentDate; Date)
        {
            Caption = 'Payment';
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
        field(70; EanNumber; Text[14])
        {
            Caption = 'EAN';
        }
        field(71; VatGroup; Code[10])
        {
            Caption = 'VAT group';
        }
        field(72; CardType; Text[2])
        {
            Caption = 'Card type';
        }
        field(73; StdAccount; Option)
        {
            Caption = 'Default';
            OptionMembers = No,Yes;
        }
        field(74; VatNumberType; Text[10])
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

