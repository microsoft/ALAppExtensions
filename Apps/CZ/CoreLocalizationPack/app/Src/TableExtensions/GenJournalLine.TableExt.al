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
        field(11717; "Specific Symbol CZL"; Code[10])
        {
            Caption = 'Specific Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;
        }
        field(11718; "Variable Symbol CZL"; Code[10])
        {
            Caption = 'Variable Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;
        }
        field(11719; "Constant Symbol CZL"; Code[10])
        {
            Caption = 'Constant Symbol';
            CharAllowed = '09';
            TableRelation = "Constant Symbol CZL";
            DataClassification = CustomerContent;
        }
        field(11720; "Bank Account Code CZL"; Code[20])
        {
            Caption = 'Bank Account Code';
            TableRelation = if ("Account Type" = const(Customer), "Document Type" = filter(Payment | "Credit Memo"))
              "Customer Bank Account".Code where("Customer No." = field("Bill-to/Pay-to No.")) else
            if ("Account Type" = const(Customer), "Document Type" = filter(Refund | Invoice))
              "Bank Account" else
            if ("Bal. Account Type" = const(Customer), "Document Type" = filter(Payment | "Credit Memo"))
              "Customer Bank Account".Code where("Customer No." = field("Bill-to/Pay-to No.")) else
            if ("Bal. Account Type" = const(Customer), "Document Type" = filter(Refund | Invoice))
              "Bank Account" else
            if ("Account Type" = const(Vendor), "Document Type" = filter(Payment | "Credit Memo"))
              "Bank Account" else
            if ("Account Type" = const(Vendor), "Document Type" = filter(Refund | Invoice))
              "Vendor Bank Account".Code where("Vendor No." = field("Bill-to/Pay-to No.")) else
            if ("Bal. Account Type" = const(Vendor), "Document Type" = filter(Payment | "Credit Memo"))
              "Bank Account" else
            if ("Bal. Account Type" = const(Vendor), "Document Type" = filter(Refund | Invoice))
              "Vendor Bank Account".Code where("Vendor No." = field("Bill-to/Pay-to No."));
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BankAccount: Record "Bank Account";
                CustomerBankAccount: Record "Customer Bank Account";
                VendorBankAccount: Record "Vendor Bank Account";
                BankAccountCodeErr: Label 'Is not possible enter %1 for combination %2, %3 and %4.', Comment = '%1 = Bank Account Code FieldCaption, %2 = Account Type, %3 = Bal. Account Type FieldCaption, %4 = Document Type FieldCaption';
            begin
                if "Bank Account Code CZL" = '' then begin
                    UpdateBankInfoCZL('', '', '', '', '');
                    exit;
                end;
                case true of
                    ("Account Type" = "Account Type"::Customer) and
                    ("Document Type" in ["Document Type"::Refund, "Document Type"::Invoice]),
                    ("Bal. Account Type" = "Bal. Account Type"::Customer) and
                    ("Document Type" in ["Document Type"::Refund, "Document Type"::Invoice]),
                    ("Account Type" = "Account Type"::Vendor) and
                    ("Document Type" in ["Document Type"::Payment, "Document Type"::"Credit Memo"]),
                    ("Bal. Account Type" = "Bal. Account Type"::Vendor) and
                    ("Document Type" in ["Document Type"::Payment, "Document Type"::"Credit Memo"]):
                        begin
                            BankAccount.Get("Bank Account Code CZL");
                            UpdateBankInfoCZL(
                              BankAccount."No.",
                              BankAccount."Bank Account No.",
                              BankAccount."Transit No.",
                              BankAccount.IBAN,
                              BankAccount."SWIFT Code");
                        end;
                    ("Account Type" = "Account Type"::Customer) and
                    ("Document Type" in ["Document Type"::Payment, "Document Type"::"Credit Memo"]),
                    ("Bal. Account Type" = "Bal. Account Type"::Customer) and
                    ("Document Type" in ["Document Type"::Payment, "Document Type"::"Credit Memo"]):
                        begin
                            CustomerBankAccount.Get("Bill-to/Pay-to No.", "Bank Account Code CZL");
                            UpdateBankInfoCZL(
                              CustomerBankAccount.Code,
                              CustomerBankAccount."Bank Account No.",
                              CustomerBankAccount."Transit No.",
                              CustomerBankAccount.IBAN,
                              CustomerBankAccount."SWIFT Code");
                        end;
                    ("Account Type" = "Account Type"::Vendor) and
                    ("Document Type" in ["Document Type"::Refund, "Document Type"::Invoice]),
                    ("Bal. Account Type" = "Bal. Account Type"::Vendor) and
                    ("Document Type" in ["Document Type"::Refund, "Document Type"::Invoice]):
                        begin
                            VendorBankAccount.Get("Bill-to/Pay-to No.", "Bank Account Code CZL");
                            UpdateBankInfoCZL(
                              VendorBankAccount.Code,
                              VendorBankAccount."Bank Account No.",
                              VendorBankAccount."Transit No.",
                              VendorBankAccount.IBAN,
                              VendorBankAccount."SWIFT Code");
                        end
                    else
                        Error(BankAccountCodeErr, FieldCaption("Bank Account Code CZL"), "Account Type",
                                FieldCaption("Bal. Account Type"), FieldCaption("Document Type"));
                end;
            end;
        }
        field(11721; "Bank Account No. CZL"; Text[30])
        {
            Caption = 'Bank Account No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11724; "Transit No. CZL"; Text[20])
        {
            Caption = 'Transit No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11725; "IBAN CZL"; Code[50])
        {
            Caption = 'IBAN';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11726; "SWIFT Code CZL"; Code[20])
        {
            Caption = 'SWIFT Code';
            Editable = false;
            TableRelation = "SWIFT Code";
            DataClassification = CustomerContent;
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
        field(31115; "From Adjustment CZL"; Boolean)
        {
            Caption = 'From Adjustment';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    procedure AdjustDebitCreditCZL(Invert: Boolean)
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get("Account No.");
        if GLAccount."Debit/Credit" = GLAccount."Debit/Credit"::Both then
            exit;
        if Invert then
            if GLAccount."Debit/Credit" = GLAccount."Debit/Credit"::Debit then
                GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Credit
            else
                GLAccount."Debit/Credit" := GLAccount."Debit/Credit"::Debit;
        case GLAccount."Debit/Credit" of
            GLAccount."Debit/Credit"::Debit:
                if "Credit Amount" <> 0 then
                    Validate("Debit Amount", -"Credit Amount");
            GLAccount."Debit/Credit"::Credit:
                if "Debit Amount" <> 0 then
                    Validate("Credit Amount", -"Debit Amount");
        end;
    end;

    local procedure UpdateBankInfoCZL(BankAccountCode: Code[20]; BankAccountNo: Text[30]; TransitNo: Text[20]; IBANCode: Code[50]; SWIFTCode: Code[20])
    begin
        "Bank Account Code CZL" := BankAccountCode;
        "Bank Account No. CZL" := BankAccountNo;
        "Transit No. CZL" := TransitNo;
        "IBAN CZL" := IBANCode;
        "SWIFT Code CZL" := SWIFTCode;
        OnAfterUpdateBankInfoCZL(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateBankInfoCZL(var GenJournalLine: Record "Gen. Journal Line")
    begin
    end;
}
