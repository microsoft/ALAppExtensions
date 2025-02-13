// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using System.Utilities;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.Attachment;

page 6181 "E-Document Purchase Draft"
{
    ApplicationArea = Basic, Suite;
    DataCaptionExpression = DataCaption;
    PageType = Card;
    SourceTable = "E-Document";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Record; RecordLinkTxt)
                {
                    Caption = 'Document';
                    Editable = false;
                    Importance = Promoted;
                    ToolTip = 'Specifies the record, document, journal line, or ledger entry, that is linked to the electronic document.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowRecord();
                        CurrPage.Update();
                    end;
                }
                field("Status"; Rec.Status)
                {
                    Caption = 'Status';
                    Importance = Promoted;
                    ToolTip = 'Specifies the current state of the electronic document.';
                    StyleExpr = StyleStatusTxt;
                    Editable = false;
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
                        Editable = true;
                        Lookup = true;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            LookupVendor();
                        end;
                    }
                    field("Vendor Name"; EDocumentPurchaseHeader."Vendor Name")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Vendor Name';
                        Importance = Promoted;
                        Editable = false;
                        ToolTip = 'Specifies the name of the vendor who delivers the products.';
                    }
                    field("Vendor Address"; EDocumentPurchaseHeader."Vendor Address")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Address';
                        Importance = Additional;
                        Editable = false;
                        ToolTip = 'Specifies the vendor''s buy-from address.';
                    }
                }
                group(Document)
                {
                    ShowCaption = false;
                    field("Document Type"; Rec."Document Type")
                    {
                        Importance = Additional;
                        ToolTip = 'Specifies the electronic document type.';
                        Editable = false;
                    }
                    field("Document No."; EDocumentPurchaseHeader."Sales Invoice No.")
                    {
                        Importance = Promoted;
                        ToolTip = 'Specifies the electronic document number.';
                        Editable = false;
                    }
                    field("Document Date"; EDocumentPurchaseHeader."Invoice Date")
                    {
                        ToolTip = 'Specifies the document date of the electronic document.';
                        Importance = Promoted;
                        Editable = false;
                    }
                    field("Due Date"; EDocumentPurchaseHeader."Due Date")
                    {
                        Importance = Promoted;
                        ToolTip = 'Specifies the due date of the electronic document.';
                        Editable = false;
                    }
                }
            }
            part(Lines; "E-Doc. Purchase Draft Subform")
            {
                ApplicationArea = Suite;
                Editable = true;
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
                field("Amount Excl. VAT"; EDocumentPurchaseHeader.Total - EDocumentPurchaseHeader."Total Tax")
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
                Caption = 'Create Document';
                ToolTip = 'Process the selected electronic document into a business central document';
                Image = CreateDocument;
                Visible = ShowCreateDocumentAction;

                trigger OnAction()
                begin
                    ProcessEDocument();
                end;
            }
            action(AnalyzeDocument)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Analyze Document';
                ToolTip = 'Analyze the selected electronic document';
                Image = SendAsPDF;
                Visible = ShowAnalyzeDocumentAction;

                trigger OnAction()
                begin
                    AnalyzeEDocument();
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
            }
        }
    }

    trigger OnOpenPage()
    begin
        if EDocumentPurchaseHeader.Get(Rec."Entry No") then;
        if EDocumentHeaderMapping.Get(Rec."Entry No") then;
        EDocumentServiceStatus := Rec.GetEDocumentServiceStatus();
        HasErrorsOrWarnings := false;
        HasErrors := false;
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
        DataCaption := 'Purchase Document Draft ' + Format(Rec."Entry No");

        ShowCreateDocumentAction := Rec.GetEDocumentImportProcessingStatus() = Enum::"Import E-Doc. Proc. Status"::"Draft Ready";
        ShowAnalyzeDocumentAction :=
            (Rec.GetEDocumentImportProcessingStatus() = Enum::"Import E-Document Steps"::"Structure received data") and
            (Rec.Status = Enum::"E-Document Status"::Error);
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
        RecordLinkTxt, StyleStatusTxt, ServiceStatusStyleTxt, VendorName, DataCaption : Text;
        HasErrorsOrWarnings, HasErrors : Boolean;
        ShowCreateDocumentAction: Boolean;
        ShowAnalyzeDocumentAction: Boolean;
        EDocHasErrorOrWarningMsg: Label 'Errors or warnings found for E-Document. Please review below in "Error Messages" section.';

}
