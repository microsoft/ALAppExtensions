codeunit 13731 "Job Posting Group DK"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"Job Posting Group", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnbeforeInsertJobPostingGroup(var Rec: Record "Job Posting Group")
    var
        CreateJobPostingGroup: Codeunit "Create Job Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateGLAccDK: Codeunit "Create GL Acc. DK";
    begin
        case Rec.Code of
            CreateJobPostingGroup.DefaultJobPostingGroup():
                ValidateRecordFields(Rec, CreateGLAccount.WIPJobCosts(), CreateGLAccount.AccruedJobCosts(), CreateGLAccDK.Jobcostsapplied(), '', CreateGLAccount.WIPJobSales(), CreateGLAccount.WIPJobCosts(), CreateGLAccDK.Jobsalesapplied(), '', CreateGLAccount.JobCosts(), CreateGLAccount.JobCosts());
        end;
    end;

    procedure ValidateRecordFields(JobPostingGroup: Record "Job Posting Group"; WIPCostsAcc: Code[20]; WIPAccruedCostsAcc: Code[20]; JobCostsAppliedAcc: Code[20]; JobCostsAdjAcc: Code[20]; WIPAccruedSalesAcc: Code[20]; WIPInvoicedSalesAcc: Code[20]; JobSalesAppliedAcc: Code[20]; JobSalesAdjAcc: Code[20]; RecognizedCostAcc: Code[20]; RecognizedSalesAcc: Code[20])
    begin
        JobPostingGroup.Validate("WIP Costs Account", WIPCostsAcc);
        JobPostingGroup.Validate("WIP Accrued Costs Account", WIPAccruedCostsAcc);
        JobPostingGroup.Validate("Job Costs Applied Account", JobCostsAppliedAcc);
        JobPostingGroup.Validate("Job Costs Adjustment Account", JobCostsAdjAcc);
        JobPostingGroup.Validate("WIP Accrued Sales Account", WIPAccruedSalesAcc);
        JobPostingGroup.Validate("WIP Invoiced Sales Account", WIPInvoicedSalesAcc);
        JobPostingGroup.Validate("Job Sales Applied Account", JobSalesAppliedAcc);
        JobPostingGroup.Validate("Job Sales Adjustment Account", JobSalesAdjAcc);
        JobPostingGroup.Validate("Recognized Costs Account", RecognizedCostAcc);
        JobPostingGroup.Validate("Recognized Sales Account", RecognizedSalesAcc);
    end;
}