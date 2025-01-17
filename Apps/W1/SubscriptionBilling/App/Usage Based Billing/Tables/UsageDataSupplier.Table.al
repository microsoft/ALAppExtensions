namespace Microsoft.SubscriptionBilling;

using Microsoft.Purchases.Vendor;

table 8014 "Usage Data Supplier"
{
    Caption = 'Usage Data Supplier';
    DataClassification = CustomerContent;
    LookupPageId = "Usage Data Suppliers";
    DrillDownPageId = "Usage Data Suppliers";
    Access = Internal;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(2; Description; Text[80])
        {
            Caption = 'Description';
        }
        field(3; Type; Enum "Usage Data Supplier Type")
        {
            Caption = 'Type';
        }
        field(4; "Unit Price from Import"; Boolean)
        {
            Caption = 'Unit Price from Import';
        }
        field(5; "Vendor Invoice per"; Enum "Vendor Invoice Per")
        {
            Caption = 'Vendor Invoice per';
        }
        field(6; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                if "Vendor No." <> '' then begin
                    Vendor.Get("Vendor No.");
                    "Vendor Name" := Vendor.Name;
                end else
                    "Vendor Name" := '';
            end;
        }
        field(7; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            TableRelation = Vendor.Name;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                VendorName: Text;
            begin
                VendorName := "Vendor Name";
                LookupVendorName(VendorName);
                "Vendor Name" := CopyStr(VendorName, 1, MaxStrLen("Vendor Name"));
            end;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                if ShouldSearchForVendorByName("Vendor No.") then
                    Validate("Vendor No.", Vendor.GetVendorNo("Vendor Name"));
            end;

        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description)
        {
        }
    }

    trigger OnDelete()
    var
        UsageDataSupplierReference: Record "Usage Data Supplier Reference";
        GenericImportSettings: Record "Generic Import Settings";
    begin
        UsageDataSupplierReference.SetRange("Supplier No.", "No.");
        UsageDataSupplierReference.DeleteAll(false);

        GenericImportSettings.SetRange("Usage Data Supplier No.", "No.");
        GenericImportSettings.DeleteAll(false);
    end;

    internal procedure OpenSupplierSettings()
    var
        GenericImportSettings: Record "Generic Import Settings";
    begin
        case Rec.Type of
            Enum::"Usage Data Supplier Type"::Generic:
                begin
                    GenericImportSettings.FilterGroup(2);
                    GenericImportSettings.SetRange("Usage Data Supplier No.", Rec."No.");
                    GenericImportSettings.FilterGroup(0);
                    Page.RunModal(Page::"Generic Import Settings Card", GenericImportSettings);
                end;

        end;
    end;

    local procedure ShouldSearchForVendorByName(VendorNo: Code[20]): Boolean
    var
        Vendor: Record Vendor;
    begin
        if VendorNo = '' then
            exit(true);

        if not Vendor.Get(VendorNo) then
            exit(true);

        exit(not Vendor."Disable Search by Name");
    end;

    local procedure LookupVendorName(var VendorName: Text): Boolean
    var
        Vendor: Record Vendor;
        RecVariant: Variant;
        SearchVendorName: Text;
    begin
        SearchVendorName := VendorName;
        if "Vendor No." <> '' then
            Vendor.Get("Vendor No.");

        if LookupVendor(Vendor) then begin
            if Rec."Vendor Name" = Vendor.Name then
                VendorName := SearchVendorName
            else
                VendorName := Vendor.Name;
            "Vendor No." := Vendor."No.";
            RecVariant := Vendor;
            exit(true);
        end;
    end;

    local procedure LookupVendor(var Vendor: Record Vendor): Boolean
    var
        VendorLookup: Page "Vendor Lookup";
        Result: Boolean;
    begin
        VendorLookup.SetTableView(Vendor);
        VendorLookup.SetRecord(Vendor);
        VendorLookup.LookupMode := true;
        Result := VendorLookup.RunModal() = Action::LookupOK;
        if Result then
            VendorLookup.GetRecord(Vendor)
        else
            Clear(Vendor);

        exit(Result);
    end;
}
