table 31003 "Advance Letter Template CZZ"
{
    Caption = 'Advance Letter Template';
    DataClassification = CustomerContent;
    LookupPageId = "Advance Letter Templates CZZ";

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Sales/Purchase"; Enum "Advance Letter Type CZZ")
        {
            Caption = 'Sales/Purchase';
            DataClassification = CustomerContent;
        }
        field(5; "Advance Letter G/L Account"; Code[20])
        {
            Caption = 'Advance Letter G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";

            trigger OnValidate()
            var
                SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
                PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
                ChangeAccountQst: Label 'Do you really want to change G/L Account although letters with status "To Use" exist?';
            begin
                if "Advance Letter G/L Account" = xRec."Advance Letter G/L Account" then
                    exit;

                case "Sales/Purchase" of
                    "Sales/Purchase"::Sales:
                        begin
                            SalesAdvLetterHeaderCZZ.SetCurrentKey("Bill-to Customer No.", Status);
                            SalesAdvLetterHeaderCZZ.SetRange(Status, PurchAdvLetterHeaderCZZ.Status::"To Use");
                            SalesAdvLetterHeaderCZZ.SetRange("Advance Letter Code", Rec.Code);
                            if not SalesAdvLetterHeaderCZZ.IsEmpty() then
                                if not ConfirmManagement.GetResponse(ChangeAccountQst, false) then
                                    Error('');
                        end;
                    "Sales/Purchase"::Purchase:
                        begin
                            PurchAdvLetterHeaderCZZ.SetCurrentKey("Pay-to Vendor No.", Status);
                            PurchAdvLetterHeaderCZZ.SetRange(Status, PurchAdvLetterHeaderCZZ.Status::"To Use");
                            PurchAdvLetterHeaderCZZ.SetRange("Advance Letter Code", Rec.Code);
                            if not PurchAdvLetterHeaderCZZ.IsEmpty() then
                                if not ConfirmManagement.GetResponse(ChangeAccountQst, false) then
                                    Error('');
                        end;
                end;
                GLAccountCategoryMgt.CheckGLAccountWithoutCategory("Advance Letter G/L Account", false, false);
            end;

            trigger OnLookup()
            begin
                GLAccountCategoryMgt.LookupGLAccountWithoutCategory("Advance Letter G/L Account");
            end;
        }
        field(8; "Advance Letter Document Nos."; Code[20])
        {
            Caption = 'Advance Letter Document Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(10; "Advance Letter Invoice Nos."; Code[20])
        {
            Caption = 'Advance Letter Invoice Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(11; "Advance Letter Cr. Memo Nos."; Code[20])
        {
            Caption = 'Advance Letter Cr. Memo Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(13; "VAT Bus. Posting Group"; Code[20])
        {
            Caption = 'VAT Bus. Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group";
        }
        field(15; "Document Report ID"; Integer)
        {
            Caption = 'Document Report ID';
            DataClassification = CustomerContent;
            BlankZero = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));
            trigger OnValidate()
            begin
                CalcFields("Document Report Caption");
            end;
        }
        field(16; "Document Report Caption"; Text[249])
        {
            Caption = 'Document Report Caption';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Report), "Object ID" = field("Document Report ID")));
        }
        field(18; "Invoice/Cr. Memo Report ID"; Integer)
        {
            Caption = 'Invoice/Cr. Memo Report ID';
            DataClassification = CustomerContent;
            BlankZero = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Report));
            trigger OnValidate()
            begin
                CalcFields("Invoice/Cr. Memo Rep. Caption");
            end;
        }
        field(19; "Invoice/Cr. Memo Rep. Caption"; Text[249])
        {
            Caption = 'Invoice/Cr. Memo Report Caption';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Report), "Object ID" = field("Invoice/Cr. Memo Report ID")));
        }
        field(25; "Automatic Post VAT Document"; Boolean)
        {
            Caption = 'Automatic Post VAT Document';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    var
        GLAccountCategoryMgt: Codeunit "G/L Account Category Mgt.";
        ConfirmManagement: Codeunit "Confirm Management";
}
