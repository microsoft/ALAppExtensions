// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139541 "Sales Frcst. Mock Service"
{
    // version Test,W1,All

    // TODO fix when we have mocks in extension V2 Subtype = Test;
    // TestPermissions = Disabled;

    // var
    //     MSSalesForecastSetup: Record "MS - Sales Forecast Setup";
    //     Assert: Codeunit Assert;
    //     LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
    //     MSSalesForecastHandler: Codeunit "Sales Forecast Handler";
    //     MockServiceKeyTxt: Label 'TestKey', Locked=true;
    //     SalesForecastLib: Codeunit "Sales Forecast Lib";
    // HttpMessageHandler: DotNet "'MockTest, Version=11.0.0.0, Culture=neutral, PublicKeyToken=null'.MockTest.MockHttpResponse.MockHttpMessageHandler";

    // [Test]
    // procedure TestPredictStandardForecast();
    // var
    //     Item: Record Item;
    //     MSSalesForecast: Record "MS - Sales Forecast";
    // begin
    //     // [Scenario] Normal prediction of item with history
    //     Initialize();
    //     LibraryLowerPermissions.SetOutsideO365Scope();

    //     // [Given] Sales history for an Item with 10 historic points
    //     // [Given] The Api Uri key has been set and the horizon is 12 periods
    //     // [When] Item sales is being forecast for the given item
    //     CreateItemForecastHistory(Item);
    //     LibraryLowerPermissions.SetO365Basic();

    //     // [Then] There are 10 Base Item Sales forecast entries
    //     MSSalesForecast.SetRange("Forecast Data", MSSalesForecast."Forecast Data"::Base);
    //     Assert.AreEqual(10, MSSalesForecast.Count(), '');

    //     // [Then] There are 12 Result Item Sales forecast entries
    //     MSSalesForecast.SetRange("Forecast Data", MSSalesForecast."Forecast Data"::Result);
    //     Assert.AreEqual(12, MSSalesForecast.Count(), '');
    // end;

    // [Test]
    // procedure TestDeletionOfItemAndForecast();
    // var
    //     Item: Record Item;
    //     MSSalesForecast: Record "MS - Sales Forecast";
    //     MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
    // begin
    //     // [Scenario] When a item is deleted, its forecast data is deleted as well
    //     Initialize();
    //     LibraryLowerPermissions.SetOutsideO365Scope();

    //     // [Given] An item with forecast data
    //     CreateItemForecastHistory(Item);
    //     LibraryLowerPermissions.SetO365Basic();
    //     MSSalesForecast.SetRange("Item No.", Item."No.");
    //     MSSalesForecastParameter.SetRange("Item No.", Item."No.");
    //     Assert.RecordIsNotEmpty(MSSalesForecast);
    //     Assert.RecordIsNotEmpty(MSSalesForecastParameter);

    //     // [When] The item is deleted
    //     LibraryLowerPermissions.SetOutsideO365Scope();
    //     Item.Delete();

    //     // [Then] The item's forecast data is deleted as well
    //     Assert.RecordIsEmpty(MSSalesForecast);
    //     Assert.RecordIsEmpty(MSSalesForecastParameter);
    // end;

    // [Test]
    // procedure TestDeletionOfTemporaryItemAndForecastRemains();
    // var
    //     Item: Record Item;
    //     TempItem: Record Item temporary;
    //     MSSalesForecast: Record "MS - Sales Forecast";
    //     MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
    // begin
    //     // [Scenario] When a item is deleted, its forecast data is deleted as well
    //     Initialize();
    //     LibraryLowerPermissions.SetOutsideO365Scope();

    //     // [Given] An item with forecast data
    //     CreateItemForecastHistory(Item);
    //     LibraryLowerPermissions.SetO365Basic();
    //     MSSalesForecast.SetRange("Item No.", Item."No.");
    //     MSSalesForecastParameter.SetRange("Item No.", Item."No.");
    //     Assert.RecordIsNotEmpty(MSSalesForecast);
    //     Assert.RecordIsNotEmpty(MSSalesForecastParameter);

    //     // [Given] Temporary item "T" copied from "X"
    //     LibraryLowerPermissions.SetOutsideO365Scope();
    //     CopyItemToTemp(Item, TempItem);

    //     // [When] Delete "T"
    //     TempItem.Delete();

    //     // [Then] The item's forecast data remains
    //     Assert.RecordIsNotEmpty(MSSalesForecast);
    //     Assert.RecordIsNotEmpty(MSSalesForecastParameter);
    // end;

    // [Test]
    // procedure TestItemSalesForecastUpdatesProcessingTime();
    // var
    //     CortanaIntelligenceUsage: Record "Cortana Intelligence Usage";
    //     Item: Record Item;
    //     PermissionManager: Codeunit "Permission Manager";
    //     TimeSeriesManagement: Codeunit "Time Series Management";
    // begin
    //     // [Scenario]Sales Item Forecast updates AzureML Total Processing Time
    //     Initialize();
    //     LibraryLowerPermissions.SetOutsideO365Scope();

    //     // [Given] Sales Item Forecast is set use Azure ML
    //     CortanaIntelligenceUsage.DeleteAll();
    //     PermissionManager.SetTestabilitySoftwareAsAService(true);
    //     SalesForecastLib.CreateTestData(Item, 10);

    //     // [Given] Api URI and Api Key are refreshed from Azure Key Vault
    //     RefreshURIAndKey;

    //     // [When]When Sales Item Forecast  is called
    //     LibraryLowerPermissions.SetO365Basic();
    //     TimeSeriesManagement.SetMessageHandler(HttpMessageHandler.MockHttpMessageHandler(GetInetroot + GetResponseFileName));
    //     Assert.IsTrue(MSSalesForecastHandler.CalculateForecast(Item, TimeSeriesManagement), 'Forecast failed');

    //     // [Then]Total Processing Time is increased
    //     CortanaIntelligenceUsage.GetSingleInstance(CortanaIntelligenceUsage.Service::"Machine Learning");
    //     Assert.IsTrue(CortanaIntelligenceUsage.GetTotalProcessingTime(CortanaIntelligenceUsage.Service::"Machine Learning") > 0,
    //       'Azure ML Total Processing time is not increased after Item Sales Forecast used.');

    //     PermissionManager.SetTestabilitySoftwareAsAService(false);
    // end;

    // local procedure Initialize();
    // var
    //     MSSalesForecast: Record "MS - Sales Forecast";
    //     MSSalesForecastParameter: Record "MS - Sales Forecast Parameter";
    //     JobQueueEntry: Record "Job Queue Entry";
    //     PermissionManager: Codeunit "Permission Manager";
    // begin
    //     PermissionManager.SetTestabilitySoftwareAsAService(false);
    //     MSSalesForecastSetup.DeleteAll();
    //     MSSalesForecast.DeleteAll();
    //     MSSalesForecastParameter.DeleteAll();

    //     JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
    //     JobQueueEntry.SetRange("Object ID to Run", Codeunit::"Sales Forecast Update");
    //     JobQueueEntry.DeleteAll();
    // end;

    // local procedure Setup();
    // var
    //     AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
    // begin
    //     MSSalesForecastSetup.GetSingleInstance(AzureKeyVaultManagement);
    //     MSSalesForecastSetup.Validate("API URI",
    //       COPYSTR(SalesForecastLib.GetMockServiceURItxt, 1, MAXSTRLEN(MSSalesForecastSetup."API URI")));
    //     MSSalesForecastSetup.SetUserDefinedAPIKey(MockServiceKeyTxt);
    //     MSSalesForecastSetup.Modify(true);
    // end;

    // local procedure RefreshURIAndKey();
    // var
    //     AzureKeyVaultManagement: Codeunit "Azure Key Vault Management";
    //     AzureKeyVaultSecretProvider: DotNet "'MockTest, Version=11.0.0.0, Culture=neutral, PublicKeyToken=null'.MockTest.MockAzureKeyVaultSecret.MockAzureKeyVaultSecretProvider";
    // begin
    //     AzureKeyVaultManagement.SetAzureKeyVaultSecretProvider(
    //       AzureKeyVaultSecretProvider.MockAzureKeyVaultSecretProvider(GetInetroot + GetSecretFileName));
    //     MSSalesForecastSetup.GetSingleInstance(AzureKeyVaultManagement);
    // end;

    // local procedure GetInetroot(): Text[170];
    // begin
    //     exit(ApplicationPath + '\..\..\..\..\..\');
    // end;

    // local procedure GetResponseFileName(): Text[80];
    // begin
    //     exit('\App\Test\Files\AzureMLResponse\Time_Series_Forecast.txt');
    // end;

    // local procedure GetSecretFileName(): Text[80];
    // begin
    //     exit('\App\Test\Files\AzureKeyVaultSecret\TimeSeriesForecastSecret.txt');
    // end;

    // local procedure CreateItemForecastHistory(var Item: Record Item);
    // var
    //     TimeSeriesManagement: Codeunit "Time Series Management";
    // begin
    //     // Create Sales history for an Item with 10 historic points
    //     SalesForecastLib.CreateTestData(Item, 10);

    //     // The Api Uri key has been set and the horizon is 12 periods
    //     Setup;

    //     // Item sales is being forecast for the given item
    //     TimeSeriesManagement.SetMessageHandler(HttpMessageHandler.MockHttpMessageHandler(GetInetroot + GetResponseFileName));
    //     Assert.IsTrue(MSSalesForecastHandler.CalculateForecast(Item, TimeSeriesManagement), 'Forecast failed');
    // end;

    // local procedure CopyItemToTemp(Item: Record Item; var TempItem: Record Item temporary);
    // begin
    //     TempItem := Item;
    //     TempItem.Insert();
    // end;
}

