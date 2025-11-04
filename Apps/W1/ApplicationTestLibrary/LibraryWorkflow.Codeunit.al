/// <summary>
/// Provides utility functions for creating and managing workflows in test scenarios, including workflow steps, workflow events, and workflow responses.
/// </summary>
codeunit 131101 "Library - Workflow"
{
    Permissions = TableData "Workflow Step" = d,
                  TableData "Workflow Step Instance" = d,
                  TableData "Workflow Table Relation Value" = d,
                  TableData "Workflow Step Argument" = d,
                  TableData "Workflow Rule" = d,
                  TableData "Workflow - Record Change" = d,
                  TableData "Workflow Record Change Archive" = d,
                  TableData "Workflow Step Instance Archive" = d,
                  TableData "Workflow Step Argument Archive" = d;

    trigger OnRun()
    begin
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        InvalidEventCondErr: Label 'No event conditions are specified.';

    procedure CreateWorkflow(var Workflow: Record Workflow)
    begin
        Workflow.Init();
        Workflow.Code := GenerateRandomWorkflowCode();
        Workflow.Description := CopyStr(LibraryUtility.GenerateRandomXMLText(MaxStrLen(Workflow.Description)), 1, MaxStrLen(Workflow.Description));
        Workflow.Category := CreateWorkflowCategory();
        Workflow.Template := false;
        Workflow.Insert(true);
    end;

    procedure CreateTemplateWorkflow(var Workflow: Record Workflow)
    begin
        CreateWorkflow(Workflow);
        Workflow.Validate(Template, true);
        Workflow.Modify();
    end;

    procedure CreateEnabledWorkflow(var Workflow: Record Workflow; WorkflowCode: Code[17])
    var
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        CopyWorkflow(Workflow, WorkflowSetup.GetWorkflowTemplateCode(WorkflowCode));
        EnableWorkflow(Workflow);
    end;

    procedure CreateWorkflowTableRelation(var WorkflowTableRelation: Record "Workflow - Table Relation"; TableId: Integer; FieldId: Integer; RelatedTableId: Integer; RelatedFieldId: Integer)
    begin
        WorkflowTableRelation.Init();
        WorkflowTableRelation."Table ID" := TableId;
        WorkflowTableRelation."Field ID" := FieldId;
        WorkflowTableRelation."Related Table ID" := RelatedTableId;
        WorkflowTableRelation."Related Field ID" := RelatedFieldId;
        if WorkflowTableRelation.Insert(true) then;
    end;

    procedure CreateWorkflowStepArgument(var WorkflowStepArgument: Record "Workflow Step Argument"; Type: Option; UserID: Code[50]; TemplateName: Code[10]; BatchName: Code[10]; ApproverType: Enum "Workflow Approver Type"; InformUser: Boolean)
    begin
        WorkflowStepArgument.Init();
        WorkflowStepArgument.Type := Type;
        WorkflowStepArgument."General Journal Template Name" := TemplateName;
        WorkflowStepArgument."General Journal Batch Name" := BatchName;
        WorkflowStepArgument."Notification User ID" := UserID;
        WorkflowStepArgument."Approver Type" := ApproverType;
        WorkflowStepArgument."Approver Limit Type" := WorkflowStepArgument."Approver Limit Type"::"Approver Chain";
        WorkflowStepArgument."Show Confirmation Message" := InformUser;
        WorkflowStepArgument.Insert(true);
    end;

    procedure CreateNotificationSetup(var NotificationSetup: Record "Notification Setup"; UserID: Code[50]; NotificationType: Enum "Notification Entry Type"; NotificationMethod: Enum "Notification Method Type")
    begin
        NotificationSetup.Init();
        NotificationSetup."User ID" := UserID;
        NotificationSetup."Notification Type" := NotificationType;
        NotificationSetup."Notification Method" := NotificationMethod;
        NotificationSetup.Insert(true);
    end;

    procedure SetNotifySenderInResponse(WorkflowCode: Code[20]; StepID: Integer)
    var
        WorkflowStep: Record "Workflow Step";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        WorkflowStep.Get(WorkflowCode, StepID);
        WorkflowStepArgument.Get(WorkflowStep.Argument);
        WorkflowStepArgument.Validate("Notify Sender", true);
        WorkflowStepArgument.Modify();
    end;

    procedure DeleteAllExistingWorkflows()
    var
        Workflow: Record Workflow;
        WorkflowStep: Record "Workflow Step";
        WorkflowStepInstance: Record "Workflow Step Instance";
        WorkflowTableRelationValue: Record "Workflow Table Relation Value";
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowStepArgumentArchive: Record "Workflow Step Argument Archive";
        WorkflowStepInstanceArchive: Record "Workflow Step Instance Archive";
        WorkflowRule: Record "Workflow Rule";
        WorkflowRecordChange: Record "Workflow - Record Change";
        WorkflowRecordChangeArchive: Record "Workflow Record Change Archive";
    begin
        WorkflowRecordChange.DeleteAll();
        WorkflowRecordChangeArchive.DeleteAll();

        WorkflowTableRelationValue.DeleteAll();

        WorkflowStepArgument.DeleteAll();
        WorkflowStepArgumentArchive.DeleteAll();

        WorkflowRule.DeleteAll();
        WorkflowStepInstanceArchive.DeleteAll();

        WorkflowStepInstance.DeleteAll();
        WorkflowStep.DeleteAll();

        Workflow.DeleteAll();
    end;

    procedure DisableAllWorkflows()
    var
        Workflow: Record Workflow;
    begin
        Workflow.SetRange(Template, false);
        Workflow.ModifyAll(Enabled, false, true);
    end;

    procedure EnableWorkflow(var Workflow: Record Workflow)
    begin
        Workflow.Validate(Enabled, true);
        Workflow.Modify(true);
    end;

    procedure DeleteNotifications()
    var
        NotificationEntry: Record "Notification Entry";
    begin
        NotificationEntry.DeleteAll();
    end;

    procedure GetGeneralJournalTemplateAndBatch(var GeneralJnlTemplateCode: Code[10]; var GeneralJnlBatchCode: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        LibraryERM: Codeunit "Library - ERM";
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Payments);
        GenJournalTemplate.FindFirst();

        GeneralJnlTemplateCode := GenJournalTemplate.Name;

        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GeneralJnlTemplateCode);

        GeneralJnlBatchCode := GenJournalBatch.Name;
    end;

    procedure InsertEntryPointEventStep(Workflow: Record Workflow; ActivityName: Code[128]): Integer
    var
        WorkflowStep: Record "Workflow Step";
    begin
        InsertStep(WorkflowStep, Workflow.Code, WorkflowStep.Type::"Event", ActivityName);
        WorkflowStep.Validate("Entry Point", true);
        WorkflowStep.Modify(true);
        exit(WorkflowStep.ID);
    end;

    procedure InsertEventStep(Workflow: Record Workflow; ActivityName: Code[128]; PreviousStepID: Integer): Integer
    var
        WorkflowStep: Record "Workflow Step";
    begin
        InsertStep(WorkflowStep, Workflow.Code, WorkflowStep.Type::"Event", ActivityName);
        WorkflowStep."Sequence No." := GetNextSequenceNo(Workflow, PreviousStepID);
        WorkflowStep.Validate("Previous Workflow Step ID", PreviousStepID);
        WorkflowStep.Modify(true);
        exit(WorkflowStep.ID);
    end;

    procedure InsertResponseStep(Workflow: Record Workflow; ActivityName: Code[128]; PreviousStepID: Integer): Integer
    var
        WorkflowStep: Record "Workflow Step";
    begin
        InsertStep(WorkflowStep, Workflow.Code, WorkflowStep.Type::Response, ActivityName);
        WorkflowStep."Sequence No." := GetNextSequenceNo(Workflow, PreviousStepID);
        WorkflowStep.Validate("Previous Workflow Step ID", PreviousStepID);
        WorkflowStep.Modify(true);
        exit(WorkflowStep.ID);
    end;

    procedure InsertSubWorkflowStep(Workflow: Record Workflow; WorkflowCode: Code[20]; PreviousStepID: Integer): Integer
    var
        WorkflowStep: Record "Workflow Step";
    begin
        InsertStep(WorkflowStep, Workflow.Code, WorkflowStep.Type::"Sub-Workflow", WorkflowCode);
        WorkflowStep."Sequence No." := GetNextSequenceNo(Workflow, PreviousStepID);
        WorkflowStep.Validate("Previous Workflow Step ID", PreviousStepID);
        WorkflowStep.Modify(true);
        exit(WorkflowStep.ID);
    end;

    local procedure InsertStep(var WorkflowStep: Record "Workflow Step"; WorkflowCode: Code[20]; StepType: Option; FunctionName: Code[128])
    begin
        WorkflowStep.Validate("Workflow Code", WorkflowCode);
        WorkflowStep.Validate(Type, StepType);
        WorkflowStep.Validate("Function Name", FunctionName);
        WorkflowStep.Insert(true);
    end;

    local procedure GetNextSequenceNo(Workflow: Record Workflow; PreviousStepID: Integer): Integer
    var
        WorkflowStep: Record "Workflow Step";
    begin
        WorkflowStep.SetRange("Workflow Code", Workflow.Code);
        WorkflowStep.SetRange("Previous Workflow Step ID", PreviousStepID);
        WorkflowStep.SetCurrentKey("Sequence No.");
        if WorkflowStep.FindLast() then
            exit(WorkflowStep."Sequence No." + 1);
        exit(1);
    end;

    procedure SetSequenceNo(Workflow: Record Workflow; WorkflowStepID: Integer; SequenceNo: Integer)
    var
        WorkflowStep: Record "Workflow Step";
    begin
        WorkflowStep.Get(Workflow.Code, WorkflowStepID);
        WorkflowStep.Validate("Sequence No.", SequenceNo);
        WorkflowStep.Modify(true);
    end;

    procedure SetNextStep(Workflow: Record Workflow; WorkflowStepID: Integer; NextStepID: Integer)
    var
        WorkflowStep: Record "Workflow Step";
    begin
        WorkflowStep.Get(Workflow.Code, WorkflowStepID);
        WorkflowStep.Validate("Next Workflow Step ID", NextStepID);
        WorkflowStep.Modify(true);
    end;

    procedure SetEventStepAsEntryPoint(Workflow: Record Workflow; WorkflowStepID: Integer)
    var
        WorkflowStep: Record "Workflow Step";
    begin
        WorkflowStep.Get(Workflow.Code, WorkflowStepID);
        WorkflowStep.TestField(Type, WorkflowStep.Type::"Event");
        WorkflowStep.Validate("Entry Point", true);
        WorkflowStep.Modify(true);
    end;

    procedure SetSubWorkflowStepAsEntryPoint(Workflow: Record Workflow; WorkflowStepID: Integer)
    var
        WorkflowStep: Record "Workflow Step";
    begin
        WorkflowStep.Get(Workflow.Code, WorkflowStepID);
        WorkflowStep.TestField(Type, WorkflowStep.Type::"Sub-Workflow");
        WorkflowStep.Validate("Entry Point", true);
        WorkflowStep.Modify(true);
    end;

    procedure FindWorkflowStepForCreateApprovalRequests(var WorkflowStep: Record "Workflow Step"; WorkflowCode: Code[20])
    var
        WorkflowResponseHandling: Codeunit "Workflow Response Handling";
    begin
        WorkflowStep.SetRange("Workflow Code", WorkflowCode);
        WorkflowStep.SetRange(Type, WorkflowStep.Type::Response);
        WorkflowStep.SetRange("Function Name", WorkflowResponseHandling.CreateApprovalRequestsCode());
        WorkflowStep.FindFirst();
    end;

    procedure UpdateWorkflowStepArgumentWithDirectApproverLimitType(Argument: Guid)
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        UpdateWorkflowStepArgumentApproverLimitType(
          Argument, WorkflowStepArgument."Approver Type"::Approver,
          WorkflowStepArgument."Approver Limit Type"::"Direct Approver", '', '');
    end;

    procedure UpdateWorkflowStepArgumentApproverLimitType(Argument: Guid; ApproverType: Enum "Workflow Approver Type"; ApproverLimitType: Enum "Workflow Approver Limit Type"; WorkflowUserGroupCode: Code[20]; ApproverUserID: Code[50])
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        WorkflowStepArgument.Get(Argument);
        WorkflowStepArgument."Approver Type" := ApproverType;
        WorkflowStepArgument."Approver Limit Type" := ApproverLimitType;
        WorkflowStepArgument."Workflow User Group Code" := WorkflowUserGroupCode;
        WorkflowStepArgument."Approver User ID" := ApproverUserID;
        WorkflowStepArgument.Modify();
    end;

    procedure SetWorkflowDirectApprover(WorkflowCode: Code[20])
    var
        WorkflowStep: Record "Workflow Step";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        FindWorkflowStepForCreateApprovalRequests(WorkflowStep, WorkflowCode);
        UpdateWorkflowStepArgumentApproverLimitType(
          WorkflowStep.Argument, WorkflowStepArgument."Approver Type"::Approver,
          WorkflowStepArgument."Approver Limit Type"::"Direct Approver", '', '');
    end;

    procedure SetWorkflowSpecificApprover(WorkflowCode: Code[20]; ApproverID: Code[50])
    var
        WorkflowStep: Record "Workflow Step";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        FindWorkflowStepForCreateApprovalRequests(WorkflowStep, WorkflowCode);
        UpdateWorkflowStepArgumentApproverLimitType(
          WorkflowStep.Argument, WorkflowStepArgument."Approver Type"::Approver,
          WorkflowStepArgument."Approver Limit Type"::"Specific Approver", '', ApproverID);
    end;

    procedure SetWorkflowGroupApprover(WorkflowCode: Code[20]; GroupCode: Code[20])
    var
        WorkflowStep: Record "Workflow Step";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        FindWorkflowStepForCreateApprovalRequests(WorkflowStep, WorkflowCode);
        UpdateWorkflowStepArgumentApproverLimitType(
          WorkflowStep.Argument, WorkflowStepArgument."Approver Type"::"Workflow User Group",
          WorkflowStepArgument."Approver Limit Type"::"Approver Chain", GroupCode, '');
    end;

    procedure SetWorkflowChainApprover(WorkflowCode: Code[20])
    var
        WorkflowStep: Record "Workflow Step";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        FindWorkflowStepForCreateApprovalRequests(WorkflowStep, WorkflowCode);
        UpdateWorkflowStepArgumentApproverLimitType(
          WorkflowStep.Argument, WorkflowStepArgument."Approver Type"::Approver,
          WorkflowStepArgument."Approver Limit Type"::"Approver Chain", '', '');
    end;

    procedure InsertTableRelation(TableId: Integer; FieldId: Integer; RelatedTableId: Integer; RelatedFieldId: Integer)
    var
        WorkflowTableRelation: Record "Workflow - Table Relation";
    begin
        WorkflowTableRelation.Init();
        WorkflowTableRelation."Table ID" := TableId;
        WorkflowTableRelation."Field ID" := FieldId;
        WorkflowTableRelation."Related Table ID" := RelatedTableId;
        WorkflowTableRelation."Related Field ID" := RelatedFieldId;
        WorkflowTableRelation.Insert();
    end;

    procedure InsertEventArgument(WorkflowStepID: Integer; EventConditions: Text)
    var
        WorkflowStep: Record "Workflow Step";
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        if EventConditions = '' then
            Error(InvalidEventCondErr);

        WorkflowStepArgument.Type := WorkflowStepArgument.Type::"Event";
        WorkflowStepArgument.Insert(true);
        WorkflowStepArgument.SetEventFilters(EventConditions);

        WorkflowStep.SetRange(ID, WorkflowStepID);
        WorkflowStep.FindFirst();
        WorkflowStep.Validate(Argument, WorkflowStepArgument.ID);
        WorkflowStep.Modify(true);
    end;

    procedure InsertNotificationArgument(WorkflowStepID: Integer; NotifUserID: Code[50]; LinkTargetPage: Integer; CustomLink: Text[250])
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        InsertStepArgument(WorkflowStepArgument, WorkflowStepID);

        WorkflowStepArgument."Notification User ID" := NotifUserID;
        WorkflowStepArgument."Link Target Page" := LinkTargetPage;
        WorkflowStepArgument."Custom Link" := CustomLink;
        WorkflowStepArgument.Modify(true);
    end;

    procedure InsertMessageArgument(WorkflowStepID: Integer; Msg: Text[250])
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        InsertStepArgument(WorkflowStepArgument, WorkflowStepID);

        WorkflowStepArgument.Message := Msg;
        WorkflowStepArgument.Modify(true);
    end;

    procedure InsertPmtLineCreationArgument(WorkflowStepID: Integer; GenJnlTemplateName: Code[10]; GenJnlBatchName: Code[10])
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        InsertStepArgument(WorkflowStepArgument, WorkflowStepID);

        WorkflowStepArgument."General Journal Template Name" := GenJnlTemplateName;
        WorkflowStepArgument."General Journal Batch Name" := GenJnlBatchName;
        WorkflowStepArgument.Modify(true);
    end;

    procedure InsertApprovalArgument(WorkflowStepID: Integer; ApproverType: Enum "Workflow Approver Type"; ApproverLimitType: Enum "Workflow Approver Limit Type"; WorkflowUserGroupCode: Text[20]; InformUser: Boolean)
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        InsertStepArgument(WorkflowStepArgument, WorkflowStepID);

        WorkflowStepArgument."Approver Type" := ApproverType;
        WorkflowStepArgument."Approver Limit Type" := ApproverLimitType;
        WorkflowStepArgument."Workflow User Group Code" := WorkflowUserGroupCode;
        WorkflowStepArgument."Show Confirmation Message" := InformUser;
        WorkflowStepArgument.Modify(true);
    end;

    procedure InsertRecChangeValueArgument(WorkflowStepID: Integer; TableNo: Integer; FieldNo: Integer)
    var
        WorkflowStepArgument: Record "Workflow Step Argument";
    begin
        InsertStepArgument(WorkflowStepArgument, WorkflowStepID);

        WorkflowStepArgument."Table No." := TableNo;
        WorkflowStepArgument."Field No." := FieldNo;
        WorkflowStepArgument.Modify(true);
    end;

    local procedure InsertStepArgument(var WorkflowStepArgument: Record "Workflow Step Argument"; WorkflowStepID: Integer)
    var
        WorkflowStep: Record "Workflow Step";
    begin
        WorkflowStep.SetRange(ID, WorkflowStepID);
        WorkflowStep.FindFirst();

        if WorkflowStepArgument.Get(WorkflowStep.Argument) then
            exit;

        WorkflowStepArgument.Type := WorkflowStepArgument.Type::Response;
        WorkflowStepArgument.Validate("Response Function Name", WorkflowStep."Function Name");
        WorkflowStepArgument.Insert(true);

        WorkflowStep.Validate(Argument, WorkflowStepArgument.ID);
        WorkflowStep.Modify(true);
    end;

    procedure InsertEventRule(WorkflowStepId: Integer; FieldNo: Integer; Operator: Option)
    var
        WorkflowStep: Record "Workflow Step";
        WorkflowRule: Record "Workflow Rule";
        WorkflowEvent: Record "Workflow Event";
    begin
        WorkflowStep.SetRange(ID, WorkflowStepId);
        WorkflowStep.FindFirst();

        WorkflowRule.Init();
        WorkflowRule."Workflow Code" := WorkflowStep."Workflow Code";
        WorkflowRule."Workflow Step ID" := WorkflowStep.ID;
        WorkflowRule.Operator := Operator;

        if WorkflowEvent.Get(WorkflowStep."Function Name") then
            WorkflowRule."Table ID" := WorkflowEvent."Table ID";
        WorkflowRule."Field No." := FieldNo;
        WorkflowRule.Insert(true);
    end;

    procedure CreateDynamicRequestPageEntity(Name: Code[20]; TableID: Integer; RelatedTableID: Integer): Code[20]
    var
        DynamicRequestPageEntity: Record "Dynamic Request Page Entity";
    begin
        DynamicRequestPageEntity.Init();
        DynamicRequestPageEntity.Validate(Name, Name);
        DynamicRequestPageEntity.Validate("Table ID", TableID);
        DynamicRequestPageEntity.Validate("Related Table ID", RelatedTableID);
        DynamicRequestPageEntity.Insert(true);
        exit(DynamicRequestPageEntity.Name);
    end;

    procedure CreateDynamicRequestPageField(TableID: Integer; FieldID: Integer)
    var
        DynamicRequestPageField: Record "Dynamic Request Page Field";
    begin
        DynamicRequestPageField.Init();
        DynamicRequestPageField.Validate("Table ID", TableID);
        DynamicRequestPageField.Validate("Field ID", FieldID);
        DynamicRequestPageField.Insert(true);
    end;

    procedure DeleteDynamicRequestPageFields(TableID: Integer)
    var
        DynamicRequestPageField: Record "Dynamic Request Page Field";
    begin
        DynamicRequestPageField.SetRange("Table ID", TableID);
        DynamicRequestPageField.DeleteAll(true);
    end;

    procedure CopyWorkflow(var Workflow: Record Workflow; FromWorkflowCode: Code[20])
    var
        FromWorkflow: Record Workflow;
    begin
        FromWorkflow.Get(FromWorkflowCode);

        CreateWorkflow(Workflow);

        if Workflow.Description = '' then
            Workflow.Description := FromWorkflow.Description;
        Workflow.Modify();

        CopyWorkflowSteps(Workflow, FromWorkflowCode);
    end;

    procedure CopyWorkflowTemplate(var Workflow: Record Workflow; FromWorkflowTemplateCode: Code[17])
    var
        FromWorkflow: Record Workflow;
        WorkflowSetup: Codeunit "Workflow Setup";
    begin
        FromWorkflow.Get(WorkflowSetup.GetWorkflowTemplateCode(FromWorkflowTemplateCode));

        CreateWorkflow(Workflow);

        if Workflow.Description = '' then
            Workflow.Description := FromWorkflow.Description;
        Workflow.Modify();

        CopyWorkflowSteps(Workflow, FromWorkflow.Code);
    end;

    local procedure CopyWorkflowSteps(Workflow: Record Workflow; FromTemplateCode: Code[20])
    var
        FromWorkflowStep: Record "Workflow Step";
        FromWorkflowStepArgument: Record "Workflow Step Argument";
        ToWorkflowStep: Record "Workflow Step";
    begin
        ToWorkflowStep.SetRange("Workflow Code", Workflow.Code);
        ToWorkflowStep.DeleteAll(true);

        FromWorkflowStep.SetRange("Workflow Code", FromTemplateCode);
        if FromWorkflowStep.FindSet() then
            repeat
                ToWorkflowStep.Copy(FromWorkflowStep);

                ToWorkflowStep."Workflow Code" := Workflow.Code;
                if FromWorkflowStepArgument.Get(FromWorkflowStep.Argument) then
                    ToWorkflowStep.Argument := FromWorkflowStepArgument.Clone();
                ToWorkflowStep.Insert(true);

                CopyWorkflowRules(FromWorkflowStep, ToWorkflowStep);
            until FromWorkflowStep.Next() = 0;
    end;

    local procedure CopyWorkflowRules(FromWorkflowStep: Record "Workflow Step"; ToWorkflowStep: Record "Workflow Step")
    var
        FromWorkflowRule: Record "Workflow Rule";
        ToWorkflowRule: Record "Workflow Rule";
    begin
        FromWorkflowStep.FindWorkflowRules(FromWorkflowRule);
        if FromWorkflowRule.FindSet() then
            repeat
                ToWorkflowRule.Copy(FromWorkflowRule);
                ToWorkflowRule.ID := 0;
                ToWorkflowRule."Workflow Code" := ToWorkflowStep."Workflow Code";
                ToWorkflowRule."Workflow Step ID" := ToWorkflowStep.ID;
                ToWorkflowRule.Insert(true);
            until FromWorkflowRule.Next() = 0;
    end;

    procedure CreatePredecessor(Type: Option; FunctionName: Code[128]; PredecessorType: Option; PredecessorFunctionName: Code[128])
    var
        WFEventResponseCombination: Record "WF Event/Response Combination";
    begin
        WFEventResponseCombination.Init();
        WFEventResponseCombination.Type := Type;
        WFEventResponseCombination."Function Name" := FunctionName;
        WFEventResponseCombination."Predecessor Type" := PredecessorType;
        WFEventResponseCombination."Predecessor Function Name" := PredecessorFunctionName;
        if WFEventResponseCombination.Insert() then;
    end;

    procedure CreateEventPredecessor(FunctionName: Code[128]; PredecessorFunctionName: Code[128])
    var
        WFEventResponseCombination: Record "WF Event/Response Combination";
    begin
        CreatePredecessor(WFEventResponseCombination.Type::"Event", FunctionName,
          WFEventResponseCombination."Predecessor Type"::"Event", PredecessorFunctionName);
    end;

    procedure CreateResponsePredecessor(FunctionName: Code[128]; PredecessorFunctionName: Code[128])
    var
        WFEventResponseCombination: Record "WF Event/Response Combination";
    begin
        CreatePredecessor(WFEventResponseCombination.Type::Response, FunctionName,
          WFEventResponseCombination."Predecessor Type"::"Event", PredecessorFunctionName);
    end;

    procedure CreateWorkflowCategory(): Code[20]
    var
        WorkflowCategory: Record "Workflow Category";
    begin
        WorkflowCategory.Code := LibraryUtility.GenerateRandomCode(WorkflowCategory.FieldNo(Code), DATABASE::"Workflow Category");
        WorkflowCategory.Description :=
          CopyStr(LibraryUtility.GenerateRandomXMLText(MaxStrLen(WorkflowCategory.Description)), 1, MaxStrLen(WorkflowCategory.Description));
        WorkflowCategory.Insert();
        exit(WorkflowCategory.Code);
    end;

    local procedure GenerateRandomWorkflowCode() ReturnCode: Code[20]
    var
        Workflow: Record Workflow;
    begin
        repeat
            ReturnCode := LibraryUtility.GenerateRandomCode(Workflow.FieldNo(Code), DATABASE::Workflow);
        until not Workflow.Get(ReturnCode);
    end;
}

