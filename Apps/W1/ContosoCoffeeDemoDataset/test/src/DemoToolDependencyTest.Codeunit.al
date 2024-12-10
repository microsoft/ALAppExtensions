codeunit 148048 "DemoTool Dependency Test"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        CircularDependencyErr: Label 'The demo data module cannot be added. Adding this demo data module %1 would cause a circular dependency with %2', Comment = '%1 = Module Name, %2 = Dependency Name';

    [Test]
    procedure TestDependenciesAreCorrectlyGenerated()
    var
        ContosoDemoDataModule: Record "Contoso Demo Data Module";
        ContosoModuleDependency: Codeunit "Contoso Module Dependency";
        ContosoDemoTool: Codeunit "Contoso Demo Tool";
        DemoDataModulesList, SortedModulesList : List of [Enum "Contoso Demo Data Module"];
    begin
        // [SCENARIO] There are 3 modules in the list, testing the dependency order.
        ContosoDemoTool.RefreshModules(ContosoDemoDataModule);

        // [GIVEN] The "Contoso Test 1" module is taken dependencies on by the other 2 modules.
        DemoDataModulesList.Add(Enum::"Contoso Demo Data Module"::"Contoso Test 3");
        DemoDataModulesList.Add(Enum::"Contoso Demo Data Module"::"Contoso Test 2");
        DemoDataModulesList.Add(Enum::"Contoso Demo Data Module"::"Contoso Test 1");

        // [WHEN] The dependencies list is generated.
        ContosoModuleDependency.BuildSortedDependencyList(SortedModulesList, DemoDataModulesList);

        // [THEN] The list should contain 3 modules.
        Assert.AreEqual(3, SortedModulesList.Count(), 'There should only be 3 modules in the list');

        // [THEN] The "Contoso Test 1" module should be first in the list.
        Assert.AreEqual(1, SortedModulesList.IndexOf(Enum::"Contoso Demo Data Module"::"Contoso Test 1"), 'The module that is taken dependencies on should be first');
    end;

    [Test]
    procedure TestCircularDependency()
    var
        ContosoDemoDataModule: Record "Contoso Demo Data Module";
        ContosoModuleDependency: Codeunit "Contoso Module Dependency";
        ContosoDemoTool: Codeunit "Contoso Demo Tool";
    begin
        // [SCENARIO] There are 3 modules in the list (dependency is defined in the implementations), testing the circular dependency.
        ContosoDemoTool.RefreshModules(ContosoDemoDataModule);

        // [GIVEN] Faking a circular dependency
        asserterror ContosoModuleDependency.AddDependency(Enum::"Contoso Demo Data Module"::"Contoso Test 1", Enum::"Contoso Demo Data Module"::"Contoso Test 2");

        // [THEN] Expect a circular dependency error
        Assert.ExpectedError(StrSubstNo(CircularDependencyErr, Enum::"Contoso Demo Data Module"::"Contoso Test 1", Enum::"Contoso Demo Data Module"::"Contoso Test 2"));
    end;
}