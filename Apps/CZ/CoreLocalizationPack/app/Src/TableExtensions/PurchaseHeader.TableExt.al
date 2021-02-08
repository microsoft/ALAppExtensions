#pragma warning disable AA0232
tableextension 11705 "Purchase Header CZL" extends "Purchase Header"
{
    fields
    {
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
                                                                                            Code = field("Bank Account Code")));
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
        exit(UnreliablePayerMgtCZL.IsPublicBankAccount("Pay-To Vendor No.", "VAT Registration No.", "Bank Account No.", IBAN));
    end;

    local procedure CheckCurrencyExchangeRateCZL(CurrencyDate: Date)
    var
        CurrExchRate: Record "Currency Exchange Rate";
        CurrExchRateNotExistsErr: Label '%1 does not exist for currency %2 and date %3.', Comment = '%1 = CurrExchRate.TableCaption, %2 = Currency Code, %3 = Date';
    begin
        if "Currency Code" = '' then
            exit;
        CurrExchRate.SetRange("Currency Code", "Currency Code");
        CurrExchRate.SetRange("Starting Date", 0D, CurrencyDate);
        if CurrExchRate.IsEmpty() then
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
        CurrExchRate: Record "Currency Exchange Rate";
        VATCurrencyFactor: Decimal;
        UpdateChangedFieldQst: Label 'You have changed %1. Do you want to update %2?', Comment = '%1 = field caption, %2 = field caption';
    begin
        if ("VAT Currency Code CZL" <> '') and ("Currency Factor" = xRec."Currency Factor") and (xRec."Currency Factor" <> 0) then begin
            VATCurrencyFactor := CurrExchRate.ExchangeRate("VAT Date CZL", "VAT Currency Code CZL");
            if "VAT Currency Factor CZL" <> VATCurrencyFactor then
                if ConfirmManagement.GetResponseOrDefault(StrSubstNo(UpdateChangedFieldQst, FieldCaption("VAT Date CZL"), FieldCaption("VAT Currency Factor CZL")), true) then
                    Validate("VAT Currency Factor CZL", VATCurrencyFactor);
        end;
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
}
