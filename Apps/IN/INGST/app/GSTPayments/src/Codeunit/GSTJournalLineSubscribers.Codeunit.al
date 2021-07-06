codeunit 18243 "GST Journal Line Subscribers"
{
    var
        GSTJournalLineValidations: Codeunit "GST Journal Line Validations";
        GSTTDSTCSAmtGreaterErr: label 'GST TDS/TCS Base Amount must not be greater than Amount %1.', Comment = '%1 =Amount';
        GSTTDSTCSAmtPostiveErr: label 'GST TDS/TCS Base Amount must be positive.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Document GL Posting", 'OnBeforeGenJnlLineAdjustEntry', '', false, false)]
    local procedure AdjustPartyType(var GenJnlLine: Record "Gen. Journal Line"; var AdjustEntry: Boolean; var IsHandled: Boolean)
    begin
        if (GenJnlLine."Party Type" <> GenJnlLine."Party Type"::" ") and (GenJnlLine."Party Code" <> '') then begin
            if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Invoice) and (GenJnlLine.Amount < 0) and (GenJnlLine."GST Credit" = GenJnlLine."GST Credit"::Availment) then
                AdjustEntry := true;

            if (GenJnlLine."GST Credit" = GenJnlLine."GST Credit"::"Non-Availment") then
                AdjustEntry := true;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'GST TDS/GST TCS', false, false)]
    local procedure ValidateGSTTCS(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.OnValidateGSTTDSTCS(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'POS Out Of India', false, false)]
    local procedure ValidatePOSOutOfIndia(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.POSOutOfIndia(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'POS as Vendor State', false, false)]
    local procedure validatePOSasVendorState(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.POSasVendorState(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'GST Assessable Value', false, false)]
    local procedure validateGSTAssessableValue(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.GSTAssessableValue(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Custom Duty Amount', false, false)]
    local procedure validateCustomDutyAmount(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.CustomDutyAmount(rec)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Sales Invoice Type', false, false)]
    local procedure validateSalesInvoiceType(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.SalesInvoiceType(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'GST on Advance Payment', false, false)]
    local procedure validateGSTonAdvancePayment(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.GSTonAdvancePayment(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'GST Place of supply', false, false)]
    local procedure ValidateGSTPlaceofSuppply(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.GSTPlaceofsuppply(rec, xrec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'GST Group Code', false, false)]
    local procedure ValidateGSTGroupCode(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.GSTGroupCode(Rec, Xrec)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Party Code', false, false)]
    local procedure ValdiatePartyCode(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.partycode(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Location Code', false, false)]
    local procedure ValidateLocationCode(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.LocationCode(rec)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Amount', false, false)]
    local procedure ValidateAmount(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.amount(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Currency Code', false, false)]
    local procedure ValidateCurrencyCode(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.CurrencyCode(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetVendorBalAccount', '', false, false)]
    local procedure ValidateBalVendNo(var GenJournalLine: Record "Gen. Journal Line"; var Vendor: Record Vendor)
    begin
        GSTJournalLineValidations.BalVendNo(GenJournalLine, Vendor)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetCustomerBalAccount', '', false, false)]
    local procedure ValidateBalCustNo(var GenJournalLine: Record "Gen. Journal Line"; var Customer: Record Customer)
    begin
        GSTJournalLineValidations.BalCustNo(GenJournalLine, Customer)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetGLBalAccount', '', false, false)]
    local procedure ValidateBalGLAccountNo(
        var GenJournalLine: Record "Gen. Journal Line";
        var GLAccount: Record "G/L Account")
    begin
        GSTJournalLineValidations.BalGLAccountNo(GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnValidateBalAccountNoOnBeforeAssignValue', '', false, false)]
    local procedure ValidateBalAccountNo(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.BalAccountNo(GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Document Type', false, false)]
    local procedure ValidateDocumentType(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.documenttype(rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterInsertEvent', '', false, false)]
    local procedure OnafterInsert(var Rec: Record "Gen. Journal Line")
    begin
        //GSTJournalLineValidations.AfterInsert(Rec)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeValidateEvent', 'Account Type', false, false)]
    local procedure ValidateAccountType(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.AccountType(Rec)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeValidateEvent', 'Account no.', false, false)]
    local procedure OnbeforevalidateAccountNo(var Rec: Record "Gen. Journal Line")
    begin
        GSTJournalLineValidations.BeforeValidateAccountNo(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetGLAccount', '', false, false)]
    local procedure GLAccountInfo(
        var GenJournalLine: Record "Gen. Journal Line";
        var GLAccount: Record "G/L Account")
    begin
        GSTJournalLineValidations.PopulateGSTInvoiceCrMemo(true, false, GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetCustomerAccount', '', false, false)]
    local procedure ValidateCustAccount(var GenJournalLine: Record "Gen. Journal Line"; var Customer: Record Customer)
    begin
        GSTJournalLineValidations.CustAccount(GenJournalLine, customer)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetVendorAccount', '', false, false)]
    local procedure ValidateVendorAccount(var GenJournalLine: Record "Gen. Journal Line"; var Vendor: Record Vendor)
    begin
        GSTJournalLineValidations.VendAccount(GenJournalLine, Vendor)
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterAccountNoOnValidateGetFAAccount', '', false, false)]
    local procedure ValidateFAAccount(
        var GenJournalLine: Record "Gen. Journal Line";
        var FixedAsset: Record "Fixed Asset")
    begin
        GSTJournalLineValidations.FaAccount(GenJournalLine, FixedAsset);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterSetupNewLine', '', false, false)]
    local procedure Setupnewlinevalue(
        GenJournalBatch: Record "Gen. Journal Batch";
        var GenJournalLine: Record "Gen. Journal Line")
    var
        location: Record Location;
    begin
        GenJournalLine."Location Code" := GenJournalBatch."Location Code";
        if Location.Get(GenJournalBatch."Location Code") then begin
            GenJournalLine."Location State Code" := Location."State Code";
            GenJournalLine."Location GST Reg. No." := Location."GST Registration No.";
            GenJournalLine."GST Input Service Distribution" := Location."GST Input Service Distributor";
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'Currency Factor', false, false)]
    local procedure OnValidateCurrencyCode(var Rec: Record "Gen. Journal Line"; var xRec: Record "Gen. Journal Line")
    var
        CalculateTax: Codeunit "Calculate Tax";
    begin
        CalculateTax.CallTaxEngineOnGenJnlLine(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnAfterValidateEvent', 'GST TDS/TCS Base Amount', false, false)]
    local procedure onAfterValidateValidateGSTTDSTCSBaseAmount(var Rec: Record "Gen. Journal Line")
    begin
        if Rec."GST TDS/TCS Base Amount" <> 0 then begin
            Rec.TestField("Document Type", Rec."Document Type"::Payment);
            Rec.TestField(Amount);

            if Abs(Rec."GST TDS/TCS Base Amount") > Abs(Rec.Amount) then
                Error(GSTTDSTCSAmtGreaterErr, Rec.Amount);

            if (Rec."GST TDS/TCS Base Amount" < 0) then
                error(GSTTDSTCSAmtPostiveErr);
        end;
    end;
}