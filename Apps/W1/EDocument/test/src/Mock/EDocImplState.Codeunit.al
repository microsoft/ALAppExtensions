codeunit 139630 "E-Doc. Impl. State"
{
    EventSubscriberInstance = Manual;

    var
        TmpPurchHeader: Record "Purchase Header" temporary;
        TmpPurchLine: Record "Purchase Line" temporary;
        PurchDocTestBuffer: Codeunit "E-Doc. Test Buffer";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        EnableOnCheck, DisableOnCreateOutput, DisableOnCreateBatch, IsAsync2, EnableHttpData, ThrowIntegrationRuntimeError, ThrowIntegrationLoggedError : Boolean;
        ThrowRuntimeError, ThrowLoggedError, ThrowBasicInfoError, ThrowCompleteInfoError, OnGetResponseSuccess, OnGetApprovalSuccess : Boolean;
        LocalHttpResponse: HttpResponseMessage;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Export", 'OnAfterCreateEDocument', '', false, false)]
    local procedure OnAfterCreateEDocument(var EDocument: Record "E-Document")
    begin
        LibraryVariableStorage.Enqueue(EDocument);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Export", 'OnBeforeCreateEDocument', '', false, false)]
    local procedure OnBeforeCreatedEDocument(var EDocument: Record "E-Document")
    begin
        LibraryVariableStorage.Enqueue(EDocument);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Format Mock", 'OnCheck', '', false, false)]
    local procedure OnCheck(var SourceDocumentHeader: RecordRef; EDocService: Record "E-Document Service"; EDocumentProcessingPhase: enum "E-Document Processing Phase")
    var
        ErrorMessageMgt: Codeunit "Error Message Management";
    begin
        if not EnableOnCheck then
            exit;
        if ThrowRuntimeError then
            Error('TEST');
        if ThrowLoggedError then
            ErrorMessageMgt.LogErrorMessage(4, 'TEST', EDocService, EDocService.FieldNo("Auto Import"), '');

        LibraryVariableStorage.Enqueue(SourceDocumentHeader);
        LibraryVariableStorage.Enqueue(EDocService);
        LibraryVariableStorage.Enqueue(EDocumentProcessingPhase.AsInteger());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Format Mock", 'OnCreate', '', false, false)]
    local procedure OnCreate(EDocService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: codeunit "Temp Blob")
    var
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        OutStream: OutStream;
    begin
        if ThrowRuntimeError then
            Error('TEST');
        if ThrowLoggedError then
            EDocErrorHelper.LogErrorMessage(EDocument, EDocService, EDocService.FieldNo("Auto Import"), 'TEST');

        if not DisableOnCreateOutput then begin
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText('TEST');
            LibraryVariableStorage.Enqueue(TempBlob.Length());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Format Mock", 'OnCreateBatch', '', false, false)]
    local procedure OnCreateBatch(EDocService: Record "E-Document Service"; var EDocuments: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: codeunit "Temp Blob")
    var
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        OutStream: OutStream;
    begin
        if ThrowRuntimeError then
            Error('TEST');
        if ThrowLoggedError then
            EDocErrorHelper.LogErrorMessage(EDocuments, EDocService, EDocService.FieldNo("Auto Import"), 'TEST');

        if not DisableOnCreateBatch then begin
            TempBlob.CreateOutStream(OutStream);
            OutStream.WriteText('TEST');
            LibraryVariableStorage.Enqueue(TempBlob.Length());
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Format Mock", 'OnGetBasicInfoFromReceivedDocument', '', false, false)]
    local procedure OnGetBasicInfoFromReceivedDocument(var EDocument: Record "E-Document"; var TempBlob: codeunit "Temp Blob")
    var
        CompanyInformation: Record "Company Information";
        GLSetup: Record "General Ledger Setup";
    begin
        if ThrowBasicInfoError then
            Error('Test Get Basic Info From Received Document Error.');

        CompanyInformation.Get();
        GLSetup.Get();

        PurchDocTestBuffer.GetPurchaseDocToTempVariables(TmpPurchHeader, TmpPurchLine);
        if TmpPurchHeader.FindFirst() then begin
            if EDocument."Index In Batch" <> 0 then
                TmpPurchHeader.Next(EDocument."Index In Batch" - 1);

            case TmpPurchHeader."Document Type" of
                TmpPurchHeader."Document Type"::Invoice:
                    begin
                        EDocument."Document Type" := EDocument."Document Type"::"Purchase Invoice";
                        EDocument."Incoming E-Document No." := TmpPurchHeader."Vendor Invoice No.";
                    end;
                TmpPurchHeader."Document Type"::"Credit Memo":
                    begin
                        EDocument."Document Type" := EDocument."Document Type"::"Purchase Credit Memo";
                        EDocument."Incoming E-Document No." := TmpPurchHeader."Vendor Cr. Memo No.";
                    end;
            end;

            EDocument."Bill-to/Pay-to No." := TmpPurchHeader."Pay-to Vendor No.";
            EDocument."Bill-to/Pay-to Name" := TmpPurchHeader."Pay-to Name";
            EDocument."Document Date" := TmpPurchHeader."Document Date";
            EDocument."Due Date" := TmpPurchHeader."Due Date";
            EDocument."Receiving Company VAT Reg. No." := CompanyInformation."VAT Registration No.";
            EDocument."Receiving Company GLN" := CompanyInformation.GLN;
            EDocument."Receiving Company Name" := CompanyInformation.Name;
            EDocument."Receiving Company Address" := CompanyInformation.Address;
            EDocument."Currency Code" := GLSetup."LCY Code";
            TmpPurchHeader.CalcFields(Amount, "Amount Including VAT");
            EDocument."Amount Excl. VAT" := TmpPurchHeader.Amount;
            EDocument."Amount Incl. VAT" := TmpPurchHeader."Amount Including VAT";
            EDocument."Order No." := PurchDocTestBuffer.GetEDocOrderNo();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Format Mock", 'OnGetCompleteInfoFromReceivedDocument', '', false, false)]
    local procedure OnGetCompleteInfoFromReceivedDocument(var EDocument: Record "E-Document"; var CreatedDocumentHeader: RecordRef; var CreatedDocumentLines: RecordRef; var TempBlob: codeunit "Temp Blob")
    var
        TmpPurchHeader2: Record "Purchase Header" temporary;
        TmpPurchLine2: Record "Purchase Line" temporary;
    begin
        if ThrowCompleteInfoError then
            Error('Test Get Complete Info From Received Document Error.');

        PurchDocTestBuffer.GetPurchaseDocToTempVariables(TmpPurchHeader, TmpPurchLine);
        if TmpPurchHeader.FindFirst() then begin
            if EDocument."Index In Batch" <> 0 then
                TmpPurchHeader.Next(EDocument."Index In Batch" - 1);

            TmpPurchHeader2.Init();
            TmpPurchHeader2.TransferFields(TmpPurchHeader);
            TmpPurchHeader2."Vendor Invoice No." := TmpPurchHeader."No.";
            TmpPurchHeader2.Insert();

            TmpPurchLine.SetRange("Document Type", TmpPurchHeader."Document Type");
            TmpPurchLine.SetRange("Document No.", TmpPurchHeader."No.");
            if TmpPurchLine.FindSet() then
                repeat
                    TmpPurchLine2.Init();
                    TmpPurchLine2.TransferFields(TmpPurchLine);
                    TmpPurchLine2.Insert();
                until TmpPurchLine.Next() = 0;
        end;

        CreatedDocumentHeader.GetTable(TmpPurchHeader2);
        CreatedDocumentLines.GetTable(TmpPurchLine2);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Integration Mock", 'OnSend', '', false, false)]
    local procedure OnSend(var EDocument: Record "E-Document"; var TempBlob: Codeunit "Temp Blob"; var IsAsync: Boolean; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        EDocErrorHelper: Codeunit "E-Document Error Helper";
    begin
        IsAsync := IsAsync2;
        HttpResponse := LocalHttpResponse;

        if ThrowIntegrationRuntimeError then
            Error('TEST');

        if ThrowIntegrationLoggedError then
            EDocErrorHelper.LogSimpleErrorMessage(EDocument, 'TEST');

        if EnableHttpData then begin
            HttpRequest.SetRequestUri('http://cronus.test');
            HttpRequest.Method := 'POST';

            HttpRequest.Content.WriteFrom('Test request');
            HttpResponse.Content.WriteFrom('Test response');
            HttpResponse.Headers.Add('Accept', '*');
        end;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Integration Mock", 'OnGetResponse', '', false, false)]
    local procedure OnGetResponse(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Success: Boolean)
    var
        EDocErrorHelper: Codeunit "E-Document Error Helper";
    begin
        Success := OnGetResponseSuccess;
        HttpResponse := LocalHttpResponse;

        if ThrowIntegrationRuntimeError then
            Error('TEST');

        if ThrowIntegrationLoggedError then
            EDocErrorHelper.LogSimpleErrorMessage(EDocument, 'TEST');

        if EnableHttpData then begin
            HttpRequest.SetRequestUri('http://cronus.test');
            HttpRequest.Method := 'POST';

            HttpRequest.Content.WriteFrom('Test request');
            HttpResponse.Content.WriteFrom('Test response');
            HttpResponse.Headers.Add('Accept', '*');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Integration Mock", 'OnGetDocumentCountInBatch', '', false, false)]
    local procedure OnGetDocumentCountInBatch(var Count: Integer)
    var
        TmpPurchHeader: Record "Purchase Header" temporary;
        TmpPurchLine: Record "Purchase Line" temporary;
        PurchDocTestBuffer: Codeunit "E-Doc. Test Buffer";
    begin
        if LibraryVariableStorage.Length() > 0 then
            Count := LibraryVariableStorage.DequeueInteger()
        else begin
            PurchDocTestBuffer.GetPurchaseDocToTempVariables(TmpPurchHeader, TmpPurchLine);
            Count := TmpPurchHeader.Count();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Integration Mock", 'OnReceiveDocument', '', false, false)]
    local procedure OnReceiveDocument(var TempBlob: codeunit "Temp Blob"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage)
    var
        OutStr: OutStream;
    begin
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        if LibraryVariableStorage.Length() > 0 then
            OutStr.WriteText(LibraryVariableStorage.DequeueText())
        else
            OutStr.WriteText('Some Test Content');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Integration Mock", 'OnGetApproval', '', false, false)]
    local procedure OnGetApproval(var EDocument: Record "E-Document"; var HttpRequest: HttpRequestMessage; var HttpResponse: HttpResponseMessage; var Success: Boolean)
    var
        EDocErrorHelper: Codeunit "E-Document Error Helper";
    begin
        Success := OnGetApprovalSuccess;
        HttpResponse := LocalHttpResponse;

        if ThrowIntegrationRuntimeError then
            Error('TEST');

        if ThrowIntegrationLoggedError then
            EDocErrorHelper.LogSimpleErrorMessage(EDocument, 'TEST');
    end;

    internal procedure SetOnGetApprovalSuccess()
    begin
        OnGetApprovalSuccess := true;
    end;

    internal procedure SetOnGetResponseSuccess()
    begin
        OnGetResponseSuccess := true;
    end;

    internal procedure SetThrowCompleteInfoError()
    begin
        ThrowCompleteInfoError := true;
    end;

    internal procedure SetThrowBasicInfoError()
    begin
        ThrowBasicInfoError := true;
    end;

    internal procedure SetDisableOnCreateOutput()
    begin
        DisableOnCreateOutput := true;
    end;

    internal procedure SetDisableOnCreateBatchOutput()
    begin
        DisableOnCreateBatch := true;
    end;

    internal procedure EnableOnCheckEvent()
    begin
        EnableOnCheck := true;
    end;

    internal procedure SetThrowRuntimeError()
    begin
        ThrowRuntimeError := true;
    end;

    internal procedure SetThrowLoggedError()
    begin
        ThrowLoggedError := true;
    end;

    internal procedure SetIsAsync()
    begin
        IsAsync2 := true;
    end;

    internal procedure SetEnableHttpData()
    begin
        EnableHttpData := true;
    end;

    internal procedure SetThrowIntegrationLoggedError()
    begin
        ThrowIntegrationLoggedError := true;
    end;

    internal procedure SetThrowIntegrationRuntimeError()
    begin
        ThrowIntegrationRuntimeError := true;
    end;

    internal procedure SetHttpResponse(HttpResponse: HttpResponseMessage)
    begin
        LocalHttpResponse := HttpResponse;
    end;

    internal procedure SetVariableStorage(var NewLibraryVariableStorage: Codeunit "Library - Variable Storage")
    begin
        LibraryVariableStorage := NewLibraryVariableStorage;
    end;

    internal procedure GetVariableStorage(var NewLibraryVariableStorage: Codeunit "Library - Variable Storage")
    begin
        NewLibraryVariableStorage := LibraryVariableStorage;
    end;


}