// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AS0031, AS0032
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Attachment;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.Purchases.Vendor;

page 6105 "Inbound E-Documents"
{
    ApplicationArea = Basic, Suite;
    SourceTable = "E-Document";
    PageType = List;
    RefreshOnActivate = true;
    Editable = false;
    DeleteAllowed = true;
    InsertAllowed = false;
    SourceTableView = sorting(SystemCreatedAt) order(descending) where(Direction = const("E-Document Direction"::Incoming));

    layout
    {
        area(Content)
        {

            repeater(DocumentList)
            {
                ShowCaption = false;
                field("Entry No"; Rec."Entry No")
                {
                    Caption = 'Entry No.';
                    ToolTip = 'Specifies the unique number of the electronic document.';
                    Visible = false;
                }
                field("Document Name"; DocumentNameTxt)
                {
                    Caption = 'Document';
                    ToolTip = 'Specifies the unique name for the document.';
                    trigger OnDrillDown()
                    begin
                        EDocumentHelper.OpenDraftPage(Rec);
                    end;
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Received At';
                    ToolTip = 'Specifies the date and time when the electronic document was created.';
                }
                field(Service; Rec.Service)
                {
                    Visible = false;
                    Caption = 'Service';
                    ToolTip = 'Specifies the service code of the electronic document.';
                }
                field("Service Integration"; Rec."Service Integration")
                {
                    Caption = 'Source';
                    ToolTip = 'Specifies the source of the electronic document.';
                }
                field("Source Details"; Rec."Source Details")
                {
                    Caption = 'Source Details';
                    ToolTip = 'Specifies the details about the source of the electronic document.';
                }
                field("Vendor Name"; VendorNameTxt)
                {
                    Caption = 'Sender';
                    ToolTip = 'Specifies the vendor name of the electronic document.';
                }
                field("Import Processing Status"; ImportProcessingStatus)
                {
                    Caption = 'Processing Status';
                    ToolTip = 'Specifies the processing status of the inbound electronic document.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    Caption = 'Finalized Document Type';
                    ToolTip = 'Specifies the document type of the electronic document.';
                }
                field("Document Record ID"; RecordLinkTxt)
                {
                    Caption = 'Finalized Document No.';
                    ToolTip = 'Specifies the document created from the electronic document.';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowRecord();
                    end;
                }
            }
        }
        area(FactBoxes)
        {
            part("Attached Documents List"; "Doc. Attachment List Factbox")
            {
                ApplicationArea = All;
                Caption = 'Documents';
                UpdatePropagation = Both;
                SubPageLink = "E-Document Entry No." = field("Entry No"),
                              "E-Document Attachment" = const(true);
            }
            part(InboundEDocFactbox; "Inbound E-Doc. Factbox")
            {
                Caption = 'E-Document';
                SubPageLink = "E-Document Entry No" = field("Entry No");
                ShowFilter = false;
            }
        }
    }
    actions
    {
        area(Processing)
        {

            fileuploadaction(ImportPdf)
            {
                Caption = 'Import PDF';
                ToolTip = 'Create an electronic document by importing a PDF file.';
                AllowedFileExtensions = '.pdf';
                AllowMultipleFiles = true;
                Image = SendAsPDF;

                trigger OnAction(Files: List of [FileUpload])
                begin
                    NewFromPdf(Files);
                end;
            }
            fileuploadaction(ImportXML)
            {
                Caption = 'Import XML';
                ToolTip = 'Create an electronic document by importing an XML file.';
                AllowedFileExtensions = '.xml';
                AllowMultipleFiles = true;
                Image = XMLFile;

                trigger OnAction(Files: List of [FileUpload])
                begin
                    NewFromXml(Files);
                end;
            }
            fileuploadaction(ImportManually)
            {
                Caption = 'Import other file';
                ToolTip = 'Create an electronic document by manually uploading a file.';
                Image = Import;
                AllowMultipleFiles = true;

                trigger OnAction(Files: List of [FileUpload])
                begin
                    NewFromFile(Files);
                end;
            }
            action(OpenDraftDocument)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Open draft document';
                ToolTip = 'Process the selected electronic document.';
                Image = PurchaseInvoice;
                Enabled = Rec."Entry No" <> 0;

                trigger OnAction()
                var
                    EDocImportParameters: Record "E-Doc. Import Parameters";
                    EDocImport: Codeunit "E-Doc. Import";
                    ImportEDocumentProcess: Codeunit "Import E-Document Process";
                begin
                    if ImportEDocumentProcess.IsEDocumentInStateGE(Rec, Enum::"Import E-Doc. Proc. Status"::"Ready for draft") then
                        EDocumentHelper.OpenDraftPage(Rec)
                    else begin
                        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Prepare draft";
                        EDocImport.ProcessIncomingEDocument(Rec, EDocImportParameters);
                    end;
                end;
            }
            action(EDocumentServices)
            {
                RunObject = Page "E-Document Services";
                Caption = 'E-Document Services';
                ToolTip = 'Opens E-Document Services page.';
                Image = Server;
            }
            action(EDocumentLogs)
            {
                RunObject = Page "E-Document Logs";
                Caption = 'E-Document Logs';
                ToolTip = 'Opens E-Document Logs page.';
                Image = Log;
            }
            action(ViewFile)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'View source file';
                ToolTip = 'View the source file.';
                Image = ViewDetails;

                trigger OnAction()
                begin
                    Rec.ViewSourceFile();
                end;
            }
            action(DownloadFile)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Download file';
                ToolTip = 'Download the source file.';
                Image = Download;

                trigger OnAction()
                begin
                    Rec.ExportDataStorage();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_New)
            {
                Caption = 'Import';
                ShowAs = SplitButton;

                actionref(Promoted_ImportPdf; ImportPdf)
                {
                }
                actionref(Promoted_ImportXML; ImportXML)
                {
                }
                actionref(Promoted_ImportManually; ImportManually)
                {
                }
            }
            actionref(Promoted_ViewFile; ViewFile) { }
            actionref(Promoted_EDocumentServices; EDocumentServices) { }
        }
    }

    var
        EDocumentHelper: Codeunit "E-Document Helper";
        ImportProcessingStatus: Enum "Import E-Doc. Proc. Status";
        RecordLinkTxt, VendorNameTxt, DocumentNameTxt : Text;

    trigger OnAfterGetRecord()
    var
        EDocumentProcessing: Codeunit "E-Document Processing";
    begin
        ImportProcessingStatus := Rec.GetEDocumentImportProcessingStatus();
        RecordLinkTxt := EDocumentProcessing.GetRecordLinkText(Rec);
        PopulateDocumentNameTxt();
        PopulateVendorNameTxt();
    end;

    local procedure PopulateDocumentNameTxt()
    var
        CaptionBuilder: TextBuilder;
    begin
        if Rec."File Name" <> '' then
            CaptionBuilder.Append(Rec."File Name" + ' - ')
        else
            CaptionBuilder.Append('Draft document - ');

        CaptionBuilder.Append(Format(Rec."Entry No"));
        DocumentNameTxt := CaptionBuilder.ToText();
    end;

    local procedure PopulateVendorNameTxt()
    var
        EDocumentHeaderMapping: Record "E-Document Header Mapping";
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        Vendor: Record Vendor;
    begin
        VendorNameTxt := Rec."Bill-to/Pay-to Name";
        EDocumentHeaderMapping := Rec.GetEDocumentHeaderMapping();
        if Vendor.Get(EDocumentHeaderMapping."Vendor No.") then
            VendorNameTxt := Vendor.Name
        else begin
            EDocumentPurchaseHeader := EDocumentHeaderMapping.GetEDocumentPurchaseHeader();
            if EDocumentPurchaseHeader."Vendor Company Name" <> '' then
                VendorNameTxt := EDocumentPurchaseHeader."Vendor Company Name";
        end;
    end;

    trigger OnOpenPage()
    var
        EDocumentsSetup: Record "E-Documents Setup";
    begin
        if not EDocumentsSetup.IsNewEDocumentExperienceActive() then
            Error('');
    end;

    #region File Upload Actions

    local procedure NewFromFile(Files: List of [FileUpload])
    var
        EDocumentService: Record "E-Document Service";
    begin
        if not ChooseEDocumentService(EDocumentService) then
            exit;

        ProcessFilesUploads(EDocumentService, Files, Enum::"E-Doc. Data Storage Blob Type"::Unspecified);
    end;

    local procedure NewFromPdf(Files: List of [FileUpload])
    var
        EDocumentService: Record "E-Document Service";
    begin
        EDocumentService.GetPDFReaderService();
        ProcessFilesUploads(EDocumentService, Files, Enum::"E-Doc. Data Storage Blob Type"::PDF);
    end;

    local procedure NewFromXml(Files: List of [FileUpload])
    var
        EDocumentService: Record "E-Document Service";
    begin
        if not ChooseEDocumentService(EDocumentService) then
            exit;

        ProcessFilesUploads(EDocumentService, Files, Enum::"E-Doc. Data Storage Blob Type"::XML);
    end;

    local procedure ProcessFilesUploads(EDocumentService: Record "E-Document Service"; Files: List of [FileUpload]; Type: Enum "E-Doc. Data Storage Blob Type")
    var
        EDocument: Record "E-Document";
        EDocImport: Codeunit "E-Doc. Import";
        File: FileUpload;
        InStream: InStream;
        OpenDraft, Processed : Boolean;
        DocumentIndex: Integer;
        TotalFiles, ProcessedFiles, FailedFiles : Integer;
        Progress: Dialog;
        Msg: Label 'Processing documents...\To Import:#1#######\Failed:#2#######\Imported:#3#######', Comment = '#1 Number of to import, #2 Number of failed, #3 = Number of imported';
    begin
        DocumentIndex := 1;
        if GuiAllowed() then begin
            TotalFiles := Files.Count();
            Progress.Open(Msg, TotalFiles, FailedFiles, ProcessedFiles);
            Progress.Update(1, TotalFiles);
            Progress.Update(2, FailedFiles);
            Progress.Update(3, ProcessedFiles);
        end;
        foreach File in Files do begin
            Clear(EDocument);

            // Open last document in the list
            OpenDraft := Files.Count() = DocumentIndex;
            DocumentIndex += 1;

            File.CreateInStream(InStream);
            EDocImport.CreateFromType(EDocument, EDocumentService, Type, File.FileName, InStream);
            Processed := ProcessEDocument(EDocument, OpenDraft);

            if GuiAllowed() then begin
                ProcessedFiles += 1;
                if not Processed then
                    FailedFiles += 1;
                Progress.Update(2, FailedFiles);
                Progress.Update(3, ProcessedFiles);
            end;
        end;

        if GuiAllowed then
            Progress.Close();
    end;

    #endregion File Upload Actions

    local procedure ProcessEDocument(var EDocument: Record "E-Document"; OpenDraft: Boolean) Success: Boolean
    var
        EDocImport: Codeunit "E-Doc. Import";
    begin
        if not EDocumentHelper.EnsureInboundEDocumentHasService(EDocument) then
            exit;

        if not EDocImport.ProcessAutomaticallyIncomingEDocument(EDocument) then
            exit;

        Success := EDocument.GetEDocumentImportProcessingStatus() = "Import E-Doc. Proc. Status"::"Draft Ready";
        if Success and OpenDraft then
            EDocumentHelper.OpenDraftPage(EDocument);
    end;

    local procedure ChooseEDocumentService(var EDocumentService: Record "E-Document Service"): Boolean
    begin
        exit(Page.RunModal(Page::"E-Document Services", EDocumentService) = Action::LookupOK);
    end;

}

#pragma warning restore AS0031, AS0032