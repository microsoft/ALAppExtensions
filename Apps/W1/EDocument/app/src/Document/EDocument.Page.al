// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument;

using Microsoft.Bank.Reconciliation;
using Microsoft.eServices.EDocument.OrderMatch;
using Microsoft.eServices.EDocument.OrderMatch.Copilot;
using System.Telemetry;
using System.Utilities;

page 6121 "E-Document"
{
    ApplicationArea = Basic, Suite;
    PageType = Card;
    SourceTable = "E-Document";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
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
                    ToolTip = 'Specifies the record, document, journal line, or ledger entry, that is linked to the electronic document.';

                    trigger OnDrillDown()
                    begin
                        Rec.ShowRecord();
                        CurrPage.Update();
                    end;
                }
                field("Electronic Document Status"; Rec.Status)
                {
                    Editable = false;
                    Caption = 'Document Status';
                    ToolTip = 'Specifies the status of the electronic document.';
                    StyleExpr = StyleStatusTxt;
                }
                field(Direction; Rec.Direction)
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the direction of the electronic document.';
                }
                field("Workflow Code"; Rec."Workflow Code")
                {
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the Workflow used on the electronic document.';
                }
                field("Incoming E-Document No."; Rec."Incoming E-Document No.")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the electronic document number.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the electronic document type.';
                }
                field("Document No."; Rec."Document No.")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the document number of the electronic document.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ToolTip = 'Specifies the document date of the electronic document.';
                    Importance = Additional;
                }
                field("Due Date"; Rec."Due Date")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the due date of the electronic document.';
                }
                field("Order No."; Rec."Order No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the related order number of the electronic document.';
                    Importance = Additional;
                }
                field("Amount Excl. VAT"; Rec."Amount Excl. VAT")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the total amount of the electronic document excluding VAT.';
                }
                field("Amount Incl. VAT"; Rec."Amount Incl. VAT")
                {
                    ToolTip = 'Specifies the total amount of the electronic document including VAT.';
                    Importance = Additional;
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the electronic document currency code.';
                }
                field("Bill-to/Pay-to No."; Rec."Bill-to/Pay-to No.")
                {
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the customer/vendor of the electronic document.';
                }
                field("Bill-to/Pay-to Name"; Rec."Bill-to/Pay-to Name")
                {
                    ToolTip = 'Specifies the customer/vendor name of the electronic document.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    Importance = Additional;
                    ToolTip = 'Specifies the electronic document posting date.';
                }
            }
            group(ReceivingCompanyInfo)
            {
                Caption = 'Receiving Company Information';
                Visible = false;

                field("Receiving Company VAT Reg. No."; Rec."Receiving Company VAT Reg. No.")
                {
                    Caption = 'VAT Registration No.';
                    Editable = false;
                    ToolTip = 'Specifies the receiving company VAT number.';
                }
                field("Receiving Company GLN"; Rec."Receiving Company GLN")
                {
                    Caption = 'GLN';
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the receiving company GLN.';
                }
                field("Receiving Company Name"; Rec."Receiving Company Name")
                {
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the receiving company name.';
                }
                field("Receiving Company Address"; Rec."Receiving Company Address")
                {
                    Caption = 'Address';
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the receiving company address.';
                }
            }
            part(EdocoumentServiceStatus; "E-Document Service Status")
            {
                Caption = 'Service Status';
                SubPageLink = "E-Document Entry No" = field("Entry No");
                ShowFilter = false;
            }
#if NOT CLEAN24
            group(EDocServiceStatus)
            {
                Visible = false;
                Enabled = false;
                ObsoleteTag = '24.0';
                ObsoleteReason = 'Part inside group moved out';
                ObsoleteState = Pending;
            }
#endif
            part(ErrorMessagesPart; "Error Messages Part")
            {
                Visible = HasErrorsOrWarnings;
                ShowFilter = false;
                UpdatePropagation = Both;
            }
#if NOT CLEAN24
            group("Errors and Warnings")
            {
                Visible = false;
                Enabled = false;
                ObsoleteTag = '24.0';
                ObsoleteReason = 'Part inside group moved out';
                ObsoleteState = Pending;
            }
