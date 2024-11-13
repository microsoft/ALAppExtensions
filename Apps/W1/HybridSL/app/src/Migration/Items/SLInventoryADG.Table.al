// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47016 "SL InventoryADG"
{
    Access = Internal;
    Caption = 'SL InventoryADG';
    DataClassification = CustomerContent;

    fields
    {
        field(1; AllowGenCont; Integer)
        {
            Caption = 'AllowGenCont';
        }
        field(2; BatchSize; Decimal)
        {
            Caption = 'BatchSize';
        }
        field(3; BOLClass; Text[20])
        {
            Caption = 'BOLClass';
        }
        field(4; CategoryCode; Text[10])
        {
            Caption = 'CategoryCode';
        }
        field(5; CountryOrig; Text[20])
        {
            Caption = 'CountryOrig';
        }
        field(6; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(7; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(8; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(9; Density; Decimal)
        {
            Caption = 'Density';
        }
        field(10; DensityUOM; Text[5])
        {
            Caption = 'DensityUOM';
        }
        field(11; Depth; Decimal)
        {
            Caption = 'Depth';
        }
        field(12; DepthUOM; Text[5])
        {
            Caption = 'DepthUOM';
        }
        field(13; Diameter; Decimal)
        {
            Caption = 'Diameter';
        }
        field(14; DiameterUOM; Text[5])
        {
            Caption = 'DiameterUOM';
        }
        field(15; Gauge; Decimal)
        {
            Caption = 'Gauge';
        }
        field(16; GaugeUOM; Text[5])
        {
            Caption = 'GaugeUOM';
        }
        field(17; Height; Decimal)
        {
            Caption = 'Height';
        }
        field(18; HeightUOM; Text[5])
        {
            Caption = 'HeightUOM';
        }
        field(19; InvtID; Text[30])
        {
            Caption = 'InvtID';
        }
        field(20; Len; Decimal)
        {
            Caption = 'Len';
        }
        field(21; LenUOM; Text[5])
        {
            Caption = 'LenUOM';
        }
        field(22; ListPrice; Decimal)
        {
            Caption = 'ListPrice';
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
        field(26; MinPrice; Decimal)
        {
            Caption = 'MinPrice';
        }
        field(27; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(28; OMCOGSAcct; Text[10])
        {
            Caption = 'OMCOGSAcct';
        }
        field(29; OMCOGSSub; Text[31])
        {
            Caption = 'OMCOGSSub';
        }
        field(30; OMSalesAcct; Text[10])
        {
            Caption = 'OMSalesAcct';
        }
        field(31; OMSalesSub; Text[31])
        {
            Caption = 'OMSalesSub';
        }
        field(32; Pack; Integer)
        {
            Caption = 'Pack';
        }
        field(33; PackCnvFact; Decimal)
        {
            Caption = 'PackCnvFact';
        }
        field(34; PackMethod; Text[2])
        {
            Caption = 'PackMethod';
        }
        field(35; PackSize; Integer)
        {
            Caption = 'PackSize';
        }
        field(36; PackUnitMultDiv; Text[1])
        {
            Caption = 'PackUnitMultDiv';
        }
        field(37; PackUOM; Text[6])
        {
            Caption = 'PackUOM';
        }
        field(38; ProdLineID; Text[4])
        {
            Caption = 'ProdLineID';
        }
        field(39; RetailPrice; Decimal)
        {
            Caption = 'RetailPrice';
        }
        field(40; RoyaltyCode; Text[10])
        {
            Caption = 'RoyaltyCode';
        }
        field(41; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(42; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(43; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(44; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(45; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(46; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(47; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(48; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(49; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(50; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(51; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(52; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(53; SCHeight; Decimal)
        {
            Caption = 'SCHeight';
        }
        field(54; SCHeightUOM; Text[6])
        {
            Caption = 'SCHeightUOM';
        }
        field(55; SCLen; Decimal)
        {
            Caption = 'SCLen';
        }
        field(56; SCLenUOM; Text[6])
        {
            Caption = 'SCLenUOM';
        }
        field(57; SCVolume; Decimal)
        {
            Caption = 'SCVolume';
        }
        field(58; SCVolumeUOM; Text[6])
        {
            Caption = 'SCVolumeUOM';
        }
        field(59; SCWeight; Decimal)
        {
            Caption = 'SCWeight';
        }
        field(60; SCWeightUOM; Text[6])
        {
            Caption = 'SCWeightUOM';
        }
        field(61; SCWidth; Decimal)
        {
            Caption = 'SCWidth';
        }
        field(62; SCWidthUOM; Text[6])
        {
            Caption = 'SCWidthUOM';
        }
        field(63; StdCartonBreak; Integer)
        {
            Caption = 'StdCartonBreak';
        }
        field(64; StdGrossWt; Decimal)
        {
            Caption = 'StdGrossWt';
        }
        field(65; StdTareWt; Decimal)
        {
            Caption = 'StdTareWt';
        }
        field(66; Style; Text[20])
        {
            Caption = 'Style';
        }
        field(67; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(68; User10; DateTime)
        {
            Caption = 'User10';
        }
        field(69; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(70; User3; Text[30])
        {
            Caption = 'User3';
        }
        field(71; User4; Text[30])
        {
            Caption = 'User4';
        }
        field(72; User5; Decimal)
        {
            Caption = 'User5';
        }
        field(73; User6; Decimal)
        {
            Caption = 'User6';
        }
        field(74; User7; Text[10])
        {
            Caption = 'User7';
        }
        field(75; User8; Text[10])
        {
            Caption = 'User8';
        }
        field(76; User9; DateTime)
        {
            Caption = 'User9';
        }
        field(77; Volume; Decimal)
        {
            Caption = 'Volume';
        }
        field(78; VolUOM; Text[6])
        {
            Caption = 'VolUOM';
        }
        field(79; Weight; Decimal)
        {
            Caption = 'Weight';
        }
        field(80; WeightUOM; Text[6])
        {
            Caption = 'WeightUOM';
        }
        field(81; Width; Decimal)
        {
            Caption = 'Width';
        }
        field(82; WidthUOM; Text[5])
        {
            Caption = 'WidthUOM';
        }
    }

    keys
    {
        key(Key1; InvtID)
        {
            Clustered = true;
        }
    }
}