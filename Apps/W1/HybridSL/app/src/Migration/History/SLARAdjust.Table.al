// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47026 "SL ARAdjust"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; AdjAmt; Decimal)
        {
            Caption = 'AdjAmt';
        }
        field(2; AdjBatNbr; Text[10])
        {
            Caption = 'AdjBatNbr';
        }
        field(3; AdjdDocType; Text[2])
        {
            Caption = 'AdjdDocType';
        }
        field(4; AdjDiscAmt; Decimal)
        {
            Caption = 'AdjDiscAmt';
        }
        field(5; AdjdRefNbr; Text[10])
        {
            Caption = 'AdjdRefNbr';
        }
        field(6; AdjgDocDate; DateTime)
        {
            Caption = 'AdjgDocDate';
        }
        field(7; AdjgDocType; Text[2])
        {
            Caption = 'AdjgDocType';
        }
        field(8; AdjgPerPost; Text[6])
        {
            Caption = 'AdjgPerPost';
        }
        field(9; AdjgRefNbr; Text[10])
        {
            Caption = 'AdjgRefNbr';
        }
        field(10; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(11; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(12; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(13; CuryAdjdAmt; Decimal)
        {
            Caption = 'CuryAdjdAmt';
        }
        field(14; CuryAdjdCuryId; Text[4])
        {
            Caption = 'CuryAdjdCuryId';
        }
        field(15; CuryAdjdDiscAmt; Decimal)
        {
            Caption = 'CuryAdjdDiscAmt';
        }
        field(16; CuryAdjdMultDiv; Text[1])
        {
            Caption = 'CuryAdjdMultDiv';
        }
        field(17; CuryAdjdRate; Decimal)
        {
            Caption = 'CuryAdjdRate';
        }
        field(18; CuryAdjgAmt; Decimal)
        {
            Caption = 'CuryAdjgAmt';
        }
        field(19; CuryAdjgDiscAmt; Decimal)
        {
            Caption = 'CuryAdjgDiscAmt';
        }
        field(20; CuryRGOLAmt; Decimal)
        {
            Caption = 'CuryRGOLAmt';
        }
        field(21; CustId; Text[15])
        {
            Caption = 'CustId';
        }
        field(22; DateAppl; DateTime)
        {
            Caption = 'DateAppl';
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
        field(26; PC_Status; Text[1])
        {
            Caption = 'PC_Status';
        }
        field(27; PerAppl; Text[6])
        {
            Caption = 'PerAppl';
        }
        field(28; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(29; "RecordID"; Integer)
        {
            Caption = 'RecordID';
        }
        field(30; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(31; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(32; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(33; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(34; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(35; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(36; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(37; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(38; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(39; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(40; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(41; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(42; TaskID; Text[32])
        {
            Caption = 'TaskID';
        }
        field(43; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(44; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(45; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(46; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(47; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(48; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(49; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(50; User8; DateTime)
        {
            Caption = 'User8';
        }
    }

    keys
    {
        key(Key1; AdjdRefNbr, RecordID)
        {
            Clustered = true;
        }
    }
}