#pragma warning disable AA0247
table 14100 "CD Location Setup"
{
    Caption = 'CD Location Setup';
    LookupPageID = "CD Location Setup";

    fields
    {
        field(1; "Item Tracking Code"; Code[10])
        {
            Caption = 'Item Tracking Code';
            NotBlank = true;
            TableRelation = "Item Tracking Code";
        }
        field(2; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            NotBlank = true;
            TableRelation = Location;
        }
        field(3; Description; Text[50])
        {
            Caption = 'Description';
        }
        field(21; "CD Info. Must Exist"; Boolean)
        {
            Caption = 'CD Info. Must Exist';
        }
        field(23; "CD Sales Check on Release"; Boolean)
        {
            Caption = 'CD Sales Check on Release';
        }
        field(24; "CD Purchase Check on Release"; Boolean)
        {
            Caption = 'CD Purchase Check on Release';
        }
        field(25; "Allow Temporary CD Number"; Boolean)
        {
            Caption = 'Allow Temporary CD Number';
        }
    }

    keys
    {
        key(Key1; "Item Tracking Code", "Location Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        TestDelete();
    end;

    trigger OnInsert()
    begin
        TestInsert();
    end;

    var
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        CannotDeleteErr: Label 'You cannot delete setup because it is used on one or more items.';

    local procedure TestDelete()
    begin
        Item.Reset();
        Item.SetRange("Item Tracking Code", "Item Tracking Code");
        if Item.Find('-') then
            repeat
                ItemLedgerEntry.Reset();
                ItemLedgerEntry.SetCurrentKey("Item No.");
                ItemLedgerEntry.SetRange("Item No.", Item."No.");
                ItemLedgerEntry.SetRange("Location Code", "Location Code");
                if ItemLedgerEntry.FindFirst() then
                    Error(CannotDeleteErr);
            until Item.Next() = 0;
    end;

    local procedure TestInsert()
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        ItemTrackingCode.Get("Item Tracking Code");
        ItemTrackingCode.TestField("Package Specific Tracking");
    end;
}

