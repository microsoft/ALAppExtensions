// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL.HistoricalData;

table 42819 "SL Hist. GLTran"
{
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; Acct; Text[10])
        {
            Caption = 'Acct';
        }
        field(2; AppliedDate; DateTime)
        {
            Caption = 'AppliedDate';
        }
        field(3; BalanceType; Text[1])
        {
            Caption = 'BalanceType';
        }
        field(4; BaseCuryID; Text[4])
        {
            Caption = 'BaseCuryID';
        }
        field(5; BatNbr; Text[10])
        {
            Caption = 'BatNbr';
        }
        field(6; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(7; CrAmt; Decimal)
        {
            Caption = 'CrAmt';
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
        field(11; CuryCrAmt; Decimal)
        {
            Caption = 'CuryCrAmt';
        }
        field(12; CuryDrAmt; Decimal)
        {
            Caption = 'CuryDrAmt';
        }
        field(13; CuryEffDate; DateTime)
        {
            Caption = 'CuryEffDate';
        }
        field(14; CuryId; Text[4])
        {
            Caption = 'CuryId';
        }
        field(15; CuryMultDiv; Text[1])
        {
            Caption = 'CuryMultDiv';
        }
        field(16; CuryRate; Decimal)
        {
            Caption = 'CuryRate';
        }
        field(17; CuryRateType; Text[6])
        {
            Caption = 'CuryRateType';
        }
        field(18; DrAmt; Decimal)
        {
            Caption = 'DrAmt';
        }
        field(19; EmployeeID; Text[10])
        {
            Caption = 'EmployeeID';
        }
        field(20; ExtRefNbr; Text[15])
        {
            Caption = 'ExtRefNbr';
        }
        field(21; FiscYr; Text[4])
        {
            Caption = 'FiscYr';
        }
        field(22; IC_Distribution; Integer)
        {
            Caption = 'IC_Distribution';
        }
        field(23; Id; Text[20])
        {
            Caption = 'Id';
        }
        field(24; JrnlType; Text[3])
        {
            Caption = 'JrnlType';
        }
        field(25; Labor_Class_Cd; Text[4])
        {
            Caption = 'Labor_Class_Cd';
        }
        field(26; LedgerID; Text[10])
        {
            Caption = 'LedgerID';
        }
        field(27; LineId; Integer)
        {
            Caption = 'LineId';
        }
        field(28; LineNbr; Integer)
        {
            Caption = 'LineNbr';
        }
        field(29; LineRef; Text[5])
        {
            Caption = 'LineRef';
        }
        field(30; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(31; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(32; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(33; Module; Text[2])
        {
            Caption = 'Module';
        }
        field(34; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(35; OrigAcct; Text[10])
        {
            Caption = 'OrigAcct';
        }
        field(36; OrigBatNbr; Text[10])
        {
            Caption = 'OrigBatNbr';
        }
        field(37; OrigCpnyID; Text[10])
        {
            Caption = 'OrigCpnyID';
        }
        field(38; OrigSub; Text[24])
        {
            Caption = 'OrigSub';
        }
        field(39; PC_Flag; Text[1])
        {
            Caption = 'PC_Flag';
        }
        field(40; PC_ID; Text[20])
        {
            Caption = 'PC_ID';
        }
        field(41; PC_Status; Text[1])
        {
            Caption = 'PC_Status';
        }
        field(42; PerEnt; Text[6])
        {
            Caption = 'PerEnt';
        }
        field(43; PerPost; Text[6])
        {
            Caption = 'PerPost';
        }
        field(44; Posted; Text[1])
        {
            Caption = 'Posted';
        }
        field(45; ProjectID; Text[16])
        {
            Caption = 'ProjectID';
        }
        field(46; Qty; Decimal)
        {
            Caption = 'Qty';
        }
        field(47; RefNbr; Text[10])
        {
            Caption = 'RefNbr';
        }
        field(48; RevEntryOption; Text[1])
        {
            Caption = 'RevEntryOption';
        }
        field(49; Rlsed; Integer)
        {
            Caption = 'Rlsed';
        }
        field(50; S4Future01; Text[30])
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
        field(63; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(64; ServiceDate; DateTime)
        {
            Caption = 'ServiceDate';
        }
        field(65; Sub; Text[24])
        {
            Caption = 'Sub';
        }
        field(66; TaskID; Text[32])
        {
            Caption = 'TaskID';
        }
        field(67; TranDate; DateTime)
        {
            Caption = 'TranDate';
        }
        field(68; TranDesc; Text[30])
        {
            Caption = 'TranDesc';
        }
        field(69; TranType; Text[2])
        {
            Caption = 'TranType';
        }
        field(70; Units; Decimal)
        {
            Caption = 'Units';
        }
        field(71; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(73; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(74; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(75; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(76; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(77; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(78; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(79; User8; DateTime)
        {
            Caption = 'User8';
        }
    }

    keys
    {
        key(Key1; Module, BatNbr, LineNbr)
        {
            Clustered = true;
        }
    }
}