#endif
        }
    }
    actions
    {
        area(Processing)
        {
            group(Outgoing)
            {
                Caption = 'Outgoing';

                action(Send)
                {
                    Caption = 'Send Document';
                    ToolTip = 'Starts the document export.';
                    Image = SendElectronicDocument;
                    Visible = not IsIncomingDoc;

                    trigger OnAction()
                    begin
                        SendEDocument();
                    end;
                }
                action(Recreate)
                {
                    Caption = 'Recreate Document';
                    ToolTip = 'Recreates the electronic document';
                    Image = CreateDocument;
                    Visible = not IsIncomingDoc;

                    trigger OnAction()
                    var
                        EDocService: Record "E-Document Service";
                        EDocExport: Codeunit "E-Doc. Export";
                        EDocServices: Page "E-Document Services";
                    begin
                        EDocServices.LookupMode := true;
                        if EDocServices.RunModal() = Action::LookupOK then begin
                            EDocServices.GetRecord(EDocService);
                            EDocumentErrorHelper.ClearErrorMessages(Rec);
                            EDocExport.Recreate(Rec, EDocService);
                        end
                    end;
                }
                action(GetApproval)
                {
                    Caption = 'Get Approval';
                    ToolTip = 'Gets if the electronic document is approved or rejected';
                    Image = Approval;
                    Visible = not IsIncomingDoc;

                    trigger OnAction()
                    var
                        EDocService: Record "E-Document Service";
                        EDocServices: Page "E-Document Services";
                    begin
                        EDocServices.LookupMode := true;
                        if EDocServices.RunModal() = Action::LookupOK then begin
                            EDocServices.GetRecord(EDocService);
                            EDocumentErrorHelper.ClearErrorMessages(Rec);
                            EDocIntegrationManagement.GetApproval(Rec, EDocService);
                        end
                    end;
                }
                action(Cancel)
                {
                    Caption = 'Cancel EDocument';
                    ToolTip = 'Cancels the electronic document';
                    Image = Cancel;
                    Visible = not IsIncomingDoc;

                    trigger OnAction()
                    var
                        EDocService: Record "E-Document Service";
                        EDocServices: Page "E-Document Services";
                    begin
                        EDocServices.LookupMode := true;
                        if EDocServices.RunModal() = Action::LookupOK then begin
                            EDocServices.GetRecord(EDocService);
                            EDocumentErrorHelper.ClearErrorMessages(Rec);
                            EDocIntegrationManagement.Cancel(Rec, EDocService);
                        end
                    end;
                }
            }
            group(Incoming)
            {
                Caption = 'Incoming';
                action(GetBasicInfo)
                {
                    Caption = 'Get Basic Info';
                    ToolTip = 'Gets the electronic document basic info.';
                    Image = GetOrder;
                    Visible = false;

                    trigger OnAction()
                    begin
                        EDocImport.GetBasicInfo(Rec);
                    end;
                }
                action(CreateDocument)
                {
                    Caption = 'Reprocess Document';
                    ToolTip = 'Reprocess the electronic file to a purchase document.';
                    Image = CreateXMLFile;
                    Visible = IsIncomingDoc and (not IsProcessed);

                    trigger OnAction()
                    begin
                        EDocImport.ProcessDocument(Rec, false);
                        if EDocumentErrorHelper.HasErrors(Rec) then
                            Message(DocNotCreatedMsg, Rec."Document Type");
                    end;
                }
                action(CreateJournal)
                {
                    Caption = 'Reprocess Journal Line';
                    ToolTip = 'Reprocess the electronic file to a journal line.';
                    Image = Journal;
                    Visible = IsIncomingDoc and (not IsProcessed);

                    trigger OnAction()
                    begin
                        EDocImport.ProcessDocument(Rec, true);
                        if EDocumentErrorHelper.HasErrors(Rec) then
                            Message(DocNotCreatedMsg, Rec."Document Type");
                    end;
                }
#if not CLEAN24
                action(UpdateOrder)
                {
                    Caption = 'Update Order';
                    ToolTip = 'Updates related order.';
                    Image = UpdateDescription;
                    Visible = false;
                    Enabled = false;
                    ObsoleteTag = '24.0';
                    ObsoleteReason = 'Update order changed to "Receive E-Document To" on Vendor';
                    ObsoleteState = Pending;

                    trigger OnAction()
                    begin
                        exit;
                    end;
                }
#endif
                action(MatchToOrderCopilotEnabled)
                {
                    Caption = 'Match Purchase Order With Copilot';
                    ToolTip = 'Match E-document lines to Purchase Order.';
                    Image = SparkleFilled;
                    Visible = ShowMapToOrder and CopilotVisible;

                    trigger OnAction()
                    var
                        EDocOrderMatch: Codeunit "E-Doc. Line Matching";
                    begin
                        EDocOrderMatch.RunMatching(Rec, true);
                    end;
                }
                action(MatchToOrder)
                {
                    Caption = 'Match Purchase Order';
                    ToolTip = 'Match E-document lines to Purchase Order.';
                    Image = Reconcile;
                    Visible = ShowMapToOrder;

                    trigger OnAction()
                    var
                        EDocOrderMatch: Codeunit "E-Doc. Line Matching";
                    begin
                        EDocOrderMatch.RunMatching(Rec);
                    end;
                }
            }
            group(Troubleshoot)
            {
                Caption = 'Troubleshoot';
                action(ImportManually)
                {
                    Caption = 'Replace Source Document';
                    ToolTip = 'Import and replace the electronic document.';
                    Image = UpdateXML;
                    Visible = IsIncomingDoc and (not IsProcessed);

                    trigger OnAction()
                    begin
                        EDocImport.UploadDocument(Rec);
                        CurrPage.Update();
                    end;
                }
                action(TextToAccountMapping)
                {
                    Caption = 'Map Text to Account';
                    Image = MapAccounts;
                    RunObject = Page "Text-to-Account Mapping Wksh.";
                    ToolTip = 'Create a mapping of text on electronic documents to identical text on specific debit, credit, and balancing accounts in the general ledger or on bank accounts so that the resulting document or journal lines are prefilled with the specified information.';
                    Visible = IsIncomingDoc and HasErrors and (not ShowRelink);
                }
                action(LinkOrder)
                {
                    Caption = 'Update Purchase Order Link';
                    ToolTip = 'Updated Purchase Order link for E-Document to different Purchase Order.';
                    Image = LinkAccount;
                    Visible = IsIncomingDoc and ShowRelink and (not IsProcessed);

                    trigger OnAction()
                    begin
                        EDocImport.UpdatePurchaseOrderLink(Rec);
                    end;
                }
            }

        }
        area(Navigation)
        {
            action(EDocumentLog)
            {
                Caption = 'Logs';
                ToolTip = 'Shows all logs for the E-Document.';
                Image = Log;
                RunObject = Page "E-Document Logs";
                RunPageLink = "E-Doc. Entry No" = field("Entry No");
                RunPageMode = View;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(MatchToOrderCE_Promoted; MatchToOrderCopilotEnabled) { }
                actionref(MatchToOrder_Promoted; MatchToOrder) { }
                actionref(LinkOrder_Promoted; LinkOrder) { }
                actionref(CreateDocument_Promoted; CreateDocument) { }
                actionref(CreateJournal_Promoted; CreateJournal) { }
                actionref(ImportManually_Promoted; ImportManually) { }
                actionref(TextToAccountMapping_Promoted; TextToAccountMapping) { }
                actionref(Send_Promoted; Send) { }
                actionref(Recreate_Promoted; Recreate) { }
                actionref(Cancel_promoteed; Cancel) { }
                actionref(Approval_promoteed; GetApproval) { }

            }
            group(Category_Troubleshoot)
            {
                Caption = 'Troubleshoot';
                Visible = false;
            }
#if not CLEAN24            
            group(Out)
            {
                Caption = 'Outgoing';
                Visible = false;
                ObsoleteTag = '24.0';
                ObsoleteReason = 'Actionrefs moved to process category';
                ObsoleteState = Pending;
            }
            group(In)
            {
                Caption = 'Incoming';
                Visible = false;
                ObsoleteTag = '24.0';
                ObsoleteReason = 'Actionrefs moved to process category';
                ObsoleteState = Pending;
                actionref(GetBasicInfo_Promoted; GetBasicInfo)
                {
                    ObsoleteTag = '24.0';
                    ObsoleteReason = 'Actionref removed';
                    ObsoleteState = Pending;
                }
                group(CreateDoc)
                {
                    Visible = false;
                    ShowAs = SplitButton;
                    ObsoleteTag = '24.0';
                    ObsoleteReason = 'CreateDoc group removed';
                    ObsoleteState = Pending;

                    actionref(UpdateOrder_Promoted; UpdateOrder)
                    {
                        Visible = false;
                        ObsoleteTag = '24.0';
                        ObsoleteReason = 'Update order changed to "Receive E-Document To" on Vendor';
                        ObsoleteState = Pending;
                    }
                }
            }
#endif
        }
    }

    trigger OnOpenPage()
    var
        EDocPOMatching: Codeunit "E-Doc. PO Copilot Matching";
    begin
        ShowMapToOrder := false;
        HasErrorsOrWarnings := false;
        HasErrors := false;
        IsProcessed := false;
        CopilotVisible := EDocPOMatching.IsCopilotVisible();
    end;

    trigger OnAfterGetRecord()
    begin
        IsProcessed := Rec.Status = Rec.Status::Processed;
        IsIncomingDoc := Rec.Direction = Rec.Direction::Incoming;

        RecordLinkTxt := EDocumentHelper.GetRecordLinkText(Rec);
        HasErrorsOrWarnings := (EDocumentErrorHelper.ErrorMessageCount(Rec) + EDocumentErrorHelper.WarningMessageCount(Rec)) > 0;
        HasErrors := EDocumentErrorHelper.ErrorMessageCount(Rec) > 0;
        if HasErrorsOrWarnings then
            ShowErrorsAndWarnings();

        SetStyle();
        ResetActionVisiability();
        SetIncomingDocActions();

        EDocImport.ProcessEDocPendingOrderMatch(Rec);
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

    local procedure SendEDocument()
    var
        EDocService: Record "E-Document Service";
        EDocServices: Page "E-Document Services";
        IsAsync: Boolean;
    begin
        EDocServices.LookupMode(true);
        if EDocServices.RunModal() <> Action::LookupOK then
            exit;
        EDocServices.GetRecord(EDocService);
        EDocumentErrorHelper.ClearErrorMessages(Rec);
        if not EDocIntegrationManagement.Send(Rec, EDocService, IsAsync) then
            exit;
        if IsAsync then
            EDocumentBackgroundjobs.ScheduleGetResponseJob();
    end;

    local procedure SetIncomingDocActions()
    var
        EDocService: Record "E-Document Service";
        EDocServiceStatus2: Record "E-Document Service Status";
        EDocLog: Codeunit "E-Document Log";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        EDocPOCopilotMatching: Codeunit "E-Doc. PO Copilot Matching";
    begin
        if not IsIncomingDoc then
            exit;

        EDocService := EDocLog.GetLastServiceFromLog(Rec);
        if (Rec."Document Type" = Enum::"E-Document Type"::"Purchase Order") and (Rec.Status <> Rec.Status::Processed) then begin
            EDocServiceStatus2.Get(Rec."Entry No", EDocService.Code);
            ShowMapToOrder := EDocServiceStatus2.Status = Enum::"E-Document Service Status"::"Order Linked";
            ShowRelink := true;
            FeatureTelemetry.LogUptake('0000MMK', EDocPOCopilotMatching.FeatureName(), Enum::"Feature Uptake Status"::Discovered);
        end;
    end;

    local procedure ResetActionVisiability()
    begin
        ShowMapToOrder := false;
        ShowRelink := false;
    end;

    var
        EDocumentBackgroundjobs: Codeunit "E-Document Background Jobs";
        EDocIntegrationManagement: Codeunit "E-Doc. Integration Management";
        EDocImport: Codeunit "E-Doc. Import";
        EDocumentErrorHelper: Codeunit "E-Document Error Helper";
        EDocumentHelper: Codeunit "E-Document Processing";
        ErrorsAndWarningsNotification: Notification;
        RecordLinkTxt, StyleStatusTxt : Text;
        ShowRelink, ShowMapToOrder, HasErrorsOrWarnings, HasErrors, IsIncomingDoc, IsProcessed, CopilotVisible : Boolean;
        EDocHasErrorOrWarningMsg: Label 'Errors or warnings found for E-Document. Please review below in "Error Messages" section.';
        DocNotCreatedMsg: Label 'Failed to create new %1 from E-Document. Please review errors below.', Comment = '%1 - E-Document Document Type';

}
