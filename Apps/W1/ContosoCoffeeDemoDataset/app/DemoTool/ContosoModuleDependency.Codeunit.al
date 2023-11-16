codeunit 5138 "Contoso Module Dependency"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;
    Permissions = tabledata "Contoso Module Dependency" = rim;

    var
        CircularDependencyErr: Label 'The demo data module cannot be added. Adding this demo data module %1 would cause a circular dependency with %2', Comment = '%1 = Module Name, %2 = Dependency Name';

    procedure AddDependency(Name: Enum "Contoso Demo Data Module"; DependsOn: Enum "Contoso Demo Data Module")
    var
        DemoDataFeatureDependency: Record "Contoso Module Dependency";
    begin
        if Name = DependsOn then
            exit;

        if DemoDataFeatureDependency.Get(Name, DependsOn) then
            exit;

        if IsCircularDependency(Name, DependsOn) then
            Error(CircularDependencyErr, Name, DependsOn);

        DemoDataFeatureDependency.Validate(Name, Name);
        DemoDataFeatureDependency.Validate(DependsOn, DependsOn);
        DemoDataFeatureDependency.Insert(true);
    end;

    local procedure IsCircularDependency(Name: Enum "Contoso Demo Data Module"; DependsOn: Enum "Contoso Demo Data Module"): Boolean
    var
        DemoDataFeatureDependency: Record "Contoso Module Dependency";
    begin
        DemoDataFeatureDependency.SetRange(Name, DependsOn);

        if DemoDataFeatureDependency.FindSet() then
            repeat
                if DemoDataFeatureDependency.DependsOn = Name then
                    exit(true);
                exit(IsCircularDependency(Name, DemoDataFeatureDependency.DependsOn));

            until DemoDataFeatureDependency.Next() = 0;
        exit(false);
    end;

    procedure BuildSortedDependencyList(var SortedModulesList: List of [Enum "Contoso Demo Data Module"]; ModulesList: List of [Enum "Contoso Demo Data Module"])
    var
        DemoDataModuleDependency: Record "Contoso Module Dependency";
        Module: Enum "Contoso Demo Data Module";
        NewModulesList: List of [Enum "Contoso Demo Data Module"];
    begin
        foreach Module in ModulesList do begin
            Clear(NewModulesList);
            if not SortedModulesList.Contains(Module) then
                SortedModulesList.Add(Module);

            DemoDataModuleDependency.SetRange(Name, Module);
            if DemoDataModuleDependency.FindSet() then begin
                repeat
                    NewModulesList.Add(DemoDataModuleDependency.DependsOn);
                    if not SortedModulesList.Contains(DemoDataModuleDependency.DependsOn) then
                        SortedModulesList.Insert(SortedModulesList.IndexOf(Module), DemoDataModuleDependency.DependsOn);
                until DemoDataModuleDependency.Next() = 0;

                BuildSortedDependencyList(SortedModulesList, NewModulesList);
            end
        end;
    end;
}