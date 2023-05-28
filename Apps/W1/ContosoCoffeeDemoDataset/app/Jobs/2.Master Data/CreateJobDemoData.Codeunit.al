codeunit 5114 "Create Job Demo Data"
{
    Permissions = tabledata Item = rim,
        tabledata "Item Unit of Measure" = rim,
        tabledata "Job" = rim,
        tabledata "Job Task" = rim;

    var
        JobsDemoDataSetup: Record "Jobs Demo Data Setup";
        AdjustJobsDemoData: Codeunit "Adjust Jobs Demo Data";
        JobsDemoDataFiles: Codeunit "Jobs Demo Data Files";
        DoRunTriggers: Boolean;
        PCSTok: Label 'PCS', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        MachineDescTok: Label 'S-210 Semi-Automatic', MaxLength = 100;
        ConsumableDescTok: Label '100-Pack Filters', MaxLength = 100;
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
        DoRunTriggers := true;
        OnBeforeStartCreation(DoRunTriggers);
        JobsDemoDataSetup.Get();

        CreateItems();
        OnAfterCreatedItems();

        CreateJob();
        OnAfterCreatedJob();

        CreateJobTasks();
        OnAfterCreatedJobTasks();
    end;

    local procedure CreateItems()
    begin
        // Create two Items using the JobsDemoDataSetup Item values
        InsertItem(JobsDemoDataSetup."Item Machine No.", MachineDescTok, AdjustJobsDemoData.AdjustPrice(17900), AdjustJobsDemoData.AdjustPrice(15500),
            JobsDemoDataSetup."Retail Code", JobsDemoDataSetup."Resale Code", Enum::"Costing Method"::FIFO, PCSTok, 0.75, JobsDemoDataFiles.GetMachinePicture(), '');
        InsertItem(JobsDemoDataSetup."Item Consumable No.", ConsumableDescTok, AdjustJobsDemoData.AdjustPrice(65), AdjustJobsDemoData.AdjustPrice(100),
            JobsDemoDataSetup."Retail Code", JobsDemoDataSetup."Resale Code", Enum::"Costing Method"::FIFO, PCSTok, 0.75, JobsDemoDataFiles.GetConsumablePicture(), '');
    end;

    local procedure InsertItem("No.": Code[20]; Description: Text[100]; UnitPrice: Decimal; LastDirectCost: Decimal; GenProdPostingGr: Code[20];
                                InventoryPostingGroup: Code[20]; CostingMethod: Enum "Costing Method"; BaseUnitOfMeasure: Code[10]; NetWeight: Decimal;
                                ItempPicTempBlob: Codeunit "Temp Blob"; ItemPictureDescription: Text)
    var
        Item: Record Item;
        ObjInStream: InStream;
    begin
        if Item.Get("No.") then
            exit;
        Item.Init();
        Item.Validate("No.", "No.");

        Item.Validate(Description, Description);

        if BaseUnitOfMeasure <> '' then
            Item."Base Unit of Measure" := BaseUnitOfMeasure
        else
            Item."Base Unit of Measure" := PCSTok;

        Item."Net Weight" := NetWeight;

        Item."Sales Unit of Measure" := Item."Base Unit of Measure";
        Item."Purch. Unit of Measure" := Item."Base Unit of Measure";

        if InventoryPostingGroup <> '' then
            Item."Inventory Posting Group" := InventoryPostingGroup
        else
            Item."Inventory Posting Group" := JobsDemoDataSetup."Resale Code";

        if GenProdPostingGr <> '' then
            Item.Validate("Gen. Prod. Posting Group", GenProdPostingGr)
        else
            Item.Validate("Gen. Prod. Posting Group", JobsDemoDataSetup."Retail Code");

        Item."Costing Method" := CostingMethod;

        Item."Last Direct Cost" := LastDirectCost;
        if Item."Costing Method" = "Costing Method"::Standard then
            Item."Standard Cost" := Item."Last Direct Cost";
        Item."Unit Cost" := Item."Last Direct Cost";

        Item.Validate("Unit Price", UnitPrice);

        if ItempPicTempBlob.HasValue() then begin
            ItempPicTempBlob.CreateInStream(ObjInStream);
            Item.Picture.ImportStream(ObjInStream, ItemPictureDescription);
        end;

        OnBeforeItemInsert(Item);
        Item.Insert(DoRunTriggers);

        // Create the Item Unit of Measure
        CreateBaseItemUnitOfMeasure(Item);
    end;

    local procedure CreateBaseItemUnitOfMeasure(Item: Record Item)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        ItemUnitOfMeasure.Init();
        ItemUnitOfMeasure.Validate("Item No.", Item."No.");
        ItemUnitOfMeasure.Validate(Code, Item."Base Unit of Measure");
        ItemUnitOfMeasure."Qty. per Unit of Measure" := 1;
        ItemUnitOfMeasure.Insert();
    end;

    local procedure CreateJob()
    var
        Job: Record Job;
    begin
        if not Job.Get(JobNoTok) then begin
            Job.Init();
            Job."No." := JobNoTok;
            Job.Validate(Description, JobNameTok);
            OnBeforeJobInsert(Job);
            Job.Insert(DoRunTriggers);
            Job.Validate("Bill-to Customer No.", JobsDemoDataSetup."Customer No.");
            Job.Modify(DoRunTriggers);
        end;
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
        OnAfterCreatedJobTasks();
    end;

    local procedure CreateJobTask(JobNo: Code[20]; JobTaskNo: Code[20]; TaskDescription: Text[100]; JobTaskType: Enum "Job Task Type")
    var
        JobTask: Record "Job Task";
    begin
        if not JobTask.Get(JobNo, JobTaskNo) then begin
            JobTask.Init();
            JobTask.Validate("Job No.", JobNo);
            JobTask.Validate("Job Task No.", JobTaskNo);
            JobTask.Validate(Description, TaskDescription);
            JobTask."Job Task Type" := JobTaskType;
            OnBeforeJobTaskInsert(JobTask);
            JobTask.Insert(DoRunTriggers);
        end;
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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeItemInsert(var Item: Record Item)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatedItems()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeStartCreation(var DoRunTriggers: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeJobInsert(Job: Record Job)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatedJob()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeJobTaskInsert(JobTask: Record "Job Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatedJobTasks()
    begin
    end;
}