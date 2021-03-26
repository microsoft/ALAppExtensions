#pragma warning disable AA0232
tableextension 11705 "Purchase Header CZL" extends "Purchase Header"
{
    fields
    {
        field(11717; "Specific Symbol CZL"; Code[10])
        {
            Caption = 'Specific Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
            end;
        }
        field(11718; "Variable Symbol CZL"; Code[10])
        {
            Caption = 'Variable Symbol';
            CharAllowed = '09';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
            end;
        }
        field(11719; "Constant Symbol CZL"; Code[10])
        {
            Caption = 'Constant Symbol';
            CharAllowed = '09';
            TableRelation = "Constant Symbol CZL";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField(Status, Status::Open);
            end;
        }
        field(11720; "Bank Account Code CZL"; Code[20])
        {
            Caption = 'Bank Account Code';
            TableRelation = if ("Document Type" = filter(Quote | Order | Invoice | "Blanket Order")) "Vendor Bank Account".Code where("Vendor No." = field("Pay-to Vendor No.")) else
            if ("Document Type" = filter("Credit Memo" | "Return Order")) "Bank Account";
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                VendorBankAccount: Record "Vendor Bank Account";
                BankAccount: Record "Bank Account";
            begin
                TestField(Status, Status::Open);
                if "Bank Account Code CZL" = '' then begin
                    UpdateBankInfoCZL('', '', '', '', '', '', '');
                    exit;
                end;
                case "Document Type" of
                    "Document Type"::Quote, "Document Type"::Order,
                    "Document Type"::Invoice, "Document Type"::"Blanket Order":
                        begin
                            TestField("Pay-to Vendor No.");
                            VendorBankAccount.Get("Pay-to Vendor No.", "Bank Account Code CZL");
                            UpdateBankInfoCZL(
                              VendorBankAccount.Code,
                              VendorBankAccount."Bank Account No.",
                              VendorBankAccount."Bank Branch No.",
                              VendorBankAccount.Name,
                              VendorBankAccount."Transit No.",
                              VendorBankAccount.IBAN,
                              VendorBankAccount."SWIFT Code");
                        end;
                    "Document Type"::"Credit Memo", "Document Type"::"Return Order":
                        begin
                            BankAccount.Get("Bank Account Code CZL");
                            UpdateBankInfoCZL(
                              BankAccount."No.",
                              BankAccount."Bank Account No.",
                              BankAccount."Bank Branch No.",
                              BankAccount.Name,
                              BankAccount."Transit No.",
                              BankAccount.IBAN,
                              BankAccount."SWIFT Code");
                        end;
                end;
            end;
        }
        field(11721; "Bank Account No. CZL"; Text[30])
        {
            Caption = 'Bank Account No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11722; "Bank Branch No. CZL"; Text[20])
        {
            Caption = 'Bank Branch No.';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(11723; "Bank Name CZL"; Text[100])
        {
            Caption = 'Bank Name';
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
        field(11774; "VAT Currency Factor CZL"; Decimal)
        {
            Caption = 'VAT Currency Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 15;
            MinValue = 0;

            trigger OnValidate()
            begin
                TestField("Currency Code");
            end;
        }
        field(11775; "VAT Currency Code CZL"; Code[10])
        {
            Caption = 'VAT Currency Code';
            DataClassification = CustomerContent;
            TableRelation = Currency;
            Editable = false;

            trigger OnValidate()
            begin
                TestField("VAT Currency Code CZL", "Currency Code");
            end;
        }
        field(11767; "Last Unreliab. Check Date CZL"; Date)
        {
            CalcFormula = max("Unreliable Payer Entry CZL"."Check Date" where("VAT Registration No." = field("VAT Registration No."),
                                                                            "Entry Type" = const(Payer)));
            Caption = 'Last Unreliability Check Date';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11768; "VAT Unreliable Payer CZL"; Option)
        {
            CalcFormula = lookup("Unreliable Payer Entry CZL"."Unreliable Payer" where("VAT Registration No." = field("VAT Registration No."),
                                                                                        "Entry Type" = const(Payer),
                                                                                        "Check Date" = field("Last Unreliab. Check Date CZL")));
            Caption = 'VAT Unreliable Payer';
            Editable = false;
            FieldClass = FlowField;
            OptionCaption = ' ,NO,YES,NOTFOUND';
            OptionMembers = " ",NO,YES,NOTFOUND;
        }
        field(11779; "Third Party Bank Account CZL"; Boolean)
        {
            CalcFormula = lookup("Vendor Bank Account"."Third Party Bank Account CZL" where("Vendor No." = field("Pay-to Vendor No."),
                                                                                            Code = field("Bank Account Code CZL")));
            Caption = 'Third Party Bank Account';
            Editable = false;
            FieldClass = FlowField;
        }
        field(11780; "VAT Date CZL"; Date)
        {
            Caption = 'VAT Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                GLSetup: Record "General Ledger Setup";
                PurchaseSetup: Record "Purchases & Payables Setup";
            begin
                GLSetup.Get();
                if not GLSetup."Use VAT Date CZL" then
                    TestField("VAT Date CZL", "Posting Date");
                CheckCurrencyExchangeRateCZL("VAT Date CZL");
                PurchaseSetup.Get();
                if PurchaseSetup."Def. Orig. Doc. VAT Date CZL" = PurchaseSetup."Def. Orig. Doc. VAT Date CZL"::"VAT Date" then
                    Validate("Original Doc. VAT Date CZL", "VAT Date CZL");
                if "Currency Code" <> '' then
                    VATDateUpdateVATCurrencyFactorCZL();
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
        field(31068; "Physical Transfer CZL"; Boolean)
        {
            Caption = 'Physical Transfer';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Physical Transfer CZL" then
                    if not ("Document Type" in ["Document Type"::"Credit Memo", "Document Type"::"Return Order"]) then
                        FieldError("Document Type");
                UpdatePurchLinesByFieldNo(FieldNo("Physical Transfer CZL"), CurrFieldNo <> 0);
            end;
        }
        field(31069; "Intrastat Exclude CZL"; Boolean)
        {
            Caption = 'Intrastat Exclude';
            DataClassification = CustomerContent;
        }
        field(31072; "EU 3-Party Intermed. Role CZL"; Boolean)
        {
            Caption = 'EU 3-Party Intermediate Role';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "EU 3-Party Intermed. Role CZL" then
                    "EU 3-Party Trade CZL" := true;
            end;
        }
        field(31073; "EU 3-Party Trade CZL"; Boolean)
        {
            Caption = 'EU 3-Party Trade';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if not "EU 3-Party Trade CZL" then
                    "EU 3-Party Intermed. Role CZL" := false;
            end;
        }
        field(31112; "Original Doc. VAT Date CZL"; Date)
        {
            Caption = 'Original Document VAT Date';
            DataClassification = CustomerContent;
        }
    }

    var
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
        ConfirmManagement: Codeunit "Confirm Management";
        GlobalDocumentType: Enum "Purchase Document Type";
        GlobalDocumentNo: Code[20];
        GlobalIsIntrastatTransaction: Boolean;

    procedure IsUnreliablePayerCheckPossibleCZL(): Boolean
    var
        Vendor: Record Vendor;
        CheckPossible: Boolean;
    begin
        if not Vendor.Get("Pay-to Vendor No.") then
            exit(false);
        CheckPossible := not Vendor."Disable Unreliab. Check CZL" and
                            UnreliablePayerMgtCZL.IsVATRegNoExportPossible("VAT Registration No.", "Pay-to Country/Region Code");
        OnBeforeIsUnreliablePayerCheckPossibleCZL(Rec, CheckPossible);
        exit(CheckPossible);
    end;

    procedure GetUnreliablePayerStatusCZL(): Integer
    var
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
    begin
        UnreliablePayerEntryCZL.SetCurrentKey("VAT Registration No.");
        UnreliablePayerEntryCZL.SetRange("VAT Registration No.", "VAT Registration No.");
        UnreliablePayerEntryCZL.SetRange("Entry Type", UnreliablePayerEntryCZL."Entry Type"::Payer);
        if not UnreliablePayerEntryCZL.FindLast() then
            exit(UnreliablePayerEntryCZL."Unreliable Payer"::NOTFOUND);
        exit(UnreliablePayerEntryCZL."Unreliable Payer");
    end;

    procedure IsPublicBankAccountCZL(): Boolean
    begin
        exit(UnreliablePayerMgtCZL.IsPublicBankAccount("Pay-To Vendor No.", "VAT Registration No.", "Bank Account No. CZL", "IBAN CZL"));
    end;

    local procedure CheckCurrencyExchangeRateCZL(CurrencyDate: Date)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        CurrExchRateNotExistsErr: Label '%1 does not exist for currency %2 and date %3.', Comment = '%1 = CurrExchRate.TableCaption, %2 = Currency Code, %3 = Date';
    begin
        if "Currency Code" = '' then
            exit;
        CurrencyExchangeRate.SetRange("Currency Code", "Currency Code");
        CurrencyExchangeRate.SetRange("Starting Date", 0D, CurrencyDate);
        if CurrencyExchangeRate.IsEmpty() then
            Error(CurrExchRateNotExistsErr)
    end;

    procedure UpdateVATCurrencyFactorCZL()
    var
        UpdateChangedFieldQst: Label 'You have changed %1. Do you want to update %2?', Comment = '%1 = field caption, %2 = field caption';
    begin
        if "Currency Code" = '' then begin
            "VAT Currency Factor CZL" := 0;
            exit;
        end;

        if ("Currency Factor" <> xRec."Currency Factor") and ("Currency Factor" <> "VAT Currency Factor CZL") and
           (("VAT Date CZL" = xRec."VAT Date CZL") or (xRec."VAT Date CZL" = 0D)) then begin
            if (xRec."Currency Factor" = "VAT Currency Factor CZL") or (xRec."Currency Factor" = 0) or HideValidationDialog then begin
                Validate("VAT Currency Factor CZL", "Currency Factor");
                exit;
            end;
            if ConfirmManagement.GetResponseOrDefault(StrSubstNo(UpdateChangedFieldQst, FieldCaption("Currency Factor"), FieldCaption("VAT Currency Factor CZL")), true) then
                Validate("VAT Currency Factor CZL", "Currency Factor");
        end
    end;

    local procedure VATDateUpdateVATCurrencyFactorCZL()
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        VATCurrencyFactor: Decimal;
        UpdateChangedFieldQst: Label 'You have changed %1. Do you want to update %2?', Comment = '%1 = field caption, %2 = field caption';
    begin
        if ("VAT Currency Code CZL" <> '') and ("Currency Factor" = xRec."Currency Factor") and (xRec."Currency Factor" <> 0) then begin
            VATCurrencyFactor := CurrencyExchangeRate.ExchangeRate("VAT Date CZL", "VAT Currency Code CZL");
            if "VAT Currency Factor CZL" <> VATCurrencyFactor then
                if ConfirmManagement.GetResponseOrDefault(StrSubstNo(UpdateChangedFieldQst, FieldCaption("VAT Date CZL"), FieldCaption("VAT Currency Factor CZL")), true) then
                    Validate("VAT Currency Factor CZL", VATCurrencyFactor);
        end;
    end;

    procedure UpdateBankInfoCZL(BankAccountCode: Code[20]; BankAccountNo: Text[30]; BankBranchNo: Text[20]; BankName: Text[100]; TransitNo: Text[20]; IBANCode: Code[50]; SWIFTCode: Code[20])
    begin
        "Bank Account Code CZL" := BankAccountCode;
        "Bank Account No. CZL" := BankAccountNo;
        "Bank Branch No. CZL" := BankBranchNo;
        "Bank Name CZL" := BankName;
        "Transit No. CZL" := TransitNo;
        "IBAN CZL" := IBANCode;
        "SWIFT Code CZL" := SWIFTCode;
        OnAfterUpdateBankInfoCZL(Rec);
    end;

    procedure CheckIntrastatMandatoryFieldsCZL()
    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
    begin
        if not (Ship or Receive) then
            exit;
        if IsIntrastatTransactionCZL() and ShipOrReceiveInventoriableTypeItems() then begin
            StatutoryReportingSetupCZL.Get();
            if StatutoryReportingSetupCZL."Transaction Type Mandatory" then
                TestField("Transaction Type");
            if StatutoryReportingSetupCZL."Transaction Spec. Mandatory" then
                TestField("Transaction Specification");
            if StatutoryReportingSetupCZL."Transport Method Mandatory" then
                TestField("Transport Method");
            if StatutoryReportingSetupCZL."Shipment Method Mandatory" then
                TestField("Shipment Method Code");
        end;
    end;

    procedure IsIntrastatTransactionCZL(): Boolean
    begin
        if ("Document Type" <> GlobalDocumentType) or ("No." <> GlobalDocumentNo) or ("No." = '') then begin
            GlobalDocumentType := "Document Type";
            GlobalDocumentNo := "No.";
            GlobalIsIntrastatTransaction := UpdateGlobalIsIntrastatTransaction();
        end;
        exit(GlobalIsIntrastatTransaction);
    end;

    local procedure UpdateGlobalIsIntrastatTransaction(): Boolean
    var
        CountryRegion: Record "Country/Region";
    begin
        if "EU 3-Party Intermed. Role CZL" then
            exit(false);
        if "Intrastat Exclude CZL" then
            exit(false);
        if IsCreditDocType() then
            exit(CountryRegion.IsIntrastatCZL("VAT Country/Region Code", true));
        if "VAT Country/Region Code" = "Ship-to Country/Region Code" then
            exit(false);
        if CountryRegion.IsLocalCountryCZL("Ship-to Country/Region Code", true) then
            exit(CountryRegion.IsIntrastatCZL("VAT Country/Region Code", true));
        exit(CountryRegion.IsIntrastatCZL("Ship-to Country/Region Code", true));
    end;

    [Obsolete('This procedure will be removed after removing feature from Base Application.', '17.0')]
    procedure CopyRecCurrencyFactortoxRecCurrencyFactor(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header")
    begin
        xRec."Currency Factor" := Rec."Currency Factor";
    end;

    [Obsolete('This procedure will be removed after removing feature from Base Application.', '17.0')]
    procedure IsCurrentFieldNoDiffZero(CurrFieldNo: Integer): Boolean
    begin
        exit(CurrFieldNo <> 0);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeIsUnreliablePayerCheckPossibleCZL(var PurchaseHeader: Record "Purchase Header"; var CheckPossible: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterUpdateBankInfoCZL(var PurchaseHeader: Record "Purchase Header")
    begin
    end;
}
