codeunit 5115 "Create Job Resource Demo Data"
{

    Permissions = tabledata "Resource" = rim,
        tabledata "Resource Unit of Measure" = rim;

    var
        JobsDemoDataSetup: Record "Jobs Demo Data Setup";
        AdjustJobsDemoData: Codeunit "Adjust Jobs Demo Data";
        ResourceUnitOfMeasureTok: Label 'HOUR', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        ResourceGenProdPostingGroupTok: Label 'SERVICES', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        ResourceVATProdPostingGroupTok: Label 'REDUCED', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';

    trigger OnRun()
    begin
        JobsDemoDataSetup.Get();

        CreateResources();
        OnAfterCreatedResources();
    end;

    procedure CreateResources()
    var
        Resource: Record Resource;
    begin
        if not Resource.Get(JobsDemoDataSetup."Resource Installer No.") then begin
            Resource."No." := JobsDemoDataSetup."Resource Installer No.";
            Resource.Name := JobsDemoDataSetup."Resource Installer No.";
            Resource."Base Unit of Measure" := ResourceUnitOfMeasureTok;
            Resource."Gen. Prod. Posting Group" := ResourceGenProdPostingGroupTok;
            Resource."VAT Prod. Posting Group" := ResourceVATProdPostingGroupTok;
            Resource."Unit Cost" := AdjustJobsDemoData.AdjustPrice(70);
            Resource."Unit Price" := AdjustJobsDemoData.AdjustPrice(100);
            OnBeforeResourceInsert(Resource);
            Resource.Insert(true);
            CreateResourceUnitOfMeasure(Resource);
        end;
        if not Resource.Get(JobsDemoDataSetup."Resource Vehicle No.") then begin
            Resource."No." := JobsDemoDataSetup."Resource Vehicle No.";
            Resource.Name := JobsDemoDataSetup."Resource Vehicle No.";
            Resource."Base Unit of Measure" := ResourceUnitOfMeasureTok;
            Resource."Gen. Prod. Posting Group" := ResourceGenProdPostingGroupTok;
            Resource."VAT Prod. Posting Group" := ResourceVATProdPostingGroupTok;
            Resource."Unit Cost" := AdjustJobsDemoData.AdjustPrice(250);
            Resource."Unit Price" := AdjustJobsDemoData.AdjustPrice(300);
            OnBeforeResourceInsert(Resource);
            Resource.Insert(true);
            CreateResourceUnitOfMeasure(Resource);
        end;
    end;

    local procedure CreateResourceUnitOfMeasure(Resource: Record Resource);
    var
        ResourceUnitOfMeasure: Record "Resource Unit of Measure";
    begin
        if not ResourceUnitOfMeasure.Get(Resource."No.", Resource."Base Unit of Measure") then begin
            ResourceUnitOfMeasure."Resource No." := Resource."No.";
            ResourceUnitOfMeasure."Code" := Resource."Base Unit of Measure";
            ResourceUnitOfMeasure.Insert(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResourceInsert(var Resource: Record Resource)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatedResources()
    begin
    end;
}