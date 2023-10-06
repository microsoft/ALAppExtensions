codeunit 5193 "Contoso Demo Tool"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Contoso Demo Data Module" = rim;

    var
        SelectedModulesGeneratedErr: Label 'All the selected modules have already been generated.';

    internal procedure CreateDemoData(var ContosoDemoDataModule: Record "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        ContosoModuleDependency: Codeunit "Contoso Module Dependency";
        DemoDataModulesList, SortedModulesList : List of [Enum "Contoso Demo Data Module"];
    begin
        if ContosoDemoDataModule.FindSet() then
            repeat
                if not IsModuleGenerated(ContosoDemoDataModule, ContosoDemoDataLevel) then
                    DemoDataModulesList.Add(ContosoDemoDataModule.Module);
            until ContosoDemoDataModule.Next() = 0;

        if DemoDataModulesList.Count() = 0 then
            Error(SelectedModulesGeneratedErr);

        // Find dependencies and sort modules based on it
        ContosoModuleDependency.BuildSortedDependencyList(SortedModulesList, DemoDataModulesList);

        // Run each demo layer for each module
        GenerateDemoData(SortedModulesList, Enum::"Contoso Demo Data Level"::"Setup Data");

        if ContosoDemoDataLevel = Enum::"Contoso Demo Data Level"::All then begin
            GenerateDemoData(SortedModulesList, Enum::"Contoso Demo Data Level"::"Master Data");
            GenerateDemoData(SortedModulesList, Enum::"Contoso Demo Data Level"::"Transactional Data");
            GenerateDemoData(SortedModulesList, Enum::"Contoso Demo Data Level"::"Historical Data");
        end;
    end;

    local procedure GenerateDemoData(SortedModulesList: List of [enum "Contoso Demo Data Module"]; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        ContosoDemoDataModule: Record "Contoso Demo Data Module";
        Module: Enum "Contoso Demo Data Module";
        ModuleProvider: Interface "Contoso Demo Data Module";
    begin
        foreach Module in SortedModulesList do begin

            ModuleProvider := Module;
            ContosoDemoDataModule.Get(Module);

            if not IsModuleGenerated(ContosoDemoDataModule, ContosoDemoDataLevel) then begin

                OnBeforeGeneratingDemoData(Module, ContosoDemoDataLevel);

                case ContosoDemoDataLevel of
                    Enum::"Contoso Demo Data Level"::"Setup Data":
                        begin
                            ModuleProvider.CreateSetupData();
                            ContosoDemoDataModule.Validate("Data Level", ContosoDemoDataLevel);
                            ContosoDemoDataModule.Modify(true);
                        end;
                    Enum::"Contoso Demo Data Level"::"Master Data":
                        ModuleProvider.CreateMasterData();
                    Enum::"Contoso Demo Data Level"::"Transactional Data":
                        ModuleProvider.CreateTransactionalData();
                    Enum::"Contoso Demo Data Level"::"Historical Data":
                        begin
                            ModuleProvider.CreateHistoricalData();
                            ContosoDemoDataModule.Validate("Data Level", Enum::"Contoso Demo Data Level"::All);
                            ContosoDemoDataModule.Modify(true);
                        end;
                end;

                OnAfterGeneratingDemoData(Module, ContosoDemoDataLevel);
            end;

        end;
    end;

    local procedure IsModuleGenerated(ContosoDemoDataModule: Record "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level"): Boolean
    begin
        exit((ContosoDemoDataModule."Data Level".AsInteger() >= ContosoDemoDataLevel.AsInteger()) or (ContosoDemoDataModule."Data Level" = Enum::"Contoso Demo Data Level"::All));
    end;

    internal procedure RefreshModules()
    var
        ContosoDemoDataModuleRec: Record "Contoso Demo Data Module";
        ContosoModuleDependency: codeunit "Contoso Module Dependency";
        ModuleProvider: Interface "Contoso Demo Data Module";
        Dependency, Module : Enum "Contoso Demo Data Module";
    begin
        foreach Module in Enum::"Contoso Demo Data Module".Ordinals() do begin
            ModuleProvider := Module;

            if not ContosoDemoDataModuleRec.Get(Module) then begin
                ContosoDemoDataModuleRec.Init();
                ContosoDemoDataModuleRec.Validate(Name, Format(Module));
                ContosoDemoDataModuleRec.Validate(Module, Module);
                ContosoDemoDataModuleRec.Insert(true);
            end;

            foreach Dependency in ModuleProvider.GetDependencies() do
                ContosoModuleDependency.AddDependency(Module, Dependency);
        end;
    end;

    procedure CreateAllDemoData()
    var
        ContosoDemoDataModule: Record "Contoso Demo Data Module";
    begin
        RefreshModules();

        if ContosoDemoDataModule.FindSet() then
            CreateDemoData(ContosoDemoDataModule, Enum::"Contoso Demo Data Level"::All);
    end;

    procedure CreateSetupDemoData()
    var
        ContosoDemoDataModule: Record "Contoso Demo Data Module";
    begin
        RefreshModules();

        if ContosoDemoDataModule.FindSet() then
            CreateDemoData(ContosoDemoDataModule, Enum::"Contoso Demo Data Level"::"Setup Data");
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGeneratingDemoData(Module: Enum "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    begin
    end;
}