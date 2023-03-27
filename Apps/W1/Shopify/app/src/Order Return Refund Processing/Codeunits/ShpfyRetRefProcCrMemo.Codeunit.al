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
        NotProcessedErr: Label 'The Shopify Order %1 is not yet processed. The order must be processed befor you can create an credit memo.';
        AlreadyProcessedMsg: Label 'The refund with "%1": %2 is already processed.', Comment = '%1 = FieldCaption of "Shopify Refund Id", %2 = Refund Id';
        OrderNotFoundErr: Label 'The shopify order with "%1": %2 is not found in tha table %3', Comment = '%1 = FieldCaption of "Shopify Order Id", %2 = OrderId, %3 = TableCaption("Shpfy Order Header")';
        RefundErr: Label 'Can not create a credit memo for the refund with id: %1', Comment = '%1 = Refund Id';
    begin
        RefundHeader.LoadFields("Refund Id", "Order Id");
        RefundHeader.SetAutoCalcFields("Is Processed");
        if SourceDocumentType = "Shpfy Source Document Type"::Refund then
            if RefundHeader.Get(SourceDocumentId) then
                if not RefundHeader."Is Processed" then
                    if OrderHeader.Get(RefundHeader."Order Id") then
                        if OrderHeader.IsProcessed() or OrderHeader.Processed then
                            exit(true)
                        else begin
                            ErrorInfo.ErrorType := ErrorType::Client;
                            ErrorInfo.DetailedMessage := StrSubstNo(NotProcessedErr, OrderHeader."Shopify Order No.");
                            ErrorInfo.Message := StrSubstNo(RefundErr, RefundHeader."Refund Id");
                            ErrorInfo.RecordId := RefundHeader.RecordId;
                            ErrorInfo.SystemId := RefundHeader.SystemId;
                            ErrorInfo.TableId := Database::"Shpfy Refund Header";
                            ErrorInfo.Verbosity := Verbosity::Error;
                        end
                    else begin
                        ErrorInfo.ErrorType := ErrorType::Client;
                        ErrorInfo.DetailedMessage := StrSubstNo(OrderNotFoundErr, OrderHeader.FieldCaption("Shopify Order Id"), RefundHeader."Order Id", OrderHeader.TableCaption);
                        ErrorInfo.Message := StrSubstNo(RefundErr, RefundHeader."Refund Id");
                        ErrorInfo.RecordId := RefundHeader.RecordId;
                        ErrorInfo.SystemId := RefundHeader.SystemId;
                        ErrorInfo.TableId := Database::"Shpfy Refund Header";
                        ErrorInfo.Verbosity := Verbosity::Error;
                    end
                else begin
                    ErrorInfo.ErrorType := ErrorType::Client;
                    ErrorInfo.DetailedMessage := StrSubstNo(AlreadyProcessedMsg, RefundHeader.FieldCaption("Refund Id"), RefundHeader."Order Id");
                    ErrorInfo.Message := StrSubstNo(RefundErr, RefundHeader."Refund Id");
                    ErrorInfo.RecordId := RefundHeader.RecordId;
                    ErrorInfo.SystemId := RefundHeader.SystemId;
                    ErrorInfo.TableId := Database::"Shpfy Refund Header";
                    ErrorInfo.Verbosity := Verbosity::Warning;
                end;
    end;

    procedure CreateSalesDocument(SourceDocumentType: Enum "Shpfy Source Document Type"; SourceDocumentId: BigInteger) SalesHeader: Record "Sales Header"
    var
        CreateSalesDocRefund: codeunit "Shpfy Create Sales Doc. Refund";
        IDocumentrSource: Interface "Shpfy IDocument Source";
        ErrorInfo: ErrorInfo;
        TextBuilder: TextBuilder;
    begin
        IDocumentrSource := SourceDocumentType;
        Clear(SalesHeader);
        if not CanCreateSalesDocumentFor(SourceDocumentType, SourceDocumentId, ErrorInfo) then
            if ErrorInfo.Verbosity = Verbosity::Error then begin
                TextBuilder.AppendLine(ErrorInfo.Message);
                TextBuilder.AppendLine(ErrorInfo.DetailedMessage);
                IDocumentrSource.SetErrorInfo(SourceDocumentId, TextBuilder.ToText());
                exit;
            end;

        CreateSalesDocRefund.SetSource(SourceDocumentId);
        CreateSalesDocRefund.SetTargetDocumentType("Sales Document Type"::"Credit Memo");
        Commit();
        if CreateSalesDocRefund.Run() then begin
            SalesHeader := CreateSalesDocRefund.GetSalesHeader();
            IDocumentrSource.SetErrorInfo(SourceDocumentId, '');
        end else
            IDocumentrSource.SetErrorInfo(SourceDocumentId, GetLastErrorText(false));
        Commit();
    end;
}
