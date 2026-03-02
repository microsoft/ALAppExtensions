// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47010 "SL AR_Balances"
{
    Access = Internal;
    Caption = 'SL AR_Balances';
    DataClassification = CustomerContent;

    fields
    {
        field(1; AccruedRevAgeBal00; Decimal)
        {
            Caption = 'AccruedRevAgeBal00';
            AutoFormatType = 0;
        }
        field(2; AccruedRevAgeBal01; Decimal)
        {
            Caption = 'AccruedRevAgeBal01';
            AutoFormatType = 0;
        }
        field(3; AccruedRevAgeBal02; Decimal)
        {
            Caption = 'AccruedRevAgeBal02';
            AutoFormatType = 0;
        }
        field(4; AccruedRevAgeBal03; Decimal)
        {
            Caption = 'AccruedRevAgeBal03';
            AutoFormatType = 0;
        }
        field(5; AccruedRevAgeBal04; Decimal)
        {
            Caption = 'AccruedRevAgeBal04';
            AutoFormatType = 0;
        }
        field(6; AccruedRevBal; Decimal)
        {
            Caption = 'AccruedRevBal';
            AutoFormatType = 0;
        }
        field(7; AgeBal00; Decimal)
        {
            Caption = 'AgeBal00';
            AutoFormatType = 0;
        }
        field(8; AgeBal01; Decimal)
        {
            Caption = 'AgeBal01';
            AutoFormatType = 0;
        }
        field(9; AgeBal02; Decimal)
        {
            Caption = 'AgeBal02';
            AutoFormatType = 0;
        }
        field(10; AgeBal03; Decimal)
        {
            Caption = 'AgeBal03';
            AutoFormatType = 0;
        }
        field(11; AgeBal04; Decimal)
        {
            Caption = 'AgeBal04';
            AutoFormatType = 0;
        }
        field(12; AvgDayToPay; Decimal)
        {
            Caption = 'AvgDayToPay';
            AutoFormatType = 0;
        }
        field(13; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
        }
        field(14; CrLmt; Decimal)
        {
            Caption = 'CrLmt';
            AutoFormatType = 0;
        }
        field(15; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(16; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(17; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(18; CurrBal; Decimal)
        {
            Caption = 'CurrBal';
            AutoFormatType = 0;
        }
        field(19; CuryID; Text[4])
        {
            Caption = 'CuryID';
        }
        field(20; CuryPromoBal; Decimal)
        {
            Caption = 'CuryPromoBal';
            AutoFormatType = 0;
        }
        field(21; CustID; Text[15])
        {
            Caption = 'CustID';
        }
        field(22; FutureBal; Decimal)
        {
            Caption = 'FutureBal';
            AutoFormatType = 0;
        }
        field(23; LastActDate; DateTime)
        {
            Caption = 'LastActDate';
        }
        field(24; LastAgeDate; DateTime)
        {
            Caption = 'LastAgeDate';
        }
        field(25; LastFinChrgDate; DateTime)
        {
            Caption = 'LastFinChrgDate';
        }
        field(26; LastInvcDate; DateTime)
        {
            Caption = 'LastInvcDate';
        }
        field(27; LastStmtBal00; Decimal)
        {
            Caption = 'LastStmtBal00';
            AutoFormatType = 0;
        }
        field(28; LastStmtBal01; Decimal)
        {
            Caption = 'LastStmtBal01';
            AutoFormatType = 0;
        }
        field(29; LastStmtBal02; Decimal)
        {
            Caption = 'LastStmtBal02';
            AutoFormatType = 0;
        }
        field(30; LastStmtBal03; Decimal)
        {
            Caption = 'LastStmtBal03';
            AutoFormatType = 0;
        }
        field(31; LastStmtBal04; Decimal)
        {
            Caption = 'LastStmtBal04';
            AutoFormatType = 0;
        }
        field(32; LastStmtBegBal; Decimal)
        {
            Caption = 'LastStmtBegBal';
            AutoFormatType = 0;
        }
        field(33; LastStmtDate; DateTime)
        {
            Caption = 'LastStmtDate';
        }
        field(34; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(35; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(36; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(37; NbrInvcPaid; Decimal)
        {
            Caption = 'NbrInvcPaid';
            AutoFormatType = 0;
        }
        field(38; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(39; PaidInvcDays; Decimal)
        {
            Caption = 'PaidInvcDays';
            AutoFormatType = 0;
        }
        field(40; PerNbr; Text[6])
        {
            Caption = 'PerNbr';
        }
        field(41; PromoBal; Decimal)
        {
            Caption = 'PromoBal';
            AutoFormatType = 0;
        }
        field(42; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(43; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(44; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
            AutoFormatType = 0;
        }
        field(45; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
            AutoFormatType = 0;
        }
        field(46; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
            AutoFormatType = 0;
        }
        field(47; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
            AutoFormatType = 0;
        }
        field(48; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(49; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(50; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(51; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(52; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(53; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(54; TotOpenOrd; Decimal)
        {
            Caption = 'TotOpenOrd';
            AutoFormatType = 0;
        }
        field(55; TotPrePay; Decimal)
        {
            Caption = 'TotPrePay';
            AutoFormatType = 0;
        }
        field(56; TotShipped; Decimal)
        {
            Caption = 'TotShipped';
            AutoFormatType = 0;
        }
        field(57; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(58; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(59; User3; Decimal)
        {
            Caption = 'User3';
            AutoFormatType = 0;
        }
        field(60; User4; Decimal)
        {
            Caption = 'User4';
            AutoFormatType = 0;
        }
        field(61; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(62; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(63; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(64; User8; DateTime)
        {
            Caption = 'User8';
        }
    }

    keys
    {
        key(Key1; CpnyID, CustID)
        {
            Clustered = true;
        }
    }
}