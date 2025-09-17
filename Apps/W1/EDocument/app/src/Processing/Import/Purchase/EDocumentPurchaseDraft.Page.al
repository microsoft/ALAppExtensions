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
using System.Telemetry;

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
                field(DraftType; Rec."Read into Draft Impl.")
                {
                    Caption = 'Draft Type';
                    ToolTip = 'Specifies the type of draft document.';
                    Visible = false;
                    Editable = false;
                }
                group("Buy-from")
                {
                    ShowCaption = false;
                    field("Vendor No."; EDocumentPurchaseHeader."[BC] Vendor No.")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Vendor No.';
                        Importance = Promoted;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the internal vendor identifier code.';
                        Editable = PageEditable;
                        Lookup = true;

                        trigger OnValidate()
                        begin
                            EDocumentPurchaseHeader.Validate("[BC] Vendor No.", EDocumentPurchaseHeader."[BC] Vendor No.");
                            EDocumentPurchaseHeader.Modify();
                            PrepareDraft();
                        end;

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            exit(LookupVendor(Text));
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
                        Editable = true;

                        trigger OnValidate()
                        begin
                            EDocumentPurchaseHeader.Modify();
                            CurrPage.Update();
                        end;
                    }
                    field("Document Date"; EDocumentPurchaseHeader."Document Date")
                    {
                        Caption = 'Document Date';
                        ToolTip = 'Specifies the extracted document date.';
                        Importance = Promoted;
                        Editable = true;

                        trigger OnValidate()
                        begin
                            EDocumentPurchaseHeader.Modify();
                            CurrPage.Update();
                        end;
                    }
                    field("Due Date"; EDocumentPurchaseHeader."Due Date")
                    {
                        Importance = Promoted;
                        Caption = 'Due Date';
                        ToolTip = 'Specifies the extracted due date.';
                        Editable = true;

                        trigger OnValidate()
                        begin
                            EDocumentPurchaseHeader.Modify();
                            CurrPage.Update();
                        end;
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
                field("Amount Excl. VAT"; EDocumentPurchaseHeader."Sub Total")
                {
                    Caption = 'Amount Excl. VAT';
                    ToolTip = 'Specifies the total amount of the electronic document excluding VAT.';
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        UpdateTotal();
                        EDocumentPurchaseHeader.Modify();
                        CurrPage.Update();
                    end;
                }
                field("Invoice Discount"; EDocumentPurchaseHeader."Total Discount")
                {
                    Caption = 'Invoice Discount';
                    ToolTip = 'Specifies the discount in addition to the lines';
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        UpdateTotal();
                        EDocumentPurchaseHeader.Modify();
                        CurrPage.Update();
                    end;
                }
                field("Total VAT"; EDocumentPurchaseHeader."Total VAT")
                {
                    Caption = 'Total VAT';
                    ToolTip = 'Specifies the total VAT';
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        UpdateTotal();
                        EDocumentPurchaseHeader.Modify();
                        CurrPage.Update();
                    end;
                }
                field("Amount Incl. VAT"; EDocumentPurchaseHeader.Total)
                {
                    ToolTip = 'Specifies the total amount of the electronic document including VAT.';
                    Importance = Promoted;

                    trigger OnValidate()
                    begin
                        EDocumentPurchaseHeader.Modify();
                        CurrPage.Update();
                    end;

                }
                field("Currency Code"; EDocumentPurchaseHeader."Currency Code")
                {
                    Importance = Promoted;
                    ToolTip = 'Specifies the electronic document currency code.';
                    Editable = true;

                    trigger OnValidate()
                    begin
                        EDocumentPurchaseHeader.Modify();
                        CurrPage.Update();
                    end;
                }
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
            part(InboundEDocPicture; "Inbound E-Doc. Picture")
            {
                Caption = 'E-Document Pdf Preview';
                SubPageLink = "Entry No." = field("Unstructured Data Entry No."),
                            "File Format" = const("E-Doc. File Format"::PDF);
                ShowFilter = false;
            }
            part(InboundEDocFactbox; "Inbound E-Doc. Factbox")
            {
                Caption = 'Details';
                SubPageLink = "E-Document Entry No" = field("Entry No");
                ShowFilter = false;
            }
            part(ErrorMessagesFactBox; "Error Messages Part")
            {
                Visible = false;
                ShowFilter = false;
                UpdatePropagation = Both;
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
                    FinalizeEDocument();
                end;
            }
            action(ResetDraftDocument)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reset draft';
                ToolTip = 'Resets the draft document. Any changes made to the draft document will be lost.';
                Image = Restore;
                Visible = true;
                trigger OnAction()
                begin
                    ResetDraft();
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
                Visible = HasPDFSource;

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
                    EDocImport: Codeunit "E-Doc. Import";
                begin
                    EDocImport.ViewExtractedData(Rec);
                end;
            }
        }
        area(Navigation)
        {
            group(Vendors)
            {
                Visible = false;
                action(CreateVendorAction)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Create Vendor';
                    ToolTip = 'Creates a vendor based on the invoice details.';
                    Image = Vendor;

                    trigger OnAction()
                    var
                        Vendor: Record Vendor;
                        VendorTemplMgt: Codeunit "Vendor Templ. Mgt.";
                        VendorCard: Page "Vendor Card";
                        IsHandled: Boolean;
                    begin
                        if VendorTemplMgt.CreateVendorFromTemplate(Vendor, IsHandled) then begin
                            Vendor.Validate(Blocked, Enum::"Vendor Blocked"::All);
                            Vendor.Modify();
                            VendorCard.SetRecord(Vendor);
                            VendorCard.Run();
                        end;
                    end;
                }
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
        EDocumentNotification: Codeunit "E-Document Notification";
    begin
        if not EDocumentsSetup.IsNewEDocumentExperienceActive() then
            Error('');

        if EDocumentPurchaseHeader.Get(Rec."Entry No") then;
        HasPDFSource := Rec."Read into Draft Impl." = "E-Doc. Read into Draft"::ADI;
        EDocumentServiceStatus := Rec.GetEDocumentServiceStatus();
        HasErrorsOrWarnings := false;
        HasErrors := false;
        PageEditable := IsEditable();
        EDocumentNotification.SendPurchaseDocumentDraftNotifications(Rec."Entry No");

        if Rec."Entry No" <> 0 then
            Rec.SetRecFilter(); // Filter the record to only this instance to avoid navigation 
    end;

    local procedure IsEditable(): Boolean
    begin
        exit(Rec.Status <> Rec.Status::Processed);
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

        Rec.CalcFields("Import Processing Status");
        ShowFinalizeDraftAction := Rec."Import Processing Status" = Enum::"Import E-Doc. Proc. Status"::"Draft Ready";
        ShowAnalyzeDocumentAction :=
            (Rec."Import Processing Status" = Enum::"Import E-Document Steps"::"Structure received data") and
            (Rec.Status = Enum::"E-Document Status"::Error);

        PageEditable := IsEditable();
    end;

    local procedure SetPageCaption()
    var
        Vendor: Record Vendor;
        CaptionBuilder: TextBuilder;
    begin
        if Rec."File Name" <> '' then
            CaptionBuilder.Append(Rec."File Name" + ' - ');

        EDocumentPurchaseHeader.GetFromEDocument(Rec);
        if Vendor.Get(EDocumentPurchaseHeader."[BC] Vendor No.") then
            CaptionBuilder.Append(Vendor.Name + ' - ')
        else
            if EDocumentPurchaseHeader."Vendor Company Name" <> '' then
                CaptionBuilder.Append(EDocumentPurchaseHeader."Vendor Company Name" + ' - ');

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

    local procedure UpdateTotal()
    begin
        EDocumentPurchaseHeader.Total := EDocumentPurchaseHeader."Sub Total" - EDocumentPurchaseHeader."Total Discount" + EDocumentPurchaseHeader."Total VAT";
    end;

    local procedure ShowErrorsAndWarnings()
    var
        ErrorMessage: Record "Error Message";
        TempErrorMessage: Record "Error Message" temporary;
    begin
        ErrorMessage.SetRange("Context Record ID", Rec.RecordId);
        ErrorMessage.CopyToTemp(TempErrorMessage);

        CurrPage.ErrorMessagesFactBox.Page.SetRecords(TempErrorMessage);
        CurrPage.ErrorMessagesFactBox.Page.Update(false);
    end;

    local procedure LookupVendor(var VendorNo: Text): Boolean
    var
        Vendor: Record Vendor;
        VendorList: Page "Vendor List";
    begin
        VendorList.LookupMode := true;
        if VendorList.RunModal() = Action::LookupOK then begin
            VendorList.GetRecord(Vendor);
            VendorNo := Vendor."No.";
            exit(true);
        end;
    end;

    local procedure ClearErrorsAndWarnings()
    var
        TempErrorMessage: Record "Error Message" temporary;
    begin
        CurrPage.ErrorMessagesFactBox.Page.SetRecords(TempErrorMessage);
        CurrPage.ErrorMessagesFactBox.Page.Update(false);
    end;

    local procedure FinalizeEDocument()
    var
        TempErrorMessage: Record "Error Message" temporary;
        ErrorMessage: Record "Error Message";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocImport: Codeunit "E-Doc. Import";
    begin
        Session.LogMessage('0000PCO', FinalizeDraftInvokedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', EDocumentPurchaseHeader.FeatureName());

        if not EDocumentHelper.EnsureInboundEDocumentHasService(Rec) then
            exit;

        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Finish draft";
        EDocImport.ProcessIncomingEDocument(Rec, EDocImportParameters);
        Rec.Get(Rec."Entry No");

        if EDocumentErrorHelper.HasErrors(Rec) then begin
            ErrorMessage.SetRange("Context Record ID", Rec.RecordId);
            ErrorMessage.CopyToTemp(TempErrorMessage);
            Commit(); // Persists error messages after error is thrown.
            TempErrorMessage.ThrowError();
        end;

        PageEditable := IsEditable();
        CurrPage.Lines.Page.Update();
        CurrPage.Update();
        Session.LogMessage('0000PCP', FinalizeDraftPerformedTxt, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, 'Category', EDocumentPurchaseHeader.FeatureName());
        FeatureTelemetry.LogUsage('0000PCU', EDocumentPurchaseHeader.FeatureName(), 'Finalize draft');
        Rec.ShowRecord();
    end;

    local procedure ResetDraft()
    var
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocImport: Codeunit "E-Doc. Import";
        ConfirmDialogMgt: Codeunit "Confirm Management";
        Progress: Dialog;
    begin
        if not EDocumentHelper.EnsureInboundEDocumentHasService(Rec) then
            exit;
        if not ConfirmDialogMgt.GetResponseOrDefault(ResetDraftQst) then
            exit;
        if GuiAllowed() then
            Progress.Open(ProcessingDocumentMsg);

        // Regardless of document state, we re-run the read data into IR, then prepare draft step.
        EDocImportParameters."Step to Run" := Enum::"Import E-Document Steps"::"Read into Draft";
        EDocImport.ProcessIncomingEDocument(Rec, EDocImportParameters);
        EDocImportParameters."Step to Run" := Enum::"Import E-Document Steps"::"Prepare draft";
        EDocImport.ProcessIncomingEDocument(Rec, EDocImportParameters);

        Rec.Get(Rec."Entry No");
        if GuiAllowed() then
            Progress.Close();
    end;

    local procedure PrepareDraft()
    var
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocImport: Codeunit "E-Doc. Import";
        EDocumentHelper: Codeunit "E-Document Helper";
        Progress: Dialog;
    begin
        if not EDocumentHelper.EnsureInboundEDocumentHasService(Rec) then
            exit;
        if GuiAllowed() then
            Progress.Open(ProcessingDocumentMsg);

        EDocImportParameters."Step to Run" := Enum::"Import E-Document Steps"::"Prepare draft";
        EDocImport.ProcessIncomingEDocument(Rec, EDocImportParameters);

        Rec.Get(Rec."Entry No");
        if GuiAllowed() then
            Progress.Close();
    end;

    local procedure AnalyzeEDocument()
    var
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocImport: Codeunit "E-Doc. Import";
        Progress: Dialog;
    begin
        if not EDocumentHelper.EnsureInboundEDocumentHasService(Rec) then
            exit;
        if GuiAllowed() then
            Progress.Open(ProcessingDocumentMsg);

        // Regardless of document state, we re-run the structure received data, then prepare draft step.
        EDocImportParameters."Step to Run" := Enum::"Import E-Document Steps"::"Structure received data";
        EDocImport.ProcessIncomingEDocument(Rec, EDocImportParameters);
        EDocImportParameters."Step to Run" := Enum::"Import E-Document Steps"::"Prepare draft";
        EDocImport.ProcessIncomingEDocument(Rec, EDocImportParameters);

        Rec.Get(Rec."Entry No");
        if GuiAllowed() then
            Progress.Close();
    end;

    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        EDocumentProcessing: Codeunit "E-Document Processing";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        EDocumentHelper: Codeunit "E-Document Helper";
        RecordLinkTxt, StyleStatusTxt, ServiceStatusStyleTxt, VendorName, DataCaption : Text;
        HasErrorsOrWarnings, HasErrors : Boolean;
        ShowFinalizeDraftAction: Boolean;
        ShowAnalyzeDocumentAction: Boolean;
        FinalizeDraftInvokedTxt: Label 'User invoked Finalize Draft action.';
        FinalizeDraftPerformedTxt: Label 'User completed Finalize Draft action.';
        ProcessingDocumentMsg: Label 'Processing document...';
        ResetDraftQst: Label 'All the changes that you may have made on the document draft will be lost. Do you want to continue?';
        PageEditable, HasPDFSource : Boolean;
}
