tableextension 11723 "Gen. Journal Line CZL" extends "Gen. Journal Line"
{
    fields
    {
        field(11712; "VAT Delay CZL"; Boolean)
        {
            Caption = 'VAT Delay';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11776; "VAT Currency Factor CZL"; Decimal)
        {
            Caption = 'VAT Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 15;
            Editable = false;
            MinValue = 0;
        }
        field(11777; "VAT Currency Code CZL"; Code[10])
        {
            Caption = 'VAT Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
        }
        field(11780; "VAT Date CZL"; Date)
        {
            Caption = 'VAT Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                GLSetup: Record "General Ledger Setup";
            begin
                GLSetup.Get();
                if not GLSetup."Use VAT Date CZL" then
                    if CurrFieldNo = FieldNo("VAT Date CZL") then
                        TestField("VAT Date CZL", "Posting Date");
                "Original Doc. VAT Date CZL" := "VAT Date CZL";
            end;
        }
        field(11781; "Registration No. CZL"; Text[20])
        {
            Caption = 'Registration No.';
            DataClassification = CustomerContent;
        }
        field(11782; "Tax Registration No. CZL"; Text[20])
        {
            Caption = 'Tax Registration No.';
            DataClassification = CustomerContent;
        }
        field(31072; "EU 3-Party Intermed. Role CZL"; Boolean)
        {
            Caption = 'EU 3-Party Intermediate Role';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "EU 3-Party Intermed. Role CZL" then
                    "EU 3-Party Trade" := true;
            end;
        }
        field(31110; "Original Doc. Partner Type CZL"; Option)
        {
            Caption = 'Original Document Partner Type';
            OptionCaption = ' ,Customer,Vendor';
            OptionMembers = " ",Customer,Vendor;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Original Doc. Partner Type CZL" <> "Original Doc. Partner Type CZL"::" " then begin
                    TestField("Account Type", "Account Type"::"G/L Account".AsInteger());
                    TestField("Bal. Account Type", "Bal. Account Type"::"G/L Account".AsInteger());
                end;
                if ("Account Type" = "Account Type"::"G/L Account") and ("Bal. Account Type" = "Bal. Account Type"::"G/L Account")
                then begin
                    Validate("Country/Region Code", '');
                    Validate("VAT Registration No.", '');
                end;
                "Original Doc. Partner No. CZL" := '';
            end;
        }
        field(31111; "Original Doc. Partner No. CZL"; Code[20])
        {
            Caption = 'Original Document Partner No.';
            TableRelation = if ("Original Doc. Partner Type CZL" = const(Customer)) Customer else
            if ("Original Doc. Partner Type CZL" = const(Vendor)) Vendor;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Cust: Record Customer;
                Vend: Record Vendor;
            begin
                TestField("Original Doc. Partner Type CZL");
                if "Original Doc. Partner No. CZL" <> '' then
                    case "Original Doc. Partner Type CZL" of
                        "Original Doc. Partner Type CZL"::Customer:
                            begin
                                Cust.Get("Original Doc. Partner No. CZL");
                                Validate("Country/Region Code", Cust."Country/Region Code");
                                Validate("VAT Registration No.", Cust."VAT Registration No.");
                            end;
                        "Original Doc. Partner Type CZL"::Vendor:
                            begin
                                Vend.Get("Original Doc. Partner No. CZL");
                                Validate("Country/Region Code", Vend."Country/Region Code");
                                Validate("VAT Registration No.", Vend."VAT Registration No.");
                            end;
                    end
                else begin
                    Validate("Country/Region Code", '');
                    Validate("VAT Registration No.", '');
                end;
            end;
        }
        field(31112; "Original Doc. VAT Date CZL"; Date)
        {
            Caption = 'Original Document VAT Date';
            DataClassification = CustomerContent;
        }
    }

    procedure AdjustDebitCreditCZL(Invert: Boolean)
    var
        GLAcc: Record "G/L Account";
    begin
        GLAcc.Get("Account No.");
        if GLAcc."Debit/Credit" = GLAcc."Debit/Credit"::Both then
            exit;
        if Invert then
            if GLAcc."Debit/Credit" = GLAcc."Debit/Credit"::Debit then
                GLAcc."Debit/Credit" := GLAcc."Debit/Credit"::Credit
            else
                GLAcc."Debit/Credit" := GLAcc."Debit/Credit"::Debit;
        case GLAcc."Debit/Credit" of
            GLAcc."Debit/Credit"::Debit:
                if "Credit Amount" <> 0 then
                    Validate("Debit Amount", -"Credit Amount");
            GLAcc."Debit/Credit"::Credit:
                if "Debit Amount" <> 0 then
                    Validate("Credit Amount", -"Debit Amount");
        end;
    end;
}
