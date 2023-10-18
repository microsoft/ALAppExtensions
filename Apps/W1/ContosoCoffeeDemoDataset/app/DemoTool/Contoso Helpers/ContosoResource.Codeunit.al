codeunit 5120 "Contoso Resource"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions =
        tabledata Resource = rim,
        tabledata "Resource Skill" = rim;

    var
        OverwriteData: Boolean;

    procedure SetOverwriteData(Overwrite: Boolean)
    begin
        OverwriteData := Overwrite;
    end;

    procedure InsertResource(ResourceCode: Code[20]; Name: Text[100]; UnitOfMeasure: Code[10]; GenProdPostingGroup: Code[20]; UnitCost: Decimal; UnitPrice: Decimal; TaxGroup: Code[20])
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        Resource: Record Resource;
        Exists: Boolean;
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if Resource.Get(ResourceCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        Resource.Validate("No.", ResourceCode);
        Resource.Validate(Name, ResourceCode);
        Resource.Validate("Gen. Prod. Posting Group", GenProdPostingGroup);

        if ContosoCoffeeDemoDataSetup."Company Type" = ContosoCoffeeDemoDataSetup."Company Type"::"Sales Tax" then
            if GenProdPostingGroup <> '' then
                Resource.Validate("Tax Group Code", TaxGroup);

        Resource.Validate("Unit Cost", UnitCost);
        Resource.Validate("Unit Price", UnitPrice);

        if Exists then
            Resource.Modify(true)
        else
            Resource.Insert(true);

        if UnitOfMeasure <> '' then begin
            Resource.Validate("Base Unit of Measure", UnitOfMeasure);
            Resource.Modify(true);
        end;
    end;

    procedure InsertResourceSkill(ResourceSkillType: Enum "Resource Skill Type"; ResourceNo: Code[20]; SkillCode: Code[20])
    var
        ResourceSkill: Record "Resource Skill";
        Exists: Boolean;
    begin
        if ResourceSkill.Get(ResourceSkillType, ResourceNo, SkillCode) then begin
            Exists := true;

            if not OverwriteData then
                exit;
        end;

        ResourceSkill.Validate(Type, ResourceSkillType);
        ResourceSkill.Validate("No.", ResourceNo);
        ResourceSkill.Validate("Skill Code", skillCode);

        if Exists then
            ResourceSkill.Modify(true)
        else
            ResourceSkill.Insert(true);
    end;
}