// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 139591 "Img. Analyzer Mgt. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
    trigger OnRun();
    begin
        // [FEATURE] [Image Analysis]
    end;

    [Test]
    procedure TestSetup()
    var
        ImageAnalysisSetup: Record "Image Analysis Setup";
        ImageAnalyzerExtMgt: Codeunit "Image Analyzer Ext. Mgt.";
    begin
        // [Scenario] Setup feature

        // [Given] That setup has been invoked
        ImageAnalyzerExtMgt.HandleSetupAndEnable();

        // [When]

        // [Then] Setup is enabled
        ImageAnalysisSetup.GetSingleInstance();
        Assert.IsTrue(ImageAnalysisSetup."Image-Based Attribute Recognition Enabled", 'Item attribute population was not enabled.');
    end;

    [Test]
    procedure TestDeactivateNotification()
    var
        MyNotifications: Record "My Notifications";
        ImageAnalyzerExtMgt: Codeunit "Image Analyzer Ext. Mgt.";
        SetupNotification: Notification;
    begin
        // [Feature] [Notification]
        // [Scenario] Deactivate feature notification
        SetupNotification.SetData('NotificationId', ImageAnalyzerExtMgt.GetSetupNotificationId());

        // [Given] That deactivate has been invoked from the notification
        ImageAnalyzerExtMgt.HandleDeactivateNotification(SetupNotification);

        // [When]

        // [Then] The notification is disabled
        MyNotifications.Get(UserId(), ImageAnalyzerExtMgt.GetSetupNotificationId());
        Assert.IsFalse(MyNotifications.Enabled, 'Item attribute population notification is enabled.')
    end;

    [Test]
    procedure TestIsSaasAndCannotUseRelationshipMgmtFalse()
    var
        ImageAnalyzerExtMgt: Codeunit "Image Analyzer Ext. Mgt.";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        // [Scenario] When Not in a saas environment IsSaasAndCannotUseRelationshipMgmt should be false

        // [Given] Not in saas
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);

        // [When]

        // [Then] Function returns false
        Assert.IsFalse(ImageAnalyzerExtMgt.IsSaasAndCannotUseRelationshipMgmt(), 'Saas is enabled.')
    end;

    [Test]
    procedure TestIsSaasAndCannotUseRelationshipMgmtFalse2()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ImageAnalyzerExtMgt: Codeunit "Image Analyzer Ext. Mgt.";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        // [Scenario] When in a saas environment and no application area IsSaasAndCannotUseRelationshipMgmt should be false

        // [Given] In saas and no application area is setup
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        ApplicationAreaSetup.DeleteAll();
        ApplicationAreaMgmtFacade.SetupApplicationArea();

        // [When]

        // [Then] Function returns false
        Assert.IsFalse(ImageAnalyzerExtMgt.IsSaasAndCannotUseRelationshipMgmt(), 'In Saas and cannot use relationship mgmt.')
    end;

    [Test]
    procedure TestIsSaasAndCannotUseRelationshipMgmtFalse3()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ImageAnalyzerExtMgt: Codeunit "Image Analyzer Ext. Mgt.";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        // [Scenario] When in a saas environment and is advanced experience IsSaasAndCannotUseRelationshipMgmt should be false

        // [Given] In saas and is advanced experience
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        ApplicationAreaSetup.DeleteAll();
        ApplicationAreaSetup."Company Name" := '';
        ApplicationAreaSetup."Profile ID" := '';
        ApplicationAreaSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(ApplicationAreaSetup."User ID"));
        ApplicationAreaSetup.Advanced := true;
        ApplicationAreaSetup.Insert();
        ApplicationAreaMgmtFacade.SetupApplicationArea();
        // [When]

        // [Then] Function returns false
        Assert.IsFalse(ImageAnalyzerExtMgt.IsSaasAndCannotUseRelationshipMgmt(), 'In Saas and cannot use relationship mgmt.')
    end;

    [Test]
    procedure TestIsSaasAndCannotUseRelationshipMgmtFalse4()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ImageAnalyzerExtMgt: Codeunit "Image Analyzer Ext. Mgt.";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        // [Scenario] When in a saas environment and relationshipmgmt enabled IsSaasAndCannotUseRelationshipMgmt should be false

        // [Given] In saas and relationshipmgmt enabled
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        ApplicationAreaSetup.DeleteAll();
        ApplicationAreaSetup."Company Name" := '';
        ApplicationAreaSetup."Profile ID" := '';
        ApplicationAreaSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(ApplicationAreaSetup."User ID"));
        ApplicationAreaSetup.Basic := true;
        ApplicationAreaSetup."Relationship Mgmt" := true;
        ApplicationAreaSetup.Insert();
        ApplicationAreaMgmtFacade.SetupApplicationArea();

        // [When]

        // [Then] Function returns false
        Assert.IsFalse(ImageAnalyzerExtMgt.IsSaasAndCannotUseRelationshipMgmt(), 'In Saas and cannot use relationship mgmt.')
    end;

    [Test]
    procedure TestIsSaasAndCannotUseRelationshipMgmtTrue()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ImageAnalyzerExtMgt: Codeunit "Image Analyzer Ext. Mgt.";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
    begin
        // [Scenario] When in a saas environment IsSaasAndCannotUseRelationshipMgmt should be false

        // [Given] In saas and only application area basic enabled (making advanced experience false and isAllDisabled false)
        ApplicationAreaSetup.DeleteAll();
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        ApplicationAreaSetup."Company Name" := '';
        ApplicationAreaSetup."Profile ID" := '';
        ApplicationAreaSetup."User ID" := CopyStr(UserId(), 1, MaxStrLen(ApplicationAreaSetup."User ID"));
        ApplicationAreaSetup.Basic := true;
        ApplicationAreaSetup.Insert();
        ApplicationAreaMgmtFacade.SetupApplicationArea();

        // [When]

        // [Then] Function returns true
        Assert.IsTrue(ImageAnalyzerExtMgt.IsSaasAndCannotUseRelationshipMgmt(), 'Not in saas or can use relationship mgmt')
    end;
}
