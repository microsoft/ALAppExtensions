table 4049 "GP Vendor Address"
{
    ReplicateData = false;
    Permissions = tabledata "Ship-to Address" = rim;

    fields
    {
        field(1; VENDORID; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(2; ADRSCODE; Text[15])
        {
            DataClassification = CustomerContent;
        }
        field(3; VNDCNTCT; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(4; ADDRESS1; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(5; ADDRESS2; Text[61])
        {
            DataClassification = CustomerContent;
        }
        field(7; CITY; Text[35])
        {
            DataClassification = CustomerContent;
        }
        field(8; STATE; Text[29])
        {
            DataClassification = CustomerContent;
        }
        field(9; ZIPCODE; Text[11])
        {
            DataClassification = CustomerContent;
        }
        field(12; PHNUMBR1; Text[21])
        {
            DataClassification = CustomerContent;
        }
        field(15; FAXNUMBR; Text[21])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; VENDORID, ADRSCODE)
        {
            Clustered = true;
        }
    }

    procedure MoveStagingData()
    var
        OrderAddress: Record "Order Address";
        Vendor: Record Vendor;
        Exists: Boolean;
    begin
        if Vendor.Get(VENDORID) then begin
            Exists := OrderAddress.Get(VENDORID, CopyStr(ADRSCODE, 1, 10));
            OrderAddress.Init();
            OrderAddress."Vendor No." := VENDORID;
            OrderAddress.Code := CopyStr(ADRSCODE, 1, 10);
            OrderAddress.Name := Vendor.Name;
            OrderAddress.Address := ADDRESS1;
            OrderAddress."Address 2" := CopyStr(ADDRESS2, 1, 50);
            OrderAddress.City := CopyStr(CITY, 1, 30);
            OrderAddress.Contact := VNDCNTCT;
            OrderAddress."Phone No." := PHNUMBR1;
            OrderAddress."Fax No." := FAXNUMBR;

            if (CopyStr(OrderAddress."Phone No.", 1, 14) = '00000000000000') then
                OrderAddress."Phone No." := '';

            if (CopyStr(OrderAddress."Fax No.", 1, 14) = '00000000000000') then
                OrderAddress."Fax No." := '';

            OrderAddress."Post Code" := ZIPCODE;
            OrderAddress.County := STATE;

            if not Exists then
                OrderAddress.Insert()
            else
                OrderAddress.Modify();
        end;
    end;
}