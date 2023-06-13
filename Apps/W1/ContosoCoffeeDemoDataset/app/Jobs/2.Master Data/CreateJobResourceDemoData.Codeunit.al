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
    end;

    procedure CreateResources()
    begin
        CreateResource(JobsDemoDataSetup."Resource Installer No.", 70, 100);
        CreateResource(JobsDemoDataSetup."Resource Vehicle No.", 250, 300);
    end;

    procedure CreateResource(ResourceCode: Code[20]; UnitCost: Decimal; UnitPrice: Decimal)
    var
        Resource: Record Resource;
    begin
        if Resource.Get(ResourceCode) then
            exit;
        Resource."No." := ResourceCode;
        Resource.Name := ResourceCode;
        Resource."Base Unit of Measure" := ResourceUnitOfMeasureTok;
        Resource."Gen. Prod. Posting Group" := ResourceGenProdPostingGroupTok;
        Resource."VAT Prod. Posting Group" := ResourceVATProdPostingGroupTok;
        Resource."Unit Cost" := AdjustJobsDemoData.AdjustPrice(UnitCost);
        Resource."Unit Price" := AdjustJobsDemoData.AdjustPrice(UnitPrice);
        Resource.Insert(true);
        CreateResourceUnitOfMeasure(Resource);
    end;

    local procedure CreateResourceUnitOfMeasure(Resource: Record Resource);
    var
        ResourceUnitOfMeasure: Record "Resource Unit of Measure";
    begin
        if ResourceUnitOfMeasure.Get(Resource."No.", Resource."Base Unit of Measure") then
            exit;

        ResourceUnitOfMeasure."Resource No." := Resource."No.";
        ResourceUnitOfMeasure."Code" := Resource."Base Unit of Measure";
        ResourceUnitOfMeasure.Insert(true);
    end;
}