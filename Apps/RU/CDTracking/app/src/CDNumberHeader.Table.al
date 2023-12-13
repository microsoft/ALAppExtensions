table 14104 "CD Number Header"
{
    Caption = 'CD Number Header';
    LookupPageID = "Customs Declarations";

    fields
    {
        field(1; "No."; Code[30])
        {
            Caption = 'No.';
            NotBlank = true;
        }
        field(3; "Country/Region of Origin Code"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";

            trigger OnValidate()
            begin
                PackageNoInformation.Reset();
                PackageNoInformation.SetRange("CD Header Number", "No.");
                if not PackageNoInformation.IsEmpty() then
                    if Confirm(ChangeLinesQst, true) then
                        PackageNoInformation.ModifyAll("Country/Region Code", "Country/Region of Origin Code");
            end;
        }
        field(4; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "Declaration Date"; Date)
        {
            Caption = 'Declaration Date';
            DataClassification = CustomerContent;
        }
        field(7; "Source Type"; Option)
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Customer,Vendor,Item';
            OptionMembers = " ",Customer,Vendor,Item;
        }
        field(8; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Source Type" = CONST(Customer)) Customer
            ELSE
            IF ("Source Type" = CONST(Vendor)) Vendor
            ELSE
            IF ("Source Type" = CONST(Item)) Item;

            trigger OnValidate()
            var
                Customer: Record Customer;
                Vendor: Record Vendor;
            begin
                case "Source Type" of
                    "Source Type"::Customer:
                        begin
                            Customer.Get("Source No.");
                            Validate("Country/Region of Origin Code", Customer."Country/Region Code");
                        end;
                    "Source Type"::Vendor:
                        begin
                            Vendor.Get("Source No.");
                            Validate("Country/Region of Origin Code", Vendor."Country/Region Code");
                        end;
                end;
            end;
        }
        field(12; Comment; Boolean)
        {
            CalcFormula = Exist("Purch. Comment Line" WHERE("Document Type" = CONST("Custom Declaration"),
                                                             "No." = FIELD("No.")));
            Caption = 'Comment';
            Editable = false;
            FieldClass = FlowField;
        }
        field(17; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", "Declaration Date", "Source Type", "Source No.", "Country/Region of Origin Code")
        {
        }
    }

    trigger OnInsert()
    begin
    end;

    trigger OnDelete()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.Reset();
        ItemLedgerEntry.SetCurrentKey("Package No.");
        ItemLedgerEntry.SetRange("Package No.", "No.");
        if not ItemLedgerEntry.IsEmpty() then
            Error(CannotDeleteErr, "No.");

        PackageNoInformation.Reset();
        PackageNoInformation.SetRange("CD Header Number", "No.");
        PackageNoInformation.DeleteAll(true);
    end;

    trigger OnRename()
    begin
        PackageNoInformation.Reset();
        PackageNoInformation.SetRange("CD Header Number", xRec."No.");
        if PackageNoInformation.FindFirst() then
            Error(CannotRenameErr, xRec."No.");
    end;

    var
        PackageNoInformation: Record "Package No. Information";
        CannotRenameErr: Label 'You cannot rename Custom Declaration %1.', Comment = '%1 - custom declaration number';
        ChangeLinesQst: Label 'You have changed the header. Do you want to change lines?';
        CannotDeleteErr: Label 'You cannot delete Custom Declaration %1.', Comment = '%1 - custom declaration number';
}

