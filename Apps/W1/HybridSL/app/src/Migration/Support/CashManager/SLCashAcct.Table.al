// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47094 "SL CashAcct"
{
    Caption = 'SL CashAcct';
    DataClassification = CustomerContent;

    fields
    {
        field(1; AcceptGLUpdates; Integer)
        {
            Caption = 'AcceptGLUpdates';
        }
        field(2; AcctNbr; Text[30])
        {
            Caption = 'AcctNbr';
        }
        field(3; AcctType; Text[1])
        {
            Caption = 'AcctType';
        }
        field(4; Active; Integer)
        {
            Caption = 'Active';
        }
        field(5; Addr1; Text[30])
        {
            Caption = 'Addr1';
        }
        field(6; Addr2; Text[30])
        {
            Caption = 'Addr2';
        }
        field(7; AddrID; Text[10])
        {
            Caption = 'AddrID';
        }
        field(8; Attn; Text[30])
        {
            Caption = 'Attn';
        }
        field(9; BankAcct; Text[10])
        {
            Caption = 'BankAcct';
        }
        field(10; BankID; Text[10])
        {
            Caption = 'BankID';
        }
        field(11; BankSub; Text[24])
        {
            Caption = 'BankSub';
        }
        field(12; CashAcctName; Text[30])
        {
            Caption = 'CashAcctName';
        }
        field(13; City; Text[30])
        {
            Caption = 'City';
        }
        field(14; Country; Text[3])
        {
            Caption = 'Country';
        }
        field(15; CpnyID; Text[30])
        {
            Caption = 'CpnyID';
        }
        field(16; Crtd_DateTime; DateTime)
        {
            Caption = 'Crtd_DateTime';
        }
        field(17; Crtd_Prog; Text[8])
        {
            Caption = 'Crtd_Prog';
        }
        field(18; Crtd_User; Text[10])
        {
            Caption = 'Crtd_User';
        }
        field(19; CurrentBal; Decimal)
        {
            Caption = 'CurrentBal';
            AutoFormatType = 0;
        }
        field(20; curycurrentbal; Decimal)
        {
            Caption = 'curycurrentbal';
            AutoFormatType = 0;
        }
        field(21; CuryID; Text[4])
        {
            Caption = 'CuryID';
        }
        field(22; CustID; Text[15])
        {
            Caption = 'CustID';
        }
        field(23; Fax; Text[15])
        {
            Caption = 'Fax';
        }
        field(24; LastAutoCheckNbr; Text[10])
        {
            Caption = 'LastAutoCheckNbr';
        }
        field(25; LastManualCheckNbr; Text[10])
        {
            Caption = 'LastManualCheckNbr';
        }
        field(26; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(27; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(28; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(29; Name; Text[30])
        {
            Caption = 'Name';
        }
        field(30; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(31; Phone; Text[15])
        {
            Caption = 'Phone';
        }
        field(32; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(33; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(34; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
            AutoFormatType = 0;
        }
        field(35; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
            AutoFormatType = 0;
        }
        field(36; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
            AutoFormatType = 0;
        }
        field(37; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
            AutoFormatType = 0;
        }
        field(38; S4Future07; Date)
        {
            Caption = 'S4Future07';
        }
        field(39; S4Future08; Date)
        {
            Caption = 'S4Future08';
        }
        field(40; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(41; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(42; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(43; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(44; Salut; Text[30])
        {
            Caption = 'Salut';
        }
        field(45; State; Text[3])
        {
            Caption = 'State';
        }
        field(46; transitnbr; Text[9])
        {
            Caption = 'transitnbr';
        }
        field(47; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(48; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(49; User3; Decimal)
        {
            Caption = 'User3';
            AutoFormatType = 0;
        }
        field(50; User4; Decimal)
        {
            Caption = 'User4';
            AutoFormatType = 0;
        }
        field(51; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(52; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(53; User7; Date)
        {
            Caption = 'User7';
        }
        field(54; User8; Date)
        {
            Caption = 'User8';
        }
        field(55; Zip; Text[10])
        {
            Caption = 'Zip';
        }
    }

    keys
    {
        key(PK; CpnyID, BankAcct, BankSub)
        {
            Clustered = true;
        }
    }
}