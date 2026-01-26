// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.Purchases.Vendor;

table 47055 "SL POAddress"
{
    Access = Internal;
    DataClassification = CustomerContent;
    Permissions = tabledata "Order Address" = rim;
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
        field(5; Country; Text[3])
        {
        }
        field(6; Crtd_DateTime; DateTime)
        {
        }
        field(7; Crtd_Prog; Text[8])
        {
        }
        field(8; Crtd_User; Text[10])
        {
        }
        field(9; Descr; Text[30])
        {
        }
        field(10; EMailAddr; Text[80])
        {
        }
        field(11; Fax; Text[30])
        {
        }
        field(12; LUpd_DateTime; DateTime)
        {
        }
        field(13; LUpd_Prog; Text[8])
        {
        }
        field(14; LUpd_User; Text[10])
        {
        }
        field(15; Name; Text[60])
        {
        }
        field(16; NoteId; Integer)
        {
        }
        field(17; OrdFromId; Text[10])
        {
        }
        field(18; Phone; Text[30])
        {
        }
        field(19; S4Future01; Text[30])
        {
        }
        field(20; S4Future02; Text[30])
        {
        }
        field(21; S4Future03; Decimal)
        {
        }
        field(22; S4Future04; Decimal)
        {
        }
        field(23; S4Future05; Decimal)
        {
        }
        field(24; S4Future06; Decimal)
        {
        }
        field(25; S4Future07; DateTime)
        {
        }
        field(26; S4Future08; DateTime)
        {
        }
        field(27; S4Future09; Integer)
        {
        }
        field(28; S4Future10; Integer)
        {
        }
        field(29; S4Future11; Text[10])
        {
        }
        field(30; S4Future12; Text[10])
        {
        }
        field(31; State; Text[3])
        {
        }
        field(32; TaxId00; Text[10])
        {
        }
        field(33; TaxId01; Text[10])
        {
        }
        field(34; TaxId02; Text[10])
        {
        }
        field(35; TaxId03; Text[10])
        {
        }
        field(36; TaxLocId; Text[15])
        {
        }
        field(37; TaxRegNbr; Text[15])
        {
        }
        field(38; User1; Text[30])
        {
        }
        field(39; User2; Text[30])
        {
        }
        field(40; User3; Decimal)
        {
        }
        field(41; User4; Decimal)
        {
        }
        field(42; User5; Text[10])
        {
        }
        field(43; User6; Text[10])
        {
        }
        field(44; User7; DateTime)
        {
        }
        field(45; User8; DateTime)
        {
        }
        field(46; VendId; Text[15])
        {
        }
        field(47; Zip; Text[10])
        {
        }
    }

    keys
    {
        key(Key1; VendId, OrdFromId)
        {
            Clustered = true;
        }
    }

    internal procedure MoveStagingData()
    var
        OrderAddress: Record "Order Address";
        Vendor: Record Vendor;
        Exists: Boolean;
    begin
        if Vendor.Get(VendId) then begin
            Exists := OrderAddress.Get(VendId, OrdFromId);
            OrderAddress.Init();
            OrderAddress."Vendor No." := VendId;
            OrderAddress.Code := OrdFromId;
            OrderAddress.Name := Name;
            OrderAddress.Address := Addr1;
            OrderAddress."Address 2" := CopyStr(Addr2, 1, 50);
            OrderAddress.City := City;
            OrderAddress.Contact := Attn;
            OrderAddress."Phone No." := Phone;
            OrderAddress."Fax No." := Fax;
            OrderAddress."Post Code" := Zip;
            OrderAddress.County := State;
            OrderAddress."E-Mail" := EMailAddr;

            if not Exists then
                OrderAddress.Insert()
            else
                OrderAddress.Modify();
        end;
    end;
}