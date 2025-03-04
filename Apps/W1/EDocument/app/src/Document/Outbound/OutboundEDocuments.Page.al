// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Foundation.Attachment;
using Microsoft.eServices.EDocument.Service;

page 6106 "Outbound E-Documents"
{
    ApplicationArea = Basic, Suite;
    Extensible = false;
    SourceTable = "E-Document";
    CardPageId = "E-Document";
    PageType = List;
    RefreshOnActivate = true;
    Editable = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    SourceTableView = sorting("Entry No") order(descending) where(Direction = const(Direction::Outgoing));

    layout
    {
        area(Content)
        {
            repeater(DocumentList)
            {
                ShowCaption = false;
                field("Entry No"; Rec."Entry No")
                {
                    Caption = 'No.';
                    ToolTip = 'Specifies the entry number.';
                }
                field("Customer Name"; Rec."Bill-to/Pay-to Name")
                {
                    ToolTip = 'Specifies the customer name of the electronic document.';
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
            part("Outbound E-Doc. Factbox"; "Outbound E-Doc. Factbox")
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
            actionref(Promoted_EDocumentServices; EDocumentServices) { }
        }
    }

    trigger OnOpenPage()
    var
        EDocumentsSetup: Record "E-Documents Setup";
    begin
        if not EDocumentsSetup.IsNewEDocumentExperienceActive() then
            Error('');
    end;

}
