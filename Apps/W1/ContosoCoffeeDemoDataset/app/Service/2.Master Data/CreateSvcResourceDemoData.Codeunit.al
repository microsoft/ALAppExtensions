/// <summary>
/// This codeunit is used to create the resource and resource settings used for Contoso, like Resource Skills and Zones
/// </summary>
codeunit 5105 "Create Svc Resource Demo Data"
{

    Permissions = tabledata "Resource" = rim,
        tabledata "Resource Unit of Measure" = rim,
        tabledata "Resource Skill" = rim,
        tabledata "Resource Service Zone" = rim;

    var
        SvcDemoDataSetup: Record "Svc Demo Data Setup";
        AdjustSvcDemoData: Codeunit "Adjust Svc Demo Data";
        CreateSvcSetup: Codeunit "Create Svc Setup";
        ResourceUnitOfMeasureTok: Label 'HOUR', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        ResourceGenProdPostingGroupTok: Label 'SERVICES', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';
        ResourceVATProdPostingGroupTok: Label 'REDUCED', MaxLength = 10, Comment = 'Must be the same as Standard and Eval demodata';

    trigger OnRun()
    begin
        SvcDemoDataSetup.Get();

        CreateResources();
        CreateResourceSkills();
        CreateResourceServiceZones();
    end;

    procedure CreateResources()
    begin
        // Create Resources R1 and R2 for 'REMOTE' and L1 and L2 for 'LOCAL' workers
        CreateResource(SvcDemoDataSetup."Resource R1 No.", 150);
        CreateResource(SvcDemoDataSetup."Resource R2 No.", 200);
        CreateResource(SvcDemoDataSetup."Resource L1 No.", 100);
        CreateResource(SvcDemoDataSetup."Resource L2 No.", 125);
    end;

    procedure CreateResource(ResourceCode: Code[20]; UnitPrice: Decimal)
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
        Resource."Unit Price" := AdjustSvcDemoData.AdjustPrice(UnitPrice);
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

    procedure CreateResourceSkills()
    begin
        CreateResourceSkill(SvcDemoDataSetup."Resource L1 No.", CreateSvcSetup.GetSkillCodeSmallTok());
        CreateResourceSkill(SvcDemoDataSetup."Resource R1 No.", CreateSvcSetup.GetSkillCodeSmallTok());
        CreateResourceSkill(SvcDemoDataSetup."Resource L2 No.", CreateSvcSetup.GetSkillCodeLargeTok());
        CreateResourceSkill(SvcDemoDataSetup."Resource R2 No.", CreateSvcSetup.GetSkillCodeLargeTok());
    end;

    procedure CreateResourceSkill(ResourceCode: Code[20]; SkillCode: Code[10])
    var
        ResourceSkill: Record "Resource Skill";
    begin
        if ResourceSkill.Get(ResourceSkill.Type::Resource, ResourceCode, SkillCode) then
            exit;
        ResourceSkill.Type := ResourceSkill.Type::Resource;
        ResourceSkill."No." := ResourceCode;
        ResourceSkill."Skill Code" := SkillCode;
        ResourceSkill.Insert(true);
    end;

    procedure CreateResourceServiceZones()
    begin
        CreateResourceServiceZones(SvcDemoDataSetup."Resource L1 No.", CreateSvcSetup.GetServiceZoneLocalTok());
        CreateResourceServiceZones(SvcDemoDataSetup."Resource L2 No.", CreateSvcSetup.GetServiceZoneLocalTok());
        CreateResourceServiceZones(SvcDemoDataSetup."Resource R1 No.", CreateSvcSetup.GetServiceZoneRemoteTok());
        CreateResourceServiceZones(SvcDemoDataSetup."Resource R2 No.", CreateSvcSetup.GetServiceZoneRemoteTok());
    end;

    procedure CreateResourceServiceZones(ResourceCode: Code[20]; ZoneCode: Code[10])
    var
        ResourceServiceZone: Record "Resource Service Zone";
    begin
        if ResourceServiceZone.Get(ResourceCode, ZoneCode) then
            exit;
        ResourceServiceZone."Resource No." := ResourceCode;
        ResourceServiceZone."Service Zone Code" := ZoneCode;
        ResourceServiceZone.Insert(true);
    end;
}