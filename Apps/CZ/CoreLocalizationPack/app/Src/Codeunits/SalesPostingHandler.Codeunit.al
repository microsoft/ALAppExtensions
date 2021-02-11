codeunit 31038 "Sales Posting Handler CZL"
{
    var
        GeneralLedgerSetup: Record "General Ledger Setup";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterValidatePostingAndDocumentDate', '', false, false)]
    local procedure ValidateVATDateOnAfterValidatePostingAndDocumentDate(var SalesHeader: Record "Sales Header")
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
              BatchProcessingMgt.GetBooleanParameter(SalesHeader.RecordId, "Batch Posting Parameter Type"::"Replace VAT Date CZL", ReplaceVATDate) and
              BatchProcessingMgt.GetDateParameter(SalesHeader.RecordId, "Batch Posting Parameter Type"::"VAT Date CZL", VATDate);
            if VATDateExists and (ReplaceVATDate or (SalesHeader."VAT Date CZL" = 0D)) then begin
                SalesHeader.Validate("VAT Date CZL", VATDate);
                SalesHeader.Modify();
            end;
        end else
            if BatchProcessingMgt.GetDateParameter(SalesHeader.RecordId, "Batch Posting Parameter Type"::"Posting Date", PostingDate) and
               (SalesHeader."Posting Date" <> SalesHeader."VAT Date CZL")
            then begin
                SalesHeader.Validate("VAT Date CZL", PostingDate);
                SalesHeader.Modify();
            end;
    end;
}