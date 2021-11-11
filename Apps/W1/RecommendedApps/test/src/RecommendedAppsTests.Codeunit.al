codeunit 139527 "Recommended Apps Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure TestInsertApp()
    var
        RecommendedApps: Record "Recommended Apps";
    begin
        // [SCENARIO] Test the InsertApp method to insert a new recommended app
        // [WHEN] There are no recommended apps
        RecommendedApps.DeleteAll();

        // [WHEN] 3 new recommended apps are inserted
        InsertMultipleApps();

        // [THEN] the total count of recommended apps in the table is 3
        Assert.AreEqual(10, RecommendedApps.Count(), 'There should be 10 recommended apps.');
    end;

    [Test]
    procedure TestInsertAppWhenURLAppInfoAreWrong()
    var
        RecommendedAppsTable: Record "Recommended Apps";
        RecommendedApps: Codeunit "Recommended Apps";
        AppRecommandedBy: Enum "App Recommended By";
        AppId: Guid;
        Err1Msg: Label 'Cannot add the recommended app with ID %1. The URL https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.thetasystemslimitedWRONG|AID.bc_excel_importer|PAPPID.24466323-aee9-4049-a66d-a1af24466323?tab=Overview cannot be reached, and the HTTP status code is 404. Are you sure that the information about the app is correct?';
        Err2Msg: Label 'Cannot add the recommended app with ID %1. The URL https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/pu.thetasystemslimitedWRONG%7CAID.bc_excel_importer%7CPAPPID.24466323-aee9-4049-a66d-a1af24466323?tab=Overview is not formatted correctly. Are you sure that the information about the app is correct?';
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
        Assert.ExpectedError(StrSubstNo(Err2Msg, AppId));
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
    procedure TestUpdateApp()
    var
        RecommendedAppsTable: Record "Recommended Apps";
        RecommendedApps: Codeunit "Recommended Apps";
        AppRecommandedBy: Enum "App Recommended By";
        AppId: Guid;
    begin
        // [SCENARIO] Test the UpdateApp method to update values of a specific app
        // [WHEN] There are no recommended apps
        RecommendedAppsTable.DeleteAll();

        // [WHEN] A new recommended app is inserted
        AppId := InsertSingleApp();
        // [WHEN] The new inserted app is updated
        Assert.AreEqual(
            true,
            RecommendedApps.UpdateApp(
                AppId,
                2,
                'Jet Reports',
                'Jet Global Data Technologies',
                'Short description test 2',
                'Long description test',
                AppRecommandedBy::"Your Microsoft Reseller",
                'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.jetreports%7CAID.jetreports%7CPAPPID.bec4ca36-c7fb-4110-9db5-29559cc1f84c?tab=Overview'
            ),
            'when an app is updated the procedure should return true'
        );

        // [THEN] The new values are successfully updated
        RecommendedAppsTable.Get(AppId);
        Assert.AreEqual(2, RecommendedAppsTable.SortingId, 'SortingId should be equal to 2.');
        Assert.AreEqual('Jet Reports', RecommendedAppsTable.Name, 'Name should be equal to ''Jet Reports''.');
        Assert.AreEqual('Jet Global Data Technologies', RecommendedAppsTable.Publisher, 'Publisher should be equal to ''Jet Global Data Technologies''.');
        Assert.AreEqual('Short description test 2', RecommendedAppsTable."Short Description", '''Short Description'' should be equal to ''Short description test''.');
        Assert.AreEqual('Long description test', RecommendedAppsTable."Long Description", 'Long Description should be equal to ''Long description test''.');
        Assert.AreEqual(AppRecommandedBy::"Your Microsoft Reseller", RecommendedAppsTable."Recommended By", 'Recommended By should be equal to ''Your Microsoft Reseller''.');
        Assert.AreEqual('en-us', RecommendedAppsTable."Language Code", 'LanguageCode should be equal to ''en-us''.');
        Assert.AreEqual('jetreports', RecommendedAppsTable.PubId, 'PubId should be equal to jetreports.');
        Assert.AreEqual('jetreports', RecommendedAppsTable.AId, 'AId should be equal to jetreports.');
        Assert.AreEqual('bec4ca36-c7fb-4110-9db5-29559cc1f84c', RecommendedAppsTable.PAppId, 'PAppId should be equal to bec4ca36-c7fb-4110-9db5-29559cc1f84c.');
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
    procedure TestDeleteAllApps()
    var
        RecommendedAppsTable: Record "Recommended Apps";
        RecommendedApps: Codeunit "Recommended Apps";
    begin
        // [SCENARIO] Test the TestDeleteAllApps method to delete all apps
        // [WHEN] There are no recommended apps
        RecommendedAppsTable.DeleteAll();
        // [WHEN] 3 new recommended apps are inserted
        InsertMultipleApps();

        // [WHEN] Deleting all apps
        RecommendedApps.DeleteAllApps();

        // [THEN] All apps should be deleted
        Assert.AreEqual(0, RecommendedAppsTable.Count(), 'No record should be found.');
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

    local procedure InsertMultipleApps()
    var
        RecommendedApps: Codeunit "Recommended Apps";
        AppRecommandedBy: Enum "App Recommended By";
    begin
        RecommendedApps.InsertApp(
            CreateGuid(),
            1,
            'Excel Importer',
            'Theta Systems Limited',
            'Import journals and documents from Excel worksheets without reformatting the columns',
            'For many companies, the source for financial transactions are available as a file. These could be payroll extracts, credit card statements, expense reports or billing schedules from vendors for services. Often the cost of integrating these systems does not justify the benefits. So, why not upload the data via an Excel file import?\Under such scenarios, one can often end up working with different file layouts. To improve efficiency and decrease the risk of error, it’s best to import the file without having to convert it to a fixed layout.',
            AppRecommandedBy::"Your Microsoft Reseller",
            'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/pUBID.THETAsystemslimited%7cAID.bc_excel_importer%7cpaPPID.24466323-aee9-4049-a66d-a1af24466323?tab=Overview'
        );

        RecommendedApps.InsertApp(
            CreateGuid(),
            2,
            'Excel Importer decoded',
            'Theta Systems Limited',
            'Import journals and documents from Excel worksheets without reformatting the columns',
            'For many companies, the source for financial transactions are available as a file. These could be payroll extracts, credit card statements, expense reports or billing schedules from vendors for services. Often the cost of integrating these systems does not justify the benefits. So, why not upload the data via an Excel file import?\Under such scenarios, one can often end up working with different file layouts. To improve efficiency and decrease the risk of error, it’s best to import the file without having to convert it to a fixed layout.',
            AppRecommandedBy::"Your Microsoft Reseller",
            'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.thetasystemslimited|aID.bc_excel_importer|PAPPid.24466323-aee9-4049-a66d-a1af24466323?tab=Overview'
        );

        RecommendedApps.InsertApp(
            CreateGuid(),
            3,
            'Jet Reports',
            'Jet Global Data Technologies',
            'Advanced Operational and Financial Reporting Inside of Excel.',
            'Jet Reports delivers a fast, accurate business reporting solution built for Microsoft Dynamics 365 Business Central that gives you the flexibility to create any report you need directly inside of Excel. Drag and drop data from any table to quickly build everything from simple financials to advanced operational reports that can be refreshed real-time, on-demand, with the click of a button. Access, share, and organize reports on the web to have the accurate answers you need from anywhere.',
            AppRecommandedBy::"Your Microsoft Reseller",
            'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.jetreports%7CAID.jetreports%7CPAPPID.bec4ca36-c7fb-4110-9db5-29559cc1f84c?tab=Overview'
        );

        RecommendedApps.InsertApp(
           CreateGuid(),
           4,
           'Jet Reports decoded',
           'Jet Global Data Technologies',
           'Advanced Operational and Financial Reporting Inside of Excel.',
           'Jet Reports delivers a fast, accurate business reporting solution built for Microsoft Dynamics 365 Business Central that gives you the flexibility to create any report you need directly inside of Excel. Drag and drop data from any table to quickly build everything from simple financials to advanced operational reports that can be refreshed real-time, on-demand, with the click of a button. Access, share, and organize reports on the web to have the accurate answers you need from anywhere.',
           AppRecommandedBy::"Your Microsoft Reseller",
           'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/pubid.jetreports%7caid.jetreports%7cpappid.bec4ca36-c7fb-4110-9db5-29559cc1f84c?tab=Overview'
        );

        RecommendedApps.InsertApp(
            CreateGuid(),
            5,
            'Visual Jobs Scheduler',
            'NETRONIC Software GmbH',
            'Ease your project and resource planning with an interactive Gantt planning board',
            'Especially the Jobs module “buries” data in a deep hierarchy of tables: jobs, job tasks, job planning lines and resource allocations. Maybe you have already wished for gaining more transparency and seeing all the project- and resource-related data at one glance, thus finally fully understanding your schedule? Our app, the Visual Jobs Scheduler, enables an effective project planning and is essential for all planners working with Microsoft Dynamics 365 Business Central. It fully integrates with Dynamics 365 Business Central and directly accesses the data of Jobs and Resources. While Dynamics 365 Business Central puts the information of your projects into different tables, the Visual Jobs Scheduler (VJS) bundles all information of these tables into one plan.Actually, it provides you with a project Gantt chart and a resource Gantt chart – both with full drag & drop capabilities. With the VJS, you quickly understand dependencies, conflicts in your schedule and any unwanted issue.',
            AppRecommandedBy::"Your Microsoft Reseller",
            'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.netronic%7CAID.visual-jobs-scheduler%7CPAPPID.9a08bc1f-7ac9-4671-b212-9076b2869e80'
        );

        RecommendedApps.InsertApp(
            CreateGuid(),
            6,
            'Visual Jobs Scheduler decoded',
            'NETRONIC Software GmbH',
            'Ease your project and resource planning with an interactive Gantt planning board',
            'Especially the Jobs module “buries” data in a deep hierarchy of tables: jobs, job tasks, job planning lines and resource allocations. Maybe you have already wished for gaining more transparency and seeing all the project- and resource-related data at one glance, thus finally fully understanding your schedule? Our app, the Visual Jobs Scheduler, enables an effective project planning and is essential for all planners working with Microsoft Dynamics 365 Business Central. It fully integrates with Dynamics 365 Business Central and directly accesses the data of Jobs and Resources. While Dynamics 365 Business Central puts the information of your projects into different tables, the Visual Jobs Scheduler (VJS) bundles all information of these tables into one plan.Actually, it provides you with a project Gantt chart and a resource Gantt chart – both with full drag & drop capabilities. With the VJS, you quickly understand dependencies, conflicts in your schedule and any unwanted issue.',
            AppRecommandedBy::"Your Microsoft Reseller",
            'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.netronic|AID.visual-jobs-scheduler|PAPPID.9a08bc1f-7ac9-4671-b212-9076b2869e80'
        );

        RecommendedApps.InsertApp(
            CreateGuid(),
            7,
            'Custom Fields',
            'Apportunix',
            'Easily create your own custom fields for customers, vendors, contacts and more',
            'Do you have customer data you can’t register? Are you missing important contact or vendor information which is essential for your company business? And is there any sync between contacts, customers and vendors? Just some important issues Small to Midsize Businesses struggle with nowadays. Already a lot of standard fields for entities like contacts, customers and vendors are provided, but what if you want to register company specific data for your company process in Microsoft Dynamics 365 Business Central? We have the perfect app to help you get more productive. With the Custom Fields extension you can easily create your own specific fields for customers, vendors, contacts and other entities. Each field can be set up with a field type for data entry, you can use customizable lists and can translate each custom field into your own language. The extension Custom Fields also supports synchronization of the custom fields between contacts, customers and vendors. This will enable you to maintain your data in one place and keep it in sync with the related data. A time-saving and error-limiting functionality! Custom Fields are also available for your sales & purchase documents and the app also transfers your field data from entities to documents.',
            AppRecommandedBy::"Your Microsoft Reseller",
            'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.wsb_solutions%7CAID.custom_fields%7CPAPPID.1ba841c1-087c-4fb7-b0bf-35db594ce248?tab=overview'
        );

        RecommendedApps.InsertApp(
            CreateGuid(),
            8,
            'Custom Fields decoded',
            'Apportunix',
            'Easily create your own custom fields for customers, vendors, contacts and more',
            'Do you have customer data you can’t register? Are you missing important contact or vendor information which is essential for your company business? And is there any sync between contacts, customers and vendors? Just some important issues Small to Midsize Businesses struggle with nowadays. Already a lot of standard fields for entities like contacts, customers and vendors are provided, but what if you want to register company specific data for your company process in Microsoft Dynamics 365 Business Central? We have the perfect app to help you get more productive. With the Custom Fields extension you can easily create your own specific fields for customers, vendors, contacts and other entities. Each field can be set up with a field type for data entry, you can use customizable lists and can translate each custom field into your own language. The extension Custom Fields also supports synchronization of the custom fields between contacts, customers and vendors. This will enable you to maintain your data in one place and keep it in sync with the related data. A time-saving and error-limiting functionality! Custom Fields are also available for your sales & purchase documents and the app also transfers your field data from entities to documents.',
            AppRecommandedBy::"Your Microsoft Reseller",
            'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.wsb_solutions|AID.custom_fields|PAPPID.1ba841c1-087c-4fb7-b0bf-35db594ce248?tab=OVERVIEW'
        );

        RecommendedApps.InsertApp(
            CreateGuid(),
            9,
            'eCommerce for Dynamics 365 Business Central',
            'Dynamics eShop Inc.',
            'A complete eCommerce solution with real-time integration to Microsoft Dynamics 365 Business Central',
            'Dynamics eShop offers a powerful, all-in-one cloud eCommerce solution that provides full functionalities to successfully setup a webstore for your business. Built to provide 100% integration in real time with Microsoft Dynamics 365 Business',
            AppRecommandedBy::"Your Microsoft Reseller",
            'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.dynamics-eshop%7CAID.6d0fa8dd-50e3-493a-befd-393960238c88%7CPAPPID.c56100aa-6290-440a-b14f-4273ac6fcc78?tab=Overview'
        );

        RecommendedApps.InsertApp(
            CreateGuid(),
            10,
            'eCommerce for Dynamics 365 Business Central decoded',
            'Dynamics eShop Inc.',
            'A complete eCommerce solution with real-time integration to Microsoft Dynamics 365 Business Central',
            'Dynamics eShop offers a powerful, all-in-one cloud eCommerce solution that provides full functionalities to successfully setup a webstore for your business. Built to provide 100% integration in real time with Microsoft Dynamics 365 Business',
            AppRecommandedBy::"Your Microsoft Reseller",
            'https://appsource.microsoft.com/en-us/product/dynamics-365-business-central/PUBID.dynamics-eshop|AID.6d0fa8dd-50e3-493a-befd-393960238c88|PAPPID.c56100aa-6290-440a-b14f-4273ac6fcc78?tab=Overview'
        );
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