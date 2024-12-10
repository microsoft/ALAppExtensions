// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47039 "SL PurchOrd"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; AckDateTime; DateTime)
        {
            Caption = 'AckDateTime';
        }
        field(2; ASID; Integer)
        {
            Caption = 'ASID';
        }
        field(3; BatNbr; Text[10])
        {
            Caption = 'BatNbr';
        }
        field(4; BillShipAddr; Integer)
        {
            Caption = 'BillShipAddr';
        }
        field(5; BlktExprDate; DateTime)
        {
            Caption = 'BlktExprDate';
        }
        field(6; BlktPONbr; Text[10])
        {
            Caption = 'BlktPONbr';
        }
        field(7; Buyer; Text[10])
        {
            Caption = 'Buyer';
        }
        field(8; BuyerEmail; Text[80])
        {
            Caption = 'BuyerEmail';
        }
        field(9; CertCompl; Integer)
        {
            Caption = 'CertCompl';
        }
        field(10; ConfirmTo; Text[10])
        {
            Caption = 'ConfirmTo';
        }
        field(11; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(12; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(13; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(14; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(15; CurrentNbr; Integer)
        {
            Caption = 'CurrentNbr';
        }
        field(16; CuryEffDate; DateTime)
        {
            Caption = 'CuryEffDate';
        }
        field(17; CuryFreight; Decimal)
        {
            Caption = 'CuryFreight';
        }
        field(18; CuryID; Text[4])
        {
            Caption = 'CuryID';
        }
        field(19; CuryMultDiv; Text[1])
        {
            Caption = 'CuryMultDiv';
        }
        field(20; CuryPOAmt; Decimal)
        {
            Caption = 'CuryPOAmt';
        }
        field(21; CuryPOItemTotal; Decimal)
        {
            Caption = 'CuryPOItemTotal';
        }
        field(22; CuryRate; Decimal)
        {
            Caption = 'CuryRate';
        }
        field(23; CuryRateType; Text[6])
        {
            Caption = 'CuryRateType';
        }
        field(24; CuryRcptTotAmt; Decimal)
        {
            Caption = 'CuryRcptTotAmt';
        }
        field(25; CuryTaxTot00; Decimal)
        {
            Caption = 'CuryTaxTot00';
        }
        field(26; CuryTaxTot01; Decimal)
        {
            Caption = 'CuryTaxTot01';
        }
        field(27; CuryTaxTot02; Decimal)
        {
            Caption = 'CuryTaxTot02';
        }
        field(28; CuryTaxTot03; Decimal)
        {
            Caption = 'CuryTaxTot03';
        }
        field(29; CuryTxblTot00; Decimal)
        {
            Caption = 'CuryTxblTot00';
        }
        field(30; CuryTxblTot01; Decimal)
        {
            Caption = 'CuryTxblTot01';
        }
        field(31; CuryTxblTot02; Decimal)
        {
            Caption = 'CuryTxblTot02';
        }
        field(32; CuryTxblTot03; Decimal)
        {
            Caption = 'CuryTxblTot03';
        }
        field(33; EDI; Integer)
        {
            Caption = 'EDI';
        }
        field(34; FOB; Text[15])
        {
            Caption = 'FOB';
        }
        field(35; Freight; Decimal)
        {
            Caption = 'Freight';
        }
        field(36; LastRcptDate; DateTime)
        {
            Caption = 'LastRcptDate';
        }
        field(37; LineCntr; Integer)
        {
            Caption = 'LineCntr';
        }
        field(38; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(39; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(40; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(41; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(42; OpenPO; Integer)
        {
            Caption = 'OpenPO';
        }
        field(43; PC_Status; Text[1])
        {
            Caption = 'PC_Status';
        }
        field(44; PerClosed; Text[6])
        {
            Caption = 'PerClosed';
        }
        field(45; PerEnt; Text[6])
        {
            Caption = 'PerEnt';
        }
        field(46; POAmt; Decimal)
        {
            Caption = 'POAmt';
        }
        field(47; PODate; DateTime)
        {
            Caption = 'PODate';
        }
        field(48; POItemTotal; Decimal)
        {
            Caption = 'POItemTotal';
        }
        field(49; PONbr; Text[10])
        {
            Caption = 'PONbr';
        }
        field(50; POType; Text[2])
        {
            Caption = 'POType';
        }
        field(51; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(52; PrtBatNbr; Text[10])
        {
            Caption = 'PrtBatNbr';
        }
        field(53; PrtFlg; Integer)
        {
            Caption = 'PrtFlg';
        }
        field(54; RcptStage; Text[1])
        {
            Caption = 'RcptStage';
        }
        field(55; RcptTotAmt; Decimal)
        {
            Caption = 'RcptTotAmt';
        }
        field(56; ReqNbr; Text[10])
        {
            Caption = 'ReqNbr';
        }
        field(57; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(58; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(59; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(60; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(61; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(62; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(63; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(64; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(65; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(66; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(67; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(68; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(69; ServiceCallID; Text[10])
        {
            Caption = 'ServiceCallID';
        }
        field(70; ShipAddr1; Text[60])
        {
            Caption = 'ShipAddr1';
        }
        field(71; ShipAddr2; Text[60])
        {
            Caption = 'ShipAddr2';
        }
        field(72; ShipAddrID; Text[10])
        {
            Caption = 'ShipAddrID';
        }
        field(73; ShipAttn; Text[30])
        {
            Caption = 'ShipAttn';
        }
        field(74; ShipCity; Text[30])
        {
            Caption = 'ShipCity';
        }
        field(75; ShipCountry; Text[3])
        {
            Caption = 'ShipCountry';
        }
        field(76; ShipCustID; Text[15])
        {
            Caption = 'ShipCustID';
        }
        field(77; ShipEmail; Text[80])
        {
            Caption = 'ShipEmail';
        }
        field(78; ShipFax; Text[30])
        {
            Caption = 'ShipFax';
        }
        field(79; ShipName; Text[60])
        {
            Caption = 'ShipName';
        }
        field(80; ShipPhone; Text[30])
        {
            Caption = 'ShipPhone';
        }
        field(81; ShipSiteID; Text[10])
        {
            Caption = 'ShipSiteID';
        }
        field(82; ShipState; Text[3])
        {
            Caption = 'ShipState';
        }
        field(83; ShiptoID; Text[10])
        {
            Caption = 'ShiptoID';
        }
        field(84; ShiptoType; Text[1])
        {
            Caption = 'ShiptoType';
        }
        field(85; ShipVendAddrID; Text[10])
        {
            Caption = 'ShipVendAddrID';
        }
        field(86; ShipVendID; Text[15])
        {
            Caption = 'ShipVendID';
        }
        field(87; ShipVia; Text[15])
        {
            Caption = 'ShipVia';
        }
        field(88; ShipZip; Text[10])
        {
            Caption = 'ShipZip';
        }
        field(89; Status; Text[1])
        {
            Caption = 'Status';
        }
        field(90; TaxCntr00; Integer)
        {
            Caption = 'TaxCntr00';
        }
        field(91; TaxCntr01; Integer)
        {
            Caption = 'TaxCntr01';
        }
        field(92; TaxCntr02; Integer)
        {
            Caption = 'TaxCntr02';
        }
        field(93; TaxCntr03; Integer)
        {
            Caption = 'TaxCntr03';
        }
        field(94; TaxID00; Text[10])
        {
            Caption = 'TaxID00';
        }
        field(95; TaxID01; Text[10])
        {
            Caption = 'TaxID01';
        }
        field(96; TaxID02; Text[10])
        {
            Caption = 'TaxID02';
        }
        field(97; TaxID03; Text[10])
        {
            Caption = 'TaxID03';
        }
        field(98; TaxTot00; Decimal)
        {
            Caption = 'TaxTot00';
        }
        field(99; TaxTot01; Decimal)
        {
            Caption = 'TaxTot01';
        }
        field(100; TaxTot02; Decimal)
        {
            Caption = 'TaxTot02';
        }
        field(101; TaxTot03; Decimal)
        {
            Caption = 'TaxTot03';
        }
        field(102; Terms; Text[2])
        {
            Caption = 'Terms';
        }
        field(103; TxblTot00; Decimal)
        {
            Caption = 'TxblTot00';
        }
        field(104; TxblTot01; Decimal)
        {
            Caption = 'TxblTot01';
        }
        field(105; TxblTot02; Decimal)
        {
            Caption = 'TxblTot02';
        }
        field(106; TxblTot03; Decimal)
        {
            Caption = 'TxblTot03';
        }
        field(107; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(108; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(109; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(110; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(111; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(112; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(113; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(114; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(115; VendAddr1; Text[60])
        {
            Caption = 'VendAddr1';
        }
        field(116; VendAddr2; Text[60])
        {
            Caption = 'VendAddr2';
        }
        field(117; VendAddrID; Text[10])
        {
            Caption = 'VendAddrID';
        }
        field(118; VendAttn; Text[30])
        {
            Caption = 'VendAttn';
        }
        field(119; VendCity; Text[30])
        {
            Caption = 'VendCity';
        }
        field(120; VendCountry; Text[3])
        {
            Caption = 'VendCountry';
        }
        field(121; VendEmail; Text[80])
        {
            Caption = 'VendEmail';
        }
        field(122; VendFax; Text[30])
        {
            Caption = 'VendFax';
        }
        field(123; VendID; Text[15])
        {
            Caption = 'VendID';
        }
        field(124; VendName; Text[60])
        {
            Caption = 'VendName';
        }
        field(125; VendPhone; Text[30])
        {
            Caption = 'VendPhone';
        }
        field(126; VendState; Text[3])
        {
            Caption = 'VendState';
        }
        field(127; VendZip; Text[10])
        {
            Caption = 'VendZip';
        }
        field(128; VouchStage; Text[1])
        {
            Caption = 'VouchStage';
        }
        field(129; WSID; Integer)
        {
            Caption = 'VouchStage';
        }
    }

    keys
    {
        key(Key1; PONbr)
        {
            Clustered = true;
        }
    }
}