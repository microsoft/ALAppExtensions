// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.Sales.Customer;

table 47056 "SL SOAddress"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Permissions = tabledata "Ship-to Address" = rim;
    ReplicateData = false;

    fields
    {
        field(1; Addr1; Text[60])
        {
        }
        field(2; Addr2; Text[60])
        {
        }
        field(3; Attn; Text[30])
        {
        }
        field(4; City; Text[30])
        {
        }
        field(5; COGSAcct; Text[10])
        {
        }
        field(6; COGSSub; Text[31])
        {
        }
        field(7; Country; Text[3])
        {
        }
        field(8; Crtd_DateTime; DateTime)
        {
        }
        field(9; Crtd_Prog; Text[8])
        {
        }
        field(10; Crtd_User; Text[10])
        {
        }
        field(11; CustId; Text[15])
        {
        }
        field(12; Descr; Text[30])
        {
        }
        field(13; DiscAcct; Text[10])
        {
        }
        field(14; DiscSub; Text[31])
        {
        }
        field(15; EMailAddr; Text[80])
        {
        }
        field(16; Fax; Text[30])
        {
        }
        field(17; FOB; Text[15])
        {
        }
        field(18; FrghtCode; Text[4])
        {
        }
        field(19; FrtAcct; Text[10])
        {
        }
        field(20; FrtSub; Text[31])
        {
        }
        field(21; FrtTermsID; Text[10])
        {
        }
        field(22; GeoCode; Text[10])
        {
        }
        field(23; LUpd_DateTime; DateTime)
        {
        }
        field(24; LUpd_Prog; Text[8])
        {
        }
        field(25; LUpd_User; Text[10])
        {
        }
        field(26; MapLocation; Text[10])
        {
        }
        field(27; MiscAcct; Text[10])
        {
        }
        field(28; MiscSub; Text[31])
        {
        }
        field(29; Name; Text[60])
        {
        }
        field(30; NoteId; Integer)
        {
        }
        field(31; Phone; Text[30])
        {
        }
        field(32; S4Future01; Text[30])
        {
        }
        field(33; S4Future02; Text[30])
        {
        }
        field(34; S4Future03; Decimal)
        {
        }
        field(35; S4Future04; Decimal)
        {
        }
        field(36; S4Future05; Decimal)
        {
        }
        field(37; S4Future06; Decimal)
        {
        }
        field(38; S4Future07; DateTime)
        {
        }
        field(39; S4Future08; DateTime)
        {
        }
        field(40; S4Future09; Integer)
        {
        }
        field(41; S4Future10; Integer)
        {
        }
        field(42; S4Future11; Text[10])
        {
        }
        field(43; S4Future12; Text[10])
        {
        }
        field(44; ShipToId; Text[10])
        {
        }
        field(45; ShipViaID; Text[15])
        {
        }
        field(46; SiteID; Text[10])
        {
        }
        field(47; SlsAcct; Text[10])
        {
        }
        field(48; SlsPerID; Text[10])
        {
        }
        field(49; SlsSub; Text[31])
        {
        }
        field(50; State; Text[3])
        {
        }
        field(51; Status; Text[1])
        {
        }
        field(52; TaxId00; Text[10])
        {
        }
        field(53; TaxId01; Text[10])
        {
        }
        field(54; TaxId02; Text[10])
        {
        }
        field(55; TaxId03; Text[10])
        {
        }
        field(56; TaxLocId; Text[15])
        {
        }
        field(57; TaxRegNbr; Text[15])
        {
        }
        field(58; User1; Text[30])
        {
        }
        field(59; User2; Text[30])
        {
        }
        field(60; User3; Decimal)
        {
        }
        field(61; User4; Decimal)
        {
        }
        field(62; User5; Text[10])
        {
        }
        field(63; User6; Text[10])
        {
        }
        field(64; User7; DateTime)
        {
        }
        field(65; User8; DateTime)
        {
        }
        field(66; Zip; Text[10])
        {
        }
    }

    keys
    {
        key(Key1; CustId, ShipToId)
        {
            Clustered = true;
        }
    }

    internal procedure MoveStagingData()
    var
        ShipToAddress: Record "Ship-to Address";
        Customer: Record Customer;
        Exists: Boolean;
    begin
        if Customer.Get(CustId) then begin
            Exists := ShipToAddress.Get(CustId, CopyStr(ShipToId, 1, 10));
            ShipToAddress.Init();
            ShipToAddress.Validate("Customer No.", CustId);
            ShipToAddress.Code := CopyStr(ShipToId, 1, 10);
            ShipToAddress.Name := Customer.Name;
            ShipToAddress.Address := Addr1;
            ShipToAddress."Address 2" := CopyStr(Addr2, 1, 50);
            ShipToAddress.City := CopyStr(City, 1, 30);
            ShipToAddress.Contact := Attn;
            ShipToAddress."Phone No." := Phone;
            ShipToAddress."Fax No." := Fax;
            ShipToAddress."Post Code" := Zip;
            ShipToAddress."E-Mail" := EMailAddr;
            ShipToAddress.County := Country;

            if not Exists then
                ShipToAddress.Insert()
            else
                ShipToAddress.Modify();
        end;
    end;
}