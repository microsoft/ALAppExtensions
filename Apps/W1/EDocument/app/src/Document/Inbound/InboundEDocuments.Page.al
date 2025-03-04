// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Attachment;
using Microsoft.eServices.EDocument.Processing.Import;

page 6105 "Inbound E-Documents"
{
    ApplicationArea = Basic, Suite;
    SourceTable = "E-Document";
    PageType = List;
    RefreshOnActivate = true;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTableView = sorting(SystemCreatedAt) order(descending) where(Direction = const("E-Document Direction"::Incoming));

    layout
    {
        area(Content)
        {

            repeater(DocumentList)
            {
                ShowCaption = false;
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Received At';
                    ToolTip = 'Specifies the date and time when the electronic document was created.';
                    trigger OnDrillDown()
                    begin
                        EDocumentHelper.OpenDraftPage(Rec);
                    end;
                }
                field("Entry No"; Rec."Entry No")
                {
                    Caption = 'No.';
                    ToolTip = 'Specifies the entry number.';
                }
                field("File Name"; Rec."File Name")
                {
                    Caption = 'Source File';
                    ToolTip = 'Specifies the name of the source file.';

                    trigger OnDrillDown()
                    begin
                        Rec.ViewSourceFile();
                    end;
                }
                field("File Type"; Rec."File Type")
                {
                    ToolTip = 'Specifies the type of the source file.';
                    Visible = false;
                }
                field("Vendor Name"; Rec."Bill-to/Pay-to Name")
                {
                    Caption = 'Vendor Name';
                    ToolTip = 'Specifies the vendor name of the electronic document.';
                }
                field("Status"; Rec.Status)
                {
                    Caption = 'Status';
                    ToolTip = 'Specifies the status of the electronic document.';
                }
                field("Import Processing Status"; ImportProcessingStatus)
                {
                    Caption = 'Processing Status';
                    ToolTip = 'Specifies the processing status of the inbound electronic document.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the document type of the electronic document.';
                }
                field("Document Record ID"; RecordLinkTxt)
                {
                    Caption = 'Document';
                    ToolTip = 'Specifies the document created from the electronic document.';
                    trigger OnDrillDown()
                    begin
                        Rec.ShowRecord();
                    end;
                }
                field(Service; Rec.Service)
                {
                    ToolTip = 'Specifies the service code of the electronic document.';
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
            action(ImportPdf)
            {
                Caption = 'Import PDF';
                ToolTip = 'Create an electronic document by importing a PDF file.';
                Image = SendAsPDF;

                trigger OnAction()
                begin
                    NewFromPdf();
                end;
            }
            action(ImportXML)
            {
                Caption = 'Import XML';
                ToolTip = 'Create an electronic document by importing an XML file.';
                Image = XMLFile;

                trigger OnAction()
                begin
                    NewFromXml();
                end;
            }
            action(ImportManually)
            {
                Caption = 'Import other file';
                ToolTip = 'Create an electronic document by manually uploading a file.';
                Image = Import;

                trigger OnAction()
                begin
                    NewFromFile();
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
            actionref(Promoted_Process; OpenDraftDocument) { }
            actionref(Promoted_EDocumentServices; EDocumentServices) { }
            actionref(Promoted_ViewFile; ViewFile) { }
        }
    }

    var
        EDocumentHelper: Codeunit "E-Document Helper";
        ImportProcessingStatus: Enum "Import E-Doc. Proc. Status";
        ProcessDialogMsg: Label 'Processing pdf...';
        RecordLinkTxt: Text;

    trigger OnAfterGetRecord()
    var
        EDocumentProcessing: Codeunit "E-Document Processing";
    begin
        ImportProcessingStatus := Rec.GetEDocumentImportProcessingStatus();
        RecordLinkTxt := EDocumentProcessing.GetRecordLinkText(Rec);
    end;

    trigger OnOpenPage()
    var
        EDocumentsSetup: Record "E-Documents Setup";
    begin
        if not EDocumentsSetup.IsNewEDocumentExperienceActive() then
            Error('');
    end;

    local procedure NewFromFile()
    var
        EDocument: Record "E-Document";
        EDocImport: Codeunit "E-Doc. Import";
    begin
        EDocImport.UploadDocument(EDocument);
        if EDocument."Entry No" = 0 then
            exit;
    end;

    local procedure NewFromPdf()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocImport: Codeunit "E-Doc. Import";
        FileName: Text;
        InStr: InStream;
    begin
        if not UploadIntoStream('', '', '', FileName, InStr) then
            exit;

        EDocumentService.GetPDFReaderService();
        EDocImport.CreateFromType(EDocument, EDocumentService, Enum::"E-Doc. Data Storage Blob Type"::PDF, FileName, InStr);

        ProcessEDocument(EDocument);
    end;

    local procedure NewFromXml()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocImport: Codeunit "E-Doc. Import";
        FileName: Text;
        InStr: InStream;
    begin
        if Page.RunModal(Page::"E-Document Services", EDocumentService) <> Action::LookupOK then
            exit;

        if not UploadIntoStream('', '', '', FileName, InStr) then
            exit;

        EDocImport.CreateFromType(EDocument, EDocumentService, Enum::"E-Doc. Data Storage Blob Type"::XML, FileName, InStr);
        ProcessEDocument(EDocument);
    end;

    local procedure ProcessEDocument(var EDocument: Record "E-Document")
    var
        EDocImport: Codeunit "E-Doc. Import";
        Progress: Dialog;
    begin
        if not EDocumentHelper.EnsureInboundEDocumentHasService(EDocument) then
            exit;

        Progress.Open(ProcessDialogMsg);
        if not EDocImport.ProcessAutomaticallyIncomingEDocument(EDocument) then
            exit;
        Progress.Close();
        if EDocument.GetEDocumentImportProcessingStatus() = "Import E-Doc. Proc. Status"::"Draft Ready" then
            EDocumentHelper.OpenDraftPage(EDocument);
    end;

}
