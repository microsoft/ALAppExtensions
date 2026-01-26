// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47034 "SL SOHeader"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; AddressType; Text[1])
        {
            Caption = 'AddressType';
        }
        field(2; AdminHold; Integer)
        {
            Caption = 'AdminHold';
        }
        field(3; AppliedToDocRef; Text[15])
        {
            Caption = 'AppliedToDocRef';
        }
        field(4; ApprDetails; Integer)
        {
            Caption = 'ApprDetails';
        }
        field(5; ApprRMA; Integer)
        {
            Caption = 'ApprRMA';
        }
        field(6; ApprTech; Integer)
        {
            Caption = 'ApprTech';
        }
        field(7; ARAcct; Text[10])
        {
            Caption = 'ARAcct';
        }
        field(8; ARSub; Text[24])
        {
            Caption = 'ARSub';
        }
        field(9; ASID; Integer)
        {
            Caption = 'ASID';
        }
        field(10; ASID01; Integer)
        {
            Caption = 'ASID01';
        }
        field(11; AuthNbr; Text[20])
        {
            Caption = 'AuthNbr';
        }
        field(12; AutoPO; Integer)
        {
            Caption = 'AutoPO';
        }
        field(13; AutoPOVendID; Text[15])
        {
            Caption = 'AutoPOVendID';
        }
        field(14; AwardProbability; Integer)
        {
            Caption = 'AwardProbability';
        }
        field(15; BalDue; Decimal)
        {
            Caption = 'BalDue';
        }
        field(16; BIInvoice; Text[1])
        {
            Caption = 'BIInvoice';
        }
        field(17; BillAddr1; Text[60])
        {
            Caption = 'BillAddr1';
        }
        field(18; BillAddr2; Text[60])
        {
            Caption = 'BillAddr2';
        }
        field(19; BillAddrSpecial; Integer)
        {
            Caption = 'BillAddrSpecial';
        }
        field(20; BillAttn; Text[30])
        {
            Caption = 'BillAttn';
        }
        field(21; BillCity; Text[30])
        {
            Caption = 'BillCity';
        }
        field(22; BillCountry; Text[3])
        {
            Caption = 'BillCountry';
        }
        field(23; BillName; Text[60])
        {
            Caption = 'BillName';
        }
        field(24; BillPhone; Text[30])
        {
            Caption = 'BillPhone';
        }
        field(25; BillState; Text[3])
        {
            Caption = 'BillState';
        }
        field(26; BillThruProject; Integer)
        {
            Caption = 'BillThruProject';
        }
        field(27; BillZip; Text[10])
        {
            Caption = 'BillZip';
        }
        field(28; BlktOrdNbr; Text[15])
        {
            Caption = 'BlktOrdNbr';
        }
        field(29; BookCntr; Integer)
        {
            Caption = 'BookCntr';
        }
        field(30; BookCntrMisc; Integer)
        {
            Caption = 'BookCntrMisc';
        }
        field(31; BuildAssyTime; Integer)
        {
            Caption = 'BuildAssyTime';
        }
        field(32; BuildAvailDate; DateTime)
        {
            Caption = 'BuildAvailDate';
        }
        field(33; BuildInvtID; Text[30])
        {
            Caption = 'BuildInvtID';
        }
        field(34; BuildQty; Decimal)
        {
            Caption = 'BuildQty';
        }
        field(35; BuildQtyUpdated; Decimal)
        {
            Caption = 'BuildQtyUpdated';
        }
        field(36; BuildSiteID; Text[10])
        {
            Caption = 'BuildSiteID';
        }
        field(37; BuyerID; Text[10])
        {
            Caption = 'BuyerID';
        }
        field(38; BuyerName; Text[60])
        {
            Caption = 'BuyerName';
        }
        field(39; CancelDate; DateTime)
        {
            Caption = 'CancelDate';
        }
        field(40; Cancelled; Integer)
        {
            Caption = 'Cancelled';
        }
        field(41; CancelShippers; Integer)
        {
            Caption = 'CancelShippers';
        }
        field(42; CertID; Text[2])
        {
            Caption = 'CertID';
        }
        field(43; CertNoteID; Integer)
        {
            Caption = 'CertNoteID';
        }
        field(44; ChainDisc; Text[15])
        {
            Caption = 'ChainDisc';
        }
        field(45; CmmnPct; Decimal)
        {
            Caption = 'CmmnPct';
        }
        field(46; ConsolInv; Integer)
        {
            Caption = 'ConsolInv';
        }
        field(47; ContractNbr; Text[30])
        {
            Caption = 'ContractNbr';
        }
        field(48; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(49; CreditApprDays; Integer)
        {
            Caption = 'CreditApprDays';
        }
        field(50; CreditApprLimit; Decimal)
        {
            Caption = 'CreditApprLimit';
        }
        field(51; CreditChk; Integer)
        {
            Caption = 'CreditChk';
        }
        field(52; CreditHold; Integer)
        {
            Caption = 'CreditHold';
        }
        field(53; CreditHoldDate; DateTime)
        {
            Caption = 'CreditHoldDate';
        }
        field(54; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(55; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(56; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(57; CuryBalDue; Decimal)
        {
            Caption = 'CuryBalDue';
        }
        field(58; CuryEffDate; DateTime)
        {
            Caption = 'CuryEffDate';
        }
        field(59; CuryID; Text[4])
        {
            Caption = 'CuryID';
        }
        field(60; CuryMultDiv; Text[1])
        {
            Caption = 'CuryMultDiv';
        }
        field(61; CuryPremFrtAmtAppld; Decimal)
        {
            Caption = 'CuryPremFrtAmtAppld';
        }
        field(62; CuryRate; Decimal)
        {
            Caption = 'CuryRate';
        }
        field(63; CuryRateType; Text[6])
        {
            Caption = 'CuryRateType';
        }
        field(64; CuryTotFrt; Decimal)
        {
            Caption = 'CuryTotFrt';
        }
        field(65; CuryTotLineDisc; Decimal)
        {
            Caption = 'CuryTotLineDisc';
        }
        field(66; CuryTotMerch; Decimal)
        {
            Caption = 'CuryTotMerch';
        }
        field(67; CuryTotMisc; Decimal)
        {
            Caption = 'CuryTotMisc';
        }
        field(68; CuryTotOrd; Decimal)
        {
            Caption = 'CuryTotOrd';
        }
        field(69; CuryTotPmt; Decimal)
        {
            Caption = 'CuryTotPmt';
        }
        field(70; CuryTotPremFrt; Decimal)
        {
            Caption = 'CuryTotPremFrt';
        }
        field(71; CuryTotTax; Decimal)
        {
            Caption = 'CuryTotTax';
        }
        field(72; CuryTotTxbl; Decimal)
        {
            Caption = 'CuryTotTxbl';
        }
        field(73; CuryUnshippedBalance; Decimal)
        {
            Caption = 'CuryUnshippedBalance';
        }
        field(74; CuryWholeOrdDisc; Decimal)
        {
            Caption = 'CuryWholeOrdDisc';
        }
        field(75; CustGLClassID; Text[4])
        {
            Caption = 'CustGLClassID';
        }
        field(76; CustID; Text[15])
        {
            Caption = 'CustID';
        }
        field(77; CustOrdNbr; Text[25])
        {
            Caption = 'CustOrdNbr';
        }
        field(78; DateCancelled; DateTime)
        {
            Caption = 'DateCancelled';
        }
        field(79; Dept; Text[30])
        {
            Caption = 'Dept';
        }
        field(80; DiscAcct; Text[10])
        {
            Caption = 'DiscAcct';
        }
        field(81; DiscPct; Decimal)
        {
            Caption = 'DiscPct';
        }
        field(82; DiscSub; Text[24])
        {
            Caption = 'DiscSub';
        }
        field(83; "Div"; Text[30])
        {
            Caption = 'Div';
        }
        field(84; DropShip; Integer)
        {
            Caption = 'DropShip';
        }
        field(85; EDI810; Integer)
        {
            Caption = 'EDI810';
        }
        field(86; EDI856; Integer)
        {
            Caption = 'EDI856';
        }
        field(87; EDIPOID; Text[10])
        {
            Caption = 'EDIPOID';
        }
        field(88; EventCntr; Integer)
        {
            Caption = 'EventCntr';
        }
        field(89; FOBID; Text[15])
        {
            Caption = 'FOBID';
        }
        field(90; FrtAcct; Text[10])
        {
            Caption = 'FrtAcct';
        }
        field(91; FrtCollect; Integer)
        {
            Caption = 'FrtCollect';
        }
        field(92; FrtSub; Text[24])
        {
            Caption = 'FrtSub';
        }
        field(93; FrtTermsID; Text[10])
        {
            Caption = 'FrtTermsID';
        }
        field(94; GeoCode; Text[10])
        {
            Caption = 'GeoCode';
        }
        field(95; InvcDate; DateTime)
        {
            Caption = 'InvcDate';
        }
        field(96; InvcNbr; Text[15])
        {
            Caption = 'InvcNbr';
        }
        field(97; IRDemand; Integer)
        {
            Caption = 'IRDemand';
        }
        field(98; LanguageID; Text[4])
        {
            Caption = 'LanguageID';
        }
        field(99; LineCntr; Integer)
        {
            Caption = 'LineCntr';
        }
        field(100; LostSaleID; Text[2])
        {
            Caption = 'LostSaleID';
        }
        field(101; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(102; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(103; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(104; MarkFor; Integer)
        {
            Caption = 'MarkFor';
        }
        field(105; MiscChrgCntr; Integer)
        {
            Caption = 'MiscChrgCntr';
        }
        field(106; NextFunctionClass; Text[4])
        {
            Caption = 'NextFunctionClass';
        }
        field(107; NextFunctionID; Text[8])
        {
            Caption = 'NextFunctionID';
        }
        field(108; NoteId; Integer)
        {
            Caption = 'NoteId';
        }
        field(109; OrdDate; DateTime)
        {
            Caption = 'OrdDate';
        }
        field(110; OrdNbr; Text[15])
        {
            Caption = 'OrdNbr';
        }
        field(111; OrigOrdNbr; Text[15])
        {
            Caption = 'OrigOrdNbr';
        }
        field(112; PC_Status; Text[1])
        {
            Caption = 'PC_Status';
        }
        field(113; PerPost; Text[6])
        {
            Caption = 'PerPost';
        }
        field(114; PmtCntr; Integer)
        {
            Caption = 'PmtCntr';
        }
        field(115; PremFrtAmtApplied; Decimal)
        {
            Caption = 'PremFrtAmtApplied';
        }
        field(116; Priority; Integer)
        {
            Caption = 'Priority';
        }
        field(117; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(118; QuoteDate; DateTime)
        {
            Caption = 'QuoteDate';
        }
        field(119; Released; Integer)
        {
            Caption = 'Released';
        }
        field(120; ReleaseValue; Decimal)
        {
            Caption = 'ReleaseValue';
        }
        field(121; RequireStepAssy; Integer)
        {
            Caption = 'RequireStepAssy';
        }
        field(122; RequireStepInsp; Integer)
        {
            Caption = 'RequireStepInsp';
        }
        field(123; RlseForInvc; Integer)
        {
            Caption = 'RlseForInvc';
        }
        field(124; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(125; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(126; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(127; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(128; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(129; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(130; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(131; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(132; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(133; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(134; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(135; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(136; SellingSiteID; Text[10])
        {
            Caption = 'SellingSiteID';
        }
        field(137; SFOOrdNbr; Text[15])
        {
            Caption = 'SFOOrdNbr';
        }
        field(138; ShipAddr1; Text[60])
        {
            Caption = 'ShipAddr1';
        }
        field(139; ShipAddr2; Text[60])
        {
            Caption = 'ShipAddr2';
        }
        field(140; ShipAddrID; Text[10])
        {
            Caption = 'ShipAddrID';
        }
        field(141; ShipAddrSpecial; Integer)
        {
            Caption = 'ShipAddrSpecial';
        }
        field(142; ShipAttn; Text[30])
        {
            Caption = 'ShipAttn';
        }
        field(143; ShipCity; Text[30])
        {
            Caption = 'ShipCity';
        }
        field(144; ShipCmplt; Integer)
        {
            Caption = 'ShipCmplt';
        }
        field(145; ShipCountry; Text[3])
        {
            Caption = 'ShipCountry';
        }
        field(146; ShipCustID; Text[15])
        {
            Caption = 'ShipCustID';
        }
        field(147; ShipGeoCode; Text[10])
        {
            Caption = 'ShipGeoCode';
        }
        field(148; ShipName; Text[60])
        {
            Caption = 'ShipName';
        }
        field(149; ShipPhone; Text[30])
        {
            Caption = 'ShipPhone';
        }
        field(150; ShipSiteID; Text[10])
        {
            Caption = 'ShipSiteID';
        }
        field(151; ShipState; Text[3])
        {
            Caption = 'ShipState';
        }
        field(152; ShiptoID; Text[10])
        {
            Caption = 'ShiptoID';
        }
        field(153; ShiptoType; Text[1])
        {
            Caption = 'ShiptoType';
        }
        field(154; ShipVendID; Text[15])
        {
            Caption = 'ShipVendID';
        }
        field(155; ShipViaID; Text[15])
        {
            Caption = 'ShipViaID';
        }
        field(156; ShipZip; Text[10])
        {
            Caption = 'ShipZip';
        }
        field(157; SlsperID; Text[10])
        {
            Caption = 'SlsperID';
        }
        field(158; SOTypeID; Text[4])
        {
            Caption = 'SOTypeID';
        }
        field(159; Status; Text[1])
        {
            Caption = 'Status';
        }
        field(160; TaxID00; Text[10])
        {
            Caption = 'TaxID00';
        }
        field(161; TaxID01; Text[10])
        {
            Caption = 'TaxID01';
        }
        field(162; TaxID02; Text[10])
        {
            Caption = 'TaxID02';
        }
        field(163; TaxID03; Text[10])
        {
            Caption = 'TaxID03';
        }
        field(164; TermsID; Text[2])
        {
            Caption = 'TermsID';
        }
        field(165; TotCommCost; Decimal)
        {
            Caption = 'TotCommCost';
        }
        field(166; TotCost; Decimal)
        {
            Caption = 'TotCost';
        }
        field(167; TotFrt; Decimal)
        {
            Caption = 'TotFrt';
        }
        field(168; TotLineDisc; Decimal)
        {
            Caption = 'TotLineDisc';
        }
        field(169; TotMerch; Decimal)
        {
            Caption = 'TotMerch';
        }
        field(170; TotMisc; Decimal)
        {
            Caption = 'TotMisc';
        }
        field(171; TotOrd; Decimal)
        {
            Caption = 'TotOrd';
        }
        field(172; TotPmt; Decimal)
        {
            Caption = 'TotPmt';
        }
        field(173; TotPremFrt; Decimal)
        {
            Caption = 'TotPremFrt';
        }
        field(174; TotShipWght; Decimal)
        {
            Caption = 'TotShipWght';
        }
        field(175; TotTax; Decimal)
        {
            Caption = 'TotTax';
        }
        field(176; TotTxbl; Decimal)
        {
            Caption = 'TotTxbl';
        }
        field(177; UnshippedBalance; Decimal)
        {
            Caption = 'UnshippedBalance';
        }
        field(178; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(179; User10; DateTime)
        {
            Caption = 'User10';
        }
        field(180; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(181; User3; Text[30])
        {
            Caption = 'User3';
        }
        field(182; User4; Text[30])
        {
            Caption = 'User4';
        }
        field(183; User5; Decimal)
        {
            Caption = 'User5';
        }
        field(184; User6; Decimal)
        {
            Caption = 'User6';
        }
        field(185; User7; Text[10])
        {
            Caption = 'User7';
        }
        field(186; User8; Text[10])
        {
            Caption = 'User8';
        }
        field(187; User9; DateTime)
        {
            Caption = 'User9';
        }
        field(188; VendAddrID; Text[10])
        {
            Caption = 'VendAddrID';
        }
        field(189; WeekendDelivery; Integer)
        {
            Caption = 'WeekendDelivery';
        }
        field(190; WholeOrdDisc; Decimal)
        {
            Caption = 'WholeOrdDisc';
        }
        field(191; WorkflowID; Integer)
        {
            Caption = 'WorkflowID';
        }
        field(192; WorkflowStatus; Text[1])
        {
            Caption = 'WorkflowStatus';
        }
        field(193; WSID; Integer)
        {
            Caption = 'WSID';
        }
    }

    keys
    {
        key(Key1; CpnyID, OrdNbr)
        {
            Clustered = true;
        }
    }
}