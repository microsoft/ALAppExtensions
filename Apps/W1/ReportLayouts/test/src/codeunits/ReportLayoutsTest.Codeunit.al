// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

codeunit 139595 "Report Layouts Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    [Test]
    [HandlerFunctions('NewLayoutModalHandler')]
    procedure TestReportLayoutsInsertedLayoutsCanBeFound()
    var
        TenantReportLayout: Record "Tenant Report Layout";
        ReportLayoutsTest: Codeunit "Report Layouts Test";
        ReportLayoutsPage: TestPage "Report Layouts";
        EmptyGuid: Guid;
    begin
        // Init - Ensure layouts are not inserted for the test report
        EnsureNewLayoutsAreCleaned();

        BindSubscription(ReportLayoutsTest);

        // Act - Open Page and create a new layout
        ReportLayoutsPage.OpenView();
        Assert.IsTrue(ReportLayoutsPage.NewLayout.Enabled(), 'New layout should always be enabled.');

        ReportLayoutsTest.SetLayoutContents(SampleTextTxt);
        ReportLayoutsPage.NewLayout.Invoke();

        ReportLayoutsPage.Close();

        // Assert - Layout Exists
        Assert.IsTrue(TenantReportLayout.Get(139595, NewLayoutNameTxt, EmptyGuid), 'Layout should exist in the Tenant Report Layout table.');

        Assert.AreEqual(NewLayoutNameTxt, TenantReportLayout.Name, 'Incorrect layout name.');

        Assert.AreEqual('', TenantReportLayout."Company Name", 'Layout should be inserted for all companies.');
    end;

    [Test]
    [HandlerFunctions('NewLayoutModalHandlerCurrentCompany')]
    procedure TestReportLayoutsInsertedLayoutForCurrentCompanyIsOnlyForCurrentCompany()
    var
        TenantReportLayout: Record "Tenant Report Layout";
        ReportLayoutsTest: Codeunit "Report Layouts Test";
        ReportLayoutsPage: TestPage "Report Layouts";
        EmptyGuid: Guid;
    begin
        // Init - Ensure layouts are not inserted for the test report
        EnsureNewLayoutsAreCleaned();

        BindSubscription(ReportLayoutsTest);

        // Act - Open Page and create a new layout
        ReportLayoutsPage.OpenView();
        Assert.IsTrue(ReportLayoutsPage.NewLayout.Enabled(), 'New layout should always be enabled.');

        ReportLayoutsTest.SetLayoutContents(SampleTextTxt);
        ReportLayoutsPage.NewLayout.Invoke();

        ReportLayoutsPage.Close();

        // Assert - Layout Exists for current company

        Assert.IsTrue(TenantReportLayout.Get(139595, NewLayoutNameTxt, EmptyGuid), 'Layout should exist in the Tenant Report Layout table.');

        Assert.AreEqual(NewLayoutNameTxt, TenantReportLayout.Name, 'Incorrect layout name.');

        Assert.AreEqual(CompanyName(), TenantReportLayout."Company Name", 'Layout should be only for the current company.');
    end;

    [Test]
    [HandlerFunctions('NewLayoutModalHandler,EditLayoutModalHandler')]
    procedure TestReportLayoutsEditLayoutActuallyEditsTheLayout()
    begin
        EditLayoutTestCore('');
    end;

    [Test]
    [HandlerFunctions('NewLayoutModalHandlerCurrentCompany,EditLayoutModalHandler')]
    procedure TestReportLayoutsEditLayoutPreservesCompanyOnTheLayout()
    begin
        EditLayoutTestCore(CompanyName());
    end;

    [Test]
    [HandlerFunctions('NewLayoutModalHandler,ConfirmHandler')]
    procedure TestReportLayoutsReplaceLayoutReplacesLayout()
    var
        TenantReportLayout: Record "Tenant Report Layout";
        ReportLayoutList: Record "Report Layout List";
        ReportLayoutsTest: Codeunit "Report Layouts Test";
        ReportLayoutsPage: TestPage "Report Layouts";
        ReplacedLayoutOutStream: OutStream;
        ReplacedLayoutText: Text;
        EmptyGuid: Guid;
    begin
        // Init - Ensure layouts are not inserted for the test report and insert a new layout
        EnsureNewLayoutsAreCleaned();

        BindSubscription(ReportLayoutsTest);

        ReportLayoutsPage.OpenView();
        Assert.IsTrue(ReportLayoutsPage.NewLayout.Enabled(), 'New layout should always be enabled.');

        ReportLayoutsTest.SetLayoutContents(SampleTextTxt);
        ReportLayoutsPage.NewLayout.Invoke();

        Assert.IsTrue(TenantReportLayout.Get(139595, NewLayoutNameTxt, EmptyGuid), 'Layout should exist in the Tenant Report Layout table.');

        Assert.AreEqual(NewLayoutNameTxt, TenantReportLayout.Name, 'Incorrect layout name.');

        Assert.AreEqual('', TenantReportLayout."Company Name", 'Layout should exist for all companies.');

        // Act - Delete the layout

        ReportLayoutList.Get(139595, NewLayoutNameTxt, EmptyGuid);
        ReportLayoutsPage.GoToRecord(ReportLayoutList);

        // Replace the text with new text
        ReportLayoutsTest.SetLayoutContents(AlternateLayoutTextTxt);
        ReportLayoutsPage.ReplaceLayout.Invoke();

        // Assert - Layout exists and contains new contents
        ReportLayoutList.Get(139595, NewLayoutNameTxt, EmptyGuid);

        TempBlob.CreateOutStream(ReplacedLayoutOutStream);
        ReportLayoutList.Layout.ExportStream(ReplacedLayoutOutStream);

        TempBlob.CreateInStream().ReadText(ReplacedLayoutText, StrLen(AlternateLayoutTextTxt));
        Assert.AreEqual(AlternateLayoutTextTxt, ReplacedLayoutText, 'The contents of the layout were not replaced.');
    end;

    [Test]
    [HandlerFunctions('NewLayoutModalHandler,EditLayoutModalHandler,MessageHandler')]
    procedure TestReportLayoutsSetsCorrectSelections()
    var
        TenantReportLayout: Record "Tenant Report Layout";
        ReportLayoutList: Record "Report Layout List";
        TenantReportLayoutSelection: Record "Tenant Report Layout Selection";
        ReportLayoutsTest: Codeunit "Report Layouts Test";
        ReportLayoutsPage: TestPage "Report Layouts";
        EmptyGuid: Guid;
    begin
        // Init - Ensure layouts are not inserted for the test report and insert a new layout
        EnsureNewLayoutsAreCleaned();

        BindSubscription(ReportLayoutsTest);

        ReportLayoutsPage.OpenView();
        Assert.IsTrue(ReportLayoutsPage.NewLayout.Enabled(), 'New layout should always be enabled.');

        ReportLayoutsTest.SetLayoutContents(SampleTextTxt);
        ReportLayoutsPage.NewLayout.Invoke();

        Assert.IsTrue(TenantReportLayout.Get(139595, NewLayoutNameTxt, EmptyGuid), 'Layout should exist in the Tenant Report Layout table.');

        Assert.AreEqual(NewLayoutNameTxt, TenantReportLayout.Name, 'Incorrect layout name.');

        Assert.AreEqual('', TenantReportLayout."Company Name", 'Layout should exist for all companies.');

        // Act - Set a selection

        ReportLayoutList.Get(139595, NewLayoutNameTxt, EmptyGuid);
        ReportLayoutsPage.GoToRecord(ReportLayoutList);

        ReportLayoutsPage.DefaulLayoutSelection.Invoke();

        // Assert - Selection is added
        Assert.IsTrue(TenantReportLayoutSelection.Get(139595, CompanyName(), EmptyGuid), 'A selection should have been set but was not');
        Assert.AreEqual(NewLayoutNameTxt, TenantReportLayoutSelection."Layout Name", 'The inserted layout name does not match the layout.');

        // Act - Edit the layout to change its name
        ReportLayoutsPage.EditLayout.Invoke();

        // Assert 
        Assert.IsTrue(TenantReportLayoutSelection.Get(139595, CompanyName(), EmptyGuid), 'A selection should have been set but was not');
        Assert.AreEqual(EditedLayoutNameTxt, TenantReportLayoutSelection."Layout Name", 'The inserted layout name does not match the layout.');
    end;

    local procedure EditLayoutTestCore(ExpectedCompanyName: Text)
    var
        TenantReportLayout: Record "Tenant Report Layout";
        ReportLayoutsTest: Codeunit "Report Layouts Test";
        ReportLayoutsPage: TestPage "Report Layouts";
        EmptyGuid: Guid;
    begin
        // Init - Ensure layouts are not inserted for the test report and insert a new layout
        EnsureNewLayoutsAreCleaned();

        BindSubscription(ReportLayoutsTest);

        ReportLayoutsPage.OpenView();
        Assert.IsTrue(ReportLayoutsPage.NewLayout.Enabled(), 'New layout should always be enabled.');

        ReportLayoutsTest.SetLayoutContents(SampleTextTxt);
        ReportLayoutsPage.NewLayout.Invoke();

        Assert.IsTrue(TenantReportLayout.Get(139595, NewLayoutNameTxt, EmptyGuid), 'Layout should exist in the Tenant Report Layout table.');

        Assert.AreEqual(NewLayoutNameTxt, TenantReportLayout.Name, 'Incorrect layout name.');

        Assert.AreEqual(ExpectedCompanyName, TenantReportLayout."Company Name", 'Layout should exist for all companies.');

        // Act - Layout is edited

        ReportLayoutsPage.EditLayout.Invoke();

        // Assert - Layout has been changed

        Assert.IsTrue(TenantReportLayout.Get(139595, EditedLayoutNameTxt, EmptyGuid), 'Edited layout should exist');

        Assert.AreEqual(EditedLayoutNameTxt, TenantReportLayout.Description, 'Description was not edited properly.');

        Assert.AreEqual(EditedLayoutNameTxt, TenantReportLayout.Name, 'Name was not edited properly.');

        Assert.AreEqual(ExpectedCompanyName, TenantReportLayout."Company Name", 'The company should have been empty (available for all companies) but had a different value.');
    end;

    /// <summary>
    /// Sets the contents of the layout that will be inserted by
    /// the event subscriber.
    /// </summary>
    /// <param name="WhatToInsert">The contents.</param>
    procedure SetLayoutContents(WhatToInsert: Text)
    begin
        InsertedLayoutContextTxt := WhatToInsert;
    end;

    [ModalPageHandler]
    procedure NewLayoutModalHandler(var ReportLayoutNewDialog: TestPage "Report Layout New Dialog")
    var
    begin
        ReportLayoutNewDialog.LayoutName.Value := NewLayoutNameTxt;
        ReportLayoutNewDialog.Description.Value := NewLayoutNameTxt;
        ReportLayoutNewDialog."Format Options".Value := 'External';

        Assert.AreEqual('Yes', ReportLayoutNewDialog.AvailableInAllCompanies.Value, 'The available in all companies toggle should be on by default.');

        ReportLayoutNewDialog.ReportID.Value := '139595';
        ReportLayoutNewDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure NewLayoutModalHandlerCurrentCompany(var ReportLayoutNewDialog: TestPage "Report Layout New Dialog")
    var
    begin
        ReportLayoutNewDialog.LayoutName.Value := NewLayoutNameTxt;
        ReportLayoutNewDialog.Description.Value := NewLayoutNameTxt;
        ReportLayoutNewDialog."Format Options".Value := 'External';

        Assert.AreEqual('Yes', ReportLayoutNewDialog.AvailableInAllCompanies.Value, 'The available in all companies toggle should be on by default.');
        ReportLayoutNewDialog.AvailableInAllCompanies.SetValue(false);

        ReportLayoutNewDialog.ReportID.Value := '139595';
        ReportLayoutNewDialog.OK().Invoke();
    end;

    [ModalPageHandler]
    procedure EditLayoutModalHandler(var ReportLayoutEditDialog: TestPage "Report Layout Edit Dialog")
    var
    begin
        ReportLayoutEditDialog.LayoutName.Value := EditedLayoutNameTxt;
        ReportLayoutEditDialog.Description.Value := EditedLayoutNameTxt;
        ReportLayoutEditDialog.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    var
    begin
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    local procedure EnsureNewLayoutsAreCleaned()
    var
        TenantReportLayout: Record "Tenant Report Layout";
    begin
        TenantReportLayout.SetRange("Report ID", 139595);
        TenantReportLayout.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Report Layouts Impl.", 'OnBeforeUpload', '', false, false)]
    local procedure UploadHandler(var AlreadyUploaded: Boolean; var UploadFileName: Text; var FileInStream: InStream)
    var
        TempOutStream: OutStream;
    begin
        if AlreadyUploaded then
            exit;

        TempBlob.CreateOutStream(TempOutStream);
        TempOutStream.WriteText(InsertedLayoutContextTxt, StrLen(InsertedLayoutContextTxt));

        TempBlob.CreateInStream(FileInStream);

        UploadFileName := 'TestLayout';
        AlreadyUploaded := true;
    end;

    var
        Assert: Codeunit Assert;
        TempBlob: Codeunit "Temp Blob";
        NewLayoutNameTxt: Label 'NewLayout';
        EditedLayoutNameTxt: Label 'EditedLayout';
        SampleTextTxt: Label 'ATAKLOA, TINWTABSBATF.';
        AlternateLayoutTextTxt: Label 'IWATSTGIFLBOTG.';
        InsertedLayoutContextTxt: Text;
}
