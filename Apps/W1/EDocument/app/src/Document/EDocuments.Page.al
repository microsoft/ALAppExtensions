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
            action(ImportManually)
            {
                Caption = 'New From File';
                ToolTip = 'Create an electronic document by manually uploading a file.';
                Image = Import;

                trigger OnAction()
                begin
                    NewFromFile();
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
        }
        area(Promoted)
        {
            actionref(Promoted_ImportManually; ImportManually) { }
            actionref(Promoted_EDocumentServices; EDocumentServices) { }
        }
    }

    var
        DocNotCreatedQst: Label 'Failed to create new %1 from E-Document. Do you want to open E-Document and see the reported errors?', Comment = '%1 - E-Document Document Type';


    local procedure NewFromFile()
    var
        EDocument: Record "E-Document";
        EDocImport: Codeunit "E-Doc. Import";
        EDocErrorHelper: Codeunit "E-Document Error Helper";
    begin
        EDocImport.UploadDocument(EDocument);
        if EDocument."Entry No" <> 0 then begin
            EDocImport.ProcessDocument(EDocument, false);
            if EDocErrorHelper.HasErrors(EDocument) then
                if Confirm(DocNotCreatedQst, true, EDocument."Document Type") then
                    Page.Run(Page::"E-Document", EDocument);
        end;
    end;
}
