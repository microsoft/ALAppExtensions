codeunit 139527 "Recommended Apps Tests"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestInsertAppWhenURLAppInfoAreWrong()
    var
        RecommendedAppsTable: Record "Recommended Apps";
        RecommendedApps: Codeunit "Recommended Apps";
        AppRecommandedBy: Enum "App Recommended By";
        AppId: Guid;
        Err1Msg: Label 'Cannot add the recommended app with ID %1. The URL https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.thetasystemslimitedWRONG|AID.bc_excel_importer|PAPPID.24466323-aee9-4049-a66d-a1af24466323?tab=Overview cannot be reached, and the HTTP status code is 404. Are you sure that the information about the app is correct?', Comment = '%1 = App ID';
#pragma warning disable AA0470
        Err2Msg: Label 'Cannot add the recommended app with ID %1. The URL https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/pu.thetasystemslimitedWRONG%7CAID.bc_excel_importer%7CPAPPID.24466323-aee9-4049-a66d-a1af24466323?tab=Overview is not formatted correctly. Are you sure that the information about the app is correct?', Comment = '%1 = App ID';
#pragma warning restore AA0470
    begin
        // [SCENARIO] 
        // Scenario 1 - Test the InsertApp method to insert a new recommended app when the app info are wrong (app not found in the store) so the BC App Source URL returns 404 not found
        // [WHEN] There are no recommended apps
        RecommendedAppsTable.DeleteAll();

        // [WHEN] A new recommended app is inserted with wrong infpo
        AppId := CreateGuid();

        asserterror RecommendedApps.InsertApp(
            AppId,
            1,
            'Excel Importer',
            'Theta Systems Limited',
            'Import journals and documents from Excel worksheets without reformatting the columns',
            'For many companies, the source for financial transactions are available as a file. These could be payroll extracts, credit card statements, expense reports or billing schedules from vendors for services. Often the cost of integrating these systems does not justify the benefits. So, why not upload the data via an Excel file import?\Under such scenarios, one can often end up working with different file layouts. To improve efficiency and decrease the risk of error, it’s best to import the file without having to convert it to a fixed layout.',
            AppRecommandedBy::"Your Microsoft Reseller",
            'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.thetasystemslimitedWRONG%7CAID.bc_excel_importer%7CPAPPID.24466323-aee9-4049-a66d-a1af24466323?tab=Overview' // word WRONG add in URL
        );

        // [THEN] an error saying that the app could not be found in the App Source should be thrown
        Assert.ExpectedError(StrSubstNo(Err1Msg, AppId));


        // Scenario 2 - Test the InsertApp method to insert a new recommended app when the app info are wrong (missing app keywords in URL)
        // [WHEN] There are no recommended apps
        RecommendedAppsTable.DeleteAll();

        // [WHEN] A new recommended app is inserted with wrong infpo
        AppId := CreateGuid();

        asserterror RecommendedApps.InsertApp(
            AppId,
            1,
            'Excel Importer',
            'Theta Systems Limited',
            'Import journals and documents from Excel worksheets without reformatting the columns',
            'For many companies, the source for financial transactions are available as a file. These could be payroll extracts, credit card statements, expense reports or billing schedules from vendors for services. Often the cost of integrating these systems does not justify the benefits. So, why not upload the data via an Excel file import?\Under such scenarios, one can often end up working with different file layouts. To improve efficiency and decrease the risk of error, it’s best to import the file without having to convert it to a fixed layout.',
            AppRecommandedBy::"Your Microsoft Reseller",
            'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/pu.thetasystemslimitedWRONG%7CAID.bc_excel_importer%7CPAPPID.24466323-aee9-4049-a66d-a1af24466323?tab=Overview' // word WRONG add in URL
        );

        // [THEN] an error saying that the app could not be found in the App Source should be thrown
#pragma warning disable AA0131
        Assert.ExpectedError(StrSubstNo(Err2Msg, AppId));
