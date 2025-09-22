namespace Microsoft.DataMigration.GP;

using Microsoft.Sales.Customer;
using System.Email;

table 4048 "GP Customer Address"
{
    Permissions = tabledata "Ship-to Address" = rim;
    DataClassification = CustomerContent;
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
        GPSY01200: Record "GP SY01200";
        MailManagement: Codeunit "Mail Management";
        EmailAddress: Text[80];
        Exists: Boolean;
    begin
        if Customer.Get(Rec.CUSTNMBR) then begin
            Exists := ShipToAddress.Get(Rec.CUSTNMBR, CopyStr(Rec.ADRSCODE, 1, MaxStrLen(ShipToAddress.Code)));
            ShipToAddress.Init();
            ShipToAddress.Validate("Customer No.", Rec.CUSTNMBR);
            ShipToAddress.Code := CopyStr(Rec.ADRSCODE.TrimEnd(), 1, MaxStrLen(ShipToAddress.Code));
            ShipToAddress.Name := Customer.Name;
            ShipToAddress.Address := CopyStr(Rec.ADDRESS1.TrimEnd(), 1, MaxStrLen(ShipToAddress.Address));
            ShipToAddress."Address 2" := CopyStr(Rec.ADDRESS2.TrimEnd(), 1, MaxStrLen(ShipToAddress."Address 2"));
            ShipToAddress.City := CopyStr(Rec.CITY.TrimEnd(), 1, MaxStrLen(ShipToAddress.City));
            ShipToAddress.Contact := CopyStr(Rec.CNTCPRSN.TrimEnd(), 1, MaxStrLen(ShipToAddress.Contact));
            ShipToAddress."Phone No." := CopyStr(Rec.PHONE1.TrimEnd(), 1, MaxStrLen(ShipToAddress."Phone No."));
            ShipToAddress."Shipment Method Code" := CopyStr(Rec.SHIPMTHD.TrimEnd(), 1, MaxStrLen(ShipToAddress."Shipment Method Code"));
            ShipToAddress."Fax No." := CopyStr(Rec.FAX.TrimEnd(), 1, MaxStrLen(ShipToAddress."Fax No."));
            ShipToAddress."Post Code" := CopyStr(Rec.ZIP.TrimEnd(), 1, MaxStrLen(ShipToAddress."Post Code"));
            ShipToAddress.County := CopyStr(Rec.STATE.TrimEnd(), 1, MaxStrLen(ShipToAddress.County));
            ShipToAddress."Tax Area Code" := CopyStr(Rec.TAXSCHID.TrimEnd(), 1, MaxStrLen(ShipToAddress."Tax Area Code"));

            if (CopyStr(ShipToAddress."Phone No.", 1, 14) = '00000000000000') then
                ShipToAddress."Phone No." := '';

            if (CopyStr(ShipToAddress."Fax No.", 1, 14) = '00000000000000') then
                ShipToAddress."Fax No." := '';

            if GPSY01200.Get(CustomerEmailTypeCodeLbl, CUSTNMBR, ADRSCODE) then
                EmailAddress := CopyStr(GPSY01200.GetSingleEmailAddress(MaxStrLen(ShipToAddress."E-Mail")), 1, MaxStrLen(ShipToAddress."E-Mail"));

#pragma warning disable AA0139
            if MailManagement.ValidateEmailAddressField(EmailAddress) then
                ShipToAddress."E-Mail" := EmailAddress;
#pragma warning restore AA0139

            if not Exists then
                ShipToAddress.Insert()
            else
                ShipToAddress.Modify();
        end;
    end;

    var
        CustomerEmailTypeCodeLbl: Label 'CUS', Locked = true;
}