namespace Microsoft.DataMigration.SL.HistoricalData;

table 42813 "SL Hist. SOHeader"
{
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
        field(251; BillThruProject; Integer)
        {
            Caption = 'BillThruProject';
        }
        field(26; BillZip; Text[10])
        {
            Caption = 'BillZip';
        }
        field(27; BlktOrdNbr; Text[15])
        {
            Caption = 'BlktOrdNbr';
        }
        field(28; BookCntr; Integer)
        {
            Caption = 'BookCntr';
        }
        field(29; BookCntrMisc; Integer)
        {
            Caption = 'BookCntrMisc';
        }
        field(30; BuildAssyTime; Integer)
        {
            Caption = 'BuildAssyTime';
        }
        field(31; BuildAvailDate; DateTime)
        {
            Caption = 'BuildAvailDate';
        }
        field(32; BuildInvtID; Text[30])
        {
            Caption = 'BuildInvtID';
        }
        field(33; BuildQty; Decimal)
        {
            Caption = 'BuildQty';
        }
        field(34; BuildQtyUpdated; Decimal)
        {
            Caption = 'BuildQtyUpdated';
        }
        field(35; BuildSiteID; Text[10])
        {
            Caption = 'BuildSiteID';
        }
        field(36; BuyerID; Text[10])
        {
            Caption = 'BuyerID';
        }
        field(37; BuyerName; Text[60])
        {
            Caption = 'BuyerName';
        }
        field(38; CancelDate; DateTime)
        {
            Caption = 'CancelDate';
        }
        field(39; Cancelled; Integer)
        {
            Caption = 'Cancelled';
        }
        field(40; CancelShippers; Integer)
        {
            Caption = 'CancelShippers';
        }
        field(41; CertID; Text[2])
        {
            Caption = 'CertID';
        }
        field(42; CertNoteID; Integer)
        {
            Caption = 'CertNoteID';
        }
        field(43; ChainDisc; Text[15])
        {
            Caption = 'ChainDisc';
        }
        field(44; CmmnPct; Decimal)
        {
            Caption = 'CmmnPct';
        }
        field(45; ConsolInv; Integer)
        {
            Caption = 'ConsolInv';
        }
        field(46; ContractNbr; Text[30])
        {
            Caption = 'ContractNbr';
        }
        field(47; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(48; CreditApprDays; Integer)
        {
            Caption = 'CreditApprDays';
        }
        field(49; CreditApprLimit; Decimal)
        {
            Caption = 'CreditApprLimit';
        }
        field(50; CreditChk; Integer)
        {
            Caption = 'CreditChk';
        }
        field(51; CreditHold; Integer)
        {
            Caption = 'CreditHold';
        }
        field(52; CreditHoldDate; DateTime)
        {
            Caption = 'CreditHoldDate';
        }
        field(53; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(54; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(55; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(56; CuryBalDue; Decimal)
        {
            Caption = 'CuryBalDue';
        }
        field(57; CuryEffDate; DateTime)
        {
            Caption = 'CuryEffDate';
        }
        field(58; CuryID; Text[4])
        {
            Caption = 'CuryID';
        }
        field(59; CuryMultDiv; Text[1])
        {
            Caption = 'CuryMultDiv';
        }
        field(60; CuryPremFrtAmtAppld; Decimal)
        {
            Caption = 'CuryPremFrtAmtAppld';
        }
        field(61; CuryRate; Decimal)
        {
            Caption = 'CuryRate';
        }
        field(62; CuryRateType; Text[6])
        {
            Caption = 'CuryRateType';
        }
        field(63; CuryTotFrt; Decimal)
        {
            Caption = 'CuryTotFrt';
        }
        field(64; CuryTotLineDisc; Decimal)
        {
            Caption = 'CuryTotLineDisc';
        }
        field(65; CuryTotMerch; Decimal)
        {
            Caption = 'CuryTotMerch';
        }
        field(66; CuryTotMisc; Decimal)
        {
            Caption = 'CuryTotMisc';
        }
        field(67; CuryTotOrd; Decimal)
        {
            Caption = 'CuryTotOrd';
        }
        field(68; CuryTotPmt; Decimal)
        {
            Caption = 'CuryTotPmt';
        }
        field(69; CuryTotPremFrt; Decimal)
        {
            Caption = 'CuryTotPremFrt';
        }
        field(70; CuryTotTax; Decimal)
        {
            Caption = 'CuryTotTax';
        }
        field(71; CuryTotTxbl; Decimal)
        {
            Caption = 'CuryTotTxbl';
        }
        field(72; CuryUnshippedBalance; Decimal)
        {
            Caption = 'CuryUnshippedBalance';
        }
        field(73; CuryWholeOrdDisc; Decimal)
        {
            Caption = 'CuryWholeOrdDisc';
        }
        field(74; CustGLClassID; Text[4])
        {
            Caption = 'CustGLClassID';
        }
        field(75; CustID; Text[15])
        {
            Caption = 'CustID';
        }
        field(76; CustOrdNbr; Text[25])
        {
            Caption = 'CustOrdNbr';
        }
        field(77; DateCancelled; DateTime)
        {
            Caption = 'DateCancelled';
        }
        field(78; Dept; Text[30])
        {
            Caption = 'Dept';
        }
        field(79; DiscAcct; Text[10])
        {
            Caption = 'DiscAcct';
        }
        field(80; DiscPct; Decimal)
        {
            Caption = 'DiscPct';
        }
        field(81; DiscSub; Text[24])
        {
            Caption = 'DiscSub';
        }
        field(82; Div; Text[30])
        {
            Caption = 'Div';
        }
        field(83; DropShip; Integer)
        {
            Caption = 'DropShip';
        }
        field(84; EDI810; Integer)
        {
            Caption = 'EDI810';
        }
        field(85; EDI856; Integer)
        {
            Caption = 'EDI856';
        }
        field(86; EDIPOID; Text[10])
        {
            Caption = 'EDIPOID';
        }
        field(87; EventCntr; Integer)
        {
            Caption = 'EventCntr';
        }
        field(88; FOBID; Text[15])
        {
            Caption = 'FOBID';
        }
        field(89; FrtAcct; Text[10])
        {
            Caption = 'FrtAcct';
        }
        field(90; FrtCollect; Integer)
        {
            Caption = 'FrtCollect';
        }
        field(91; FrtSub; Text[24])
        {
            Caption = 'FrtSub';
        }
        field(92; FrtTermsID; Text[10])
        {
            Caption = 'FrtTermsID';
        }
        field(93; GeoCode; Text[10])
        {
            Caption = 'GeoCode';
        }
        field(94; InvcDate; DateTime)
        {
            Caption = 'InvcDate';
        }
        field(95; InvcNbr; Text[15])
        {
            Caption = 'InvcNbr';
        }
        field(96; IRDemand; Integer)
        {
            Caption = 'IRDemand';
        }
        field(97; LanguageID; Text[4])
        {
            Caption = 'LanguageID';
        }
        field(98; LineCntr; Integer)
        {
            Caption = 'LineCntr';
        }
        field(99; LostSaleID; Text[2])
        {
            Caption = 'LostSaleID';
        }
        field(100; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(101; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(102; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(103; MarkFor; Integer)
        {
            Caption = 'MarkFor';
        }
        field(104; MiscChrgCntr; Integer)
        {
            Caption = 'MiscChrgCntr';
        }
        field(105; NextFunctionClass; Text[4])
        {
            Caption = 'NextFunctionClass';
        }
        field(106; NextFunctionID; Text[8])
        {
            Caption = 'NextFunctionID';
        }
        field(107; NoteId; Integer)
        {
            Caption = 'NoteId';
        }
        field(108; OrdDate; DateTime)
        {
            Caption = 'OrdDate';
        }
        field(109; OrdNbr; Text[15])
        {
            Caption = 'OrdNbr';
        }
        field(110; OrigOrdNbr; Text[15])
        {
            Caption = 'OrigOrdNbr';
        }
        field(111; PC_Status; Text[1])
        {
            Caption = 'PC_Status';
        }
        field(112; PerPost; Text[6])
        {
            Caption = 'PerPost';
        }
        field(113; PmtCntr; Integer)
        {
            Caption = 'PmtCntr';
        }
        field(114; PremFrtAmtApplied; Decimal)
        {
            Caption = 'PremFrtAmtApplied';
        }
        field(115; Priority; Integer)
        {
            Caption = 'Priority';
        }
        field(116; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(117; QuoteDate; DateTime)
        {
            Caption = 'QuoteDate';
        }
        field(118; Released; Integer)
        {
            Caption = 'Released';
        }
        field(119; ReleaseValue; Decimal)
        {
            Caption = 'ReleaseValue';
        }
        field(120; RequireStepAssy; Integer)
        {
            Caption = 'RequireStepAssy';
        }
        field(121; RequireStepInsp; Integer)
        {
            Caption = 'RequireStepInsp';
        }
        field(122; RlseForInvc; Integer)
        {
            Caption = 'RlseForInvc';
        }
        field(123; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(124; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(125; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(126; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(127; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(128; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(129; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(130; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(131; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(132; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(133; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(134; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(135; SellingSiteID; Text[10])
        {
            Caption = 'SellingSiteID';
        }
        field(136; SFOOrdNbr; Text[15])
        {
            Caption = 'SFOOrdNbr';
        }
        field(137; ShipAddr1; Text[60])
        {
            Caption = 'ShipAddr1';
        }
        field(138; ShipAddr2; Text[60])
        {
            Caption = 'ShipAddr2';
        }
        field(139; ShipAddrID; Text[10])
        {
            Caption = 'ShipAddrID';
        }
        field(140; ShipAddrSpecial; Integer)
        {
            Caption = 'ShipAddrSpecial';
        }
        field(141; ShipAttn; Text[30])
        {
            Caption = 'ShipAttn';
        }
        field(142; ShipCity; Text[30])
        {
            Caption = 'ShipCity';
        }
        field(143; ShipCmplt; Integer)
        {
            Caption = 'ShipCmplt';
        }
        field(144; ShipCountry; Text[3])
        {
            Caption = 'ShipCountry';
        }
        field(145; ShipCustID; Text[15])
        {
            Caption = 'ShipCustID';
        }
        field(146; ShipGeoCode; Text[10])
        {
            Caption = 'ShipGeoCode';
        }
        field(147; ShipName; Text[60])
        {
            Caption = 'ShipName';
        }
        field(148; ShipPhone; Text[30])
        {
            Caption = 'ShipPhone';
        }
        field(149; ShipSiteID; Text[10])
        {
            Caption = 'ShipSiteID';
        }
        field(150; ShipState; Text[3])
        {
            Caption = 'ShipState';
        }
        field(151; ShiptoID; Text[10])
        {
            Caption = 'ShiptoID';
        }
        field(152; ShiptoType; Text[1])
        {
            Caption = 'ShiptoType';
        }
        field(153; ShipVendID; Text[15])
        {
            Caption = 'ShipVendID';
        }
        field(154; ShipViaID; Text[15])
        {
            Caption = 'ShipViaID';
        }
        field(155; ShipZip; Text[10])
        {
            Caption = 'ShipZip';
        }
        field(156; SlsperID; Text[10])
        {
            Caption = 'SlsperID';
        }
        field(157; SOTypeID; Text[4])
        {
            Caption = 'SOTypeID';
        }
        field(158; Status; Text[1])
        {
            Caption = 'Status';
        }
        field(159; TaxID00; Text[10])
        {
            Caption = 'TaxID00';
        }
        field(160; TaxID01; Text[10])
        {
            Caption = 'TaxID01';
        }
        field(161; TaxID02; Text[10])
        {
            Caption = 'TaxID02';
        }
        field(162; TaxID03; Text[10])
        {
            Caption = 'TaxID03';
        }
        field(163; TermsID; Text[2])
        {
            Caption = 'TermsID';
        }
        field(164; TotCommCost; Decimal)
        {
            Caption = 'TotCommCost';
        }
        field(165; TotCost; Decimal)
        {
            Caption = 'TotCost';
        }
        field(166; TotFrt; Decimal)
        {
            Caption = 'TotFrt';
        }
        field(167; TotLineDisc; Decimal)
        {
            Caption = 'TotLineDisc';
        }
        field(168; TotMerch; Decimal)
        {
            Caption = 'TotMerch';
        }
        field(169; TotMisc; Decimal)
        {
            Caption = 'TotMisc';
        }
        field(170; TotOrd; Decimal)
        {
            Caption = 'TotOrd';
        }
        field(171; TotPmt; Decimal)
        {
            Caption = 'TotPmt';
        }
        field(172; TotPremFrt; Decimal)
        {
            Caption = 'TotPremFrt';
        }
        field(173; TotShipWght; Decimal)
        {
            Caption = 'TotShipWght';
        }
        field(174; TotTax; Decimal)
        {
            Caption = 'TotTax';
        }
        field(175; TotTxbl; Decimal)
        {
            Caption = 'TotTxbl';
        }
        field(176; UnshippedBalance; Decimal)
        {
            Caption = 'UnshippedBalance';
        }
        field(177; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(178; User10; DateTime)
        {
            Caption = 'User10';
        }
        field(179; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(180; User3; Text[30])
        {
            Caption = 'User3';
        }
        field(181; User4; Text[30])
        {
            Caption = 'User4';
        }
        field(182; User5; Decimal)
        {
            Caption = 'User5';
        }
        field(183; User6; Decimal)
        {
            Caption = 'User6';
        }
        field(184; User7; Text[10])
        {
            Caption = 'User7';
        }
        field(185; User8; Text[10])
        {
            Caption = 'User8';
        }
        field(186; User9; DateTime)
        {
            Caption = 'User9';
        }
        field(187; VendAddrID; Text[10])
        {
            Caption = 'VendAddrID';
        }
        field(188; WeekendDelivery; Integer)
        {
            Caption = 'WeekendDelivery';
        }
        field(189; WholeOrdDisc; Decimal)
        {
            Caption = 'WholeOrdDisc';
        }
        field(190; WorkflowID; Integer)
        {
            Caption = 'WorkflowID';
        }
        field(191; WorkflowStatus; Text[1])
        {
            Caption = 'WorkflowStatus';
        }
        field(192; WSID; Integer)
        {
            Caption = 'WSID';
        }
    }

    keys
    {
        key(PK; CpnyID, OrdNbr)
        {
            Clustered = true;
        }
    }
}