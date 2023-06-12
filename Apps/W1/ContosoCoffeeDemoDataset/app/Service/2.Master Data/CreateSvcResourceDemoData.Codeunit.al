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
        OnAfterCreatedResources();

        CreateResourceSkills();
        OnAfterCreatedResourceSkills();

        CreateResourceServiceZones();
        OnAfterCreatedResourceServiceZones();
    end;

    procedure CreateResources()
    var
        Resource: Record Resource;
    begin
        // Create Resources R1 and R2 for 'REMOTE' and L1 and L2 for 'LOCAL' workers
        if not Resource.Get(SvcDemoDataSetup."Resource R1 No.") then begin
            Resource."No." := SvcDemoDataSetup."Resource R1 No.";
            Resource.Name := SvcDemoDataSetup."Resource R1 No.";
            Resource."Base Unit of Measure" := ResourceUnitOfMeasureTok;
            Resource."Gen. Prod. Posting Group" := ResourceGenProdPostingGroupTok;
            Resource."VAT Prod. Posting Group" := ResourceVATProdPostingGroupTok;
            Resource."Unit Price" := AdjustSvcDemoData.AdjustPrice(150);
            OnBeforeResourceInsert(Resource);
            Resource.Insert(true);
            CreateResourceUnitOfMeasure(Resource);
        end;
        if not Resource.Get(SvcDemoDataSetup."Resource R2 No.") then begin
            Resource."No." := SvcDemoDataSetup."Resource R2 No.";
            Resource.Name := SvcDemoDataSetup."Resource R2 No.";
            Resource."Base Unit of Measure" := ResourceUnitOfMeasureTok;
            Resource."Gen. Prod. Posting Group" := ResourceGenProdPostingGroupTok;
            Resource."VAT Prod. Posting Group" := ResourceVATProdPostingGroupTok;
            Resource."Unit Price" := AdjustSvcDemoData.AdjustPrice(200);
            OnBeforeResourceInsert(Resource);
            Resource.Insert(true);
            CreateResourceUnitOfMeasure(Resource);
        end;
        if not Resource.Get(SvcDemoDataSetup."Resource L1 No.") then begin
            Resource."No." := SvcDemoDataSetup."Resource L1 No.";
            Resource.Name := SvcDemoDataSetup."Resource L1 No.";
            Resource."Base Unit of Measure" := ResourceUnitOfMeasureTok;
            Resource."Gen. Prod. Posting Group" := ResourceGenProdPostingGroupTok;
            Resource."VAT Prod. Posting Group" := ResourceVATProdPostingGroupTok;
            Resource."Unit Price" := AdjustSvcDemoData.AdjustPrice(100);
            OnBeforeResourceInsert(Resource);
            Resource.Insert(true);
            CreateResourceUnitOfMeasure(Resource);
        end;
        if not Resource.Get(SvcDemoDataSetup."Resource L2 No.") then begin
            Resource."No." := SvcDemoDataSetup."Resource L2 No.";
            Resource.Name := SvcDemoDataSetup."Resource L2 No.";
            Resource."Base Unit of Measure" := ResourceUnitOfMeasureTok;
            Resource."Gen. Prod. Posting Group" := ResourceGenProdPostingGroupTok;
            Resource."VAT Prod. Posting Group" := ResourceVATProdPostingGroupTok;
            Resource."Unit Price" := AdjustSvcDemoData.AdjustPrice(125);
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

    procedure CreateResourceSkills()
    var
        ResourceSkill: Record "Resource Skill";
    begin
        if not ResourceSkill.Get(ResourceSkill.Type::Resource, SvcDemoDataSetup."Resource L1 No.", CreateSvcSetup.GetSkillCodeSmallTok()) then begin
            ResourceSkill.Type := ResourceSkill.Type::Resource;
            ResourceSkill."No." := SvcDemoDataSetup."Resource L1 No.";
            ResourceSkill."Skill Code" := CreateSvcSetup.GetSkillCodeSmallTok();
            OnBeforeResourceSkillInsert(ResourceSkill);
            ResourceSkill.Insert(true);
        end;
        if not ResourceSkill.Get(ResourceSkill.Type::Resource, SvcDemoDataSetup."Resource R1 No.", CreateSvcSetup.GetSkillCodeSmallTok()) then begin
            ResourceSkill.Type := ResourceSkill.Type::Resource;
            ResourceSkill."No." := SvcDemoDataSetup."Resource R1 No.";
            ResourceSkill."Skill Code" := CreateSvcSetup.GetSkillCodeSmallTok();
            OnBeforeResourceSkillInsert(ResourceSkill);
            ResourceSkill.Insert(true);
        end;
        if not ResourceSkill.Get(ResourceSkill.Type::Resource, SvcDemoDataSetup."Resource L2 No.", CreateSvcSetup.GetSkillCodeLargeTok()) then begin
            ResourceSkill.Type := ResourceSkill.Type::Resource;
            ResourceSkill."No." := SvcDemoDataSetup."Resource L2 No.";
            ResourceSkill."Skill Code" := CreateSvcSetup.GetSkillCodeLargeTok();
            OnBeforeResourceSkillInsert(ResourceSkill);
            ResourceSkill.Insert(true);
        end;
        if not ResourceSkill.Get(ResourceSkill.Type::Resource, SvcDemoDataSetup."Resource R2 No.", CreateSvcSetup.GetSkillCodeLargeTok()) then begin
            ResourceSkill.Type := ResourceSkill.Type::Resource;
            ResourceSkill."No." := SvcDemoDataSetup."Resource R2 No.";
            ResourceSkill."Skill Code" := CreateSvcSetup.GetSkillCodeLargeTok();
            OnBeforeResourceSkillInsert(ResourceSkill);
            ResourceSkill.Insert(true);
        end;
    end;

    procedure CreateResourceServiceZones()
    var
        ResourceServiceZone: Record "Resource Service Zone";
    begin
        if not ResourceServiceZone.Get(SvcDemoDataSetup."Resource L1 No.", CreateSvcSetup.GetServiceZoneLocalTok()) then begin
            ResourceServiceZone."Resource No." := SvcDemoDataSetup."Resource L1 No.";
            ResourceServiceZone."Service Zone Code" := CreateSvcSetup.GetServiceZoneLocalTok();
            OnBeforeResourceServiceZoneInsert(ResourceServiceZone);
            ResourceServiceZone.Insert(true);
        end;
        if not ResourceServiceZone.Get(SvcDemoDataSetup."Resource R1 No.", CreateSvcSetup.GetServiceZoneRemoteTok()) then begin
            ResourceServiceZone."Resource No." := SvcDemoDataSetup."Resource R1 No.";
            ResourceServiceZone."Service Zone Code" := CreateSvcSetup.GetServiceZoneRemoteTok();
            OnBeforeResourceServiceZoneInsert(ResourceServiceZone);
            ResourceServiceZone.Insert(true);
        end;
        if not ResourceServiceZone.Get(SvcDemoDataSetup."Resource L2 No.", CreateSvcSetup.GetServiceZoneLocalTok()) then begin
            ResourceServiceZone."Resource No." := SvcDemoDataSetup."Resource L2 No.";
            ResourceServiceZone."Service Zone Code" := CreateSvcSetup.GetServiceZoneLocalTok();
            OnBeforeResourceServiceZoneInsert(ResourceServiceZone);
            ResourceServiceZone.Insert(true);
        end;
        if not ResourceServiceZone.Get(SvcDemoDataSetup."Resource R2 No.", CreateSvcSetup.GetServiceZoneRemoteTok()) then begin
            ResourceServiceZone."Resource No." := SvcDemoDataSetup."Resource R2 No.";
            ResourceServiceZone."Service Zone Code" := CreateSvcSetup.GetServiceZoneRemoteTok();
            OnBeforeResourceServiceZoneInsert(ResourceServiceZone);
            ResourceServiceZone.Insert(true);
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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResourceSkillInsert(var ResourceSkill: Record "Resource Skill")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatedResourceSkills()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeResourceServiceZoneInsert(var ResourceServiceZone: Record "Resource Service Zone")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatedResourceServiceZones()
    begin
    end;
}