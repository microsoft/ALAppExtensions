codeunit 30243 "Shpfy RetRefProc Cr.Memo" implements "Shpfy IReturnRefund Process"
{
    procedure IsImportNeededFor(SourceDocumentType: Enum "Shpfy Source Document Type"): Boolean
    begin
        exit(true);
    end;

    procedure CanCreateSalesDocumentFor(SourceDocumentType: Enum "Shpfy Source Document Type"; SourceDocumentId: BigInteger; var ErrorInfo: ErrorInfo): Boolean
    var
        OrderHeader: Record "Shpfy Order Header";
        RefundHeader: Record "Shpfy Refund Header";
        AlreadyProcessedMsg: Label 'The refund %1 is already processed.', Comment = '%1 = Refund Id';
        OrderNotFoundErr: Label 'The shopify order id %1 is not found', Comment = '%1 = Order Id';
        OrderNotProcessedErr: Label 'You must process shopify order %1 first', Comment = '%1 = OrderNumber';
        RefundErr: Label 'Can not create a credit memo for the refund %1. \%2', Comment = '%1 = Refund Id, %2 = detailed error message';
    begin
        RefundHeader.LoadFields("Refund Id", "Order Id");
        RefundHeader.SetAutoCalcFields("Is Processed");
        if SourceDocumentType = "Shpfy Source Document Type"::Refund then
            if RefundHeader.Get(SourceDocumentId) then
                if not RefundHeader."Is Processed" then
                    if OrderHeader.Get(RefundHeader."Order Id") then
                        if (OrderHeader.IsProcessed() or OrderHeader.Processed) then
                            exit(true)
                        else begin
                            ErrorInfo.ErrorType := ErrorType::Client;
                            ErrorInfo.DetailedMessage := StrSubstNo(OrderNotProcessedErr, RefundHeader."Shopify Order No.");
                            ErrorInfo.Message := StrSubstNo(RefundErr, RefundHeader."Refund Id", ErrorInfo.DetailedMessage);
                            ErrorInfo.RecordId := RefundHeader.RecordId;
                            ErrorInfo.SystemId := RefundHeader.SystemId;
                            ErrorInfo.TableId := Database::"Shpfy Refund Header";
                            ErrorInfo.Verbosity := Verbosity::Error;
                        end
                    else begin
                        ErrorInfo.ErrorType := ErrorType::Client;
                        ErrorInfo.DetailedMessage := StrSubstNo(OrderNotFoundErr, RefundHeader."Order Id");
                        ErrorInfo.Message := StrSubstNo(RefundErr, RefundHeader."Refund Id", ErrorInfo.DetailedMessage);
                        ErrorInfo.RecordId := RefundHeader.RecordId;
                        ErrorInfo.SystemId := RefundHeader.SystemId;
                        ErrorInfo.TableId := Database::"Shpfy Refund Header";
                        ErrorInfo.Verbosity := Verbosity::Error;
                    end
                else begin
                    ErrorInfo.ErrorType := ErrorType::Client;
                    ErrorInfo.DetailedMessage := StrSubstNo(AlreadyProcessedMsg, RefundHeader."Refund Id");
                    ErrorInfo.Message := StrSubstNo(RefundErr, RefundHeader."Refund Id", ErrorInfo.DetailedMessage);
                    ErrorInfo.RecordId := RefundHeader.RecordId;
                    ErrorInfo.SystemId := RefundHeader.SystemId;
                    ErrorInfo.TableId := Database::"Shpfy Refund Header";
                    ErrorInfo.Verbosity := Verbosity::Warning;
                end;
    end;

    procedure CreateSalesDocument(SourceDocumentType: Enum "Shpfy Source Document Type"; SourceDocumentId: BigInteger) SalesHeader: Record "Sales Header"
    var
        CreateSalesDocRefund: codeunit "Shpfy Create Sales Doc. Refund";
        IDocumentSource: Interface "Shpfy IDocument Source";
        ErrorInfo: ErrorInfo;
        TextBuilder: TextBuilder;
    begin
        IDocumentSource := SourceDocumentType;
        Clear(SalesHeader);
        if not CanCreateSalesDocumentFor(SourceDocumentType, SourceDocumentId, ErrorInfo) then
            if ErrorInfo.Verbosity = Verbosity::Error then begin
                TextBuilder.AppendLine(ErrorInfo.Message);
                TextBuilder.AppendLine(ErrorInfo.DetailedMessage);
                IDocumentSource.SetErrorInfo(SourceDocumentId, TextBuilder.ToText());
                exit;
            end;

        CreateSalesDocRefund.SetSource(SourceDocumentId);
        CreateSalesDocRefund.SetTargetDocumentType("Sales Document Type"::"Credit Memo");
        Commit();
        if CreateSalesDocRefund.Run() then begin
            SalesHeader := CreateSalesDocRefund.GetSalesHeader();
            IDocumentSource.SetErrorInfo(SourceDocumentId, '');
        end else
            IDocumentSource.SetErrorInfo(SourceDocumentId, GetLastErrorText(false));
        Commit();
    end;
}