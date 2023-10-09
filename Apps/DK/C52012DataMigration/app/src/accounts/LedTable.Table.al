// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

table 1863 "C5 LedTable"
{
    ReplicateData = false;

    fields
    {
        field(1; RecId; Integer)
        {
            Caption = 'Row number';
        }
        field(2; LastChanged; Date)
        {
            Caption = 'Last changed';
        }
        field(3; DEL_UserLock; Integer)
        {
            Caption = 'Lock';
        }
        field(4; Account; Code[10])
        {
            Caption = 'Account';
        }
        field(5; AccountName; Text[40])
        {
            Caption = 'Account name';
        }
        field(6; AccountType; Option)
        {
            Caption = 'A/c type';
            OptionMembers = "P/L a/c","Balance a/c",Heading,"New page",Empty,"Heading total","Counter total";
        }
        field(7; Code; Text[10])
        {
            Caption = 'Code';
        }
        field(8; DCproposal; Option)
        {
            Caption = 'DC proposal';
            OptionMembers = " ",Debit,Credit;
        }
        field(9; Department; Code[10])
        {
            Caption = 'Department';
        }
        field(10; MandDepartment; Option)
        {
            Caption = 'Mandatory department';
            OptionMembers = No,Yes;
        }
        field(11; OffsetAccount; Text[10])
        {
            Caption = 'Offset a/c';
        }
        field(12; Access; Option)
        {
            Caption = 'Access';
            OptionMembers = Open,Locked,System;
        }
        field(13; TotalFromAccount; Text[10])
        {
            Caption = 'Total from';
        }
        field(14; Vat; Code[10])
        {
            Caption = 'VAT';
        }
        field(15; BalanceCur; Decimal)
        {
            Caption = 'Balance currency';
        }
        field(16; Currency; Code[3])
        {
            Caption = 'Currency';
        }
        field(17; CostType; Text[10])
        {
            Caption = 'Cost type';
        }
        field(18; Counterunit; Text[250])
        {
            Caption = 'Counter total';
        }
        // We ignore this field, since we're not importing images
        field(19; ImageFile; Text[250])
        {
            Caption = 'Image';
        }
        field(20; BalanceMST; Decimal)
        {
            Caption = 'Balance in LCY';
        }
        field(21; TmpNumerals05; Decimal)
        {
            Caption = 'TmpNum05';
        }
        field(22; TmpNumerals06; Decimal)
        {
            Caption = 'TmpNum06';
        }
        field(23; TmpNumerals07; Decimal)
        {
            Caption = 'TmpNum07';
        }
        field(24; TmpNumerals08; Decimal)
        {
            Caption = 'TmpNum08';
        }
        field(25; TmpNumerals09; Decimal)
        {
            Caption = 'TmpNum09';
        }
        field(26; TmpNumerals10; Decimal)
        {
            Caption = 'TmpNum10';
        }
        field(27; TmpNumerals11; Decimal)
        {
            Caption = 'TmpNum11';
        }
        field(28; TmpNumerals12; Decimal)
        {
            Caption = 'TmpNum12';
        }
        field(29; TmpNumerals13; Decimal)
        {
            Caption = 'TmpNum13';
        }
        field(30; CompanyGroupAcc; Text[10])
        {
            Caption = 'Corporate a/c';
        }
        field(31; ExchAdjust; Option)
        {
            Caption = 'Exch. adjustment';
            OptionMembers = No,Yes;
        }
        field(32; Balance02; Decimal)
        {
            Caption = 'Balance in';
        }
        field(33; EDIIndex; Text[10])
        {
            Caption = 'EDI index';
        }
        field(34; Centre; Code[10])
        {
            Caption = 'Cost centre';
        }
        field(35; MandCentre; Option)
        {
            Caption = 'Mandatory cost centre';
            OptionMembers = No,Yes;
        }
        field(36; Purpose; Code[10])
        {
            Caption = 'Purpose';
        }
        field(37; MandPurpose; Option)
        {
            Caption = 'Mandatory purpose';
            OptionMembers = No,Yes;
        }
        field(38; VatBlocked; Option)
        {
            Caption = 'VAT locked';
            OptionMembers = No,Yes;
        }
        field(39; OpeningAccount; Text[10])
        {
            Caption = 'Opening account';
        }
    }

    keys
    {
        key(PK; RecId)
        {
            Clustered = true;
        }
    }
}