table 4048 "GP Customer Address"
{
    Permissions = tabledata "Ship-to Address" = rim;
    ReplicateData = false;
    Extensible = false;

    fields
    {
        field(1; CUSTNMBR; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(2; ADRSCODE; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(5; SHIPMTHD; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(6; TAXSCHID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(7; CNTCPRSN; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(8; ADDRESS1; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(9; ADDRESS2; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(12; CITY; Text[35])
        {
            DataClassification = CustomerContent;
        }
        field(13; STATE; Text[29])
        {
            DataClassification = CustomerContent;
        }
        field(14; ZIP; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(15; PHONE1; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(18; FAX; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(26; LOCNCODE; Text[11])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; CUSTNMBR, ADRSCODE)
        {
            Clustered = true;
        }
    }

    procedure MoveStagingData()
    var
        ShipToAddress: Record "Ship-to Address";
        Customer: Record Customer;
        Exists: Boolean;
    begin
        if Customer.Get(CUSTNMBR) then begin
            Exists := ShipToAddress.Get(CUSTNMBR, CopyStr(ADRSCODE, 1, 10));
            ShipToAddress.Init();
            ShipToAddress.Validate("Customer No.", CUSTNMBR);
            ShipToAddress.Code := CopyStr(ADRSCODE, 1, 10);
            ShipToAddress.Name := Customer.Name;
            ShipToAddress.Address := ADDRESS1;
            ShipToAddress."Address 2" := CopyStr(ADDRESS2, 1, 50);
            ShipToAddress.City := CopyStr(CITY, 1, 30);
            ShipToAddress.Contact := CNTCPRSN;
            ShipToAddress."Phone No." := PHONE1;
            ShipToAddress."Shipment Method Code" := CopyStr(SHIPMTHD, 1, 10);
            ShipToAddress."Fax No." := FAX;
            ShipToAddress."Post Code" := ZIP;
            ShipToAddress.County := STATE;
            ShipToAddress."Tax Area Code" := TAXSCHID;

            if (CopyStr(ShipToAddress."Phone No.", 1, 14) = '00000000000000') then
                ShipToAddress."Phone No." := '';

            if (CopyStr(ShipToAddress."Fax No.", 1, 14) = '00000000000000') then
                ShipToAddress."Fax No." := '';

            if not Exists then
                ShipToAddress.Insert()
            else
                ShipToAddress.Modify();
        end;
    end;
}