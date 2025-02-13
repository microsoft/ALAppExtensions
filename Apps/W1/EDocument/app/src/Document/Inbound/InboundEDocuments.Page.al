// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Attachment;
using Microsoft.eServices.EDocument.Processing.Import;

#pragma implicitwith disable
page 6105 "Inbound E-Documents"
{
    ApplicationArea = Basic, Suite;
    SourceTable = "E-Document";
    PageType = List;
    UsageCategory = Lists;
    AdditionalSearchTerms = 'Edoc,Inbound,Incoming,E-Doc,Electronic Document,EDocuments,E Documents,E invoices,Einvoices,Electronic';
    RefreshOnActivate = true;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTableView = sorting("Entry No") order(descending) where(Direction = const("E-Document Direction"::Incoming));

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
                    ToolTip = 'Specifies the entry number.';
                }
                field("Vendor Name"; Rec."Bill-to/Pay-to Name")
                {
                    ToolTip = 'Specifies the vendor name of the electronic document.';
                }
                field("Status"; Rec.Status)
                {
                    Caption = 'Document Status';
                    ToolTip = 'Specifies the status of the electronic document.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ToolTip = 'Specifies the document type of the electronic document.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number of the electronic document.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ToolTip = 'Specifies the document date.';
                }
                field("File Name"; Rec."File Name")
                {
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
                Caption = 'Details';
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
                Caption = 'Import other File';
                ToolTip = 'Create an electronic document by manually uploading a file.';
                Image = Import;

                trigger OnAction()
                begin
                    NewFromFile();
                end;
            }
            action(Process)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Process';
                ToolTip = 'Process the selected electronic document.';
                Image = Process;
                Enabled = Rec."Entry No" <> 0;

                trigger OnAction()
                begin
                    ProcessEDocument();
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
                Caption = 'View file';
                ToolTip = 'View the source file.';
                Image = ViewDetails;

                trigger OnAction()
                begin
                    Rec.ViewSourceFile();
                end;
            }
            action(Remove)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Remove';
                ToolTip = 'Test';
                Image = TestFile;

                trigger OnAction()
                var
                    EDocumentPurchaseHeader: Record "E-Document Purchase Header";
                    EDocumentHeaderMapping: Record "E-Document Header Mapping";
                begin
                    Rec.DeleteAll();
                    EDocumentPurchaseHeader.DeleteAll();
                    EDocumentHeaderMapping.DeleteAll();

                    Rec.Init();
                    Rec."File Name" := 'Test';
                    Rec."File Type" := Rec."File Type"::PDF;
                    Rec.Insert();


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
            actionref(Promoted_Process; Process) { }
            actionref(Promoted_EDocumentServices; EDocumentServices) { }
            actionref(Promoted_ViewFile; ViewFile) { }
        }
    }

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
    end;

    local procedure ProcessEDocument()
    var
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocImport: Codeunit "E-Doc. Import";
        EDocumentHelper: Codeunit "E-Document Helper";
    begin
        if not EDocumentHelper.EnsureInboundEDocumentHasService(Rec) then
            exit;

        EDocImportParameters."Step to Run" := EDocImportParameters."Step to Run"::"Prepare draft";
        EDocImport.ProcessIncomingEDocument(Rec, EDocImportParameters);

        EDocumentHelper.OpenDraftPage(Rec);
    end;
}

#pragma implicitwith restore
