table 11513 "Swiss QR-Bill Layout"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; "IBAN Type"; Enum "Swiss QR-Bill IBAN Type")
        {
            Caption = 'IBAN Type';

            trigger OnValidate()
            begin
                ValidateIBANType("IBAN Type");
            end;
        }
        field(4; "Unstr. Message"; Text[140])
        {
            Caption = 'Unstructured Message';
        }
        field(5; "Billing Information"; Code[20])
        {
            Caption = 'Billing Information';
            TableRelation = "Swiss QR-Bill Billing Info";
        }
        field(6; "Payment Reference Type"; Enum "Swiss QR-Bill Payment Reference Type")
        {
            Caption = 'Reference Type';

            trigger OnValidate()
            begin
                case "Payment Reference Type" of
                    "Payment Reference Type"::"Creditor Reference (ISO 11649)":
                        TestField("IBAN Type", "IBAN Type"::IBAN);
                    "Payment Reference Type"::"QR Reference":
                        TestField("IBAN Type", "IBAN Type"::"QR-IBAN");
                end;
            end;
        }
        field(7; "Alt. Procedure Name 1"; Text[10])
        {
            Caption = 'Alternate Procedure Name 1';

            trigger OnValidate()
            begin
                if "Alt. Procedure Name 1" = '' then
                    "Alt. Procedure Value 1" := '';
            end;
        }
        field(8; "Alt. Procedure Value 1"; Text[100])
        {
            Caption = 'Alternate Procedure Value 1';
        }
        field(9; "Alt. Procedure Name 2"; Text[10])
        {
            Caption = 'Alternate Procedure Name 2';

            trigger OnValidate()
            begin
                if "Alt. Procedure Name 2" = '' then
                    "Alt. Procedure Value 2" := '';
            end;
        }
        field(10; "Alt. Procedure Value 2"; Text[100])
        {
            Caption = 'Alternate Procedure Value 2';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    local procedure ValidateIBANType(NewIBANType: Enum "Swiss QR-Bill IBAN Type")
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        case NewIBANType of
            "IBAN Type"::IBAN:
                begin
                    CompanyInformation.TestField(IBAN);
                    "Payment Reference Type" := "Payment Reference Type"::"Creditor Reference (ISO 11649)";
                end;
            "IBAN Type"::"QR-IBAN":
                begin
                    CompanyInformation.TestField("Swiss QR-Bill IBAN");
                    "Payment Reference Type" := "Payment Reference Type"::"QR Reference";
                end;
        end;
    end;
}
