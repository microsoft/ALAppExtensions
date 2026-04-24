// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

table 47090 "SL CASetup"
{
    Caption = 'SL CASetup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; AcceptTransDate; Date)
        {
            Caption = 'Accept Trans Date';
        }
        field(2; ARHoldingAcct; Text[10])
        {
            Caption = 'AR Holding Account';
        }
        field(3; ARHoldingSub; Text[24])
        {
            Caption = 'AR Holding Sub';
        }
        field(4; AutoBatRpt; Integer)
        {
            Caption = 'Auto Bat Rpt';
        }
        field(5; BnkChgType; Text[2])
        {
            Caption = 'Bank Charge Type';
        }
        field(6; ClearAcct; Text[10])
        {
            Caption = 'Clear Account';
        }
        field(7; ClearSub; Text[24])
        {
            Caption = 'Clear Sub';
        }
        field(8; Crtd_DateTime; DateTime)
        {
            Caption = 'Created Date Time';
        }
        field(9; Crtd_Prog; Text[8])
        {
            Caption = 'Created Program';
        }
        field(10; Crtd_User; Text[10])
        {
            Caption = 'Created User';
        }
        field(11; CurrPerNbr; Text[6])
        {
            Caption = 'Current Period Number';
        }
        field(12; DfltRateType; Text[6])
        {
            Caption = 'Default Rate Type';
        }
        field(13; DfltRcnclAmt; Integer)
        {
            Caption = 'Default Reconcile Amount';
        }
        field(14; GlPostOpt; Text[1])
        {
            Caption = 'GL Post Option';
        }
        field(15; Init; Integer)
        {
            Caption = 'Init';
        }
        field(16; lastbatnbr; Text[10])
        {
            Caption = 'Last Batch Number';
        }
        field(17; LUpd_DateTime; DateTime)
        {
            Caption = 'Last Updated Date Time';
        }
        field(18; LUpd_Prog; Text[8])
        {
            Caption = 'Last Updated Program';
        }
        field(19; LUpd_User; Text[10])
        {
            Caption = 'Last Updated User';
        }
        field(20; MCuryBatRpt; Integer)
        {
            Caption = 'M Cury Bat Rpt';
        }
        field(21; NbrAvgDay; Integer)
        {
            Caption = 'Number Average Day';
        }
        field(22; NoteID; Integer)
        {
            Caption = 'Note ID';
        }
        field(23; paststartdate; Date)
        {
            Caption = 'Past Start Date';
        }
        field(24; PerNbr; Text[6])
        {
            Caption = 'Period Number';
        }
        field(25; PerretBal; Integer)
        {
            Caption = 'Per Ret Bal';
        }
        field(26; PerRetTran; Integer)
        {
            Caption = 'Per Ret Tran';
        }
        field(27; PostGLDetail; Integer)
        {
            Caption = 'Post GL Detail';
        }
        field(28; PrtEmpName; Integer)
        {
            Caption = 'Print Emp Name';
        }
        field(29; S4Future01; Text[30])
        {
            Caption = 'S4 Future 01';
        }
        field(30; S4Future02; Text[30])
        {
            Caption = 'S4 Future 02';
        }
        field(31; S4Future03; Decimal)
        {
            Caption = 'S4 Future 03';
            AutoFormatType = 0;
        }
        field(32; S4Future04; Decimal)
        {
            Caption = 'S4 Future 04';
            AutoFormatType = 0;
        }
        field(33; S4Future05; Decimal)
        {
            Caption = 'S4 Future 05';
            AutoFormatType = 0;
        }
        field(34; S4Future06; Decimal)
        {
            Caption = 'S4 Future 06';
            AutoFormatType = 0;
        }
        field(35; S4Future07; Date)
        {
            Caption = 'S4 Future 07';
        }
        field(36; S4Future08; Date)
        {
            Caption = 'S4 Future 08';
        }
        field(37; S4Future09; Integer)
        {
            Caption = 'S4 Future 09';
        }
        field(38; S4Future10; Integer)
        {
            Caption = 'S4 Future 10';
        }
        field(39; S4Future11; Text[10])
        {
            Caption = 'S4 Future 11';
        }
        field(40; S4Future12; Text[10])
        {
            Caption = 'S4 Future 12';
        }
        field(41; SetUpId; Text[2])
        {
            Caption = 'Setup ID';
        }
        field(42; ShowGLInfo; Integer)
        {
            Caption = 'Show GL Info';
        }
        field(43; ShowLastBankRecs; Integer)
        {
            Caption = 'Show Last Bank Recs';
        }
        field(44; User1; Text[30])
        {
            Caption = 'User 1';
        }
        field(45; User2; Text[30])
        {
            Caption = 'User 2';
        }
        field(46; User3; Decimal)
        {
            Caption = 'User 3';
            AutoFormatType = 0;
        }
        field(47; User4; Decimal)
        {
            Caption = 'User 4';
            AutoFormatType = 0;
        }
        field(48; User5; Text[10])
        {
            Caption = 'User 5';
        }
        field(49; User6; Text[10])
        {
            Caption = 'User 6';
        }
        field(50; User7; Date)
        {
            Caption = 'User 7';
        }
        field(51; User8; Date)
        {
            Caption = 'User 8';
        }
    }

    keys
    {
        key(PK; SetUpId)
        {
            Clustered = false;
        }
    }
}