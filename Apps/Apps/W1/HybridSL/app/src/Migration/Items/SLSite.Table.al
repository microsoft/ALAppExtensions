// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

table 47057 "SL Site"
{
    Access = Internal;
    DataClassification = CustomerContent;
    ReplicateData = false;

    fields
    {
        field(1; Addr1; Text[60])
        {
            Caption = 'Addr1';
        }
        field(2; Addr2; Text[60])
        {
            Caption = 'Addr2';
        }
        field(3; AlwaysShip; Boolean)
        {
            Caption = 'AlwaysShip';
        }
        field(4; Attn; Text[30])
        {
            Caption = 'Attn';
        }
        field(5; City; Text[30])
        {
            Caption = 'City';
        }
        field(6; COGSAcct; Text[10])
        {
            Caption = 'COGSAcct';
        }
        field(7; COGSSub; Text[31])
        {
            Caption = 'COGSSub';
        }
        field(8; Country; Text[3])
        {
            Caption = 'Country';
        }
        field(9; CpnyID; Text[10])
        {
            Caption = 'CpnyID';
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
        field(13; DfltInvtAcct; Text[10])
        {
            Caption = 'DfltInvtAcct';
        }
        field(14; DfltInvtSub; Text[31])
        {
            Caption = 'DfltInvtSub';
        }
        field(15; DfltRepairBin; Text[10])
        {
            Caption = 'DfltRepairBin';
        }
        field(16; DfltVendorBin; Text[10])
        {
            Caption = 'DfltVendorBin';
        }
        field(17; DicsAcct; Text[10])
        {
            Caption = 'DicsAcct';
        }
        field(18; DiscSub; Text[31])
        {
            Caption = 'DiscSub';
        }
        field(19; Fax; Text[30])
        {
            Caption = 'Fax';
        }
        field(20; FrtAcct; Text[10])
        {
            Caption = 'FrtAcct';
        }
        field(21; FrtSub; Text[31])
        {
            Caption = 'FrtSub';
        }
        field(22; GeoCode; Text[10])
        {
            Caption = 'GeoCode';
        }
        field(23; IRCalcPolicy; Text[1])
        {
            Caption = 'IRCalcPolicy';
        }
        field(24; IRDaysSupply; Decimal)
        {
            Caption = 'IRDaysSupply';
        }
        field(25; IRDemandID; Text[10])
        {
            Caption = 'IRDemandID';
        }
        field(26; IRFutureDate; DateTime)
        {
            Caption = 'IRFutureDate';
        }
        field(27; IRFuturePolicy; Text[1])
        {
            Caption = 'IRFuturePolicy';
        }
        field(28; IRLeadTimeID; Text[10])
        {
            Caption = 'IRLeadTimeID';
        }
        field(29; IRPrimaryVendID; Text[15])
        {
            Caption = 'IRPrimaryVendID';
        }
        field(30; IRSeasonEndDay; Boolean)
        {
            Caption = 'IRSeasonEndDay';
        }
        field(31; IRSeasonEndMon; Boolean)
        {
            Caption = 'IRSeasonEndMon';
        }
        field(32; IRSeasonStrtDay; Boolean)
        {
            Caption = 'IRSeasonStrtDay';
        }
        field(33; IRSeasonStrtMon; Boolean)
        {
            Caption = 'IRSeasonStrtMon';
        }
        field(34; IRServiceLevel; Decimal)
        {
            Caption = 'IRServiceLevel';
        }
        field(35; IRSftyStkDays; Decimal)
        {
            Caption = 'IRSftyStkDays';
        }
        field(36; IRSftyStkPct; Decimal)
        {
            Caption = 'IRSftyStkPct';
        }
        field(37; IRSftyStkPolicy; Text[1])
        {
            Caption = 'IRSftyStkPolicy';
        }
        field(38; IRSourceCode; Text[1])
        {
            Caption = 'IRSourceCode';
        }
        field(39; IRTargetOrdMethod; Text[1])
        {
            Caption = 'IRTargetOrdMethod';
        }
        field(40; IRTargetOrdReq; Decimal)
        {
            Caption = 'IRTargetOrdReq';
        }
        field(41; IRTransferSiteID; Text[10])
        {
            Caption = 'IRTransferSiteID';
        }
        field(42; LUpd_DateTime; DateTime)
        {
            Caption = 'LUpd_DateTime';
        }
        field(43; LUpd_Prog; Text[8])
        {
            Caption = 'LUpd_Prog';
        }
        field(44; LUpd_User; Text[10])
        {
            Caption = 'LUpd_User';
        }
        field(45; MiscAcct; Text[10])
        {
            Caption = 'MiscAcct';
        }
        field(46; MiscSub; Text[31])
        {
            Caption = 'MiscSub';
        }
        field(47; Name; Text[30])
        {
            Caption = 'Name';
        }
        field(48; NoteID; Integer)
        {
            Caption = 'NoteID';
        }
        field(49; Phone; Text[30])
        {
            Caption = 'Phone';
        }
        field(50; ReplMthd; Text[1])
        {
            Caption = 'ReplMthd';
        }
        field(51; REPWhseLoc; Text[10])
        {
            Caption = 'REPWhseLoc';
        }
        field(52; RTVWhseLoc; Text[10])
        {
            Caption = 'RTVWhseLoc';
        }
        field(53; S4Future01; Text[30])
        {
            Caption = 'S4Future01';
        }
        field(54; S4Future02; Text[30])
        {
            Caption = 'S4Future02';
        }
        field(55; S4Future03; Decimal)
        {
            Caption = 'S4Future03';
        }
        field(56; S4Future04; Decimal)
        {
            Caption = 'S4Future04';
        }
        field(57; S4Future05; Decimal)
        {
            Caption = 'S4Future05';
        }
        field(58; S4Future06; Decimal)
        {
            Caption = 'S4Future06';
        }
        field(59; S4Future07; DateTime)
        {
            Caption = 'S4Future07';
        }
        field(60; S4Future08; DateTime)
        {
            Caption = 'S4Future08';
        }
        field(61; S4Future09; Integer)
        {
            Caption = 'S4Future09';
        }
        field(62; S4Future10; Integer)
        {
            Caption = 'S4Future10';
        }
        field(63; S4Future11; Text[10])
        {
            Caption = 'S4Future11';
        }
        field(64; S4Future12; Text[10])
        {
            Caption = 'S4Future12';
        }
        field(65; Salut; Text[30])
        {
            Caption = 'Salut';
        }
        field(66; SiteId; Text[10])
        {
            Caption = 'SiteId';
        }
        field(67; SlsAcct; Text[10])
        {
            Caption = 'SlsAcct';
        }
        field(68; SlsSub; Text[31])
        {
            Caption = 'SlsSub';
        }
        field(69; State; Text[3])
        {
            Caption = 'State';
        }
        field(70; Status; Text[1])
        {
            Caption = 'Status';
        }
        field(71; User1; Text[30])
        {
            Caption = 'User1';
        }
        field(72; User2; Text[30])
        {
            Caption = 'User2';
        }
        field(73; User3; Decimal)
        {
            Caption = 'User3';
        }
        field(74; User4; Decimal)
        {
            Caption = 'User4';
        }
        field(75; User5; Text[10])
        {
            Caption = 'User5';
        }
        field(76; User6; Text[10])
        {
            Caption = 'User6';
        }
        field(77; User7; DateTime)
        {
            Caption = 'User7';
        }
        field(78; User8; DateTime)
        {
            Caption = 'User8';
        }
        field(79; VisibleForWC; Boolean)
        {
            Caption = 'VisibleForWC';
        }
        field(80; Zip; Text[10])
        {
            Caption = 'Zip';
        }
    }

    keys
    {
        key(SiteId; SiteId)
        {
            Clustered = true;
        }
    }
}