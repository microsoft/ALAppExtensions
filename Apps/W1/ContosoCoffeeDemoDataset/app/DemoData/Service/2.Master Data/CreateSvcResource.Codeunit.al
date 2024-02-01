codeunit 5105 "Create Svc Resource"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        ServiceModuleSetup: Record "Service Module Setup";
        SvcSetup: Codeunit "Create Svc Setup";
        ContosoResource: Codeunit "Contoso Resource";
        ContosoUoM: Codeunit "Create Common Unit Of Measure";
        ContosoUtilities: Codeunit "Contoso Utilities";
        Resource1Tok: Label 'RESOURCE1', MaxLength = 20;
        Resource2Tok: Label 'RESOURCE2', MaxLength = 20;

    trigger OnRun()
    begin
        ServiceModuleSetup.Get();

        CreateResources();
        CreateResourceSkills();
    end;

    procedure CreateResources()
    var
        CommonPostingGroup: Codeunit "Create Common Posting Group";
    begin
        if ServiceModuleSetup."Resource 1 No." = '' then begin
            ContosoResource.InsertResource(Resource1(), Resource1(), ContosoUoM.Hour(), CommonPostingGroup.Service(), ContosoUtilities.AdjustPrice(50), 0, CommonPostingGroup.NonTaxable());
            ServiceModuleSetup.Validate("Resource 1 No.", Resource1());
        end;

        if ServiceModuleSetup."Resource 2 No." = '' then begin
            ContosoResource.InsertResource(Resource2(), Resource2(), ContosoUoM.Hour(), CommonPostingGroup.Service(), ContosoUtilities.AdjustPrice(50), 0, CommonPostingGroup.NonTaxable());
            ServiceModuleSetup.Validate("Resource 2 No.", Resource2());
        end;

        ServiceModuleSetup.Modify();
    end;

    procedure CreateResourceSkills()
    begin
        ContosoResource.InsertResourceSkill(Enum::"Resource Skill Type"::Resource, ServiceModuleSetup."Resource 1 No.", SvcSetup.SkillElectrical());
        ContosoResource.InsertResourceSkill(Enum::"Resource Skill Type"::Resource, ServiceModuleSetup."Resource 2 No.", SvcSetup.SkillPlumbing());
    end;

    procedure Resource1(): Code[20]
    begin
        exit(Resource1Tok);
    end;

    procedure Resource2(): Code[20]
    begin
        exit(Resource2Tok);
    end;
}