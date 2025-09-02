// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Security.AccessControl;
using Microsoft.eServices.EDocument.Processing.Import;

page 6108 "Inbound E-Doc. Factbox"
{
    PageType = CardPart;
    UsageCategory = None;
    ApplicationArea = Basic, Suite;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTable = "E-Document Service Status";

    layout
    {
        area(Content)
        {
            field("E-Document Service"; Rec."E-Document Service Code")
            {
                Caption = 'Service';
                ToolTip = 'Specifies the E-Document Service that retrieved this document ';
            }
            field("Status"; Rec.Status)
            {
                Caption = 'Service Status';
                ToolTip = 'Specifies the stage in which the importing of this document is in';
            }
            field("Processing Status"; Format(Rec."Import Processing Status"))
            {
                Caption = 'Processing Status';
                ToolTip = 'Specifies the stage in which the processing of this document is in';
                Editable = false;
                Visible = ImportProcessingStatusVisible;
            }
            field(Logs; Rec.Logs())
            {
                Caption = 'Document Logs';
                ToolTip = 'Specifies the count of logs for an document. Drill down to access the logs.';

                trigger OnDrillDown()
                begin
                    Rec.ShowLogs();
                end;
            }
            field(HttpLogs; Rec.IntegrationLogs())
            {
                Caption = 'Integration Logs';
                ToolTip = 'Specifies the count of communication logs for the document. Drill down to access the logs.';

                trigger OnDrillDown()
                begin
                    Rec.ShowIntegrationLogs();
                end;
            }
            field("Created date"; EDocSystemCreatedAt)
            {
                Caption = 'Created Date';
                ToolTip = 'Specifies the date when the document was created';
            }
            field("Created by"; EDocSystemCreatedBy)
            {
                Caption = 'Created By';
                ToolTip = 'Specifies the user who created the document';
            }
#if not CLEAN27
            group(PDF)
            {
                ObsoleteReason = 'Replaced by "Inbound E-Doc. Picture"';
                ObsoleteState = Pending;
                ObsoleteTag = '27.0';

                Visible = false;
                ShowCaption = false;
                usercontrol(PDFViewer; "PDF Viewer")
                {
                    ObsoleteReason = 'Replaced by "Inbound E-Doc. Picture"';
                    ObsoleteState = Pending;
                    ObsoleteTag = '27.0';

                    ApplicationArea = All;
                    Visible = false;
                }
            }
#endif
        }
    }

#if not CLEAN27
    actions
    {
        area(Processing)
        {
            action(NextPdfPage)
            {
                ObsoleteReason = 'Replaced by "Inbound E-Doc. Picture"';
                ObsoleteState = Pending;
                ObsoleteTag = '27.0';

                Caption = 'Next pdf page';
                ToolTip = 'Next pdf page';
                ApplicationArea = All;
                Visible = false;
                Enabled = false;
                Image = NextRecord;

                trigger OnAction()
                begin
                    CurrPage.PDFViewer.NextPage();
                end;
            }
            action(PreviousPdfPage)
            {
                ObsoleteReason = 'Replaced by "Inbound E-Doc. Picture"';
                ObsoleteState = Pending;
                ObsoleteTag = '27.0';

                Caption = 'Previous pdf page';
                ToolTip = 'Previous pdf page';
                ApplicationArea = All;
                Visible = false;
                Enabled = false;
                Image = PreviousRecord;

                trigger OnAction()
                begin
                    CurrPage.PDFViewer.PreviousPage();
                end;
            }
        }
    }
#endif

    var
        ImportProcessingStatusVisible, Visible : Boolean;
        EDocSystemCreatedAt: DateTime;
        EDocSystemCreatedBy: Text;

    trigger OnOpenPage()
    var
        EDocument: Record "E-Document";
        EDocumentsSetup: Record "E-Documents Setup";
    begin
        if EDocument.Get(Rec."E-Document Entry No") then;
        ImportProcessingStatusVisible := EDocumentsSetup.IsNewEDocumentExperienceActive() and (EDocument.GetEDocumentService().GetImportProcessVersion() = Enum::"E-Document Import Process"::"Version 2.0");
    end;

    trigger OnAfterGetCurrRecord()
    var
        EDocument: Record "E-Document";
    begin
        if EDocument.Get(Rec."E-Document Entry No") then
            UpdateStatus(EDocument);
    end;

    trigger OnAfterGetRecord()
    var
        EDocument: Record "E-Document";
    begin
        if EDocument.Get(Rec."E-Document Entry No") then;
    end;

    local procedure UpdateStatus(EDocument: Record "E-Document")
    var
        User: Record User;
    begin
        if EDocument."Entry No" = 0 then
            exit;

        EDocSystemCreatedAt := EDocument.SystemCreatedAt;
        if User.Get(EDocument.SystemCreatedBy) then
            EDocSystemCreatedBy := User."Full Name"
        else
            EDocSystemCreatedBy := 'System';
    end;

}


