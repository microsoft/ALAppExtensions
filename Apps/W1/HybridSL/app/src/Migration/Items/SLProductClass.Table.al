// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47104 "SL ProductClass"
{
    Access = Internal;
    Caption = 'SL ProductClass';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Buyer; Text[10])
        {
            Caption = 'Buyer';
        }
        field(2; CFOvhMatlRate; Decimal)
        {
            Caption = 'CFOvhMatlRate';
        }
        field(3; ChkOrdQty; Text[1])
        {
            Caption = 'ChkOrdQty';
        }
        field(4; ClassID; Text[6])
        {
            Caption = 'ClassID';
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
        field(8; CVOvhMatlRate; Decimal)
        {
            Caption = 'CVOvhMatlRate';
        }
        field(9; Descr; Text[30])
        {
            Caption = 'Descr';
        }
        field(10; DfltCOGSAcct; Text[10])
        {
            Caption = 'DfltCOGSAcct';
        }
        field(11; DfltCOGSSub; Text[24])
        {
            Caption = 'DfltCOGSSub';
        }
        field(12; DfltDiscPrc; Text[1])
        {
            Caption = 'DfltDiscPrc';
        }
        field(13; DfltInvtAcct; Text[10])
        {
            Caption = 'DfltInvtAcct';
        }
        field(14; DfltInvtSub; Text[24])
        {
            Caption = 'DfltInvtSub';
        }
        field(15; DfltInvtType; Text[1])
        {
            Caption = 'DfltInvtType';
        }
        field(16; DfltLCVarianceAcct; Text[10])
        {
            Caption = 'DfltLCVarianceAcct';
        }
        field(17; DfltLCVarianceSub; Text[24])
        {
            Caption = 'DfltLCVarianceSub';
        }
        field(18; DfltLotSerAssign; Text[1])
        {
            Caption = 'DfltLotSerAssign';
        }
        field(19; DfltLotSerFxdLen; Integer)
        {
            Caption = 'DfltLotSerFxdLen';
        }
        field(20; DfltLotSerFxdTyp; Text[1])
        {
            Caption = 'DfltLotSerFxdTyp';
        }
        field(21; DfltLotSerFxdVal; Text[12])
        {
            Caption = 'DfltLotSerFxdVal';
        }
        field(22; DfltLotSerMthd; Text[1])
        {
            Caption = 'DfltLotSerMthd';
        }
        field(23; DfltLotSerNumLen; Integer)
        {
            Caption = 'DfltLotSerNumLen';
        }
        field(24; DfltLotSerNumVal; Text[25])
        {
            Caption = 'DfltLotSerNumVal';
        }
        field(25; DfltLotSerShelfLife; Integer)
        {
            Caption = 'DfltLotSerShelfLife';
        }
        field(26; DfltLotSerTrack; Text[1])
        {
            Caption = 'DfltLotSerTrack';
        }
        field(27; DfltPOUnit; Text[6])
        {
            Caption = 'DfltPOUnit';
        }
        field(28; DfltPPVAcct; Text[10])
        {
            Caption = 'DfltPPVAcct';
        }
        field(29; DfltPPVSub; Text[24])
        {
            Caption = 'DfltPPVSub';
        }
        field(30; DfltSalesAcct; Text[10])
        {
            Caption = 'DfltSalesAcct';
        }
        field(31; DfltSalesSub; Text[24])
        {
            Caption = 'DfltSalesSub';
        }
        field(32; DfltShpNotInvAcct; Text[10])
        {
            Caption = 'DfltShpNotInvAcct';
        }
        field(33; DfltShpnotInvSub; Text[24])
        {
            Caption = 'DfltShpnotInvSub';
        }
        field(34; DfltSite; Text[10])
        {
            Caption = 'DfltSite';
        }
        field(35; DfltSlsTaxCat; Text[10])
        {
            Caption = 'DfltSlsTaxCat';
        }
        field(36; DfltSOUnit; Text[6])
        {
            Caption = 'DfltSOUnit';
        }
        field(37; DfltSource; Text[1])
        {
            Caption = 'DfltSource';
        }
        field(38; DfltStatus; Text[1])
        {
            Caption = 'DfltStatus';
        }
        field(39; DfltStkItem; Integer)
        {
            Caption = 'DfltStkItem';
        }
        field(40; DfltStkWt; Decimal)
        {
            Caption = 'DfltStkWt';
        }
        field(41; DfltStkWtUnit; Text[6])
        {
            Caption = 'DfltStkWtUnit';
        }
        field(42; DfltValMthd; Text[1])
        {
            Caption = 'DfltValMthd';
        }
        field(43; DfltWarrantyDays; Integer)
        {
            Caption = 'DfltWarrantyDays';
        }
        field(44; ExplInvoice; Integer)
        {
            Caption = 'ExplInvoice';
        }
        field(45; ExplOrder; Integer)
        {
            Caption = 'ExplOrder';
        }
        field(46; ExplPackSlip; Integer)
        {
            Caption = 'ExplPackSlip';
        }
        field(47; ExplPickList; Integer)
        {
            Caption = 'ExplPickList';
        }
        field(48; ExplShipping; Integer)
        {
            Caption = 'ExplShipping';
        }
        field(49; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(50; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(51; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(52; MaterialType; Text[10])
        {
            Caption = 'MaterialType';
        }
        field(53; MinGrossProfit; Decimal)
        {
            Caption = 'MinGrossProfit';
        }
        field(54; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(55; PFOvhMatlRate; Decimal)
        {
            Caption = 'PFOvhMatlRate';
        }
        field(56; PVOvhMatlRate; Decimal)
        {
            Caption = 'PVOvhMatlRate';
        }
        field(57; RollupCost; Integer)
        {
            Caption = 'RollupCost';
        }
        field(58; RollupPrice; Integer)
        {
            Caption = 'RollupPrice';
        }
        field(59; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(60; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(61; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(62; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(63; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(64; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(65; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(66; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(67; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(68; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(69; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(70; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(71; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(72; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(73; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(74; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(75; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(76; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(77; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(78; User8; DateTime)
        {
            Caption = 'User8';
        }
    }

    keys
    {
        key(PK; ClassID)
        {
            Clustered = true;
        }
    }
}