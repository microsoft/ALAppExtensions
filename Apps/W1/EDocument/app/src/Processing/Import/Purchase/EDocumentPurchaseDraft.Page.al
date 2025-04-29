#pragma warning disable AS0050
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Processing.Import.Purchase;

using System.Utilities;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.Foundation.Attachment;
using Microsoft.Purchases.Vendor;

page 6181 "E-Document Purchase Draft"
{
    ApplicationArea = Basic, Suite;
    DataCaptionExpression = DataCaption;
    Caption = 'Purchase Document Draft';
    PageType = Card;
    SourceTable = "E-Document";
    InsertAllowed = false;
    DeleteAllowed = true;
    ModifyAllowed = true;
    Extensible = false;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Record; RecordLinkTxt)
                {
                    Caption = 'Finalized Document';
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the record, document, journal line, or ledger entry, that is linked to the electronic document.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowRecord();
                        CurrPage.Update();
                    end;
                }
                group("Buy-from")
                {
                    ShowCaption = false;
                    field("Vendor No."; EDocumentHeaderMapping."Vendor No.")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Vendor No.';
                        Importance = Promoted;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the number of the vendor who delivers the products.';
                        Editable = PageEditable;
                        Lookup = true;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            LookupVendor();
                        end;
                    }
                    field("Vendor Name"; EDocumentPurchaseHeader."Vendor Company Name")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Vendor Name';
                        Importance = Promoted;
                        Editable = false;
                        ToolTip = 'Specifies the extracted name of the vendor who delivers the products.';
                    }
                    field("Vendor Address"; EDocumentPurchaseHeader."Vendor Address")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Vendor Address';
                        Importance = Additional;
                        Editable = false;
                        ToolTip = 'Specifies the extracted vendor''s address.';
                    }
                }
                group(Document)
                {
                    ShowCaption = false;
                    field("Document Type"; Rec."Document Type")
                    {
                        Importance = Additional;
                        Caption = 'Document Type';
                        ToolTip = 'Specifies the electronic document type.';
                        Editable = false;
                    }
                    field("Document No."; EDocumentPurchaseHeader."Sales Invoice No.")
                    {
                        Importance = Promoted;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the extracted ID for this specific document.';
                        Editable = false;
                    }
                    field("Document Date"; EDocumentPurchaseHeader."Invoice Date")
                    {
                        Caption = 'Document Date';
                        ToolTip = 'Specifies the extracted document date.';
                        Importance = Promoted;
                        Editable = false;
                    }
                    field("Due Date"; EDocumentPurchaseHeader."Due Date")
                    {
                        Importance = Promoted;
                        Caption = 'Due Date';
                        ToolTip = 'Specifies the extracted due date.';
                        Editable = false;
                    }
                }
                field("Status"; Rec.Status)
                {
                    Caption = 'Status';
                    Importance = Additional;
                    ToolTip = 'Specifies whether the EDocument is in progress and awaiting processing, has been processed into a Purchase Document, or encountered an error. The processing behavior depends on the EDocument Service setup.';
                    StyleExpr = StyleStatusTxt;
                    Editable = false;
                }
            }
            part(Lines; "E-Doc. Purchase Draft Subform")
            {
                ApplicationArea = Suite;
                Editable = PageEditable;
                SubPageLink = "E-Document Entry No." = field("Entry No");
                UpdatePropagation = Both;
            }
            group("E-Document Details")
            {
                ShowCaption = false;
                field("Amount Incl. VAT"; EDocumentPurchaseHeader.Total)
                {
                    ToolTip = 'Specifies the total amount of the electronic document including VAT.';
                    Editable = false;
                    Importance = Promoted;
                }
                field("Amount Excl. VAT"; EDocumentPurchaseHeader.Total - EDocumentPurchaseHeader."Total VAT")
                {
                    Caption = 'Amount Excl. VAT';
                    ToolTip = 'Specifies the total amount of the electronic document excluding VAT.';
                    Importance = Promoted;
                    Editable = false;
                }
                field("Currency Code"; EDocumentPurchaseHeader."Currency Code")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies the electronic document currency code.';
                    Editable = false;
                }
            }

            part(ErrorMessagesPart; "Error Messages Part")
            {
                Visible = HasErrorsOrWarnings;
                ShowFilter = false;
                UpdatePropagation = Both;
            }
        }
        area(factboxes)
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
            action(CreateDocument)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Finalize draft';
                ToolTip = 'Process the electronic document into a business central document';
                Image = CreateDocument;
                Visible = ShowFinalizeDraftAction;

                trigger OnAction()
                begin
                    ProcessEDocument();
                    PageEditable := ConditionallyEditable();
                    CurrPage.Lines.Page.Update();
                    CurrPage.Update();
                end;
            }
            action(AnalyzeDocument)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Analyze document';
                ToolTip = 'Analyze the selected electronic document';
                Image = SendAsPDF;
                Visible = ShowAnalyzeDocumentAction;

                trigger OnAction()
                begin
                    AnalyzeEDocument();
                end;
            }
            action(ViewFile)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'View pdf';
                ToolTip = 'View pdf.';
                Image = ViewDetails;
                Visible = Rec."File Type" = Rec."File Type"::PDF;

                trigger OnAction()
                begin
                    Rec.ViewSourceFile();
                end;
            }
            action(ViewExtractedDocumentData)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'View extracted data';
                ToolTip = 'View the extracted data from the source file.';
                Image = ViewRegisteredOrder;

                trigger OnAction()
                var
                    EDocumentPurchaseHeader: Record "E-Document Purchase Header";
                begin
                    EDocumentPurchaseHeader.GetFromEDocument(Rec);
                    Page.Run(Page::"E-Doc. Readable Purchase Doc.", EDocumentPurchaseHeader);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Promoted_CreateDocument; CreateDocument)
                {
                }
                actionref(Promoted_AnalyseDocument; AnalyzeDocument)
                {
                }
                actionref(Promoted_ViewFile; ViewFile)
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        EDocumentsSetup: Record "E-Documents Setup";
        ImportEDocumentProcess: Codeunit "Import E-Document Process";
    begin
        if not EDocumentsSetup.IsNewEDocumentExperienceActive() then
            Error('');
        if EDocumentPurchaseHeader.Get(Rec."Entry No") then begin
            AIGeneratedContentNotification.Message(ImportEDocumentProcess.AIGeneratedContentText());
            AIGeneratedContentNotification.AddAction(ImportEDocumentProcess.TermsAndConditionsText(), Codeunit::"Import E-Document Process", 'OpenTermsAndConditions');
            AIGeneratedContentNotification.Send();
        end;
        if EDocumentHeaderMapping.Get(Rec."Entry No") then;
        EDocumentServiceStatus := Rec.GetEDocumentServiceStatus();
        HasErrorsOrWarnings := false;
        HasErrors := false;
        PageEditable := ConditionallyEditable();
    end;

    local procedure ConditionallyEditable(): Boolean
    var
        RecRef: RecordRef;
    begin
        if Rec."Document Record ID".TableNo() = 0 then
            exit(true);

        if not TryOpen(RecRef, Rec."Document Record ID".TableNo()) then
            exit(true);

        exit(not RecRef.Get(Rec."Document Record ID"));
    end;

    [TryFunction]
    local procedure TryOpen(var RecRef: RecordRef; TableNo: Integer)
    begin
        RecRef.Open(TableNo);
    end;

    trigger OnAfterGetRecord()
    begin
        RecordLinkTxt := EDocumentProcessing.GetRecordLinkText(Rec);
        HasErrorsOrWarnings := (EDocumentErrorHelper.ErrorMessageCount(Rec) + EDocumentErrorHelper.WarningMessageCount(Rec)) > 0;
        HasErrors := EDocumentErrorHelper.ErrorMessageCount(Rec) > 0;
        if HasErrorsOrWarnings then
            ShowErrorsAndWarnings()
        else
            ClearErrorsAndWarnings();

        SetStyle();
        SetPageCaption();

        ShowFinalizeDraftAction := Rec.GetEDocumentImportProcessingStatus() = Enum::"Import E-Doc. Proc. Status"::"Draft Ready";
        ShowAnalyzeDocumentAction :=
            (Rec.GetEDocumentImportProcessingStatus() = Enum::"Import E-Document Steps"::"Structure received data") and
            (Rec.Status = Enum::"E-Document Status"::Error);
    end;

    local procedure SetPageCaption()
    var
        Vendor: Record Vendor;
        CaptionBuilder: TextBuilder;
    begin
        if Rec."File Name" <> '' then
            CaptionBuilder.Append(Rec."File Name" + ' - ');

        EDocumentHeaderMapping := Rec.GetEDocumentHeaderMapping();
        if Vendor.Get(EDocumentHeaderMapping."Vendor No.") then
            CaptionBuilder.Append(Vendor.Name + ' - ')
        else begin
            EDocumentPurchaseHeader := EDocumentHeaderMapping.GetEDocumentPurchaseHeader();
            if EDocumentPurchaseHeader."Vendor Company Name" <> '' then
                CaptionBuilder.Append(EDocumentPurchaseHeader."Vendor Company Name" + ' - ');
        end;

        CaptionBuilder.Append(Format(Rec."Entry No"));
        DataCaption := CaptionBuilder.ToText();
    end;

    local procedure SetStyle()
    begin
        case Rec.Status of
            Rec.Status::Error:
                StyleStatusTxt := 'Unfavorable';
            Rec.Status::Processed:
                StyleStatusTxt := 'Favorable';
            else
                StyleStatusTxt := 'None';
        end;
    end;

    local procedure ShowErrorsAndWarnings()
    var
        ErrorMessage: Record "Error Message";
        TempErrorMessage: Record "Error Message" temporary;
    begin
        ErrorMessage.SetRange("Context Record ID", Rec.RecordId);
        ErrorMessage.CopyToTemp(TempErrorMessage);
        CurrPage.ErrorMessagesPart.Page.SetRecords(TempErrorMessage);
        CurrPage.ErrorMessagesPart.Page.Update(false);

        ErrorsAndWarningsNotification.Message(EDocHasErrorOrWarningMsg);
        ErrorsAndWarningsNotification.Send();
    end;

    local procedure LookupVendor()
    var
        Vendor: Record Vendor;
        VendorList: Page "Vendor List";
    begin
        VendorList.LookupMode := true;
        if VendorList.RunModal() = Action::LookupOK then begin
            VendorList.GetRecord(Vendor);
            EDocumentHeaderMapping."Vendor No." := Vendor."No.";
            EDocumentHeaderMapping.Modify();
        end;
    end;

    local procedure ClearErrorsAndWarnings()
    var
        TempErrorMessage: Record "Error Message" temporary;
    begin
        CurrPage.ErrorMessagesPart.Page.SetRecords(TempErrorMessage);
        CurrPage.ErrorMessagesPart.Page.Update(false);
    end;

    local procedure ProcessEDocument()
    var
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocImport: Codeunit "E-Doc. Import";
        EDocumentHelper: Codeunit "E-Document Helper";
        ImportEdocumentProcess: Codeunit "Import E-Document Process";
    begin
        if not EDocumentHelper.EnsureInboundEDocumentHasService(Rec) then
            exit;

        EDocImportParameters."Step to Run" := ImportEdocumentProcess.GetNextStep(Rec.GetEDocumentImportProcessingStatus());
        EDocImport.ProcessIncomingEDocument(Rec, EDocImportParameters);
    end;

    local procedure AnalyzeEDocument()
    var
        EDocumentService: Record "E-Document Service";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocImport: Codeunit "E-Doc. Import";
    begin
        EDocumentService.GetPDFReaderService();
        Rec.TestField("Service", EDocumentService.Code);

        EDocImportParameters."Step to Run" := Enum::"Import E-Document Steps"::"Structure received data";
        EDocImport.ProcessIncomingEDocument(Rec, EDocImportParameters);
    end;

    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentHeaderMapping: Record "E-Document Header Mapping";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        EDocumentProcessing: Codeunit "E-Document Processing";
        ErrorsAndWarningsNotification: Notification;
        AIGeneratedContentNotification: Notification;
        RecordLinkTxt, StyleStatusTxt, ServiceStatusStyleTxt, VendorName, DataCaption : Text;
        HasErrorsOrWarnings, HasErrors : Boolean;
        ShowFinalizeDraftAction: Boolean;
        ShowAnalyzeDocumentAction: Boolean;
        EDocHasErrorOrWarningMsg: Label 'Errors or warnings found for E-Document. Please review below in "Error Messages" section.';
        PageEditable: Boolean;
}
#pragma warning restore AS0050
