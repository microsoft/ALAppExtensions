codeunit 31039 "Purchase Posting Handler CZL"
{
    var
        GeneralLedgerSetup: Record "General Ledger Setup";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterValidatePostingAndDocumentDate', '', false, false)]
    local procedure ValidateVATDateOnAfterValidatePostingAndDocumentDate(var PurchaseHeader: Record "Purchase Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean)
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        VATDate: Date;
        VATDateExists: Boolean;
        ReplaceVATDate: Boolean;
        PostingDate: Date;
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Use VAT Date CZL" then begin
            VATDateExists :=
              BatchProcessingMgt.GetBooleanParameter(PurchaseHeader.RecordId, "Batch Posting Parameter Type"::"Replace VAT Date CZL", ReplaceVATDate) and
              BatchProcessingMgt.GetDateParameter(PurchaseHeader.RecordId, "Batch Posting Parameter Type"::"VAT Date CZL", VATDate);
            if VATDateExists and (ReplaceVATDate or (PurchaseHeader."VAT Date CZL" = 0D)) then begin
                PurchaseHeader.Validate("VAT Date CZL", VATDate);
                PurchaseHeader.Modify();
            end;
        end else
            if BatchProcessingMgt.GetDateParameter(PurchaseHeader.RecordId, "Batch Posting Parameter Type"::"Posting Date", PostingDate) and
               (PurchaseHeader."Posting Date" <> PurchaseHeader."VAT Date CZL")
            then begin
                PurchaseHeader.Validate("VAT Date CZL", PurchaseHeader."Posting Date");
                PurchaseHeader.Modify();
            end;
    end;
}