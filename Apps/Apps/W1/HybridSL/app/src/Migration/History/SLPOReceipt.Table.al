// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47032 "SL POReceipt"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; APRefno; Text[10])
        {
            Caption = 'APRefno';
        }
        field(2; BatNbr; Text[10])
        {
            Caption = 'BatNbr';
        }
        field(3; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(4; CreateAD; Integer)
        {
            Caption = 'CreateAD';
        }
        field(5; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(6; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(7; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(8; CuryEffDate; DateTime)
        {
            Caption = 'CuryEffDate';
        }
        field(9; CuryFreight; Decimal)
        {
            Caption = 'CuryFreight';
        }
        field(10; CuryID; Text[4])
        {
            Caption = 'CuryID';
        }
        field(11; CuryMultDiv; Text[1])
        {
            Caption = 'CuryMultDiv';
        }
        field(12; CuryRate; Decimal)
        {
            Caption = 'CuryRate';
        }
        field(13; CuryRateType; Text[6])
        {
            Caption = 'CuryRateType';
        }
        field(14; CuryRcptAmt; Decimal)
        {
            Caption = 'CuryRcptAmt';
        }
        field(15; CuryRcptAmtTot; Decimal)
        {
            Caption = 'CuryRcptAmtTot';
        }
        field(16; CuryRcptCtrlAmt; Decimal)
        {
            Caption = 'CuryRcptCtrlAmt';
        }
        field(17; CuryRcptItemTotal; Decimal)
        {
            Caption = 'CuryRcptItemTotal';
        }
        field(18; DfltFromPO; Text[1])
        {
            Caption = 'DfltFromPO';
        }
        field(19; ExcludeFreight; Text[1])
        {
            Caption = 'ExcludeFreight';
        }
        field(20; Freight; Decimal)
        {
            Caption = 'Freight';
        }
        field(21; InBal; Integer)
        {
            Caption = 'InBal';
        }
        field(22; LineCntr; Integer)
        {
            Caption = 'LineCntr';
        }
        field(23; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(24; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(25; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(26; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(27; OpenDoc; Integer)
        {
            Caption = 'OpenDoc';
        }
        field(28; PC_Status; Text[1])
        {
            Caption = 'PC_Status';
        }
        field(29; PerClosed; Text[6])
        {
            Caption = 'PerClosed';
        }
        field(30; PerEnt; Text[6])
        {
            Caption = 'PerEnt';
        }
        field(31; PONbr; Text[10])
        {
            Caption = 'PONbr';
        }
        field(32; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(33; RcptAmt; Decimal)
        {
            Caption = 'RcptAmt';
        }
        field(34; RcptAmtTot; Decimal)
        {
            Caption = 'RcptAmtTot';
        }
        field(35; RcptCtrlAmt; Decimal)
        {
            Caption = 'RcptCtrlAmt';
        }
        field(36; RcptCtrlQty; Decimal)
        {
            Caption = 'RcptCtrlQty';
        }
        field(37; RcptDate; DateTime)
        {
            Caption = 'RcptDate';
        }
        field(38; RcptItemTotal; Decimal)
        {
            Caption = 'RcptItemTotal';
        }
        field(39; RcptNbr; Text[10])
        {
            Caption = 'RcptNbr';
        }
        field(40; RcptQty; Decimal)
        {
            Caption = 'RcptQty';
        }
        field(41; RcptQtyTot; Decimal)
        {
            Caption = 'RcptQtyTot';
        }
        field(42; RcptType; Text[1])
        {
            Caption = 'RcptType';
        }
        field(43; ReopenPO; Integer)
        {
            Caption = 'ReopenPO';
        }
        field(44; Rlsed; Integer)
        {
            Caption = 'Rlsed';
        }
        field(45; RMAID; Text[15])
        {
            Caption = 'RMAID';
        }
        field(46; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(47; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(48; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(49; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(50; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(51; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(52; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(53; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(54; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(55; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(56; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(57; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(58; ServiceCallID; Text[10])
        {
            Caption = 'ServiceCallID';
        }
        field(59; ShipperID; Text[15])
        {
            Caption = 'ShipperID';
        }
        field(60; Status; Text[1])
        {
            Caption = 'Status';
        }
        field(61; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(62; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(63; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(64; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(65; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(66; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(67; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(68; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(69; VendID; Text[15])
        {
            Caption = 'VendID';
        }
        field(70; VendInvcNbr; Text[10])
        {
            Caption = 'VendInvcNbr';
        }
        field(71; VouchStage; Text[1])
        {
            Caption = 'VouchStage';
        }
        field(72; WayBillNbr; Text[10])
        {
            Caption = 'WayBillNbr';
        }
    }

    keys
    {
        key(Key1; RcptNbr)
        {
            Clustered = true;
        }
    }
}