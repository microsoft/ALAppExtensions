// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47020 "SL ItemCost"
{
    Access = Internal;
    Caption = 'SL ItemCost';
    DataClassification = CustomerContent;

    fields
    {
        field(1; BMITotCost; Decimal)
        {
            Caption = 'BMITotCost';
        }
        field(2; CostIdentity; Integer)
        {
            Caption = 'CostIdentity';
        }
        field(3; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(4; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(5; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(6; InvtID; Text[30])
        {
            Caption = 'InvtID';
        }
        field(7; LayerType; Text[2])
        {
            Caption = 'LayerType';
        }
        field(8; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(9; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(10; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(11; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(12; Qty; Decimal)
        {
            Caption = 'Qty';
        }
        field(13; QtyAllocBM; Decimal)
        {
            Caption = 'QtyAllocBM';
        }
        field(14; QtyAllocIN; Decimal)
        {
            Caption = 'QtyAllocIN';
        }
        field(15; QtyAllocOther; Decimal)
        {
            Caption = 'QtyAllocOther';
        }
        field(16; QtyAllocPORet; Decimal)
        {
            Caption = 'QtyAllocPORet';
        }
        field(17; QtyAllocSD; Decimal)
        {
            Caption = 'QtyAllocSD';
        }
        field(18; QtyAvail; Decimal)
        {
            Caption = 'QtyAvail';
        }
        field(19; QtyShipNotInv; Decimal)
        {
            Caption = 'QtyShipNotInv';
        }
        field(20; RcptDate; DateTime)
        {
            Caption = 'RcptDate';
        }
        field(21; RcptNbr; Text[15])
        {
            Caption = 'RcptNbr';
        }
        field(22; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(23; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(24; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(25; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(26; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(27; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(28; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(29; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(30; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(31; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(32; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(33; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(34; SiteID; Text[10])
        {
            Caption = 'SiteID';
        }
        field(35; SpecificCostID; Text[25])
        {
            Caption = 'SpecificCostID';
        }
        field(36; TotCost; Decimal)
        {
            Caption = 'TotCost';
        }
        field(37; UnitCost; Decimal)
        {
            Caption = 'UnitCost';
        }
        field(38; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(39; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(40; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(41; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(42; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(43; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(44; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(45; User8; DateTime)
        {
            Caption = 'User8';
        }
    }

    keys
    {
        key(Key1; InvtID, SiteID, LayerType, SpecificCostID, RcptNbr, RcptDate)
        {
            Clustered = true;
        }
    }
}