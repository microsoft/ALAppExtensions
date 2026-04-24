// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47093 "SL CashSumD"
{
    Caption = 'SL CashSumD';
    DataClassification = CustomerContent;

    fields
    {
        field(1; BankAcct; Text[10])
        {
            Caption = 'Bank Account';
        }
        field(2; BankSub; Text[24])
        {
            Caption = 'Bank Sub';
        }
        field(3; ConCuryDisbursements; Decimal)
        {
            Caption = 'Con Cury Disbursements';
            AutoFormatType = 0;
        }
        field(4; ConCuryReceipts; Decimal)
        {
            Caption = 'Con Cury Receipts';
            AutoFormatType = 0;
        }
        field(5; Condisbursements; Decimal)
        {
            Caption = 'Con Disbursements';
            AutoFormatType = 0;
        }
        field(6; ConReceipts; Decimal)
        {
            Caption = 'Con Receipts';
            AutoFormatType = 0;
        }
        field(7; CpnyID; Text[30])
        {
            Caption = 'Company ID';
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
        field(11; CuryDisbursements; Decimal)
        {
            Caption = 'Cury Disbursements';
            AutoFormatType = 0;
        }
        field(12; CuryID; Text[4])
        {
            Caption = 'Currency ID';
            AutoFormatType = 0;
        }
        field(13; CuryReceipts; Decimal)
        {
            Caption = 'Cury Receipts';
            AutoFormatType = 0;
        }
        field(14; Disbursements; Decimal)
        {
            Caption = 'Disbursements';
            AutoFormatType = 0;
        }
        field(15; LUpd_DateTime; DateTime)
        {
            Caption = 'Last Updated Date Time';
        }
        field(16; LUpd_Prog; Text[8])
        {
            Caption = 'Last Updated Program';
        }
        field(17; LUpd_User; Text[10])
        {
            Caption = 'Last Updated User';
        }
        field(18; NoteID; Integer)
        {
            Caption = 'Note ID';
        }
        field(19; PerNbr; Text[6])
        {
            Caption = 'Period Number';
        }
        field(20; Receipts; Decimal)
        {
            Caption = 'Receipts';
            AutoFormatType = 0;
        }
        field(21; S4Future01; Text[30])
        {
            Caption = 'S4 Future 01';
        }
        field(22; S4Future02; Text[30])
        {
            Caption = 'S4 Future 02';
        }
        field(23; S4Future03; Decimal)
        {
            Caption = 'S4 Future 03';
            AutoFormatType = 0;
        }
        field(24; S4Future04; Decimal)
        {
            Caption = 'S4 Future 04';
            AutoFormatType = 0;
        }
        field(25; S4Future05; Decimal)
        {
            Caption = 'S4 Future 05';
            AutoFormatType = 0;
        }
        field(26; S4Future06; Decimal)
        {
            Caption = 'S4 Future 06';
            AutoFormatType = 0;
        }
        field(27; S4Future07; Date)
        {
            Caption = 'S4 Future 07';
        }
        field(28; S4Future08; Date)
        {
            Caption = 'S4 Future 08';
        }
        field(29; S4Future09; Integer)
        {
            Caption = 'S4 Future 09';
        }
        field(30; S4Future10; Integer)
        {
            Caption = 'S4 Future 10';
        }
        field(31; S4Future11; Text[10])
        {
            Caption = 'S4 Future 11';
        }
        field(32; S4Future12; Text[10])
        {
            Caption = 'S4 Future 12';
        }
        field(33; TranDate; Date)
        {
            Caption = 'Transaction Date';
        }
        field(34; User1; Text[30])
        {
            Caption = 'User 1';
        }
        field(35; User2; Text[30])
        {
            Caption = 'User 2';
        }
        field(36; User3; Decimal)
        {
            Caption = 'User 3';
            AutoFormatType = 0;
        }
        field(37; User4; Decimal)
        {
            Caption = 'User 4';
            AutoFormatType = 0;
        }
        field(38; User5; Text[10])
        {
            Caption = 'User 5';
        }
        field(39; User6; Text[10])
        {
            Caption = 'User 6';
        }
        field(40; User7; Date)
        {
            Caption = 'User 7';
        }
        field(41; User8; Date)
        {
            Caption = 'User 8';
        }
    }

    keys
    {
        key(PK; CpnyID, BankAcct, BankSub, PerNbr, TranDate)
        {
            Clustered = true;
        }
    }
}
