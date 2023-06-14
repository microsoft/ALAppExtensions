codeunit 5119 "Create Job Demo Tasks"
{
    Permissions = tabledata "Job" = rim,
        tabledata "Job Task" = rim;

    var
        JobsDemoDataSetup: Record "Jobs Demo Data Setup";
        JobNoTok: Label 'J00010', MaxLength = 20;
        JobNameTok: Label 'Installation of S-100 Semi-Automatic', MaxLength = 100;
        TaskDelivStartNoTok: Label '100', MaxLength = 20;
        TaskDelivStartDescTok: Label 'Delivery Stage', MaxLength = 100;
        TaskDelivFeeNoTok: Label '110', MaxLength = 20;
        TaskDelivFeeDescTok: Label 'Delivery Fees', MaxLength = 100;
        TaskDelivEndNoTok: Label '199', MaxLength = 20;
        TaskDelivEndDescTok: Label 'Total, Delivery Stage', MaxLength = 100;
        TaskInstallStartNoTok: Label '200', MaxLength = 20;
        TaskInstallStartDescTok: Label 'Installation Stage', MaxLength = 100;
        TaskInstallServiceNoTok: Label '210', MaxLength = 20;
        TaskInstallServiceDescTok: Label 'Installation Service', MaxLength = 100;
        TaskInstallEndNoTok: Label '299', MaxLength = 20;
        TaskInstallEndDescTok: Label 'Total, Installation Stage', MaxLength = 100;

    trigger OnRun()
    begin
        JobsDemoDataSetup.Get();

        CreateJob();
        CreateJobTasks();
    end;

    local procedure CreateJob()
    var
        Job: Record Job;
    begin
        if Job.Get(JobNoTok) then
            exit;

        Job.Init();
        Job."No." := JobNoTok;
        Job.Validate(Description, JobNameTok);
        Job.Insert(true);
        Job.Validate("Bill-to Customer No.", JobsDemoDataSetup."Customer No.");
        Job.Modify(true);
    end;

    local procedure CreateJobTasks()
    var
        JobTask: Record "Job Task";
        PauseJobIndentEvent: Codeunit "Pause Job Indent Event";
    begin
        CreateJobTask(JobNoTok, TaskDelivStartNoTok, TaskDelivStartDescTok, Enum::"Job Task Type"::"Begin-Total");
        CreateJobTask(JobNoTok, TaskDelivFeeNoTok, TaskDelivFeeDescTok, Enum::"Job Task Type"::"Posting");
        CreateJobTask(JobNoTok, TaskDelivEndNoTok, TaskDelivEndDescTok, Enum::"Job Task Type"::"End-Total");
        CreateJobTask(JobNoTok, TaskInstallStartNoTok, TaskInstallStartDescTok, Enum::"Job Task Type"::"Begin-Total");
        CreateJobTask(JobNoTok, TaskInstallServiceNoTok, TaskInstallServiceDescTok, Enum::"Job Task Type"::"Posting");
        CreateJobTask(JobNoTok, TaskInstallEndNoTok, TaskInstallEndDescTok, Enum::"Job Task Type"::"End-Total");
        JobTask.SetRange("Job No.", JobNoTok);
        if JobTask.FindFirst() then begin
            BindSubscription(PauseJobIndentEvent);
            Codeunit.Run(Codeunit::"Job Task-Indent", JobTask);
            UnbindSubscription(PauseJobIndentEvent);
        end;
    end;

    local procedure CreateJobTask(JobNo: Code[20]; JobTaskNo: Code[20]; TaskDescription: Text[100]; JobTaskType: Enum "Job Task Type")
    var
        JobTask: Record "Job Task";
    begin
        if JobTask.Get(JobNo, JobTaskNo) then
            exit;

        JobTask.Init();
        JobTask.Validate("Job No.", JobNo);
        JobTask.Validate("Job Task No.", JobTaskNo);
        JobTask.Validate(Description, TaskDescription);
        JobTask."Job Task Type" := JobTaskType;
        JobTask.Insert(true);
    end;

    procedure GetJobNo(): Code[20]
    begin
        exit(JobNoTok);
    end;

    procedure GetDeliveryFeeTaskNo(): Code[20]
    begin
        exit(TaskDelivFeeNoTok);
    end;

    procedure GetInstallationServiceTaskNo(): Code[20]
    begin
        exit(TaskInstallServiceNoTok);
    end;
}