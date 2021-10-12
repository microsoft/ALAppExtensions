codeunit 11744 "Purchase Header Handler CZL"
{
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterInitRecord', '', false, false)]
    local procedure UpdateVatDateOnAfterInitRecord(var PurchHeader: Record "Purchase Header")
    begin
        PurchasesPayablesSetup.Get();
        case PurchasesPayablesSetup."Default VAT Date CZL" of
            PurchasesPayablesSetup."Default VAT Date CZL"::"Posting Date":
                PurchHeader."VAT Date CZL" := PurchHeader."Posting Date";
            PurchasesPayablesSetup."Default VAT Date CZL"::"Document Date":
                PurchHeader."VAT Date CZL" := PurchHeader."Document Date";
            PurchasesPayablesSetup."Default VAT Date CZL"::Blank:
                PurchHeader."VAT Date CZL" := 0D;
        end;
        case PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL" of
            PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::Blank:
                PurchHeader."Original Doc. VAT Date CZL" := 0D;
            PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::"Posting Date":
                PurchHeader."Original Doc. VAT Date CZL" := PurchHeader."Posting Date";
            PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::"VAT Date":
                PurchHeader."Original Doc. VAT Date CZL" := PurchHeader."VAT Date CZL";
            PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::"Document Date":
                PurchHeader."Original Doc. VAT Date CZL" := PurchHeader."Document Date";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Posting Date', false, false)]
    local procedure UpdateVatDateOnBeforePostingDateValidate(var Rec: Record "Purchase Header")
    begin
        PurchasesPayablesSetup.Get();
        if PurchasesPayablesSetup."Default VAT Date CZL" = PurchasesPayablesSetup."Default VAT Date CZL"::"Posting Date" then
            Rec.Validate("VAT Date CZL", Rec."Posting Date");
        if PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL" = PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::"Posting Date" then
            Rec.Validate("Original Doc. VAT Date CZL", Rec."Posting Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Document Date', false, false)]
    local procedure UpdateVatDateOnBeforeDocumentDateValidate(var Rec: Record "Purchase Header")
    begin
        PurchasesPayablesSetup.Get();
        if PurchasesPayablesSetup."Default VAT Date CZL" = PurchasesPayablesSetup."Default VAT Date CZL"::"Document Date" then
            Rec.Validate("VAT Date CZL", Rec."Document Date");
        if PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL" = PurchasesPayablesSetup."Def. Orig. Doc. VAT Date CZL"::"Document Date" then
            Rec.Validate("Original Doc. VAT Date CZL", Rec."Document Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterCopyBuyFromVendorFieldsFromVendor', '', false, false)]
    local procedure UpdateOnAfterCopyBuyFromVendorFieldsFromVendor(var PurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    begin
        PurchaseHeader."Registration No. CZL" := Vendor."Registration No. CZL";
        PurchaseHeader."Tax Registration No. CZL" := Vendor."Tax Registration No. CZL";
        if Vendor."Transaction Type CZL" <> PurchaseHeader."Transaction Type" then
            PurchaseHeader.Validate("Transaction Type", Vendor."Transaction Type CZL");
        if Vendor."Transaction Specification CZL" <> PurchaseHeader."Transaction Specification" then
            PurchaseHeader.Validate("Transaction Specification", Vendor."Transaction Specification CZL");
        if Vendor."Transport Method CZL" <> PurchaseHeader."Transport Method" then
            PurchaseHeader.Validate("Transport Method", Vendor."Transport Method CZL");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnValidatePurchaseHeaderPayToVendorNoOnBeforeCheckDocType', '', false, false)]
    local procedure UpdateBankInfoAndRegNosOnValidatePurchaseHeaderPayToVendorNo(var PurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    var
        CompanyInformation: Record "Company Information";
        ResponsibilityCenter: Record "Responsibility Center";
    begin
        if PurchaseHeader.IsCreditDocType() then begin
            if PurchaseHeader."Responsibility Center" = '' then begin
                CompanyInformation.Get();
                PurchaseHeader.Validate("Bank Account Code CZL", CompanyInformation."Default Bank Account Code CZL");
            end else begin
                ResponsibilityCenter.Get(PurchaseHeader."Responsibility Center");
                PurchaseHeader.Validate("Bank Account Code CZL", ResponsibilityCenter."Default Bank Account Code CZL");
            end;
        end else
            PurchaseHeader.Validate("Bank Account Code CZL", Vendor."Preferred Bank Account Code");
        PurchaseHeader."Registration No. CZL" := Vendor."Registration No. CZL";
        PurchaseHeader."Tax Registration No. CZL" := Vendor."Tax Registration No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Currency Code', false, false)]
    local procedure UpdateVatCurrencyCodeCZLOnBeforeCurrencyCodeValidate(var Rec: Record "Purchase Header")
    begin
        Rec.Validate("VAT Currency Code CZL", Rec."Currency Code");
    end;

#pragma warning disable AL0432
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Currency Factor', false, false)]
    local procedure UpdateVATCurrencyfactorCZLOnBeforeCurrencyFactorValidate(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    begin
        if (Rec."Currency Factor" <> xRec."Currency Factor") and (Rec.IsCurrentFieldNoDiffZero(CurrFieldNo) or (xRec."Currency Factor" = 0)) then begin
            Rec.UpdatePurchLinesByFieldNo(Rec.FieldNo("Currency Factor"), CurrFieldNo <> 0);
            Rec.UpdateVATCurrencyFactorCZL();
            Rec.CopyRecCurrencyFactortoxRecCurrencyFactor(Rec, xRec); // Elimination of double run function (synchro)
        end;
    end;
#pragma warning restore AL0432

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterUpdateCurrencyFactor', '', false, false)]
    local procedure OnAfterUpdateCurrencyFactor(var PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader.UpdateVATCurrencyFactorCZL()
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateEvent', 'Vendor Posting Group', false, false)]
    local procedure CheckPostingGroupChangeOnBeforeVendorPostingGroupValidate(var Rec: Record "Purchase Header"; var xRec: Record "Purchase Header"; CurrFieldNo: Integer)
    var
        PostingGroupManagementCZL: Codeunit "Posting Group Management CZL";
    begin
        if CurrFieldNo = Rec.FieldNo("Vendor Posting Group") then
            PostingGroupManagementCZL.CheckPostingGroupChange(Rec."Vendor Posting Group", xRec."Vendor Posting Group", Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnInitFromPurchHeader', '', false, false)]
    local procedure UpdateBankAccountOnInitPurchHeader(var PurchaseHeader: Record "Purchase Header"; SourcePurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader."Bank Account Code CZL" := SourcePurchaseHeader."Bank Account Code CZL";
        PurchaseHeader."Bank Name CZL" := SourcePurchaseHeader."Bank Name CZL";
        PurchaseHeader."Bank Account No. CZL" := SourcePurchaseHeader."Bank Account No. CZL";
        PurchaseHeader."Bank Branch No. CZL" := SourcePurchaseHeader."Bank Branch No. CZL";
        PurchaseHeader."IBAN CZL" := SourcePurchaseHeader."IBAN CZL";
        PurchaseHeader."SWIFT Code CZL" := SourcePurchaseHeader."SWIFT Code CZL";
        PurchaseHeader."Transit No. CZL" := SourcePurchaseHeader."Transit No. CZL";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnUpdatePurchLinesByChangedFieldName', '', false, false)]
    local procedure UpdatePurchLinesByChangedFieldName(PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line"; ChangedFieldName: Text[100]; ChangedFieldNo: Integer)
    begin
        case ChangedFieldNo of
            PurchHeader.FieldNo("Physical Transfer CZL"):
                if (PurchLine.Type = PurchLine.Type::Item) and (PurchLine."No." <> '') then
                    PurchLine."Physical Transfer CZL" := PurchHeader."Physical Transfer CZL";
        end;
    end;
#if CLEAN17

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnGetVATCurrencyFactor', '', false, false)]
    local procedure ReturnVATCurrencyFactorCZLOnGetVATCurrencyFactor(Rec: Record "Purchase Header"; var VATCurrencyFactor: Decimal)
    begin
        VATCurrencyFactor := Rec."VAT Currency Factor CZL";
    end;
#endif
}