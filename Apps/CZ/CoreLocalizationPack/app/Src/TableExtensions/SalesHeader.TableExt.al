tableextension 11703 "Sales Header CZL" extends "Sales Header"
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
                    TestField("VAT Date CZL", "Posting Date");
                CheckCurrencyExchangeRateCZL("VAT Date CZL");
                if "VAT Currency Code CZL" <> '' then
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
        field(11786; "Credit Memo Type CZL"; Enum "Credit Memo Type CZL")
        {
            Caption = 'Credit Memo Type';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if IsCreditDocType() then
                    TestField("Credit Memo Type CZL")
                else
                    Clear("Credit Memo Type CZL");
            end;
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
        field(31112; "Original Doc. VAT Date CZL"; Date)
        {
            Caption = 'Original Document VAT Date';
            DataClassification = CustomerContent;
        }
    }
    var
        ConfirmManagement: Codeunit "Confirm Management";

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
            if (xRec."Currency Factor" = "VAT Currency Factor CZL") or HideValidationDialog then begin
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
    procedure CopyRecCurrencyFactortoxRecCurrencyFactor(var Rec: Record "Sales Header"; var xRec: Record "Sales Header")
    begin
        xRec."Currency Factor" := Rec."Currency Factor";
    end;

    [Obsolete('This procedure will be removed after removing feature from Base Application.', '17.0')]
    procedure IsCurrentFieldNoDiffZero(CurrFieldNo: Integer): Boolean
    begin
        exit(CurrFieldNo <> 0);
    end;
}
