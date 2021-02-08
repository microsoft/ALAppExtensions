#pragma warning disable AL0432
codeunit 11744 "Purchase Header Handler CZL"
{
    var
        PurchaseSetup: Record "Purchases & Payables Setup";

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterInitRecord', '', false, false)]
    local procedure UpdateVatDateOnAfterInitRecord(var PurchHeader: Record "Purchase Header")
    begin
        PurchaseSetup.Get();
        case PurchaseSetup."Default VAT Date CZL" of
            PurchaseSetup."Default VAT Date CZL"::"Posting Date":
                PurchHeader."VAT Date CZL" := PurchHeader."Posting Date";
            PurchaseSetup."Default VAT Date CZL"::"Document Date":
                PurchHeader."VAT Date CZL" := PurchHeader."Document Date";
            PurchaseSetup."Default VAT Date CZL"::Blank:
                PurchHeader."VAT Date CZL" := 0D;
        end;
        case PurchaseSetup."Def. Orig. Doc. VAT Date CZL" of
            PurchaseSetup."Def. Orig. Doc. VAT Date CZL"::Blank:
                PurchHeader."Original Doc. VAT Date CZL" := 0D;
            PurchaseSetup."Def. Orig. Doc. VAT Date CZL"::"Posting Date":
                PurchHeader."Original Doc. VAT Date CZL" := PurchHeader."Posting Date";
            PurchaseSetup."Def. Orig. Doc. VAT Date CZL"::"VAT Date":
                PurchHeader."Original Doc. VAT Date CZL" := PurchHeader."VAT Date CZL";
            PurchaseSetup."Def. Orig. Doc. VAT Date CZL"::"Document Date":
                PurchHeader."Original Doc. VAT Date CZL" := PurchHeader."Document Date";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Posting Date', false, false)]
    local procedure UpdateVatDateOnBeforePostingDateValidate(var Rec: Record "Purchase Header")
    begin
        PurchaseSetup.Get();
        if PurchaseSetup."Default VAT Date CZL" = PurchaseSetup."Default VAT Date CZL"::"Posting Date" then
            Rec.Validate("VAT Date CZL", Rec."Posting Date");
        if PurchaseSetup."Def. Orig. Doc. VAT Date CZL" = PurchaseSetup."Def. Orig. Doc. VAT Date CZL"::"Posting Date" then
            Rec.Validate("Original Doc. VAT Date CZL", Rec."Posting Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Document Date', false, false)]
    local procedure UpdateVatDateOnBeforeDocumentDateValidate(var Rec: Record "Purchase Header")
    begin
        PurchaseSetup.Get();
        if PurchaseSetup."Default VAT Date CZL" = PurchaseSetup."Default VAT Date CZL"::"Document Date" then
            Rec.Validate("VAT Date CZL", Rec."Document Date");
        if PurchaseSetup."Def. Orig. Doc. VAT Date CZL" = PurchaseSetup."Def. Orig. Doc. VAT Date CZL"::"Document Date" then
            Rec.Validate("Original Doc. VAT Date CZL", Rec."Document Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterCopyBuyFromVendorFieldsFromVendor', '', false, false)]
    local procedure UpdateRegNoOnAfterCopyBuyFromVendorFieldsFromVendor(var PurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    begin
        PurchaseHeader."Registration No. CZL" := Vendor."Registration No. CZL";
        PurchaseHeader."Tax Registration No. CZL" := Vendor."Tax Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnValidatePurchaseHeaderPayToVendorNo', '', false, false)]
    local procedure UpdateRegNoOnValidatePurchaseHeaderPayToVendorNo(var PurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    begin
        PurchaseHeader."Registration No. CZL" := Vendor."Registration No. CZL";
        PurchaseHeader."Tax Registration No. CZL" := Vendor."Tax Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Currency Code', false, false)]
    local procedure UpdateVatCurrencyCodeCZLOnBeforeCurrencyCodeValidate(var Rec: Record "Purchase Header")
    begin
        Rec.Validate("VAT Currency Code CZL", Rec."Currency Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Currency Factor', false, false)]
    local procedure UpdateVATCurrencyfactorCZLOnBeforeCurrencyFactorValidate(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if (Rec."Currency Factor" <> xRec."Currency Factor") and (Rec.IsCurrentFieldNoDiffZero(CurrFieldNo) or (xRec."Currency Factor" = 0)) then begin
            Rec.UpdatePurchLinesByFieldNo(Rec.FieldNo("Currency Factor"), CurrFieldNo <> 0);
            Rec.UpdateVATCurrencyFactorCZL();
            Rec.CopyRecCurrencyFactortoxRecCurrencyFactor(Rec, xRec); // Elimination of double run function (synchro)
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterUpdateCurrencyFactor', '', false, false)]
    local procedure OnAfterUpdateCurrencyFactor(var PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader.UpdateVATCurrencyFactorCZL()
    end;
}
