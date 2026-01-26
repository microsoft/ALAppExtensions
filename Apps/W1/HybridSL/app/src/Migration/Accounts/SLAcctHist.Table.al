// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47007 "SL AcctHist"
{
    Access = Internal;
    Caption = 'SL AcctHist';
    DataClassification = CustomerContent;

    fields
    {
        field(1; Acct; Text[10])
        {
            Caption = 'Acct';
        }
        field(2; AnnBdgt; Decimal)
        {
            Caption = 'AnnBdgt';
        }
        field(3; AnnMemo1; Decimal)
        {
            Caption = 'AnnMemo1';
        }
        field(4; BalanceType; Text[1])
        {
            Caption = 'BalanceType';
        }
        field(5; BdgtRvsnDate; DateTime)
        {
            Caption = 'BdgtRvsnDate';
        }
        field(6; BegBal; Decimal)
        {
            Caption = 'BegBal';
        }
        field(7; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(8; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(9; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(10; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(11; CuryId; Text[4])
        {
            Caption = 'CuryId';
        }
        field(12; DistType; Text[8])
        {
            Caption = 'DistType';
        }
        field(13; FiscYr; Text[4])
        {
            Caption = 'FiscYr';
        }
        field(14; LastClosePerNbr; Text[6])
        {
            Caption = 'LastClosePerNbr';
        }
        field(15; LedgerID; Text[10])
        {
            Caption = 'LedgerID';
        }
        field(16; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(17; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(18; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(19; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(20; PtdAlloc00; Decimal)
        {
            Caption = 'PtdAlloc00';
        }
        field(21; PtdAlloc01; Decimal)
        {
            Caption = 'PtdAlloc01';
        }
        field(22; PtdAlloc02; Decimal)
        {
            Caption = 'PtdAlloc02';
        }
        field(23; PtdAlloc03; Decimal)
        {
            Caption = 'PtdAlloc03';
        }
        field(24; PtdAlloc04; Decimal)
        {
            Caption = 'PtdAlloc04';
        }
        field(25; PtdAlloc05; Decimal)
        {
            Caption = 'PtdAlloc05';
        }
        field(26; PtdAlloc06; Decimal)
        {
            Caption = 'PtdAlloc06';
        }
        field(27; PtdAlloc07; Decimal)
        {
            Caption = 'PtdAlloc07';
        }
        field(28; PtdAlloc08; Decimal)
        {
            Caption = 'PtdAlloc08';
        }
        field(29; PtdAlloc09; Decimal)
        {
            Caption = 'PtdAlloc09';
        }
        field(30; PtdAlloc10; Decimal)
        {
            Caption = 'PtdAlloc10';
        }
        field(31; PtdAlloc11; Decimal)
        {
            Caption = 'PtdAlloc11';
        }
        field(32; PtdAlloc12; Decimal)
        {
            Caption = 'PtdAlloc12';
        }
        field(33; PtdBal00; Decimal)
        {
            Caption = 'PtdBal00';
        }
        field(34; PtdBal01; Decimal)
        {
            Caption = 'PtdBal01';
        }
        field(35; PtdBal02; Decimal)
        {
            Caption = 'PtdBal02';
        }
        field(36; PtdBal03; Decimal)
        {
            Caption = 'PtdBal03';
        }
        field(37; PtdBal04; Decimal)
        {
            Caption = 'PtdBal04';
        }
        field(38; PtdBal05; Decimal)
        {
            Caption = 'PtdBal05';
        }
        field(39; PtdBal06; Decimal)
        {
            Caption = 'PtdBal06';
        }
        field(40; PtdBal07; Decimal)
        {
            Caption = 'PtdBal07';
        }
        field(41; PtdBal08; Decimal)
        {
            Caption = 'PtdBal08';
        }
        field(42; PtdBal09; Decimal)
        {
            Caption = 'PtdBal09';
        }
        field(43; PtdBal10; Decimal)
        {
            Caption = 'PtdBal10';
        }
        field(44; PtdBal11; Decimal)
        {
            Caption = 'PtdBal11';
        }
        field(45; PtdBal12; Decimal)
        {
            Caption = 'PtdBal12';
        }
        field(46; PtdCon00; Decimal)
        {
            Caption = 'PtdCon00';
        }
        field(47; PtdCon01; Decimal)
        {
            Caption = 'PtdCon01';
        }
        field(48; PtdCon02; Decimal)
        {
            Caption = 'PtdCon02';
        }
        field(49; PtdCon03; Decimal)
        {
            Caption = 'PtdCon03';
        }
        field(50; PtdCon04; Decimal)
        {
            Caption = 'PtdCon04';
        }
        field(51; PtdCon05; Decimal)
        {
            Caption = 'PtdCon05';
        }
        field(52; PtdCon06; Decimal)
        {
            Caption = 'PtdCon06';
        }
        field(53; PtdCon07; Decimal)
        {
            Caption = 'PtdCon07';
        }
        field(54; PtdCon08; Decimal)
        {
            Caption = 'PtdCon08';
        }
        field(55; PtdCon09; Decimal)
        {
            Caption = 'PtdCon09';
        }
        field(56; PtdCon10; Decimal)
        {
            Caption = 'PtdCon10';
        }
        field(57; PtdCon11; Decimal)
        {
            Caption = 'PtdCon11';
        }
        field(58; PtdCon12; Decimal)
        {
            Caption = 'PtdCon12';
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
        field(71; SpreadSheetType; Text[1])
        {
            Caption = 'SpreadSheetType';
        }
        field(72; Sub; Text[24])
        {
            Caption = 'Sub';
        }
        field(73; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(74; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(75; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(76; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(77; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(78; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(79; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(80; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(81; YtdBal00; Decimal)
        {
            Caption = 'YtdBal00';
        }
        field(82; YtdBal01; Decimal)
        {
            Caption = 'YtdBal01';
        }
        field(83; YtdBal02; Decimal)
        {
            Caption = 'YtdBal02';
        }
        field(84; YtdBal03; Decimal)
        {
            Caption = 'YtdBal03';
        }
        field(85; YtdBal04; Decimal)
        {
            Caption = 'YtdBal04';
        }
        field(86; YtdBal05; Decimal)
        {
            Caption = 'YtdBal05';
        }
        field(87; YtdBal06; Decimal)
        {
            Caption = 'YtdBal06';
        }
        field(88; YtdBal07; Decimal)
        {
            Caption = 'YtdBal07';
        }
        field(89; YtdBal08; Decimal)
        {
            Caption = 'YtdBal08';
        }
        field(90; YtdBal09; Decimal)
        {
            Caption = 'YtdBal09';
        }
        field(91; YtdBal10; Decimal)
        {
            Caption = 'YtdBal10';
        }
        field(92; YtdBal11; Decimal)
        {
            Caption = 'YtdBal11';
        }
        field(93; YtdBal12; Decimal)
        {
            Caption = 'YtdBal12';
        }
        field(94; YTDEstimated; Decimal)
        {
            Caption = 'YTDEstimated';
        }
    }

    keys
    {
        key(Key1; CpnyID, Acct, Sub, LedgerID, FiscYr)
        {
            Clustered = true;
        }
    }
}