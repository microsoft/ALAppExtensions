// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47013 "SL SOSetup"
{
    Access = Internal;
    Caption = 'SL SOSetup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; AccrRevAcct; Text[10])
        {
            Caption = 'AccrRevAcct';
        }
        field(2; AccrRevSub; Text[24])
        {
            Caption = 'AccrRevSub';
        }
        field(3; AddAlternateID; Integer)
        {
            Caption = 'AddAlternateID';
        }
        field(4; AddDaysEarly; Integer)
        {
            Caption = 'AddDaysEarly';
        }
        field(5; AddDaysLate; Integer)
        {
            Caption = 'AddDaysLate';
        }
        field(6; Addr1; Text[60])
        {
            Caption = 'Addr1';
        }
        field(7; Addr2; Text[60])
        {
            Caption = 'Addr2';
        }
        field(8; AllowDiscPrice; Integer)
        {
            Caption = 'AllowDiscPrice';
        }
        field(9; AutoCreateShippers; Integer)
        {
            Caption = 'AutoCreateShippers';
        }
        field(10; AutoInsertContacts; Integer)
        {
            Caption = 'AutoInsertContacts';
        }
        field(11; AutoRef; Integer)
        {
            Caption = 'AutoRef';
        }
        field(12; AutoReleaseBatches; Integer)
        {
            Caption = 'AutoReleaseBatches';
        }
        field(13; AutoSalesJournal; Text[1])
        {
            Caption = 'AutoSalesJournal';
        }
        field(14; AutoSave; Integer)
        {
            Caption = 'AutoSave';
        }
        field(15; BillThruProject; Integer)
        {
            Caption = 'BillThruProject';
        }
        field(16; BookingLimit; Integer)
        {
            Caption = 'BookingLimit';
        }
        field(17; CashSaleCustID; Text[15])
        {
            Caption = 'CashSaleCustID';
        }
        field(18; ChainDiscEnabled; Integer)
        {
            Caption = 'ChainDiscEnabled';
        }
        field(19; City; Text[30])
        {
            Caption = 'City';
        }
        field(20; ConsolInv; Integer)
        {
            Caption = 'ConsolInv';
        }
        field(21; CopyNotes; Integer)
        {
            Caption = 'CopyNotes';
        }
        field(22; CopyToInvc00; Text[1])
        {
            Caption = 'CopyToInvc00';
        }
        field(23; CopyToInvc01; Text[1])
        {
            Caption = 'CopyToInvc01';
        }
        field(24; CopyToInvc02; Text[1])
        {
            Caption = 'CopyToInvc02';
        }
        field(25; CopyToInvc03; Text[1])
        {
            Caption = 'CopyToInvc03';
        }
        field(26; CopyToInvc04; Text[1])
        {
            Caption = 'CopyToInvc04';
        }
        field(27; CopyToInvc05; Text[1])
        {
            Caption = 'CopyToInvc05';
        }
        field(28; CopyToInvc06; Text[1])
        {
            Caption = 'CopyToInvc06';
        }
        field(29; CopyToInvc07; Text[1])
        {
            Caption = 'CopyToInvc07';
        }
        field(30; CopyToShipper00; Text[1])
        {
            Caption = 'CopyToShipper00';
        }
        field(31; CopyToShipper01; Text[1])
        {
            Caption = 'CopyToShipper01';
        }
        field(32; CopyToShipper02; Text[1])
        {
            Caption = 'CopyToShipper02';
        }
        field(33; CopyToShipper03; Text[1])
        {
            Caption = 'CopyToShipper03';
        }
        field(34; CopyToShipper04; Text[1])
        {
            Caption = 'CopyToShipper04';
        }
        field(35; CopyToShipper05; Text[1])
        {
            Caption = 'CopyToShipper05';
        }
        field(36; CopyToShipper06; Text[1])
        {
            Caption = 'CopyToShipper06';
        }
        field(37; CopyToShipper07; Text[1])
        {
            Caption = 'CopyToShipper07';
        }
        field(38; CopyToShipper08; Text[1])
        {
            Caption = 'CopyToShipper08';
        }
        field(39; CopyToShipper09; Text[1])
        {
            Caption = 'CopyToShipper09';
        }
        field(40; Country; Text[3])
        {
            Caption = 'Country';
        }
        field(41; CpnyName; Text[30])
        {
            Caption = 'CpnyName';
        }
        field(42; CreditCheck; Integer)
        {
            Caption = 'CreditCheck';
        }
        field(43; CreditGraceDays; Integer)
        {
            Caption = 'CreditGraceDays';
        }
        field(44; CreditGracePct; Decimal)
        {
            Caption = 'CreditGracePct';
        }
        field(45; CreditNoOrdEntry; Integer)
        {
            Caption = 'CreditNoOrdEntry';
        }
        field(46; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(47; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(48; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(49; CutoffTime; DateTime)
        {
            Caption = 'CutoffTime';
        }
        field(50; DecPlNonStdQty; Integer)
        {
            Caption = 'DecPlNonStdQty';
        }
        field(51; DecPlPrice; Integer)
        {
            Caption = 'DecPlPrice';
        }
        field(52; DelayManifestUpdate; Integer)
        {
            Caption = 'DelayManifestUpdate';
        }
        field(53; DelayShipperCreation; Integer)
        {
            Caption = 'DelayShipperCreation';
        }
        field(54; DelayShipperUpdate; Integer)
        {
            Caption = 'DelayShipperUpdate';
        }
        field(55; DelayUpdOrd; Text[1])
        {
            Caption = 'DelayUpdOrd';
        }
        field(56; DfltAccrueRev; Integer)
        {
            Caption = 'DfltAccrueRev';
        }
        field(57; DfltAltIDType; Text[1])
        {
            Caption = 'DfltAltIDType';
        }
        field(58; DfltBillThruProject; Integer)
        {
            Caption = 'DfltBillThruProject';
        }
        field(59; DfltConsolInv; Integer)
        {
            Caption = 'DfltConsolInv';
        }
        field(60; DfltDiscountID; Text[1])
        {
            Caption = 'DfltDiscountID';
        }
        field(61; DfltOrderType; Text[10])
        {
            Caption = 'DfltOrderType';
        }
        field(62; DfltShipperType; Text[10])
        {
            Caption = 'DfltShipperType';
        }
        field(63; DfltSiteIDMethod; Text[1])
        {
            Caption = 'DfltSiteIDMethod';
        }
        field(64; DfltSlsperMethod; Text[1])
        {
            Caption = 'DfltSlsperMethod';
        }
        field(65; DiscBySite; Integer)
        {
            Caption = 'DiscBySite';
        }
        field(66; DiscPrcDate; Text[1])
        {
            Caption = 'DiscPrcDate';
        }
        field(67; DiscPrcSeq00; Text[2])
        {
            Caption = 'DiscPrcSeq00';
        }
        field(68; DiscPrcSeq01; Text[2])
        {
            Caption = 'DiscPrcSeq01';
        }
        field(69; DiscPrcSeq02; Text[2])
        {
            Caption = 'DiscPrcSeq02';
        }
        field(70; DiscPrcSeq03; Text[2])
        {
            Caption = 'DiscPrcSeq03';
        }
        field(71; DiscPrcSeq04; Text[2])
        {
            Caption = 'DiscPrcSeq04';
        }
        field(72; DiscPrcSeq05; Text[2])
        {
            Caption = 'DiscPrcSeq05';
        }
        field(73; DiscPrcSeq06; Text[2])
        {
            Caption = 'DiscPrcSeq06';
        }
        field(74; DiscPrcSeq07; Text[2])
        {
            Caption = 'DiscPrcSeq07';
        }
        field(75; DiscPrcSeq08; Text[2])
        {
            Caption = 'DiscPrcSeq08';
        }
        field(76; DispAvailSO; Integer)
        {
            Caption = 'DispAvailSO';
        }
        field(77; EarlyWarningCutoff; Integer)
        {
            Caption = 'EarlyWarningCutoff';
        }
        field(78; ErrorAcct; Text[10])
        {
            Caption = 'ErrorAcct';
        }
        field(79; ErrorSub; Text[24])
        {
            Caption = 'ErrorSub';
        }
        field(80; Fax; Text[30])
        {
            Caption = 'Fax';
        }
        field(81; ForceValidSerialNo; Integer)
        {
            Caption = 'ForceValidSerialNo';
        }
        field(82; INAvail; Integer)
        {
            Caption = 'INAvail';
        }
        field(83; "Init"; Integer)
        {
            Caption = 'Init';
        }
        field(84; InvTaxCat; Integer)
        {
            Caption = 'InvTaxCat';
        }
        field(85; InvtScrapAcct; Text[10])
        {
            Caption = 'InvtScrapAcct';
        }
        field(86; InvtScrapSub; Text[24])
        {
            Caption = 'InvtScrapSub';
        }
        field(87; KAAvailAtETA; Integer)
        {
            Caption = 'KAAvailAtETA';
        }
        field(88; LastRebateID; Text[10])
        {
            Caption = 'LastRebateID';
        }
        field(89; LastShipRegisterID; Text[10])
        {
            Caption = 'LastShipRegisterID';
        }
        field(90; LookupSpecChar; Text[30])
        {
            Caption = 'LookupSpecChar';
        }
        field(91; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(92; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(93; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(94; MinGPHandling; Text[1])
        {
            Caption = 'MinGPHandling';
        }
        field(95; NegQtyMsg; Text[1])
        {
            Caption = 'NegQtyMsg';
        }
        field(96; NoQueueOnUnreserve; Integer)
        {
            Caption = 'NoQueueOnUnreserve';
        }
        field(97; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(98; PerRetBook; Integer)
        {
            Caption = 'PerRetBook';
        }
        field(99; PerRetTran; Integer)
        {
            Caption = 'PerRetTran';
        }
        field(100; Phone; Text[30])
        {
            Caption = 'Phone';
        }
        field(101; PickTime; Integer)
        {
            Caption = 'PickTime';
        }
        field(102; PlanScheds; Integer)
        {
            Caption = 'PlanScheds';
        }
        field(103; POAvailAtETA; Integer)
        {
            Caption = 'POAvailAtETA';
        }
        field(104; PostBookings; Integer)
        {
            Caption = 'PostBookings';
        }
        field(105; PrenumberedForms; Integer)
        {
            Caption = 'PrenumberedForms';
        }
        field(106; ProcManSleepSecs; Integer)
        {
            Caption = 'ProcManSleepSecs';
        }
        field(107; PrtCpny; Integer)
        {
            Caption = 'PrtCpny';
        }
        field(108; PrtSite; Integer)
        {
            Caption = 'PrtSite';
        }
        field(109; PrtTax; Integer)
        {
            Caption = 'PrtTax';
        }
        field(110; RMARequired; Integer)
        {
            Caption = 'RMARequired';
        }
        field(111; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(112; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(113; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(114; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(115; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(116; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(117; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(118; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(119; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(120; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(121; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(122; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(123; SendProjInfotoPO; Integer)
        {
            Caption = 'SendProjInfotoPO';
        }
        field(124; SetupID; Text[2])
        {
            Caption = 'SetupID';
        }
        field(125; ShipConfirmNegQty; Integer)
        {
            Caption = 'ShipConfirmNegQty';
        }
        field(126; State; Text[3])
        {
            Caption = 'State';
        }
        field(127; TaxDet; Integer)
        {
            Caption = 'TaxDet';
        }
        field(128; TermsOverride; Text[1])
        {
            Caption = 'TermsOverride';
        }
        field(129; TotalOrdDisc; Integer)
        {
            Caption = 'TotalOrdDisc';
        }
        field(130; TransferAvailAtETA; Integer)
        {
            Caption = 'TransferAvailAtETA';
        }
        field(131; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(132; User10; DateTime)
        {
            Caption = 'User10';
        }
        field(133; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(134; User3; Text[30])
        {
            Caption = 'User3';
        }
        field(135; User4; Text[30])
        {
            Caption = 'User4';
        }
        field(136; User5; Decimal)
        {
            Caption = 'User5';
        }
        field(137; User6; Decimal)
        {
            Caption = 'User6';
        }
        field(138; User7; Text[10])
        {
            Caption = 'User7';
        }
        field(139; User8; Text[10])
        {
            Caption = 'User8';
        }
        field(140; User9; DateTime)
        {
            Caption = 'User9';
        }
        field(141; WCShipViaID; Text[15])
        {
            Caption = 'WCShipViaID';
        }
        field(142; WOAvailAtETA; Integer)
        {
            Caption = 'WOAvailAtETA';
        }
        field(143; Zip; Text[10])
        {
            Caption = 'Zip';
        }
    }

    keys
    {
        key(Key1; SetupID)
        {
            Clustered = true;
        }
    }
}