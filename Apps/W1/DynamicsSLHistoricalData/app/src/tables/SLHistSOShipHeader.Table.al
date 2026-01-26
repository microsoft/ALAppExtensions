// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

table 42815 "SL Hist. SOShipHeader"
{
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; AccrDocDate; DateTime)
        {
            Caption = 'AccrDocDate';
        }
        field(2; AccrPerPost; Text[6])
        {
            Caption = 'AccrPerPost';
        }
        field(3; AccrRevAcct; Text[10])
        {
            Caption = 'AccrRevAcct';
        }
        field(4; AccrRevSub; Text[24])
        {
            Caption = 'AccrRevSub';
        }
        field(5; AccrShipRegisterID; Text[10])
        {
            Caption = 'AccrShipRegisterID';
        }
        field(6; AddressType; Text[1])
        {
            Caption = 'AddressType';
        }
        field(7; AdminHold; Integer)
        {
            Caption = 'AdminHold';
        }
        field(8; AppliedToDocRef; Text[15])
        {
            Caption = 'AppliedToDocRef';
        }
        field(9; ARAcct; Text[10])
        {
            Caption = 'ARAcct';
        }
        field(10; ARBatNbr; Text[10])
        {
            Caption = 'ARBatNbr';
        }
        field(11; ARDocType; Text[2])
        {
            Caption = 'ARDocType';
        }
        field(12; ARSub; Text[24])
        {
            Caption = 'ARSub';
        }
        field(13; ASID; Integer)
        {
            Caption = 'ASID';
        }
        field(14; ASID01; Integer)
        {
            Caption = 'ASID01';
        }
        field(15; AuthNbr; Text[20])
        {
            Caption = 'AuthNbr';
        }
        field(16; AutoReleaseReturn; Integer)
        {
            Caption = 'AutoReleaseReturn';
        }
        field(17; BalDue; Decimal)
        {
            Caption = 'BalDue';
        }
        field(18; BIInvoice; Text[1])
        {
            Caption = 'BIInvoice';
        }
        field(19; BillAddr1; Text[60])
        {
            Caption = 'BillAddr1';
        }
        field(20; BillAddr2; Text[60])
        {
            Caption = 'BillAddr2';
        }
        field(21; BillAddrSpecial; Integer)
        {
            Caption = 'BillAddrSpecial';
        }
        field(22; BillAttn; Text[30])
        {
            Caption = 'BillAttn';
        }
        field(23; BillCity; Text[30])
        {
            Caption = 'BillCity';
        }
        field(24; BillCountry; Text[3])
        {
            Caption = 'BillCountry';
        }
        field(25; BillName; Text[60])
        {
            Caption = 'BillName';
        }
        field(26; BillPhone; Text[30])
        {
            Caption = 'BillPhone';
        }
        field(27; BillState; Text[3])
        {
            Caption = 'BillState';
        }
        field(28; BillThruProject; Integer)
        {
            Caption = 'BillThruProject';
        }
        field(29; BillZip; Text[10])
        {
            Caption = 'BillZip';
        }
        field(30; BlktOrdNbr; Text[15])
        {
            Caption = 'BlktOrdNbr';
        }
        field(31; BMICost; Decimal)
        {
            Caption = 'BMICost';
        }
        field(32; BMICuryID; Text[4])
        {
            Caption = 'BMICuryID';
        }
        field(33; BMIEffDate; DateTime)
        {
            Caption = 'BMIEffDate';
        }
        field(34; BMIMultDiv; Text[1])
        {
            Caption = 'BMIMultDiv';
        }
        field(35; BMIRate; Decimal)
        {
            Caption = 'BMIRate';
        }
        field(36; BMIRtTp; Text[6])
        {
            Caption = 'BMIRtTp';
        }
        field(37; BookCntr; Integer)
        {
            Caption = 'BookCntr';
        }
        field(38; BookCntrMisc; Integer)
        {
            Caption = 'BookCntrMisc';
        }
        field(39; BoxCntr; Integer)
        {
            Caption = 'BoxCntr';
        }
        field(40; BuildActQty; Decimal)
        {
            Caption = 'BuildActQty';
        }
        field(41; BuildCmpltDate; DateTime)
        {
            Caption = 'BuildCmpltDate';
        }
        field(42; BuildInvtID; Text[30])
        {
            Caption = 'BuildInvtID';
        }
        field(43; BuildLotSerCntr; Integer)
        {
            Caption = 'BuildLotSerCntr';
        }
        field(44; BuildQty; Decimal)
        {
            Caption = 'BuildQty';
        }
        field(45; BuildTotalCost; Decimal)
        {
            Caption = 'BuildTotalCost';
        }
        field(46; BuyerID; Text[10])
        {
            Caption = 'BuyerID';
        }
        field(47; BuyerName; Text[60])
        {
            Caption = 'BuyerName';
        }
        field(48; CancelBO; Integer)
        {
            Caption = 'CancelBO';
        }
        field(49; Cancelled; Integer)
        {
            Caption = 'Cancelled';
        }
        field(50; CancelOrder; Integer)
        {
            Caption = 'CancelOrder';
        }
        field(51; CertID; Text[2])
        {
            Caption = 'CertID';
        }
        field(52; CertNoteID; Integer)
        {
            Caption = 'CertNoteID';
        }
        field(53; ChainDisc; Text[15])
        {
            Caption = 'ChainDisc';
        }
        field(54; CmmnPct; Decimal)
        {
            Caption = 'CmmnPct';
        }
        field(55; ConsolInv; Integer)
        {
            Caption = 'ConsolInv';
        }
        field(56; ContractNbr; Text[25])
        {
            Caption = 'ContractNbr';
        }
        field(57; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(58; CreditApprDays; Integer)
        {
            Caption = 'CreditApprDays';
        }
        field(59; CreditApprLimit; Decimal)
        {
            Caption = 'CreditApprLimit';
        }
        field(60; CreditChk; Integer)
        {
            Caption = 'CreditChk';
        }
        field(61; CreditHold; Integer)
        {
            Caption = 'CreditHold';
        }
        field(62; CreditHoldDate; DateTime)
        {
            Caption = 'CreditHoldDate';
        }
        field(63; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(64; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(65; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(66; CuryBalDue; Decimal)
        {
            Caption = 'CuryBalDue';
        }
        field(67; CuryBuildTotCost; Decimal)
        {
            Caption = 'CuryBuildTotCost';
        }
        field(68; CuryEffDate; DateTime)
        {
            Caption = 'CuryEffDate';
        }
        field(69; CuryID; Text[4])
        {
            Caption = 'CuryID';
        }
        field(70; CuryMultDiv; Text[1])
        {
            Caption = 'CuryMultDiv';
        }
        field(71; CuryPremFrtAmt; Decimal)
        {
            Caption = 'CuryPremFrtAmt';
        }
        field(72; CuryRate; Decimal)
        {
            Caption = 'CuryRate';
        }
        field(73; CuryRateType; Text[6])
        {
            Caption = 'CuryRateType';
        }
        field(74; CuryTotFrtCost; Decimal)
        {
            Caption = 'CuryTotFrtCost';
        }
        field(75; CuryTotFrtInvc; Decimal)
        {
            Caption = 'CuryTotFrtInvc';
        }
        field(76; CuryTotInvc; Decimal)
        {
            Caption = 'CuryTotInvc';
        }
        field(77; CuryTotLineDisc; Decimal)
        {
            Caption = 'CuryTotLineDisc';
        }
        field(78; CuryTotMerch; Decimal)
        {
            Caption = 'CuryTotMerch';
        }
        field(79; CuryTotMisc; Decimal)
        {
            Caption = 'CuryTotMisc';
        }
        field(80; CuryTotPmt; Decimal)
        {
            Caption = 'CuryTotPmt';
        }
        field(81; CuryTotTax; Decimal)
        {
            Caption = 'CuryTotTax';
        }
        field(82; CuryTotTxbl; Decimal)
        {
            Caption = 'CuryTotTxbl';
        }
        field(83; CuryWholeOrdDisc; Decimal)
        {
            Caption = 'CuryWholeOrdDisc';
        }
        field(84; CustGLClassID; Text[4])
        {
            Caption = 'CustGLClassID';
        }
        field(85; CustID; Text[15])
        {
            Caption = 'CustID';
        }
        field(86; CustOrdNbr; Text[25])
        {
            Caption = 'CustOrdNbr';
        }
        field(87; DateCancelled; DateTime)
        {
            Caption = 'DateCancelled';
        }
        field(88; Dept; Text[30])
        {
            Caption = 'Dept';
        }
        field(89; DiscAcct; Text[10])
        {
            Caption = 'DiscAcct';
        }
        field(90; DiscPct; Decimal)
        {
            Caption = 'DiscPct';
        }
        field(91; DiscSub; Text[24])
        {
            Caption = 'DiscSub';
        }
        field(92; Div; Text[30])
        {
            Caption = 'Div';
        }
        field(93; DropShip; Integer)
        {
            Caption = 'DropShip';
        }
        field(94; EDI810; Integer)
        {
            Caption = 'EDI810';
        }
        field(95; EDI856; Integer)
        {
            Caption = 'EDI856';
        }
        field(96; EDIASNProcNbr; Text[10])
        {
            Caption = 'EDIASNProcNbr';
        }
        field(97; EDIInvcProcNbr; Text[10])
        {
            Caption = 'EDIInvcProcNbr';
        }
        field(98; ETADate; DateTime)
        {
            Caption = 'ETADate';
        }
        field(99; FOBID; Text[15])
        {
            Caption = 'FOBID';
        }
        field(100; FrtAcct; Text[10])
        {
            Caption = 'FrtAcct';
        }
        field(101; FrtCollect; Integer)
        {
            Caption = 'FrtCollect';
        }
        field(102; FrtSub; Text[24])
        {
            Caption = 'FrtSub';
        }
        field(103; FrtTermsID; Text[10])
        {
            Caption = 'FrtTermsID';
        }
        field(104; GeoCode; Text[10])
        {
            Caption = 'GeoCode';
        }
        field(105; INBatNbr; Text[10])
        {
            Caption = 'INBatNbr';
        }
        field(106; InvcDate; DateTime)
        {
            Caption = 'InvcDate';
        }
        field(107; InvcNbr; Text[15])
        {
            Caption = 'InvcNbr';
        }
        field(108; InvcPrint; Integer)
        {
            Caption = 'InvcPrint';
        }
        field(109; LanguageID; Text[4])
        {
            Caption = 'LanguageID';
        }
        field(110; LastAppendDate; DateTime)
        {
            Caption = 'LastAppendDate';
        }
        field(111; LastAppendTime; DateTime)
        {
            Caption = 'LastAppendTime';
        }
        field(112; LineCntr; Integer)
        {
            Caption = 'LineCntr';
        }
        field(113; LotSerialHold; Integer)
        {
            Caption = 'LotSerialHold';
        }
        field(114; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(115; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(116; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(117; MarkFor; Integer)
        {
            Caption = 'MarkFor';
        }
        field(118; MiscChrgCntr; Integer)
        {
            Caption = 'MiscChrgCntr';
        }
        field(119; NextFunctionClass; Text[4])
        {
            Caption = 'NextFunctionClass';
        }
        field(120; NextFunctionID; Text[8])
        {
            Caption = 'NextFunctionID';
        }
        field(121; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(122; OKToAppend; Integer)
        {
            Caption = 'OKToAppend';
        }
        field(123; OrdDate; DateTime)
        {
            Caption = 'OrdDate';
        }
        field(224; OrdNbr; Text[15])
        {
            Caption = 'OrdNbr';
        }
        field(124; OverridePerPost; Integer)
        {
            Caption = 'OverridePerPost';
        }
        field(125; PackDate; DateTime)
        {
            Caption = 'PackDate';
        }
        field(126; PerClosed; Text[6])
        {
            Caption = 'PerClosed';
        }
        field(127; PerPost; Text[6])
        {
            Caption = 'PerPost';
        }
        field(128; PickDate; DateTime)
        {
            Caption = 'PickDate';
        }
        field(129; PmtCntr; Integer)
        {
            Caption = 'PmtCntr';
        }
        field(130; PremFrt; Integer)
        {
            Caption = 'PremFrt';
        }
        field(131; PremFrtAmt; Decimal)
        {
            Caption = 'PremFrtAmt';
        }
        field(132; Priority; Integer)
        {
            Caption = 'Priority';
        }
        field(133; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(134; RelDate; DateTime)
        {
            Caption = 'RelDate';
        }
        field(135; ReleaseValue; Decimal)
        {
            Caption = 'ReleaseValue';
        }
        field(136; RequireStepAssy; Integer)
        {
            Caption = 'RequireStepAssy';
        }
        field(137; RequireStepInsp; Integer)
        {
            Caption = 'RequireStepInsp';
        }
        field(138; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(139; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(140; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(141; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(142; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(143; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(144; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(145; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(146; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(147; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(148; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(149; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(150; SellingSiteID; Text[10])
        {
            Caption = 'SellingSiteID';
        }
        field(151; ShipAddr1; Text[60])
        {
            Caption = 'ShipAddr1';
        }
        field(152; ShipAddr2; Text[60])
        {
            Caption = 'ShipAddr2';
        }
        field(153; ShipAddrID; Text[10])
        {
            Caption = 'ShipAddrID';
        }
        field(154; ShipAddrSpecial; Integer)
        {
            Caption = 'ShipAddrSpecial';
        }
        field(155; ShipAttn; Text[30])
        {
            Caption = 'ShipAttn';
        }
        field(156; ShipCity; Text[30])
        {
            Caption = 'ShipCity';
        }
        field(157; ShipCmplt; Integer)
        {
            Caption = 'ShipCmplt';
        }
        field(158; ShipCountry; Text[3])
        {
            Caption = 'ShipCountry';
        }
        field(159; ShipCustID; Text[15])
        {
            Caption = 'ShipCustID';
        }
        field(160; ShipDateAct; DateTime)
        {
            Caption = 'ShipDateAct';
        }
        field(161; ShipDatePlan; DateTime)
        {
            Caption = 'ShipDatePlan';
        }
        field(162; ShipGeoCode; Text[10])
        {
            Caption = 'ShipGeoCode';
        }
        field(163; ShipName; Text[60])
        {
            Caption = 'ShipName';
        }
        field(164; ShipperID; Text[15])
        {
            Caption = 'ShipperID';
        }
        field(165; ShipPhone; Text[30])
        {
            Caption = 'ShipPhone';
        }
        field(166; ShippingConfirmed; Integer)
        {
            Caption = 'ShippingConfirmed';
        }
        field(167; ShippingManifested; Integer)
        {
            Caption = 'ShippingManifested';
        }
        field(168; ShipRegisterID; Text[10])
        {
            Caption = 'ShipRegisterID';
        }
        field(169; ShipSiteID; Text[10])
        {
            Caption = 'ShipSiteID';
        }
        field(170; ShipState; Text[3])
        {
            Caption = 'ShipState';
        }
        field(171; ShiptoID; Text[10])
        {
            Caption = 'ShiptoID';
        }
        field(172; ShiptoType; Text[1])
        {
            Caption = 'ShiptoType';
        }
        field(173; ShipVendAddrID; Text[10])
        {
            Caption = 'ShipVendAddrID';
        }
        field(174; ShipVendID; Text[15])
        {
            Caption = 'ShipVendID';
        }
        field(175; ShipViaID; Text[15])
        {
            Caption = 'ShipViaID';
        }
        field(176; ShipZip; Text[10])
        {
            Caption = 'ShipZip';
        }
        field(177; SiteID; Text[10])
        {
            Caption = 'SiteID';
        }
        field(178; SlsperID; Text[10])
        {
            Caption = 'SlsperID';
        }
        field(179; SOTypeID; Text[4])
        {
            Caption = 'SOTypeID';
        }
        field(180; Status; Text[1])
        {
            Caption = 'Status';
        }
        field(181; TaxID00; Text[10])
        {
            Caption = 'TaxID00';
        }
        field(182; TaxID01; Text[10])
        {
            Caption = 'TaxID01';
        }
        field(183; TaxID02; Text[10])
        {
            Caption = 'TaxID02';
        }
        field(184; TaxID03; Text[10])
        {
            Caption = 'TaxID03';
        }
        field(185; TermsID; Text[2])
        {
            Caption = 'TermsID';
        }
        field(186; TotBoxes; Integer)
        {
            Caption = 'TotBoxes';
        }
        field(187; TotCommCost; Decimal)
        {
            Caption = 'TotCommCost';
        }
        field(188; TotCost; Decimal)
        {
            Caption = 'TotCost';
        }
        field(189; TotFrtCost; Decimal)
        {
            Caption = 'TotFrtCost';
        }
        field(190; TotFrtInvc; Decimal)
        {
            Caption = 'TotFrtInvc';
        }
        field(191; TotInvc; Decimal)
        {
            Caption = 'TotInvc';
        }
        field(192; TotLineDisc; Decimal)
        {
            Caption = 'TotLineDisc';
        }
        field(193; TotMerch; Decimal)
        {
            Caption = 'TotMerch';
        }
        field(194; TotMisc; Decimal)
        {
            Caption = 'TotMisc';
        }
        field(195; TotPallets; Integer)
        {
            Caption = 'TotPallets';
        }
        field(196; TotPmt; Decimal)
        {
            Caption = 'TotPmt';
        }
        field(197; TotShipWght; Decimal)
        {
            Caption = 'TotShipWght';
        }
        field(198; TotTax; Decimal)
        {
            Caption = 'TotTax';
        }
        field(199; TotTxbl; Decimal)
        {
            Caption = 'TotTxbl';
        }
        field(200; TrackingNbr; Text[25])
        {
            Caption = 'TrackingNbr';
        }
        field(201; TransitTime; Integer)
        {
            Caption = 'TransitTime';
        }
        field(202; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(203; User10; DateTime)
        {
            Caption = 'User10';
        }
        field(204; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(205; User3; Text[30])
        {
            Caption = 'User3';
        }
        field(206; User4; Text[30])
        {
            Caption = 'User4';
        }
        field(207; User5; Decimal)
        {
            Caption = 'User5';
        }
        field(208; User6; Decimal)
        {
            Caption = 'User6';
        }
        field(209; User7; Text[10])
        {
            Caption = 'User7';
        }
        field(210; User8; Text[10])
        {
            Caption = 'User8';
        }
        field(211; User9; DateTime)
        {
            Caption = 'User9';
        }
        field(212; WeekendDelivery; Integer)
        {
            Caption = 'WeekendDelivery';
        }
        field(213; WholeOrdDisc; Decimal)
        {
            Caption = 'WholeOrdDisc';
        }
        field(214; WorkflowID; Integer)
        {
            Caption = 'WorkflowID';
        }
        field(215; WorkflowStatus; Text[1])
        {
            Caption = 'WorkflowStatus';
        }
        field(216; WSID; Integer)
        {
            Caption = 'WSID';
        }
        field(217; WSID01; Integer)
        {
            Caption = 'WSID01';
        }
        field(218; Zone; Text[6])
        {
            Caption = 'Zone';
        }
    }

    keys
    {
        key(PK; CpnyID, ShipperID)
        {
            Clustered = true;
        }
    }
}