namespace Microsoft.SubscriptionBilling;

using Microsoft.Utilities;
using Microsoft.Sales.Document;
using Microsoft.Purchases.Document;

codeunit 8061 "Billing Correction"
{
    SingleInstance = true;
    Access = Internal;

    var
        NewerInvoiceExistErr: Label 'The service commitment has already been invoiced until %1. In order to cancel the invoice, please cancel the newer invoices first.';
        RelatedDocumentLineExistErr: Label 'The %1 %2 already exists for the service commitment. Please post or delete this %1 first.';
        CopyingErr: Label 'Copying documents with a link to a contract is not allowed. To create contract invoices, please use the "Recurring Billing" page. For cancelling a contract invoice, please use the "Create Corrective Credit Memo" function in the posted invoice.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", OnBeforeUpdateSalesLine, '', false, false)]
    local procedure TrasnferContractFieldsBeforeUpdateSalesLine(var ToSalesLine: Record "Sales Line"; var FromSalesLine: Record "Sales Line"; FromSalesDocType: Option; var FromSalesHeader: Record "Sales Header")
    begin
        if not FromSalesHeader."Recurring Billing" then
            exit;
        if FromSalesDocType <> Enum::"Sales Document Type From"::"Posted Invoice".AsInteger() then
            Error(CopyingErr);
        if ToSalesLine."Document Type" <> Enum::"Sales Document Type"::"Credit Memo" then
            Error(CopyingErr);
        ToSalesLine."Recurring Billing from" := FromSalesLine."Recurring Billing from";
        ToSalesLine."Recurring Billing to" := FromSalesLine."Recurring Billing to";
        ToSalesLine."Discount" := FromSalesLine."Discount";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", OnAfterInsertToSalesLine, '', false, false)]
    local procedure CreateBillingLineFromBillingLineArchiveAfterInsertToSalesLine(var ToSalesLine: Record "Sales Line"; FromSalesLine: Record "Sales Line"; DocLineNo: Integer; FromSalesHeader: Record "Sales Header")
    var
        ServiceCommitment: Record "Service Commitment";
        BillingLine: Record "Billing Line";
        BillingLineArchive: Record "Billing Line Archive";
        IsHandled: Boolean;
    begin
        OnBeforeCreateBillingLineFromBillingLineArchiveAfterInsertToSalesLine(ToSalesLine, IsHandled);
        if IsHandled then
            exit;
        FilterBillingLineArchiveOnSalesLineOrPurchLine(ToSalesLine, BillingLineArchive, FromSalesHeader."No.", DocLineNo);
        if BillingLineArchive.IsEmpty() then
            exit;

        ToSalesLine.TestField("Recurring Billing from");
        ToSalesLine.TestField("Recurring Billing to");

        if BillingLineArchive.FindFirst() then begin
            ServiceCommitment.SetRange("Contract No.", BillingLineArchive."Contract No.");
            ServiceCommitment.SetRange("Contract Line No.", BillingLineArchive."Contract Line No.");
            ServiceCommitment.FindFirst();
            if ServiceCommitment."Next Billing Date" - 1 > ToSalesLine."Recurring Billing to" then
                Error(NewerInvoiceExistErr, ServiceCommitment."Next Billing Date");
        end;

        BillingLine.SetRange("Document Type", Enum::"Rec. Billing Document Type"::Invoice, Enum::"Rec. Billing Document Type"::"Credit Memo");
        BillingLine.SetFilter("Document No.", '<>%1', ToSalesLine."Document No.");
        BillingLine.SetRange("Contract No.", BillingLineArchive."Contract No.");
        BillingLine.SetRange("Contract Line No.", BillingLineArchive."Contract Line No.");

        if BillingLine.FindFirst() then
            Error(RelatedDocumentLineExistErr, BillingLine."Document Type", BillingLine."Document No.");
        CreateBillingLineFromBillingLineArchive(ToSalesLine, ServiceCommitment, FromSalesHeader."No.", DocLineNo);
    end;

    local procedure CreateBillingLineFromBillingLineArchive(RecVariant: Variant; var ServiceCommitment: Record "Service Commitment"; FromDocumentNo: Code[20]; DocLineNo: Integer)
    var
        BillingLine: Record "Billing Line";
        BillingLineArchive: Record "Billing Line Archive";
        InvoiceUsageDataBilling: Record "Usage Data Billing";
        CreditMemoUsageDataBilling: Record "Usage Data Billing";
        RRef: RecordRef;
        BillingFrom: Date;
    begin
        RRef.GetTable(RecVariant);
        FilterBillingLineArchiveOnSalesLineOrPurchLine(RecVariant, BillingLineArchive, FromDocumentNo, DocLineNo);
        if BillingLineArchive.FindSet() then
            repeat
                BillingLine.TransferFields(BillingLineArchive);
                BillingLine."User ID" := CopyStr(UserId(), 1, MaxStrLen(BillingLine."User ID"));
                BillingLine."Entry No." := 0;
                BillingLine."Correction Document Type" := BillingLineArchive."Document Type";
                BillingLine."Correction Document No." := BillingLineArchive."Document No.";
                case BillingLine.Partner of
                    Enum::"Service Partner"::Customer:
                        BillingLine."Document Type" := BillingLine.GetBillingDocumentTypeFromSalesDocumentType(RRef.Field(1).Value);
                    Enum::"Service Partner"::Vendor:
                        BillingLine."Document Type" := BillingLine.GetBillingDocumentTypeFromPurchaseDocumentType(RRef.Field(1).Value);
                end;
                BillingLine."Document No." := RRef.Field(3).Value;
                BillingLine."Document Line No." := RRef.Field(4).Value;
                BillingLine."Service Amount" := -BillingLine."Service Amount";
                BillingLine.Insert(false);
            until BillingLineArchive.Next() = 0;
        BillingFrom := RRef.Field(8053).Value;
        OnBeforeUpdateNextBillingDateInCreateBillingLineFromBillingLineArchive(ServiceCommitment);
        ServiceCommitment.UpdateNextBillingDate(BillingFrom - 1);
        ServiceCommitment.Modify(false);

        if ServiceCommitment."Usage Based Billing" then
            if IsCalledFromCreditMemo(RRef) then begin
                InvoiceUsageDataBilling.SetRange("Document Type", InvoiceUsageDataBilling."Document Type"::"Posted Invoice");
                InvoiceUsageDataBilling.SetRange("Document No.", BillingLineArchive."Document No.");
                InvoiceUsageDataBilling.SetRange("Billing Line Entry No.", BillingLineArchive."Entry No.");
                if InvoiceUsageDataBilling.FindSet() then
                    repeat
                        CreditMemoUsageDataBilling := InvoiceUsageDataBilling;
                        CreditMemoUsageDataBilling."Document Type" := CreditMemoUsageDataBilling."Document Type"::"Credit Memo";
                        CreditMemoUsageDataBilling."Document No." := RRef.Field(3).Value;
                        CreditMemoUsageDataBilling."Document Line No." := RRef.Field(4).Value;
                        CreditMemoUsageDataBilling."Entry No." := 0;
                        CreditMemoUsageDataBilling.Insert(true);
                    until InvoiceUsageDataBilling.Next() = 0;
            end;

        OnAfterCreateBillingLineFromBillingLineArchive(RRef, BillingLineArchive);
    end;

    local procedure IsCalledFromCreditMemo(var RRef: RecordRef): Boolean
    var
        SalesDocumentType: Enum "Sales Document Type";
        PurchaseDocumentType: Enum "Purchase Document Type";
    begin
        if not (RRef.Number in [Database::"Sales Line", Database::"Purchase Line"]) then
            exit(false);
        case RRef.Number of
            Database::"Sales Line":
                begin
                    if not Evaluate(SalesDocumentType, Format(RRef.Field(1).Value)) then
                        exit(false);
                    exit(SalesDocumentType = "Sales Document Type"::"Credit Memo");
                end;
            Database::"Purchase Line":
                begin
                    if not Evaluate(PurchaseDocumentType, Format(RRef.Field(1).Value)) then
                        exit(false);
                    exit(PurchaseDocumentType = "Purchase Document Type"::"Credit Memo");
                end;
        end;
    end;

    local procedure FilterBillingLineArchiveOnSalesLineOrPurchLine(RecVariant: Variant; var BillingLineArchive: Record "Billing Line Archive"; FromDocumentNo: Code[20]; FromDocumentLineNo: Integer)
    var
        ToSalesHeader: Record "Sales Header";
        ToPurchaseHeader: Record "Purchase Header";
        RRef: RecordRef;
        AppliesToDocNo: Code[20];
        SalesDocumentType: Enum "Sales Document Type";
        PurchaseDocumentType: Enum "Purchase Document Type";
        DocumentNo: Code[20];
    begin
        RRef.GetTable(RecVariant);
        case RRef.Number of
            Database::"Sales Line":
                begin
                    SalesDocumentType := RRef.Field(1).Value;
                    DocumentNo := RRef.Field(3).Value;
                    ToSalesHeader.Get(SalesDocumentType, DocumentNo);
                    AppliesToDocNo := ToSalesHeader."Applies-to Doc. No.";
                end;
            Database::"Purchase Line":
                begin
                    PurchaseDocumentType := RRef.Field(1).Value;
                    DocumentNo := RRef.Field(3).Value;
                    ToPurchaseHeader.Get(PurchaseDocumentType, DocumentNo);
                    AppliesToDocNo := ToPurchaseHeader."Applies-to Doc. No.";
                end;
        end;
        if AppliesToDocNo = '' then
            AppliesToDocNo := FromDocumentNo;
        BillingLineArchive.SetRange("Document Type", BillingLineArchive."Document Type"::Invoice);
        BillingLineArchive.SetRange("Document No.", AppliesToDocNo);
        BillingLineArchive.SetRange("Document Line No.", FromDocumentLineNo);
        BillingLineArchive.SetRange("Billing from", RRef.Field(8053).Value, RRef.Field(8054).Value);
        BillingLineArchive.SetRange("Billing to", RRef.Field(8053).Value, RRef.Field(8054).Value);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", OnBeforeUpdatePurchLine, '', false, false)]
    local procedure TrasnferContractFieldsBeforeUpdatePurchaseLine(var ToPurchLine: Record "Purchase Line"; var FromPurchLine: Record "Purchase Line"; var FromPurchHeader: Record "Purchase Header"; FromPurchDocType: Option)
    begin
        if not FromPurchHeader."Recurring Billing" then
            exit;
        if FromPurchDocType <> Enum::"Purchase Document Type From"::"Posted Invoice".AsInteger() then
            Error(CopyingErr);
        if ToPurchLine."Document Type" <> Enum::"Purchase Document Type"::"Credit Memo" then
            Error(CopyingErr);
        ToPurchLine."Recurring Billing from" := FromPurchLine."Recurring Billing from";
        ToPurchLine."Recurring Billing to" := FromPurchLine."Recurring Billing to";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", OnAfterInsertToPurchLine, '', false, false)]
    local procedure CreateBillingLineFromBillingLineArchiveAfterInsertToPurchLine(var ToPurchLine: Record "Purchase Line"; var FromPurchLine: Record "Purchase Line"; RecalculateLines: Boolean; DocLineNo: Integer; FromPurchDocType: Enum "Purchase Document Type From"; var ToPurchHeader: Record "Purchase Header"; MoveNegLines: Boolean; FromPurchaseHeader: Record "Purchase Header")
    var
        ServiceCommitment: Record "Service Commitment";
        BillingLine: Record "Billing Line";
        BillingLineArchive: Record "Billing Line Archive";
    begin
        FilterBillingLineArchiveOnSalesLineOrPurchLine(ToPurchLine, BillingLineArchive, FromPurchaseHeader."No.", DocLineNo);
        if BillingLineArchive.IsEmpty() then
            exit;
        ToPurchLine.TestField("Recurring Billing from");
        ToPurchLine.TestField("Recurring Billing to");
        if BillingLineArchive.FindFirst() then begin
            ServiceCommitment.SetRange("Contract No.", BillingLineArchive."Contract No.");
            ServiceCommitment.SetRange("Contract Line No.", BillingLineArchive."Contract Line No.");
            ServiceCommitment.FindFirst();
            if ServiceCommitment."Next Billing Date" - 1 > ToPurchLine."Recurring Billing to" then
                Error(NewerInvoiceExistErr, ServiceCommitment."Next Billing Date");
        end;

        BillingLine.SetRange("Document Type", Enum::"Rec. Billing Document Type"::Invoice, Enum::"Rec. Billing Document Type"::"Credit Memo");
        BillingLine.SetFilter("Document No.", '<>%1', ToPurchLine."Document No.");
        BillingLine.SetRange("Contract No.", BillingLineArchive."Contract No.");
        BillingLine.SetRange("Contract Line No.", BillingLineArchive."Contract Line No.");
        if BillingLine.FindFirst() then
            Error(RelatedDocumentLineExistErr, BillingLine."Document Type", BillingLine."Document No.");
        CreateBillingLineFromBillingLineArchive(ToPurchLine, ServiceCommitment, FromPurchaseHeader."No.", DocLineNo);
    end;

    [InternalEvent(false, false)]
    local procedure OnAfterCreateBillingLineFromBillingLineArchive(var RRef: RecordRef; BillingLineArchive: Record "Billing Line Archive")
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeCreateBillingLineFromBillingLineArchiveAfterInsertToSalesLine(var ToSalesLine: Record "Sales Line"; var IsHandled: Boolean)
    begin
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeUpdateNextBillingDateInCreateBillingLineFromBillingLineArchive(var ServiceCommitment: Record "Service Commitment")
    begin
    end;
}