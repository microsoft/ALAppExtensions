#pragma warning disable AA0247
table 14102 "CD FA Information"
{
    Caption = 'CD FA Information';
    DataCaptionFields = "FA No.", "CD No.", Description;
    LookupPageID = "CD FA Information List";

    fields
    {
        field(1; "FA No."; Code[20])
        {
            Caption = 'FA No.';
            NotBlank = true;
            TableRelation = "Fixed Asset";

            trigger OnValidate()
            var
                FA: Record "Fixed Asset";
            begin
                FA.Get("FA No.");
                Description := FA.Description;
                Validate("CD Header Number");
            end;
        }
        field(3; "CD No."; Code[50])
        {
            Caption = 'Package No.';
            NotBlank = true;

            trigger OnValidate()
            begin
                InventorySetup.Get();
                if InventorySetup."Check CD Number Format" then
                    "Temporary CD No." := not CDNumberFormat.Check("CD No.", false);
            end;
        }
        field(5; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            TableRelation = "Country/Region";
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(9; "CD Header Number"; Code[30])
        {
            Caption = 'CD Header Number';
            TableRelation = "CD Number Header";

            trigger OnValidate()
            begin
                if "CD Header Number" <> '' then begin
                    CDNumberHeader.Get("CD Header Number");
                    if CDNumberHeader."Country/Region of Origin Code" <> '' then
                        "Country/Region Code" := CDNumberHeader."Country/Region of Origin Code";
                end;
            end;
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(11; "Temporary CD No."; Boolean)
        {
            Caption = 'Temporary CD No.';

            trigger OnValidate()
            begin
                if not "Temporary CD No." then
                    CDNumberFormat.Check("CD No.", true);
            end;
        }
        field(12; "Certificate Number"; Code[20])
        {
            Caption = 'Certificate Number';
        }
        field(13; Blocked; Boolean)
        {
            Caption = 'Blocked';
        }
        field(21; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(22; "Location Filter"; Code[10])
        {
            Caption = 'Location Filter';
            FieldClass = FlowFilter;
            TableRelation = Location;
        }
    }

    keys
    {
        key(Key1; "FA No.", "CD No.")
        {
            Clustered = true;
        }
        key(Key2; "CD No.")
        {
            Enabled = false;
        }
        key(Key3; "CD Header Number", "CD No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
    end;

    var
        CDNumberFormat: Record "CD Number Format";
        CDNumberHeader: Record "CD Number Header";
        InventorySetup: Record "Inventory Setup";

    [Scope('OnPrem')]
    procedure GetCountryName(): Text[50]
    var
        CountryRegion: Record "Country/Region";
    begin
        if not CountryRegion.Get("Country/Region Code") then
            exit('');

        if CountryRegion."Local Name" <> '' then
            exit(CountryRegion."Local Name");

        exit(CountryRegion.Name);
    end;

    [Scope('OnPrem')]
    procedure GetCountryLocalCode(): Code[10]
    var
        CountryRegion: Record "Country/Region";
    begin
        if not CountryRegion.Get("Country/Region Code") then
            exit('');

        if CountryRegion."Local Country/Region Code" <> '' then
            exit(CountryRegion."Local Country/Region Code");

        exit('');
    end;
}

