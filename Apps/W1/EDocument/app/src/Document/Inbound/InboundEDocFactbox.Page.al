// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Text;
using System.Utilities;
using System.Security.AccessControl;

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
                ToolTip = 'Specifies the service code of an E-Document';
            }
            field("Status"; Rec.Status)
            {
                Caption = 'Service Status';
                ToolTip = 'Specifies the status of an E-Document';
            }
            field("Processing Status"; Format(Rec."Import Processing Status"))
            {
                Caption = 'Processing Status';
                ToolTip = 'Specifies the processing status of an E-Document';
                Editable = false;
                Visible = ImportProcessingStatusVisible;
            }
            field(Logs; Rec.Logs())
            {
                Caption = 'Document Logs';
                ToolTip = 'Specifies the count of logs for an E-Document';

                trigger OnDrillDown()
                begin
                    Rec.ShowLogs();
                end;
            }
            field(HttpLogs; Rec.IntegrationLogs())
            {
                Caption = 'Integration Logs';
                ToolTip = 'Specifies the count of communication logs for an E-Document';

                trigger OnDrillDown()
                begin
                    Rec.ShowIntegrationLogs();
                end;
            }
            field("Created date"; EDocSystemCreatedAt)
            {
                Caption = 'Created Date';
                ToolTip = 'Specifies the date when the E-Document was created';
            }
            field("Created by"; EDocSystemCreatedBy)
            {
                Caption = 'Created By';
                ToolTip = 'Specifies the user who created the E-Document';
            }
            group(PDF)
            {
                Visible = IsPdf;
                ShowCaption = false;
                usercontrol(PDFViewer; "PDF Viewer")
                {
                    ApplicationArea = All;

                    trigger ControlAddinReady()
                    var
                        EDocument: Record "E-Document";
                    begin
                        if EDocument.Get(Rec."E-Document Entry No") then begin
                            ControlAddInReady := true;
                            SetPDFDocument(EDocument);
                        end
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NextPdfPage)
            {
                Caption = 'Next pdf page';
                ToolTip = 'Next pdf page';
                ApplicationArea = All;
                Visible = IsPdf;
                Image = NextRecord;

                trigger OnAction()
                begin
                    CurrPage.PDFViewer.NextPage();
                end;
            }
            action(PreviousPdfPage)
            {
                Caption = 'Previous pdf page';
                ToolTip = 'Previous pdf page';
                ApplicationArea = All;
                Visible = IsPdf;
                Image = PreviousRecord;

                trigger OnAction()
                begin
                    CurrPage.PDFViewer.PreviousPage();
                end;
            }
        }
    }

    var
        IsPdf, ControlAddInReady : Boolean;
        ImportProcessingStatusVisible, Visible : Boolean;
        EDocSystemCreatedAt: DateTime;
        EDocSystemCreatedBy: Text;

    trigger OnOpenPage()
    var
        EDocumentsSetup: Record "E-Documents Setup";
    begin
        ImportProcessingStatusVisible := EDocumentsSetup.IsNewEDocumentExperienceActive();
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
        IsPdf := EDocument."File Type" = EDocument."File Type"::PDF;

        // If new record is selected, then reload the PDF document
        if Rec."E-Document Entry No" <> xRec."E-Document Entry No" then
            SetPDFDocument(EDocument);
    end;

    local procedure SetPDFDocument(EDocument: Record "E-Document")
    var
        EDocumentDataStorage: Record "E-Doc. Data Storage";
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        InStreamVar: InStream;
        PDFAsTxt: Text;
    begin
        if not ControlAddInReady then
            exit;

        if (EDocument."Unstructured Data Entry No." <> 0) then begin
            Visible := true;
            EDocumentDataStorage.Get(EDocument."Unstructured Data Entry No.");
            EDocumentDataStorage.CalcFields("Data Storage");
            TempBlob.FromRecord(EDocumentDataStorage, EDocumentDataStorage.FieldNo("Data Storage"));

            TempBlob.CreateInStream(InStreamVar);
            PDFAsTxt := Base64Convert.ToBase64(InStreamVar);
            CurrPage.PDFViewer.LoadPDF(PDFAsTxt);
        end;
        CurrPage.PDFViewer.SetVisible(Visible);
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


