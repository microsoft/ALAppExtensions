codeunit 5193 "Contoso Demo Tool"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Contoso Demo Data Module" = rim;

    var
        SelectedModulesGeneratedErr: Label 'All the selected modules have already been generated.';
        LanguageConfirmationMsg: Label 'The demo data will be created with %1, which is different than the language used before (%2). Do you want to continue? \\ The differences in the language could cause issues with the demo data.', Comment = '%1 = Language Name, %2 = Language Name';

    internal procedure CreateDemoData(var ContosoDemoDataModule: Record "Contoso Demo Data Module"; ContosoDemoDataLevel: Enum "Contoso Demo Data Level")
    var
        ContosoModuleDependency: Codeunit "Contoso Module Dependency";
        DemoDataModulesList, SortedModulesList : List of [Enum "Contoso Demo Data Module"];
    begin
        if not CheckLanguageBeforeGeneratingDemoData() then
            exit;

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

        UpdateLanguageAfterGeneratingDemoDataForTheFirstRun();
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
        ContosoDemoDataModule: Record "Contoso Demo Data Module";
        ContosoModuleDependency: codeunit "Contoso Module Dependency";
        ModuleProvider: Interface "Contoso Demo Data Module";
        Dependency, Module : Enum "Contoso Demo Data Module";
    begin
        foreach Module in Enum::"Contoso Demo Data Module".Ordinals() do begin
            ModuleProvider := Module;

            if not ContosoDemoDataModule.Get(Module) then begin
                ContosoDemoDataModule.Init();
                ContosoDemoDataModule.Validate(Name, Format(Module));
                ContosoDemoDataModule.Validate(Module, Module);
                ContosoDemoDataModule.Insert(true);
            end;

            foreach Dependency in ModuleProvider.GetDependencies() do
                ContosoModuleDependency.AddDependency(Module, Dependency);
        end;
    end;

    local procedure CheckLanguageBeforeGeneratingDemoData(): Boolean
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
        Language: Codeunit "Language";
    begin
        ContosoCoffeeDemoDataSetup.InitRecord();
        ContosoCoffeeDemoDataSetup.Get();

        // If the language is not set, then it is the first run
        if ContosoCoffeeDemoDataSetup."Language ID" = 0 then
            exit(true);

        if ContosoCoffeeDemoDataSetup."Language ID" <> GlobalLanguage() then
            exit(Dialog.Confirm(LanguageConfirmationMsg, false, Language.GetWindowsLanguageName(GlobalLanguage()), Language.GetWindowsLanguageName(ContosoCoffeeDemoDataSetup."Language ID")));

        exit(true);
    end;

    local procedure UpdateLanguageAfterGeneratingDemoDataForTheFirstRun()
    var
        ContosoCoffeeDemoDataSetup: Record "Contoso Coffee Demo Data Setup";
    begin
        ContosoCoffeeDemoDataSetup.Get();

        if ContosoCoffeeDemoDataSetup."Language ID" = 0 then begin
            ContosoCoffeeDemoDataSetup.Validate("Language ID", GlobalLanguage());
            ContosoCoffeeDemoDataSetup.Modify(true);
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