#pragma warning disable AA0131
    end;

    [Test]
    procedure TestGetApp()
    var
        RecommendedAppsTable: Record "Recommended Apps";
        RecommendedApps: Codeunit "Recommended Apps";
        AppRecommandedBy: Enum "App Recommended By";
        AppId: Guid;
        SortingId: Integer;
        Name: Text[250];
        Publisher: Text[250];
        ShortDescription: Text[250];
        LongDescription: Text[2048];
        RecommendedBy: Enum "App Recommended By";
        AppSourceURL: Text;
    begin
        // [SCENARIO] Test the GetApp method to retrieve a previously inserted app
        // [WHEN] There are no recommended apps
        RecommendedAppsTable.DeleteAll();

        // [WHEN] A new recommended app is inserted
        AppId := InsertSingleApp();

        // [THEN] When getting the app the values that are returned are the same that were inserted
        Assert.AreEqual(
            true,
            RecommendedApps.GetApp(AppId, SortingId, Name, Publisher, ShortDescription, LongDescription, RecommendedBy, AppSourceURL),
            'when an app is retrieved the procedure should return true'
        );

        Assert.AreEqual(1, SortingId, 'SortingId should be equal to 1.');
        Assert.AreEqual('Excel Importer', Name, 'Name should be equal to ''Excel Importer''.');
        Assert.AreEqual('Theta Systems Limited', Publisher, 'Publisher should be equal to ''Theta Systems Limited''.');
        Assert.AreEqual('Import journals and documents from Excel worksheets without reformatting the columns', ShortDescription, 'The Short Description is wrong.');
        Assert.AreEqual(
            'For many companies, the source for financial transactions are available as a file. These could be payroll extracts, credit card statements, expense reports or billing schedules from vendors for services. Often the cost of integrating these systems does not justify the benefits. So, why not upload the data via an Excel file import?\Under such scenarios, one can often end up working with different file layouts. To improve efficiency and decrease the risk of error, it’s best to import the file without having to convert it to a fixed layout.',
            LongDescription,
            'The Long Description is wrong.'
        );
        Assert.AreEqual(AppRecommandedBy::"Your Microsoft Reseller", RecommendedBy, 'Recommended By should be equal to ''Your Microsoft Reseller''.');
        Assert.AreEqual('https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.thetasystemslimited|AID.bc_excel_importer|PAPPID.24466323-aee9-4049-a66d-a1af24466323?tab=Overview', AppSourceURL,
            'LanguageCode should be equal to ''https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.thetasystemslimited|AID.bc_excel_importer|PAPPID.24466323-aee9-4049-a66d-a1af24466323?tab=Overview''.');
    end;

    [Test]
    procedure TestRefreshImage()
    var
        RecommendedAppsTable: Record "Recommended Apps";
        RecommendedApps: Codeunit "Recommended Apps";
        AppId: Guid;
        FirstImageId: Guid;
        SecondImageId: Guid;
    begin
        // [SCENARIO] Test the RefreshImage method to re-download an app logo
        // [WHEN] There are no recommended apps
        RecommendedAppsTable.DeleteAll();
        // [WHEN] A new recommended app is inserted
        AppId := InsertSingleApp();

        // getting the Id of the original logo
        RecommendedAppsTable.Get(AppId);
        FirstImageId := RecommendedAppsTable.Logo.MediaId();

        // [WHEN] The app logo is refreshed
        Assert.AreEqual(
            true,
            RecommendedApps.RefreshImage(AppId),
            'when an app''s logo is refreshed the procedure should return true'
        );

        // getting the Id of the re-downloaded logo
        RecommendedAppsTable.Get(AppId);
        SecondImageId := RecommendedAppsTable.Logo.MediaId();

        // [THEN] The Id of the re-downloaded logo should be diffrent from the Id of the original logo. That means that a new image has been downloaded
        Assert.AreNotEqual(FirstImageId, SecondImageId, 'The logo Id of should be different because the image should have been re-downloaded.');
    end;

    [Test]
    procedure TestDeleteApp()
    var
        RecommendedAppsTable: Record "Recommended Apps";
        RecommendedApps: Codeunit "Recommended Apps";
        AppId: Guid;
    begin
        // [SCENARIO] Test the DeleteApp method to delete a specific recommended app
        // [WHEN] There are no recommended apps
        RecommendedAppsTable.DeleteAll();
        // [WHEN] A new recommended app is inserted
        AppId := InsertSingleApp();

        // [WHEN] Deleting a specific app
        Assert.AreEqual(
            true,
              RecommendedApps.DeleteApp(AppId),
            'when an app is deleted the procedure should return true'
        );


        // [THEN] The app should be deleted
        Assert.AreEqual(false, RecommendedAppsTable.Get(AppId), 'The record should not be fund.');
    end;

    [Test]
    procedure TestGetAppURL()
    var
        RecommendedAppsTable: Record "Recommended Apps";
        RecommendedApps: Codeunit "Recommended Apps";
        AppId: Guid;
        URL: Text;
    begin
        // [SCENARIO] Test the GetAppURL method to get the app link that points to the app source
        // [WHEN] There are no recommended apps
        RecommendedAppsTable.DeleteAll();
        // [WHEN] A new recommended app is inserted
        AppId := InsertSingleApp();

        // [WHEN] The app URL is retrieved
        URL := RecommendedApps.GetAppURL(AppId);

        // [THEN] The URL should be the same as the decoded URL of the BC App Source
        Assert.AreEqual(
            URL,
            // URL is decoded
            'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.thetasystemslimited|AID.bc_excel_importer|PAPPID.24466323-aee9-4049-a66d-a1af24466323?tab=Overview',
            'The AppSource URL is wrong.'
        );
    end;

    [Test]
    procedure TestGetAppURLWrongAppId()
    var
        RecommendedAppsTable: Record "Recommended Apps";
        RecommendedApps: Codeunit "Recommended Apps";
    begin
        // [SCENARIO] Test the GetAppURL method when the app is not found, an error message should be returned
        // [WHEN] There are no recommended apps
        RecommendedAppsTable.DeleteAll();
        // [WHEN] A new recommended app is inserted
        InsertSingleApp();

        // [WHEN] The app URL is retrieved with a wrong app Id
        asserterror RecommendedApps.GetAppURL(CreateGuid());

        // [THEN] Am error is thrown
        Assert.ExpectedError('Cannot get the AppSource URL.');
    end;

    local procedure InsertSingleApp(): Guid
    var
        RecommendedApps: Codeunit "Recommended Apps";
        AppRecommandedBy: Enum "App Recommended By";
        AppId: Guid;
    begin
        AppId := CreateGuid();

        Assert.AreEqual(
            true,
            RecommendedApps.InsertApp(
                AppId,
                1,
                'Excel Importer',
                'Theta Systems Limited',
                'Import journals and documents from Excel worksheets without reformatting the columns',
                'For many companies, the source for financial transactions are available as a file. These could be payroll extracts, credit card statements, expense reports or billing schedules from vendors for services. Often the cost of integrating these systems does not justify the benefits. So, why not upload the data via an Excel file import?\Under such scenarios, one can often end up working with different file layouts. To improve efficiency and decrease the risk of error, it’s best to import the file without having to convert it to a fixed layout.',
                AppRecommandedBy::"Your Microsoft Reseller",
                'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.thetasystemslimited%7CAID.bc_excel_importer%7CPAPPID.24466323-aee9-4049-a66d-a1af24466323?tab=Overview'
            ),
            'When an app is inserted the procedure should return true'
        );

        exit(AppId);
    end;
}
