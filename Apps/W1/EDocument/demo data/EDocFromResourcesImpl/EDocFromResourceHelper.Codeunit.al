codeunit 5405 "E-Doc. From Resource Helper"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Purch. Inv. Header" = rimd,
                  tabledata "Purch. Inv. Line" = rimd;

    /// <summary>
    ///  Creates E-Documents from PDF files located in the .resources\PDFs folder.
    /// </summary>
    procedure CreateEDocumentsFromResources()
    var
        EDocumentService: Record "E-Document Service";
        CreateEDocDemodataService: Codeunit "Create E-Doc DemoData Service";
        DocumentPaths: List of [Text];
        IsHandled: Boolean;
        NoPDFFilesInResourcesFolderErr: Label 'No pfd files found in the .resources\PDFs folder.';
        NoSubscribertoOnGetListOfPDFResourcesErr: Label 'No subscriber to OnGetListOfPDFResources event.';
    begin
        OnGetListOfPDFResources(DocumentPaths, IsHandled);
        if not IsHandled then
            error(NoSubscribertoOnGetListOfPDFResourcesErr);
        if DocumentPaths.Count = 0 then
            Error(NoPDFFilesInResourcesFolderErr);

        EDocumentService.Get(CreateEDocDemodataService.EDocumentServiceCode());
        CreteEDocFromResourceMappings();
        CreateEDocsFromResources(DocumentPaths, EDocumentService);
    end;

    local procedure CreateEDocsFromResources(DocumentPaths: List of [Text]; EDocumentService: Record "E-Document Service")
    var
        EDocument: Record "E-Document";
        PurchInvHeader: Record "Purch. Inv. Header";
        DocumentPath: Text;
    begin
        foreach DocumentPath in DocumentPaths do begin
            ClearLastError();
            EDocument := ImportDocument(EDocumentService, DocumentPath);
            MapPurchaseDocumentDraftLines(EDocument);
            FinalizeDraft(EDocumentService, EDocument);
            PurchInvHeader := PostPurchInvoice(EDocument);
        end;
    end;

    local procedure ImportDocument(EDocumentService: Record "E-Document Service"; DocumentPath: Text) EDocument: Record "E-Document";
    var
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocImport: Codeunit "E-Doc. Import";
        ResInStream: InStream;
        FileName: Text;
        IsHandled: Boolean;
        NoSubscriberToOnGetResourceInStreamWhenImportDocumentErr: Label 'No subscriber to OnGetResourceInStreamWhenImportDocument event.';
    begin
        OnGetResourceInStreamWhenImportDocument(ResInStream, DocumentPath, IsHandled);
        if not IsHandled then
            error(NoSubscriberToOnGetResourceInStreamWhenImportDocumentErr);
        FileName := DocumentPath.Substring(DocumentPath.LastIndexOf('/') + 1);
        EDocImport.CreateFromType(
            EDocument, EDocumentService,
            Enum::"E-Doc. File Format"::PDF, FileName, ResInStream);
        EDocument."Structure Data Impl." := Enum::"Structure Received E-Doc."::"ADI Mock";
        EDocument.Modify();
        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Read into Draft";
        EDocImport.ProcessIncomingEDocument(
            EDocument, EDocumentService, EDocImportParameters);
    end;

    local procedure MapPurchaseDocumentDraftLines(EDocument: Record "E-Document")
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        PurchaseLineCannotBeMappedErr: Label 'Purchase line cannot be mapped. Check that you have item reference, text-to account mapping or associated allocation account. Description: %1', Locked = true;
    begin
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        EDocumentPurchaseLine.SetRange("[BC] Purchase Line Type", EDocumentPurchaseLine."[BC] Purchase Line Type"::" ");
        if not EDocumentPurchaseLine.FindSet(true) then
            exit;
        repeat
            if not MapPurchaseDocumentDraftLine(EDocumentPurchaseLine) then
                Error(PurchaseLineCannotBeMappedErr, EDocumentPurchaseLine.Description);
        until EDocumentPurchaseLine.Next() = 0;
        if not EDocumentPurchaseLine.IsEmpty() then
            error(PurchaseLineCannotBeMappedErr);
    end;

    local procedure MapPurchaseDocumentDraftLine(var EDocumentPurchaseLine: Record "E-Document Purchase Line"): Boolean
    begin
        if TryMapPurchaseDraftLineToAllocationAccount(EDocumentPurchaseLine) then
            exit(true);
        exit(MapPurchaseDraftLineToEDocFromResourceMapping(EDocumentPurchaseLine));
    end;

    local procedure TryMapPurchaseDraftLineToAllocationAccount(var EDocumentPurchaseLine: Record "E-Document Purchase Line"): Boolean
    var
        AllocationAccount: Record "Allocation Account";
    begin
        AllocationAccount.SetRange(Name, EDocumentPurchaseLine.Description);
        if not AllocationAccount.FindFirst() then
            exit(false);
        EDocumentPurchaseLine.Validate("[BC] Purchase Line Type", EDocumentPurchaseLine."[BC] Purchase Line Type"::"Allocation Account");
        EDocumentPurchaseLine.Validate("[BC] Purchase Type No.", AllocationAccount."No.");
        EDocumentPurchaseLine.Modify(true);
        exit(true);
    end;

    local procedure MapPurchaseDraftLineToEDocFromResourceMapping(var EDocumentPurchaseLine: Record "E-Document Purchase Line"): Boolean
    var
        EDocFromResourceMapping: Record "E-Doc From Resource Mapping";
    begin
        if EDocumentPurchaseLine."Product Code" <> '' then begin
            EDocFromResourceMapping.SetRange("Product Code", EDocumentPurchaseLine."Product Code");
            if not EDocFromResourceMapping.FindFirst() then
                exit(false);
            EDocumentPurchaseLine.Validate("[BC] Purchase Line Type", EDocFromResourceMapping.Type);
            EDocumentPurchaseLine.Validate("[BC] Purchase Type No.", EDocFromResourceMapping."No.");
            EDocumentPurchaseLine.Validate("[BC] Unit of Measure", EDocFromResourceMapping."Unit of Measure");
            EDocumentPurchaseLine.Modify(true);
            exit(true);
        end;
        EDocFromResourceMapping.SetRange(Description, EDocumentPurchaseLine.Description);
        if not EDocFromResourceMapping.FindFirst() then
            exit(false);
        EDocumentPurchaseLine.Validate("[BC] Purchase Line Type", EDocFromResourceMapping.Type);
        EDocumentPurchaseLine.Validate("[BC] Purchase Type No.", EDocFromResourceMapping."No.");
        EDocumentPurchaseLine.Modify(true);
        exit(true);
    end;

    local procedure FinalizeDraft(EDocumentService: Record "E-Document Service"; EDocument: Record "E-Document")
    var
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocImport: Codeunit "E-Doc. Import";
    begin
        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Finish draft";
        EDocImport.ProcessIncomingEDocument(
            EDocument, EDocumentService, EDocImportParameters);
    end;

    local procedure PostPurchInvoice(EDocument: Record "E-Document") PurchInvHeader: Record "Purch. Inv. Header";
    var
        PurchaseHeader: Record "Purchase Header";
        PurchPost: Codeunit "Purch.-Post";
        PurchHeaderNotFoundForEdocErr: Label 'Purchase Header not found for E-Document with ID %1. Possible reason: %2', Comment = '%1 = E-Document ID, %2 = Last error text';
    begin
        EDocument.Find();
        if not PurchaseHeader.Get(EDocument."Document Record ID") then
            Error(PurchHeaderNotFoundForEdocErr, EDocument."Document Record ID", GetLastErrorText());
        if PurchaseHeader."Document Date" = 0D then
            PurchaseHeader.Validate("Document Date", PurchaseHeader."Posting Date");
        PurchaseHeader.Invoice := true;
        PurchaseHeader.Receive := true;
        PurchaseHeader.Modify();
        OnBeforePostPurchaseInvoice(PurchaseHeader);

        PurchPost.Run(PurchaseHeader);
        PurchInvHeader.SetRange("Pre-Assigned No.", PurchaseHeader."No.");
        PurchInvHeader.FindFirst();
    end;

    local procedure CreteEDocFromResourceMappings()
    var
        IsHandled: Boolean;
        NMoSubscriberToOnBeforeCreteEDocFromResourceMappingsErr: Label 'No subscriber to OnBeforeCreteEDocFromResourceMappings event.';
    begin
        OnBeforeCreateEDocFromResourceMappings(IsHandled);
        if not IsHandled then
            error(NMoSubscriberToOnBeforeCreteEDocFromResourceMappingsErr);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetListOfPDFResources(var PDFResourcesList: List of [Text]; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostPurchaseInvoice(var PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetResourceInStreamWhenImportDocument(var InStr: InStream; ResourceName: Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateEDocFromResourceMappings(var IsHandled: Boolean)
    begin
    end;
}