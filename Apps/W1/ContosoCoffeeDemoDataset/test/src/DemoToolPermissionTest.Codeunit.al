codeunit 148135 "Demo Tool Permission Test"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure DemeToolPageApplicationAreaEssential()
    var
        LibraryApplicationArea: Codeunit "Library - Application Area";
        ContosoDemoToolPage: TestPage "Contoso Demo Tool";
        EssentialLicenseExpectedFilterLbl: Label '<>%1&<>%2', Locked = true;
    begin
        // [SCENARIO] Application Area is used to filter out modules that are not enabled for the license (specifically, Service and Manufacturing are only for Premium)
        // [GIVEN] The Application Area is set to Essential
        LibraryApplicationArea.EnableEssentialSetup();

        // [THEN] Open the Contoso Demo Tool page, we filter out modules basing on the Application Area during OnOpenPage trigger
        ContosoDemoToolPage.OpenView();

        // [THEN] The filter should be set to filter out Service and Manufacturing modules
        Assert.AreEqual(
            StrSubstNo(EssentialLicenseExpectedFilterLbl, Enum::"Contoso Demo Data Module"::"Service Module".AsInteger(), Enum::"Contoso Demo Data Module"::"Manufacturing Module".AsInteger()),
            ContosoDemoToolPage.Filter.GetFilter(Module), 'The filter is not set correctly for Essential license');
    end;

    [Test]
    procedure DemeToolPageApplicationAreaPremium()
    var
        LibraryApplicationArea: Codeunit "Library - Application Area";
        ContosoDemoToolPage: TestPage "Contoso Demo Tool";
    begin
        // [SCENARIO] Premium license should have access to all modules
        // [GIVEN] The Application Area is set to Premium
        LibraryApplicationArea.EnablePremiumSetup();

        // [THEN] Open the Contoso Demo Tool page, we filter out modules basing on the Application Area during OnOpenPage trigger
        ContosoDemoToolPage.OpenView();

        // [THEN] The filter should be set to filter out Service and Manufacturing modules
        Assert.AreEqual('', ContosoDemoToolPage.Filter.GetFilter(Module), 'The filter should be empty for Premium license');
    end;
}