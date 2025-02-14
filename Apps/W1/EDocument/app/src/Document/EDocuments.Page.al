// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

page 6122 "E-Documents"
{
    ApplicationArea = Basic, Suite;
    SourceTable = "E-Document";
    CardPageId = "E-Document";
    PageType = List;
    UsageCategory = Lists;
    AdditionalSearchTerms = 'Edoc,Electronic Document,EDocuments,E Documents,E invoices,Einvoices,Electronic';
    RefreshOnActivate = true;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTableView = sorting("Entry No") order(descending);

    layout
    {
        area(Content)
        {
            repeater(DocumentList)
            {
                ShowCaption = false;
                field("Entry No"; Rec."Entry No")
                {
                    ToolTip = 'Specifies the entry number.';
                }
                field("Bill-to/Pay-to No."; Rec."Bill-to/Pay-to No.")
                {
                    ToolTip = 'Specifies the customer/vendor of the electronic document.';
                }
                field("Bill-to/Pay-to Name"; Rec."Bill-to/Pay-to Name")
                {
                    ToolTip = 'Specifies the customer/vendor name of the electronic document.';
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
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the status of the electronic document.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
#if not CLEAN26
            action(ImportManually)
            {
                Caption = 'New From File';
                ToolTip = 'Create an electronic document by manually uploading a file.';
                Image = Import;
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '26.0';
                ObsoleteReason = 'Functionality moved to "Import Files" action.';

                trigger OnAction()
                begin
                    NewFromFile();
                end;
            }
#endif
            fileuploadaction(ImportManuallyMultiple)
            {
                Caption = 'Import Files';
                ToolTip = 'Create electronic documents by uploading single or multiple files.';
                Image = Import;
                AllowedFileExtensions = '.xml';
                AllowMultipleFiles = true;

                trigger OnAction(Files: List of [FileUpload])
                var
                    EDocumentService: Record "E-Document Service";
                    EDocImport: Codeunit "E-Doc. Import";
                begin
                    if EDocImport.ChooseEDocumentService(EDocumentService) then begin
                        EDocImport.UploadDocuments(Files, EDocumentService);
                        CurrPage.Update(false);
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
                Caption = 'View file';
                ToolTip = 'View the source file.';
                Image = ViewDetails;

                trigger OnAction()
                begin
                    Rec.ViewSourceFile();
                end;
            }
        }
        area(Promoted)
        {
#if not CLEAN26
            actionref(Promoted_ImportManually; ImportManually)
            {
                Visible = false;
                ObsoleteState = Pending;
                ObsoleteTag = '26.0';
                ObsoleteReason = 'Functionality moved to "Import Files" action.';
            }
#endif
            actionref(Promoted_ImportManuallyMultiple; ImportManuallyMultiple) { }
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
        if EDocument."Entry No" <> 0 then begin
            EDocImport.ProcessIncomingEDocument(EDocument, EDocument.GetEDocumentService().GetDefaultImportParameters());
            Page.Run(Page::"E-Document", EDocument);
        end;
    end;
}
