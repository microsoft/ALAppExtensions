// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AdvancePayments;

using System.Apps;
using System.Automation;

codeunit 31023 "Workflow Handler CZZ"
{
    Permissions = tabledata "NAV App Installed App" = r;

    var
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
        WorkflowRequestPageHandling: Codeunit "Workflow Request Page Handling";
        WorkflowSetup: Codeunit "Workflow Setup";
        BlankDateFormula: DateFormula;
        SalesAdvanceLetterApprReqCancelledEventDescTxt: Label 'An approval request for a sales advance letter is canceled.';
        SalesAdvanceLetterCodeTxt: Label 'SALESADV', Locked = true;
        SalesAdvanceLetterDescTxt: Label 'Sales Advance Letter';
        SalesAdvanceLetterReleasedEventDescTxt: Label 'A sales advance letter is released.';
        SalesAdvanceLetterSendForApprovalEventDescTxt: Label 'Approval of a sales advance letter is requested.';
        PurchAdvanceLetterApprReqCancelledEventDescTxt: Label 'An approval request for a purchase advance letter is canceled.';
        PurchAdvanceLetterCodeTxt: Label 'PURCHADV', Locked = true;
        PurchAdvanceLetterDescTxt: Label 'Purchase Advance Letter';
        PurchAdvanceLetterReleasedEventDescTxt: Label 'A purchase advance letter is released.';
        PurchAdvanceLetterSendForApprovalEventDescTxt: Label 'Approval of a purchase advance letter is requested.';
        PurchAdvanceLetterApprWorkflowCodeTxt: Label 'PALAPWCZZ', Locked = true;
        PurchAdvanceLetterApprWorkflowDescTxt: Label 'Purchase Advance Letter Approval Workflow';
        PurchAdvanceLetterHeaderTypeCondnTxt: Label '<?xml version="1.0" encoding="utf-8" standalone="yes"?><ReportParameters><DataItems><DataItem name="Purch. Adv. Letter Header CZZ">%1</DataItem><DataItem name="Purch. Adv. Letter Line CZZ">%2</DataItem></DataItems></ReportParameters>', Locked = true;
        PurchDocCategoryTxt: Label 'PURCHDOC', Locked = true;
        SalesAdvanceLetterApprWorkflowCodeTxt: Label 'SALAPWCZZ', Locked = true;
        SalesAdvanceLetterApprWorkflowDescTxt: Label 'Sales Advance Letter Approval Workflow';
        SalesAdvanceLetterHeaderTypeCondnTxt: Label '<?xml version="1.0" encoding="utf-8" standalone="yes"?><ReportParameters><DataItems><DataItem name="Sales Adv. Letter Header CZZ">%1</DataItem><DataItem name="Sales Adv. Letter Line CZZ">%2</DataItem></DataItems></ReportParameters>', Locked = true;
        SalesDocCategoryTxt: Label 'SALESDOC', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', false, false)]
    local procedure AddWorkflowEventsToLibrary()
    begin
        WorkflowEventHandling.AddEventToLibrary(
          RunWorkflowOnSendSalesAdvanceLetterForApprovalCode(), Database::"Sales Adv. Letter Header CZZ",
          SalesAdvanceLetterSendForApprovalEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(
          RunWorkflowOnCancelSalesAdvanceLetterApprovalRequestCode(), Database::"Sales Adv. Letter Header CZZ",
          SalesAdvanceLetterApprReqCancelledEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(
          RunWorkflowOnAfterReleaseSalesAdvanceLetterCode(), Database::"Sales Adv. Letter Header CZZ",
          SalesAdvanceLetterReleasedEventDescTxt, 0, false);

        WorkflowEventHandling.AddEventToLibrary(
          RunWorkflowOnSendPurchaseAdvanceLetterForApprovalCode(), Database::"Purch. Adv. Letter Header CZZ",
          PurchAdvanceLetterSendForApprovalEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(
          RunWorkflowOnCancelPurchaseAdvanceLetterApprovalRequestCode(), Database::"Purch. Adv. Letter Header CZZ",
          PurchAdvanceLetterApprReqCancelledEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(
          RunWorkflowOnAfterReleasePurchaseAdvanceLetterCode(), Database::"Purch. Adv. Letter Header CZZ",
          PurchAdvanceLetterReleasedEventDescTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', false, false)]
    local procedure AddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    begin
        case EventFunctionName of
            RunWorkflowOnCancelSalesAdvanceLetterApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  RunWorkflowOnCancelSalesAdvanceLetterApprovalRequestCode(),
                  RunWorkflowOnSendSalesAdvanceLetterForApprovalCode());
            RunWorkflowOnCancelPurchaseAdvanceLetterApprovalRequestCode():
                WorkflowEventHandling.AddEventPredecessor(
                  RunWorkflowOnCancelPurchaseAdvanceLetterApprovalRequestCode(),
                  RunWorkflowOnSendPurchaseAdvanceLetterForApprovalCode());
            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode():
                begin
                    WorkflowEventHandling.AddEventPredecessor(
                      WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode(),
                      RunWorkflowOnSendSalesAdvanceLetterForApprovalCode());
                    WorkflowEventHandling.AddEventPredecessor(
                      WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode(),
                     RunWorkflowOnSendPurchaseAdvanceLetterForApprovalCode());
                end;
            WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode():
                begin
                    WorkflowEventHandling.AddEventPredecessor(
                      WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode(),
                      RunWorkflowOnSendSalesAdvanceLetterForApprovalCode());
                    WorkflowEventHandling.AddEventPredecessor(
                      WorkflowEventHandling.RunWorkflowOnRejectApprovalRequestCode(),
                      RunWorkflowOnSendPurchaseAdvanceLetterForApprovalCode());
                end;
            WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode():
                begin
                    WorkflowEventHandling.AddEventPredecessor(
                      WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode(),
                      RunWorkflowOnSendSalesAdvanceLetterForApprovalCode());
                    WorkflowEventHandling.AddEventPredecessor(
                      WorkflowEventHandling.RunWorkflowOnDelegateApprovalRequestCode(),
                      RunWorkflowOnSendPurchaseAdvanceLetterForApprovalCode());
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowTableRelationsToLibrary', '', false, false)]
    local procedure AddWorkflowTableRelationsToLibrary()
    var
        ApprovalEntry: Record "Approval Entry";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        WorkflowSetup.InsertTableRelation(Database::"Sales Adv. Letter Header CZZ", 0,
          Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
        WorkflowSetup.InsertTableRelation(Database::"Sales Adv. Letter Header CZZ", SalesAdvLetterHeaderCZZ.FieldNo("No."),
          Database::"Sales Adv. Letter Line CZZ", SalesAdvLetterLineCZZ.FieldNo("Document No."));

        WorkflowSetup.InsertTableRelation(Database::"Purch. Adv. Letter Header CZZ", 0,
          Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
        WorkflowSetup.InsertTableRelation(Database::"Purch. Adv. Letter Header CZZ", PurchAdvLetterHeaderCZZ.FieldNo("No."),
          Database::"Purch. Adv. Letter Line CZZ", PurchAdvLetterLineCZZ.FieldNo("Document No."));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', false, false)]
    local procedure AddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    begin
        case ResponseFunctionName of
            WorkflowResponseHandling.SetStatusToPendingApprovalCode():
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendSalesAdvanceLetterForApprovalCode());
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendPurchaseAdvanceLetterForApprovalCode());
                end;
            WorkflowResponseHandling.CreateApprovalRequestsCode():
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendSalesAdvanceLetterForApprovalCode());
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendPurchaseAdvanceLetterForApprovalCode());
                end;
            WorkflowResponseHandling.SendApprovalRequestForApprovalCode():
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendSalesAdvanceLetterForApprovalCode());
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnSendPurchaseAdvanceLetterForApprovalCode());
                end;
            WorkflowResponseHandling.OpenDocumentCode():
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnCancelSalesAdvanceLetterApprovalRequestCode());
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnCancelPurchaseAdvanceLetterApprovalRequestCode());
                end;
            WorkflowResponseHandling.CancelAllApprovalRequestsCode():
                begin
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnCancelSalesAdvanceLetterApprovalRequestCode());
                    WorkflowResponseHandling.AddResponsePredecessor(ResponseFunctionName, RunWorkflowOnCancelPurchaseAdvanceLetterApprovalRequestCode());
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', false, false)]
    local procedure ReleaseAdvanceLetter(RecRef: RecordRef; var Handled: Boolean)
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        RelPurchAdvLetterDocCZZ: Codeunit "Rel. Purch.Adv.Letter Doc. CZZ";
        RelSalesAdvLetterDocCZZ: Codeunit "Rel. Sales Adv.Letter Doc. CZZ";
    begin
        if Handled then
            exit;

        case RecRef.Number of
            Database::"Purch. Adv. Letter Header CZZ":
                begin
                    RecRef.SetTable(PurchAdvLetterHeaderCZZ);
                    RelPurchAdvLetterDocCZZ.PerformManualRelease(PurchAdvLetterHeaderCZZ);
                    Handled := true;
                end;
            Database::"Sales Adv. Letter Header CZZ":
                begin
                    RecRef.SetTable(SalesAdvLetterHeaderCZZ);
                    RelSalesAdvLetterDocCZZ.PerformManualRelease(SalesAdvLetterHeaderCZZ);
                    Handled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', false, false)]
    local procedure OpenAdvanceLetter(RecRef: RecordRef; var Handled: Boolean)
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        RelPurchAdvLetterDocCZZ: Codeunit "Rel. Purch.Adv.Letter Doc. CZZ";
        RelAdvLetterHeaderCZZ: Codeunit "Rel. Sales Adv.Letter Doc. CZZ";
    begin
        if Handled then
            exit;

        case RecRef.Number of
            Database::"Purch. Adv. Letter Header CZZ":
                begin
                    RecRef.SetTable(PurchAdvLetterHeaderCZZ);
                    RelPurchAdvLetterDocCZZ.Reopen(PurchAdvLetterHeaderCZZ);
                    Handled := true;
                end;
            Database::"Sales Adv. Letter Header CZZ":
                begin
                    RecRef.SetTable(SalesAdvLetterHeaderCZZ);
                    RelAdvLetterHeaderCZZ.Reopen(SalesAdvLetterHeaderCZZ);
                    Handled := true;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Approval Entry", 'OnAfterGetRecordDetails', '', false, false)]
    local procedure GetDetailsOnAfterGetRecordDetails(RecRef: RecordRef; ChangeRecordDetails: Text; var Details: Text)
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        ThreePlaceholdersTok: Label '%1 ; %2: %3', Locked = true;
    begin
        case RecRef.Number() of
            Database::"Sales Adv. Letter Header CZZ":
                begin
                    RecRef.SetTable(SalesAdvLetterHeaderCZZ);
                    SalesAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
                    Details := StrSubstNo(ThreePlaceholdersTok, SalesAdvLetterHeaderCZZ."Bill-to Name",
                        SalesAdvLetterHeaderCZZ.FieldCaption("Amount Including VAT"),
                        SalesAdvLetterHeaderCZZ."Amount Including VAT");
                end;
            Database::"Purch. Adv. Letter Header CZZ":
                begin
                    RecRef.SetTable(PurchAdvLetterHeaderCZZ);
                    PurchAdvLetterHeaderCZZ.CalcFields("Amount Including VAT");
                    Details := StrSubstNo(ThreePlaceholdersTok, PurchAdvLetterHeaderCZZ."Pay-to Name",
                        PurchAdvLetterHeaderCZZ.FieldCaption("Amount Including VAT"),
                        PurchAdvLetterHeaderCZZ."Amount Including VAT");
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Adv. Payments Approv. Mgt. CZZ", 'OnSendSalesAdvanceLetterForApproval', '', false, false)]
    local procedure RunWorkflowOnSendSalesAdvLetterForApproval(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendSalesAdvanceLetterForApprovalCode(), SalesAdvLetterHeaderCZZ);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Adv. Payments Approv. Mgt. CZZ", 'OnCancelSalesAdvanceLetterApprovalRequest', '', false, false)]
    local procedure RunWorkflowOnCancelSalesAdvLetterApprovalRequest(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelSalesAdvanceLetterApprovalRequestCode(), SalesAdvLetterHeaderCZZ);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Rel. Sales Adv.Letter Doc. CZZ", 'OnAfterReleaseDoc', '', false, false)]
    local procedure RunWorkflowOnAfterReleaseSalesAdvLetter(var SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnAfterReleaseSalesAdvanceLetterCode(), SalesAdvLetterHeaderCZZ);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Adv. Payments Approv. Mgt. CZZ", 'OnSendPurchaseAdvanceLetterForApproval', '', false, false)]
    local procedure RunWorkflowOnSendPurchaseAdvLetterForApproval(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendPurchaseAdvanceLetterForApprovalCode(), PurchAdvLetterHeaderCZZ);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Adv. Payments Approv. Mgt. CZZ", 'OnCancelPurchaseAdvanceLetterApprovalRequest', '', false, false)]
    local procedure RunWorkflowOnCancelPurchaseAdvLetterApprovalRequest(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelPurchaseAdvanceLetterApprovalRequestCode(), PurchAdvLetterHeaderCZZ);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Rel. Purch.Adv.Letter Doc. CZZ", 'OnAfterReleaseDoc', '', false, false)]
    local procedure RunWorkflowOnAfterReleasePurchaseAdvLetter(var PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnAfterReleasePurchaseAdvanceLetterCode(), PurchAdvLetterHeaderCZZ);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Adv. Letter Header CZZ", 'OnCheckSalesAdvanceLetterPostRestrictions', '', false, false)]
    local procedure SalesAdvanceLetterHeaderCheckSalesAdvanceLetterPostRestrictions(var Sender: Record "Sales Adv. Letter Header CZZ")
    begin
        CheckRecordHasUsageRestrictions(Sender);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Adv. Letter Header CZZ", 'OnCheckSalesAdvanceLetterReleaseRestrictions', '', false, false)]
    local procedure SalesAdvanceLetterHeaderCheckSalesAdvanceLetterReleaseRestrictions(var Sender: Record "Sales Adv. Letter Header CZZ")
    begin
        CheckRecordHasUsageRestrictions(Sender);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Adv. Letter Header CZZ", 'OnCheckPurchaseAdvanceLetterPostRestrictions', '', false, false)]
    local procedure PurchAdvanceLetterHeaderCheckPurchaseAdvanceLetterPostRestrictions(var Sender: Record "Purch. Adv. Letter Header CZZ")
    begin
        CheckRecordHasUsageRestrictions(Sender);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Adv. Letter Header CZZ", 'OnCheckPurchaseAdvanceLetterReleaseRestrictions', '', false, false)]
    local procedure PurchAdvanceLetterHeaderCheckPurchaseAdvanceLetterReleaseRestrictions(var Sender: Record "Purch. Adv. Letter Header CZZ")
    begin
        CheckRecordHasUsageRestrictions(Sender);
    end;

    local procedure CheckRecordHasUsageRestrictions(RecVariant: Variant)
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.CheckRecordHasUsageRestrictions(RecVariant);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Adv. Letter Header CZZ", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure RemoveSalesAdvanceLetterHeaderRestrictionsBeforeDelete(var Rec: Record "Sales Adv. Letter Header CZZ"; RunTrigger: Boolean)
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.AllowRecordUsage(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Adv. Letter Header CZZ", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure RemovePurchAdvanceLetterHeaderRestrictionsBeforeDelete(var Rec: Record "Purch. Adv. Letter Header CZZ"; RunTrigger: Boolean)
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.AllowRecordUsage(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Adv. Letter Header CZZ", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdateSalesAdvanceLetterHeaderRestrictionsAfterRename(var Rec: Record "Sales Adv. Letter Header CZZ"; var xRec: Record "Sales Adv. Letter Header CZZ"; RunTrigger: Boolean)
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.UpdateRestriction(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purch. Adv. Letter Header CZZ", 'OnAfterRenameEvent', '', false, false)]
    local procedure UpdatePurchAdvanceLetterHeaderRestrictionsAfterRename(var Rec: Record "Purch. Adv. Letter Header CZZ"; var xRec: Record "Purch. Adv. Letter Header CZZ"; RunTrigger: Boolean)
    var
        RecordRestrictionMgt: Codeunit "Record Restriction Mgt.";
    begin
        RecordRestrictionMgt.UpdateRestriction(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInitWorkflowTemplates', '', false, false)]
    local procedure InsertWorkflowTemplates()
    begin
        if IsTestingEnvironment() then
            exit;

        InsertSalesAdvanceLetterApprovalWorkflowTemplate();
        InsertPurchaseAdvanceLetterApprovalWorkflowTemplate();
    end;

    local procedure IsTestingEnvironment(): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        exit(NAVAppInstalledApp.Get('c4795dd0-aee3-47cc-b020-2ee93a47d4c4')); // application "Tests-Workflow"
    end;

    local procedure InsertSalesAdvanceLetterApprovalWorkflowTemplate()
    var
        Workflow: Record Workflow;
    begin
        if Workflow.Get(WorkflowSetup.GetWorkflowTemplateCode(SalesAdvanceLetterApprWorkflowCodeTxt)) then
            exit;
        WorkflowSetup.InsertWorkflowTemplate(Workflow, SalesAdvanceLetterApprWorkflowCodeTxt,
          SalesAdvanceLetterApprWorkflowDescTxt, SalesDocCategoryTxt);
        InsertSalesAdvanceLetterApprovalWorkflowDetails(Workflow);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    local procedure InsertSalesAdvanceLetterApprovalWorkflowDetails(var Workflow: Record Workflow)
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        WorkflowSetup.InitWorkflowStepArgument(
            WorkflowStepArgument, WorkflowStepArgument."Approver Type"::"Salesperson/Purchaser",
            WorkflowStepArgument."Approver Limit Type"::"Direct Approver", 0, '', BlankDateFormula, true);

        WorkflowSetup.InsertDocApprovalWorkflowSteps(Workflow,
            BuildSalesAdvanceLetterHeaderTypeConditions(SalesAdvLetterHeaderCZZ.Status::New),
            RunWorkflowOnSendSalesAdvanceLetterForApprovalCode(),
            BuildSalesAdvanceLetterHeaderTypeConditions(SalesAdvLetterHeaderCZZ.Status::"Pending Approval"),
            RunWorkflowOnCancelSalesAdvanceLetterApprovalRequestCode(),
            WorkflowStepArgument, true);
    end;

    procedure BuildSalesAdvanceLetterHeaderTypeConditions(Status: Enum "Advance Letter Doc. Status CZZ"): Text
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        SalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
    begin
        SalesAdvLetterHeaderCZZ.SetRange(Status, Status);
        exit(StrSubstNo(SalesAdvanceLetterHeaderTypeCondnTxt,
                WorkflowSetup.Encode(SalesAdvLetterHeaderCZZ.GetView(false)),
                WorkflowSetup.Encode(SalesAdvLetterLineCZZ.GetView(false))));
    end;

    local procedure InsertPurchaseAdvanceLetterApprovalWorkflowTemplate()
    var
        Workflow: Record Workflow;
    begin
        if Workflow.Get(WorkflowSetup.GetWorkflowTemplateCode(PurchAdvanceLetterApprWorkflowCodeTxt)) then
            exit;
        WorkflowSetup.InsertWorkflowTemplate(Workflow, PurchAdvanceLetterApprWorkflowCodeTxt,
          PurchAdvanceLetterApprWorkflowDescTxt, PurchDocCategoryTxt);
        InsertPurchaseAdvanceLetterApprovalWorkflowDetails(Workflow);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    local procedure InsertPurchaseAdvanceLetterApprovalWorkflowDetails(var Workflow: Record Workflow)
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        WorkflowSetup.InitWorkflowStepArgument(
            WorkflowStepArgument, WorkflowStepArgument."Approver Type"::"Salesperson/Purchaser",
            WorkflowStepArgument."Approver Limit Type"::"Direct Approver", 0, '', BlankDateFormula, true);

        WorkflowSetup.InsertDocApprovalWorkflowSteps(Workflow,
            BuildPurchAdvanceLetterHeaderTypeConditions(PurchAdvLetterHeaderCZZ.Status::New),
            RunWorkflowOnSendPurchaseAdvanceLetterForApprovalCode(),
            BuildPurchAdvanceLetterHeaderTypeConditions(PurchAdvLetterHeaderCZZ.Status::"Pending Approval"),
            RunWorkflowOnCancelPurchaseAdvanceLetterApprovalRequestCode(),
            WorkflowStepArgument, true);
    end;

    procedure BuildPurchAdvanceLetterHeaderTypeConditions(Status: Enum "Advance Letter Doc. Status CZZ"): Text
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        PurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        PurchAdvLetterHeaderCZZ.SetRange(Status, Status);
        exit(StrSubstNo(PurchAdvanceLetterHeaderTypeCondnTxt,
                WorkflowSetup.Encode(PurchAdvLetterHeaderCZZ.GetView(false)),
                WorkflowSetup.Encode(PurchAdvLetterLineCZZ.GetView(false))));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Request Page Handling", 'OnAfterAssignEntitiesToWorkflowEvents', '', false, false)]
    local procedure AssignEntitiesToWorkflowEvents()
    begin
        WorkflowRequestPageHandling.AssignEntityToWorkflowEvent(Database::"Sales Adv. Letter Header CZZ", SalesAdvanceLetterCodeTxt);
        WorkflowRequestPageHandling.AssignEntityToWorkflowEvent(Database::"Purch. Adv. Letter Header CZZ", PurchAdvanceLetterCodeTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Request Page Handling", 'OnAfterInsertRequestPageEntities', '', false, false)]
    local procedure InsertRequestPageEntities()
    begin
        WorkflowRequestPageHandling.InsertReqPageEntity(
          SalesAdvanceLetterCodeTxt, SalesAdvanceLetterDescTxt, Database::"Sales Adv. Letter Header CZZ", Database::"Sales Adv. Letter Line CZZ");
        WorkflowRequestPageHandling.InsertReqPageEntity(
          PurchAdvanceLetterCodeTxt, PurchAdvanceLetterDescTxt, Database::"Purch. Adv. Letter Header CZZ", Database::"Purch. Adv. Letter Line CZZ");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Request Page Handling", 'OnAfterInsertRequestPageFields', '', false, false)]
    local procedure InsertRequestPageFields()
    var
        DummySalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        DummySalesAdvLetterLineCZZ: Record "Sales Adv. Letter Line CZZ";
        DummyPurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        DummyPurchAdvLetterLineCZZ: Record "Purch. Adv. Letter Line CZZ";
    begin
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Sales Adv. Letter Header CZZ", DummySalesAdvLetterHeaderCZZ.FieldNo("Bill-to Customer No."));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Sales Adv. Letter Header CZZ", DummySalesAdvLetterHeaderCZZ.FieldNo("Payment Method Code"));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Sales Adv. Letter Header CZZ", DummySalesAdvLetterHeaderCZZ.FieldNo("Currency Code"));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Sales Adv. Letter Header CZZ", DummySalesAdvLetterHeaderCZZ.FieldNo("Salesperson Code"));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Sales Adv. Letter Header CZZ", DummySalesAdvLetterHeaderCZZ.FieldNo("Amount Including VAT"));

        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Sales Adv. Letter Line CZZ", DummySalesAdvLetterLineCZZ.FieldNo("Amount Including VAT"));

        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Purch. Adv. Letter Header CZZ", DummyPurchAdvLetterHeaderCZZ.FieldNo("Pay-to Vendor No."));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Purch. Adv. Letter Header CZZ", DummyPurchAdvLetterHeaderCZZ.FieldNo("Payment Method Code"));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Purch. Adv. Letter Header CZZ", DummyPurchAdvLetterHeaderCZZ.FieldNo("Currency Code"));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Purch. Adv. Letter Header CZZ", DummyPurchAdvLetterHeaderCZZ.FieldNo("Purchaser Code"));
        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Purch. Adv. Letter Header CZZ", DummyPurchAdvLetterHeaderCZZ.FieldNo("Amount Including VAT"));

        WorkflowRequestPageHandling.InsertDynReqPageField(Database::"Purch. Adv. Letter Line CZZ", DummyPurchAdvLetterLineCZZ.FieldNo("Amount Including VAT"));
    end;

    procedure RunWorkflowOnSendSalesAdvanceLetterForApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnSendSalesAdvanceLetterForApprovalCZZ'));
    end;

    procedure RunWorkflowOnCancelSalesAdvanceLetterApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelSalesAdvanceLetterApprovalRequestCZZ'));
    end;

    procedure RunWorkflowOnAfterReleaseSalesAdvanceLetterCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnAfterReleaseSalesAdvanceLetterCZZ'));
    end;

    procedure RunWorkflowOnSendPurchaseAdvanceLetterForApprovalCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnSendPurchaseAdvanceLetterForApprovalCZZ'));
    end;

    procedure RunWorkflowOnCancelPurchaseAdvanceLetterApprovalRequestCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnCancelPurchaseAdvanceLetterApprovalRequestCZZ'));
    end;

    procedure RunWorkflowOnAfterReleasePurchaseAdvanceLetterCode(): Code[128]
    begin
        exit(UpperCase('RunWorkflowOnAfterReleasePurchaseAdvanceLetterCZZ'));
    end;
}
