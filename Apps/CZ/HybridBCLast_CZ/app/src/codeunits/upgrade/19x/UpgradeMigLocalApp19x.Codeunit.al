codeunit 11802 "Upgrade Mig Local App 19x"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'This functionality will be replaced by invoking the actual upgrade from each of the apps';
    ObsoleteTag = '19.0';

    trigger OnRun()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"W1 Company Handler", 'OnUpgradePerCompanyDataForVersion', '', false, false)]
    local procedure OnUpgradePerCompanyDataUpgrade(HybridReplicationSummary: Record "Hybrid Replication Summary"; CountryCode: Text; TargetVersion: Decimal)
    begin
        if TargetVersion <> 19.0 then
            exit;

#if CLEAN17
        UpdateCashDeskWorkflowTemplate();
#endif
#if CLEAN18
        UpdateCreditWorkflowTemplate();
#endif
#if CLEAN19
        UpdatePaymentOrderWorkflowTemplate();
        UpdateAdvanceLetterWorkflowTemplate();
#endif
    end;

#if CLEAN17
    local procedure UpdateCashDeskWorkflowTemplate()
    var
        CashDocApprWorkflowCodeTxt: Label 'MS-CDAPW', Locked = true;
        UpgradeTag: Codeunit "Upgrade Tag";
        LocalUpgradeTagDefinitions: Codeunit "Local Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(LocalUpgradeTagDefinitions.GetCashDeskWorkflowTemplatesCodeUpgradeTag()) then
            exit;

        DeleteWorkflowTemplate(CashDocApprWorkflowCodeTxt);

        UpgradeTag.SetUpgradeTag(LocalUpgradeTagDefinitions.GetCashDeskWorkflowTemplatesCodeUpgradeTag());
    end;

#endif
#if CLEAN18
    local procedure UpdateCreditWorkflowTemplate()
    var
        CreditDocApprWorkflowCodeTxt: Label 'MS-CRAPW', Locked = true;
        UpgradeTag: Codeunit "Upgrade Tag";
        LocalUpgradeTagDefinitions: Codeunit "Local Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(LocalUpgradeTagDefinitions.GetCreditWorkflowTemplatesCodeUpgradeTag()) then
            exit;

        DeleteWorkflowTemplate(CreditDocApprWorkflowCodeTxt);

        UpgradeTag.SetUpgradeTag(LocalUpgradeTagDefinitions.GetCreditWorkflowTemplatesCodeUpgradeTag());
    end;

#endif
#if CLEAN19
    local procedure UpdatePaymentOrderWorkflowTemplate()
    var
        PaymentOrderApprWorkflowCodeTxt: Label 'MS-PMTORDAPW', Locked = true;
        UpgradeTag: Codeunit "Upgrade Tag";
        LocalUpgradeTagDefinitions: Codeunit "Local Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(LocalUpgradeTagDefinitions.GetPaymentOrderWorkflowTemplatesCodeUpgradeTag()) then
            exit;

        DeleteWorkflowTemplate(PaymentOrderApprWorkflowCodeTxt);

        UpgradeTag.SetUpgradeTag(LocalUpgradeTagDefinitions.GetPaymentOrderWorkflowTemplatesCodeUpgradeTag());
    end;

    local procedure UpdateAdvanceLetterWorkflowTemplate()
    var
        SalesAdvanceLetterApprWorkflowCodeTxt: Label 'MS-SALAPW', Locked = true;
        PurchAdvanceLetterApprWorkflowCodeTxt: Label 'MS-PALAPW', Locked = true;
        UpgradeTag: Codeunit "Upgrade Tag";
        LocalUpgradeTagDefinitions: Codeunit "Local Upgrade Tag Definitions";
    begin
        if UpgradeTag.HasUpgradeTag(LocalUpgradeTagDefinitions.GetAdvanceLetterWorkflowTemplatesCodeUpgradeTag()) then
            exit;

        DeleteWorkflowTemplate(SalesAdvanceLetterApprWorkflowCodeTxt);
        DeleteWorkflowTemplate(PurchAdvanceLetterApprWorkflowCodeTxt);

        UpgradeTag.SetUpgradeTag(LocalUpgradeTagDefinitions.GetAdvanceLetterWorkflowTemplatesCodeUpgradeTag());
    end;
#endif

    internal procedure DeleteWorkflowTemplate(WorkflowCode: Code[20])
    var
        Workflow: Record Workflow;
    begin
        if Workflow.Get(WorkflowCode) then begin
            Workflow.TestField(Template, true);
            DeleteWorkflowSteps(Workflow.Code);
            Workflow.Delete(false);
        end;
    end;

    local procedure DeleteWorkflowSteps(WorkflowCode: Code[20])
    var
        WorkflowStep: Record "Workflow Step";
        WorkflowStepArgument: Record "Workflow Step Argument";
        WorkflowRule: Record "Workflow Rule";
        ZeroGuid: Guid;
    begin
        WorkflowStep.SetRange("Workflow Code", WorkflowCode);
        if WorkflowStep.FindSet() then
            repeat
                if WorkflowStepArgument.Get(WorkflowStep.Argument) then
                    WorkflowStepArgument.Delete(false);

                WorkflowRule.SetRange("Workflow Code", WorkflowStep."Workflow Code");
                WorkflowRule.SetRange("Workflow Step ID", WorkflowStep.ID);
                WorkflowRule.SetRange("Workflow Step Instance ID", ZeroGuid);
                if not WorkflowRule.IsEmpty() then
                    WorkflowRule.DeleteAll();

                WorkflowStep.Delete(false);
            until WorkflowStep.Next() = 0;
    end;
}