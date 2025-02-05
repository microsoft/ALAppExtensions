// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47027 "SL Batch"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; Acct; Text[10])
        {
            Caption = 'Acct';
        }
        field(2; AutoRev; Integer)
        {
            Caption = 'AutoRev';
        }
        field(3; AutoRevCopy; Integer)
        {
            Caption = 'AutoRevCopy';
        }
        field(4; BalanceType; Text[1])
        {
            Caption = 'BalanceType';
        }
        field(5; BankAcct; Text[10])
        {
            Caption = 'BankAcct';
        }
        field(6; BankSub; Text[24])
        {
            Caption = 'BankSub';
        }
        field(7; BaseCuryID; Text[4])
        {
            Caption = 'BaseCuryID';
        }
        field(8; BatNbr; Text[10])
        {
            Caption = 'BatNbr';
        }
        field(9; BatType; Text[1])
        {
            Caption = 'BatType';
        }
        field(10; clearamt; Decimal)
        {
            Caption = 'clearamt';
        }
        field(11; Cleared; Integer)
        {
            Caption = 'Cleared';
        }
        field(12; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(13; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(14; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(15; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(16; CrTot; Decimal)
        {
            Caption = 'CrTot';
        }
        field(17; CtrlTot; Decimal)
        {
            Caption = 'CtrlTot';
        }
        field(18; CuryCrTot; Decimal)
        {
            Caption = 'CuryCrTot';
        }
        field(19; CuryCtrlTot; Decimal)
        {
            Caption = 'CuryCtrlTot';
        }
        field(20; CuryDepositAmt; Decimal)
        {
            Caption = 'CuryDepositAmt';
        }
        field(21; CuryDrTot; Decimal)
        {
            Caption = 'CuryDrTot';
        }
        field(22; CuryEffDate; DateTime)
        {
            Caption = 'CuryEffDate';
        }
        field(23; CuryId; Text[4])
        {
            Caption = 'CuryId';
        }
        field(24; CuryMultDiv; Text[1])
        {
            Caption = 'CuryMultDiv';
        }
        field(25; CuryRate; Decimal)
        {
            Caption = 'CuryRate';
        }
        field(26; CuryRateType; Text[6])
        {
            Caption = 'CuryRateType';
        }
        field(27; Cycle; Integer)
        {
            Caption = 'Cycle';
        }
        field(28; DateClr; DateTime)
        {
            Caption = 'DateClr';
        }
        field(29; DateEnt; DateTime)
        {
            Caption = 'DateEnt';
        }
        field(30; DepositAmt; Decimal)
        {
            Caption = 'DepositAmt';
        }
        field(31; Descr; Text[30])
        {
            Caption = 'Descr';
        }
        field(32; DrTot; Decimal)
        {
            Caption = 'DrTot';
        }
        field(33; EditScrnNbr; Text[5])
        {
            Caption = 'EditScrnNbr';
        }
        field(34; GLPostOpt; Text[1])
        {
            Caption = 'GLPostOpt';
        }
        field(35; JrnlType; Text[3])
        {
            Caption = 'JrnlType';
        }
        field(36; LedgerID; Text[10])
        {
            Caption = 'LedgerID';
        }
        field(37; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(38; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(39; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(40; Module; Text[2])
        {
            Caption = 'Module';
        }
        field(41; NbrCycle; Integer)
        {
            Caption = 'NbrCycle';
        }
        field(42; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(43; OrigBatNbr; Text[10])
        {
            Caption = 'OrigBatNbr';
        }
        field(44; OrigCpnyID; Text[10])
        {
            Caption = 'OrigCpnyID';
        }
        field(45; OrigScrnNbr; Text[5])
        {
            Caption = 'OrigScrnNbr';
        }
        field(46; PerEnt; Text[6])
        {
            Caption = 'PerEnt';
        }
        field(47; PerPost; Text[6])
        {
            Caption = 'PerPost';
        }
        field(48; Rlsed; Integer)
        {
            Caption = 'Rlsed';
        }
        field(49; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(50; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(51; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(52; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(53; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(54; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(55; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(56; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(57; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(58; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(59; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(60; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(61; Status; Text[1])
        {
            Caption = 'Status';
        }
        field(62; Sub; Text[24])
        {
            Caption = 'Sub';
        }
        field(64; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(65; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(66; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(67; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(68; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(69; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(70; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(71; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(72; VOBatNbrForPP; Text[10])
        {
            Caption = 'VOBatNbrForPP';
        }
    }

    keys
    {
        key(Key1; Module, BatNbr)
        {
            Clustered = true;
        }
    }
}