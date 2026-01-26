// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47048 "SL POSetup"
{
    Access = Internal;
    Caption = 'SL POSetup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; AddAlternateID; Text[1])
        {
            Caption = 'AddAlternateID';
        }
        field(2; AdminLeadTime; Integer)
        {
            Caption = 'AdminLeadTime';
        }
        field(3; APAccrAcct; Text[10])
        {
            Caption = 'APAccrAcct';
        }
        field(4; APAccrSub; Text[24])
        {
            Caption = 'APAccrSub';
        }
        field(5; AutoRef; Integer)
        {
            Caption = 'AutoRef';
        }
        field(6; BillAddr1; Text[60])
        {
            Caption = 'BillAddr1';
        }
        field(7; BillAddr2; Text[60])
        {
            Caption = 'BillAddr2';
        }
        field(8; BillAttn; Text[30])
        {
            Caption = 'BillAttn';
        }
        field(9; BillCity; Text[30])
        {
            Caption = 'BillCity';
        }
        field(10; BillCountry; Text[3])
        {
            Caption = 'BillCountry';
        }
        field(11; BillEmail; Text[80])
        {
            Caption = 'BillEmail';
        }
        field(12; BillFax; Text[30])
        {
            Caption = 'BillFax';
        }
        field(13; BillName; Text[60])
        {
            Caption = 'BillName';
        }
        field(14; BillPhone; Text[30])
        {
            Caption = 'BillPhone';
        }
        field(15; BillState; Text[3])
        {
            Caption = 'BillState';
        }
        field(16; BillZip; Text[10])
        {
            Caption = 'BillZip';
        }
        field(17; CreateAD; Integer)
        {
            Caption = 'CreateAD';
        }
        field(18; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(19; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(20; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(21; DecPlPrcCst; Integer)
        {
            Caption = 'DecPlPrcCst';
        }
        field(22; DecPlQty; Integer)
        {
            Caption = 'DecPlQty';
        }
        field(23; DefaultAltIDType; Text[1])
        {
            Caption = 'DefaultAltIDType';
        }
        field(24; DemandPeriods; Integer)
        {
            Caption = 'DemandPeriods';
        }
        field(25; DfltLstUnitCost; Text[1])
        {
            Caption = 'DfltLstUnitCost';
        }
        field(26; DfltRcptUnitFromIN; Integer)
        {
            Caption = 'DfltRcptUnitFromIN';
        }
        field(27; FrtAcct; Text[10])
        {
            Caption = 'FrtAcct';
        }
        field(28; FrtSub; Text[24])
        {
            Caption = 'FrtSub';
        }
        field(29; HotPrintPO; Integer)
        {
            Caption = 'HotPrintPO';
        }
        field(30; INAvail; Integer)
        {
            Caption = 'INAvail';
        }
        field(31; "Init"; Integer)
        {
            Caption = 'Init';
        }
        field(32; InvtCarryingCost; Decimal)
        {
            Caption = 'InvtCarryingCost';
        }
        field(33; LastBatNbr; Text[10])
        {
            Caption = 'LastBatNbr';
        }
        field(34; LastPONbr; Text[10])
        {
            Caption = 'LastPONbr';
        }
        field(35; LastRcptNbr; Text[10])
        {
            Caption = 'LastRcptNbr';
        }
        field(36; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(37; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(38; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(39; MultPOAllowed; Integer)
        {
            Caption = 'MultPOAllowed';
        }
        field(40; NonInvtAcct; Text[10])
        {
            Caption = 'NonInvtAcct';
        }
        field(41; NonInvtSub; Text[24])
        {
            Caption = 'NonInvtSub';
        }
        field(42; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(43; PCAvail; Integer)
        {
            Caption = 'PCAvail';
        }
        field(44; PerRetTran; Integer)
        {
            Caption = 'PerRetTran';
        }
        field(45; PMAvail; Integer)
        {
            Caption = 'PMAvail';
        }
        field(46; PPVAcct; Text[10])
        {
            Caption = 'PPVAcct';
        }
        field(47; PPVSub; Text[24])
        {
            Caption = 'PPVSub';
        }
        field(48; PrtAddr; Integer)
        {
            Caption = 'PrtAddr';
        }
        field(49; PrtSite; Integer)
        {
            Caption = 'PrtSite';
        }
        field(50; ReopenPO; Integer)
        {
            Caption = 'ReopenPO';
        }
        field(51; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(52; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(53; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(54; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(55; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(56; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(57; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(58; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(59; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(60; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(61; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(62; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(63; SetupCost; Decimal)
        {
            Caption = 'SetupCost';
        }
        field(64; SetupID; Text[2])
        {
            Caption = 'SetupID';
        }
        field(65; ShipAddr1; Text[60])
        {
            Caption = 'ShipAddr1';
        }
        field(66; ShipAddr2; Text[60])
        {
            Caption = 'ShipAddr2';
        }
        field(67; ShipAttn; Text[30])
        {
            Caption = 'ShipAttn';
        }
        field(68; ShipCity; Text[30])
        {
            Caption = 'ShipCity';
        }
        field(69; ShipCountry; Text[3])
        {
            Caption = 'ShipCountry';
        }
        field(70; ShipEmail; Text[80])
        {
            Caption = 'ShipEmail';
        }
        field(71; ShipFax; Text[30])
        {
            Caption = 'ShipFax';
        }
        field(72; ShipName; Text[60])
        {
            Caption = 'ShipName';
        }
        field(73; ShipPhone; Text[30])
        {
            Caption = 'ShipPhone';
        }
        field(74; ShipState; Text[3])
        {
            Caption = 'ShipState';
        }
        field(75; ShipZip; Text[10])
        {
            Caption = 'ShipZip';
        }
        field(76; TaxFlg; Integer)
        {
            Caption = 'TaxFlg';
        }
        field(77; TranDescFlg; Text[1])
        {
            Caption = 'TranDescFlg';
        }
        field(78; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(79; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(80; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(81; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(82; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(83; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(84; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(85; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(86; Vouchering; Integer)
        {
            Caption = 'Vouchering';
        }
        field(87; VouchQtyErr; Text[1])
        {
            Caption = 'VouchQtyErr';
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