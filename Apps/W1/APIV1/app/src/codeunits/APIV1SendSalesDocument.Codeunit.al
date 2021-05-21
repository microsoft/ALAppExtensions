codeunit 20038 "APIV1 - Send Sales Document"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        SendSalesDocumentFromJobQueue(Rec);
    end;

    var
        O365SetupEmail: Codeunit "O365 Setup Email";
        ThereIsNothingToSellErr: Label 'Please add at least one line item to the document.';
        EmptyEmailErr: Label 'The send-to email is empty. Specify email either for the customer or for the %1 in email preview.', Locked = true;
        CancelationEmailSubjectTxt: Label 'Your %1 has been cancelled.', Comment = '%1 - document type';
        CancelationEmailBodyTxt: Label 'Thank you for your business. Your %1 has been cancelled.', Comment = '%1 - document type';
        GreetingTxt: Label 'Hello %1,', Comment = '%1 - customer name';

    [Scope('Cloud')]
    procedure SendCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        if IsCreditMemoCancelled(SalesCrMemoHeader) then
            SendCancelledCreditMemoInBackground(SalesCrMemoHeader)
        else
            SendPostedCreditMemo(SalesCrMemoHeader);
    end;

    [Scope('Cloud')]
    procedure SendQuote(var SalesHeader: Record "Sales Header")
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Quote then
            exit;
        SendDocument(SalesHeader);
    end;

    local procedure SendCancelledCreditMemoInBackground(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := CODEUNIT::"APIV1 - Send Sales Document";
        JobQueueEntry."Maximum No. of Attempts to Run" := 3;
        JobQueueEntry."Record ID to Process" := SalesCrMemoHeader.RecordId();
        CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry);
    end;

    local procedure SendSalesDocumentFromJobQueue(JobQueueEntry: Record "Job Queue Entry")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        case true of
            SalesCrMemoHeader.Get(JobQueueEntry."Record ID to Process"):
                begin
                    if not IsCreditMemoCancelled(SalesCrMemoHeader) then
                        exit;
                    SendCancelledCreditMemo(SalesCrMemoHeader);
                    exit;
                end;
        end;
    end;

    local procedure SendPostedCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        O365SetupEmail.CheckMailSetup();
        CheckSendToEmailAddress(SalesCrMemoHeader);

        SalesCrMemoHeader.SETRECFILTER();
        SalesCrMemoHeader.EmailRecords(FALSE);
    end;

    local procedure SendCancelledCreditMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        O365SetupEmail.CheckMailSetup();
        CheckSendToEmailAddress(SalesCrMemoHeader);
        SendCreditMemoCancelationEmail(SalesCrMemoHeader);
    end;

    local procedure SendDocument(var SalesHeader: Record "Sales Header")
    var
        LinesInstructionMgt: Codeunit "Lines Instruction Mgt.";
    begin
        if not SalesHeader.SalesLinesExist() then
            Error(ThereIsNothingToSellErr);
        LinesInstructionMgt.SalesCheckAllLinesHaveQuantityAssigned(SalesHeader);
        O365SetupEmail.CheckMailSetup();
        CheckSendToEmailAddress(SalesHeader);

        SalesHeader.SETRECFILTER();
        SalesHeader.EmailRecords(FALSE);
    end;

    local procedure CheckSendToEmailAddress(var SalesHeader: Record "Sales Header")
    begin
        if GetSendToEmailAddress(SalesHeader) = '' then
            Error(EmptyEmailErr, SalesHeader."Document Type");
    end;

    local procedure CheckSendToEmailAddress(var SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        TempSalesHeader: Record "Sales Header" temporary;
    begin
        if GetSendToEmailAddress(SalesCrMemoHeader) = '' then
            Error(EmptyEmailErr, TempSalesHeader."Document Type"::"Credit Memo");
    end;

    local procedure GetSendToEmailAddress(var SalesHeader: Record "Sales Header"): Text[250]
    begin
        exit(GetSendToEmailAddress(SalesHeader."Document Type", SalesHeader."No.", SalesHeader."Sell-to Customer No."));
    end;

    local procedure GetSendToEmailAddress(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Text[250]
    var
        TempSalesHeader: Record "Sales Header" temporary;
    begin
        exit(GetSendToEmailAddress(TempSalesHeader."Document Type"::"Credit Memo", SalesCrMemoHeader."No.", SalesCrMemoHeader."Sell-to Customer No."));
    end;

    local procedure GetSendToEmailAddress(DocumentType: Enum "Sales Document Type"; DocumentNo: Code[20]; CustomerNo: Code[20]): Text[250]
    var
        EmailAddress: Text[250];
    begin
        EmailAddress := GetDocumentEmailAddress(DocumentNo, DocumentType);
        if EmailAddress <> '' then
            exit(EmailAddress);
        EmailAddress := GetCustomerEmailAddress(CustomerNo);
        exit(EmailAddress);
    end;

    local procedure GetCustomerEmailAddress(SellToCustomerNo: Code[20]): Text[250]
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(SellToCustomerNo) then
            exit('');
        exit(Customer."E-Mail");
    end;

    local procedure GetDocumentEmailAddress(DocumentNo: Code[20]; DocumentType: Enum "Sales Document Type"): Text[250]
    var
        EmailParameter: Record "Email Parameter";
    begin
        if not EmailParameter.Get(DocumentNo, DocumentType, EmailParameter."Parameter Type"::Address) then
            exit('');
        exit(EmailParameter."Parameter Value");
    end;

    local procedure SendCreditMemoCancelationEmail(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var

        TempSalesHeader: Record "Sales Header" temporary;
        ReportSelections: Record "Report Selections";
        DocumentMailing: Codeunit "Document-Mailing";
        RecordVariant: Variant;
        EmailAddress: Text[250];
        ServerEmailBodyFilePath: Text[250];
        EmailBodyTxt: Text;
    begin
        if not IsCreditMemoCancelled(SalesCrMemoHeader) then
            exit;

        RecordVariant := SalesCrMemoHeader;
        EmailAddress := GetSendToEmailAddress(SalesCrMemoHeader);
        EmailBodyTxt := GetCreditMemoEmailBody(SalesCrMemoHeader);
        ReportSelections.GetEmailBodyTextForCust(
            ServerEmailBodyFilePath, 2, RecordVariant, SalesCrMemoHeader."Bill-to Customer No.", EmailAddress, EmailBodyTxt);
        DocumentMailing.EmailFileWithSubjectAndReportUsage(
         '', '', ServerEmailBodyFilePath, StrSubstNo(CancelationEmailSubjectTxt, TempSalesHeader."Document Type"::"Credit Memo"),
         SalesCrMemoHeader."No.", EmailAddress, Format(TempSalesHeader."Document Type"::"Credit Memo"), true, 2);
    end;

    local procedure IsCreditMemoCancelled(SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Boolean
    var
        CancelledDocument: Record "Cancelled Document";
    begin
        exit(CancelledDocument.FindSalesCancelledCrMemo(SalesCrMemoHeader."No."));
    end;

    local procedure GetCreditMemoEmailBody(SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Text
    var
        TempSalesHeader: Record "Sales Header" temporary;
        CR: Text[1];
        EmailBodyTxt: Text;
    begin
        CR[1] := 10;

        // Create cancel credit memo body message
        EmailBodyTxt := StrSubstNo(GreetingTxt, SalesCrMemoHeader."Sell-to Customer Name") + CR + CR +
            StrSubstNo(CancelationEmailBodyTxt, TempSalesHeader."Document Type"::"Credit Memo");

        exit(EmailBodyTxt);
    end;
}