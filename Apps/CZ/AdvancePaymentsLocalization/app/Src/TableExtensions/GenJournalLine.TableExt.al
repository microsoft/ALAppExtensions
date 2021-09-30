tableextension 31004 "Gen. Journal Line CZZ" extends "Gen. Journal Line"
{
    fields
    {
        field(31010; "Advance Letter No. CZZ"; Code[20])
        {
            Caption = 'Advance Letter No.';
            DataClassification = CustomerContent;
            TableRelation = if ("Account Type" = const(Customer), "Document Type" = const(Payment)) "Sales Adv. Letter Header CZZ" where("Bill-to Customer No." = field("Account No."), "Currency Code" = field("Currency Code"), Status = const("To Pay")) else
            if ("Account Type" = const(Vendor), "Document Type" = const(Payment)) "Purch. Adv. Letter Header CZZ" where("Pay-to Vendor No." = field("Account No."), "Currency Code" = field("Currency Code"), Status = const("To Pay"));

            trigger OnValidate()
            var
                SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
            begin
                if "Advance Letter No. CZZ" <> '' then begin
                    TestField("Document Type", "Document Type"::Payment);
                    case "Account Type" of
                        "Account Type"::Customer:
                            begin
                                SalesAdvLetterHeaderCZZ.Get("Advance Letter No. CZZ");
                                SalesAdvLetterHeaderCZZ.TestField("Bill-to Customer No.", "Account No.");
                                SalesAdvLetterHeaderCZZ.TestField("Currency Code", "Currency Code");
                                if Amount = 0 then begin
                                    SalesAdvLetterHeaderCZZ.CalcFields("To Pay");
                                    Validate(Amount, -SalesAdvLetterHeaderCZZ."To Pay");
                                end;
                                Validate("Dimension Set ID", SalesAdvLetterHeaderCZZ."Dimension Set ID");
                            end;
                        "Account Type"::Vendor:
                            begin
                                PurchAdvLetterHeaderCZZ.Get("Advance Letter No. CZZ");
                                PurchAdvLetterHeaderCZZ.TestField("Pay-to Vendor No.", "Account No.");
                                PurchAdvLetterHeaderCZZ.TestField("Currency Code", "Currency Code");
                                if Amount = 0 then begin
                                    PurchAdvLetterHeaderCZZ.CalcFields("To Pay");
                                    Validate(Amount, PurchAdvLetterHeaderCZZ."To Pay");
                                end;
                                Validate("Dimension Set ID", PurchAdvLetterHeaderCZZ."Dimension Set ID");
                            end;
                        else
                            FieldError("Account Type");
                    end;
                end;
            end;

            trigger OnLookup()
            var
                SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
            begin
                TestField("Document Type", "Document Type"::Payment);
                if not ("Account Type" in ["Account Type"::Customer, "Account Type"::Vendor]) then
                    FieldError("Account Type");
                TestField("Account No.");

                case "Account Type" of
                    "Account Type"::Customer:
                        begin
                            SalesAdvLetterHeaderCZZ.FilterGroup(2);
                            SalesAdvLetterHeaderCZZ.SetRange("Bill-to Customer No.", "Account No.");
                            SalesAdvLetterHeaderCZZ.SetRange(Status, SalesAdvLetterHeaderCZZ.Status::"To Pay");
                            SalesAdvLetterHeaderCZZ.SetRange("Currency Code", "Currency Code");
                            SalesAdvLetterHeaderCZZ.FilterGroup(0);
                            if Page.RunModal(0, SalesAdvLetterHeaderCZZ) = Action::LookupOK then
                                Validate("Advance Letter No. CZZ", SalesAdvLetterHeaderCZZ."No.");
                        end;
                    "Account Type"::Vendor:
                        begin
                            PurchAdvLetterHeaderCZZ.FilterGroup(2);
                            PurchAdvLetterHeaderCZZ.SetRange("Pay-to Vendor No.", "Account No.");
                            PurchAdvLetterHeaderCZZ.SetRange(Status, PurchAdvLetterHeaderCZZ.Status::"To Pay");
                            PurchAdvLetterHeaderCZZ.SetRange("Currency Code", "Currency Code");
                            PurchAdvLetterHeaderCZZ.FilterGroup(0);
                            if Page.RunModal(0, PurchAdvLetterHeaderCZZ) = Action::LookupOK then
                                Validate("Advance Letter No. CZZ", PurchAdvLetterHeaderCZZ."No.");
                        end;
                end;
            end;
        }
        field(31011; "Adv. Letter No. (Entry) CZZ"; Code[20])
        {
            Caption = 'Advance Letter No. (Entry)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(31012; "Use Advance G/L Account CZZ"; Boolean)
        {
            Caption = 'Use Advance G/L Account';
            DataClassification = CustomerContent;
            Editable = false;
        }

        modify("Account No.")
        {
            trigger OnAfterValidate()
            begin
                if "Account No." <> xRec."Account No." then
                    Validate("Advance Letter No. CZZ", '');
            end;
        }
        modify("Currency Code")
        {
            trigger OnAfterValidate()
            begin
                if "Currency Code" <> xRec."Currency Code" then
                    Validate("Advance Letter No. CZZ", '');
            end;
        }
    }
}
