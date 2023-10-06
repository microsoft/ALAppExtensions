// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Privacy;

using System.Privacy;
using System.TestLibraries.Utilities;
using System.TestLibraries.Security.AccessControl;

codeunit 132649 "Privacy Notice Automate Test"
{
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";
        PrivacyNoticeInterface: Codeunit "Privacy Notice";
        PrivacyPermissionSetAdminTxt: Label 'Priv. Notice - Admin', Locked = true;

    [Test]
    procedure CheckTheBasicBehaviour()
    var
        PrivacyNotice: Record "Privacy Notice";
        PrivacyNoticeApproval: Record "Privacy Notice Approval";
        PowerAutomatePrivacyNoticeTestPage: TestPage "Power Automate Privacy Notice";
        PrivacyNoticeId: Text[50];
        EmptyGuid: Guid;
    begin
        // [GIVEN] A Power Automate privacy without approval
        PrivacyNoticeId := 'TestPowerAutomateModalBasic';
        PrivacyNoticeInterface.CreatePrivacyNotice(PrivacyNoticeId, PrivacyNoticeId);
        PermissionsMock.Set(PrivacyPermissionSetAdminTxt);
        PrivacyNotice.Get(PrivacyNoticeId);

        // [THEN] The initial state is not set
        LibraryAssert.AreEqual("Privacy Notice Approval State"::"Not set", PrivacyNoticeInterface.GetPrivacyNoticeApprovalState(PrivacyNoticeId), 'The privacy notice state was set incorrectly');

        // [WHEN] The admin accepts the privacy notice from UI
        PowerAutomatePrivacyNoticeTestPage.Trap();
        page.Run(page::"Power Automate Privacy Notice", PrivacyNotice);
        PowerAutomatePrivacyNoticeTestPage.Next.Invoke();
        PowerAutomatePrivacyNoticeTestPage.Accept.Invoke();

        // [THEN] There is a Power Automate privacy notice approval by the admin 
        LibraryAssert.IsTrue(PrivacyNoticeApproval.Get(PrivacyNoticeId, EmptyGuid), 'Admin privacy notice does not exist!');
        LibraryAssert.isTrue(PrivacyNoticeApproval.Approved, 'The user privacy notice should have been approved!');
    end;

    [Test]
    procedure DisagreeIsSavedAsNotSet()
    var
        PrivacyNotice: Record "Privacy Notice";
        PowerAutomatePrivacyNoticeTestPage: TestPage "Power Automate Privacy Notice";
        PrivacyNoticeId: Text[50];
    begin
        // [GIVEN] A Power Automate privacy without approval
        PrivacyNoticeId := 'TestPowerAutomateModal';
        PrivacyNoticeInterface.CreatePrivacyNotice(PrivacyNoticeId, PrivacyNoticeId);
        PermissionsMock.Set(PrivacyPermissionSetAdminTxt);
        PrivacyNotice.Get(PrivacyNoticeId);

        // [THEN] The initial state is not set
        LibraryAssert.AreEqual("Privacy Notice Approval State"::"Not set", PrivacyNoticeInterface.GetPrivacyNoticeApprovalState(PrivacyNoticeId), 'The privacy notice state was set incorrectly');

        // [WHEN] The admin accepts the privacy notice from UI
        PowerAutomatePrivacyNoticeTestPage.Trap();
        page.Run(page::"Power Automate Privacy Notice", PrivacyNotice);
        PowerAutomatePrivacyNoticeTestPage.Next.Invoke();
        PowerAutomatePrivacyNoticeTestPage.Reject.Invoke();

        // [THEN] The state should not change
        LibraryAssert.AreEqual("Privacy Notice Approval State"::"Not set", PrivacyNoticeInterface.GetPrivacyNoticeApprovalState(PrivacyNoticeId), 'The user privacy notice should have been not set!');
    end;

    [Test]
    [HandlerFunctions('AcceptPrivacyNoticeHandler')]
    procedure SubscriberOpensPowerAutomatePopup()
    var
        SystemPrivacyNoticeReg: Codeunit "System Privacy Notice Reg.";
        PrivacyNoticeName: Text[250];
        PrivacyNoticeId: Text[50];
    begin
        // [GIVEN] A Power Automate privacy without approval
        Commit();
        PrivacyNoticeName := SystemPrivacyNoticeReg.GetPowerAutomatePrivacyNoticeName();
        PrivacyNoticeId := SystemPrivacyNoticeReg.GetPowerAutomatePrivacyNoticeId();
        PrivacyNoticeInterface.CreatePrivacyNotice(PrivacyNoticeId, PrivacyNoticeName);
        PermissionsMock.Set(PrivacyPermissionSetAdminTxt);

        // [THEN] There is a Power Automate privacy notice approval by the admin done via Power Automate wizzard invoked in the subscription
        LibraryAssert.IsTrue(PrivacyNoticeInterface.ConfirmPrivacyNoticeApproval(PrivacyNoticeId), 'The user privacy notice should have been approved!');
    end;

    [ModalPageHandler]
    procedure AcceptPrivacyNoticeHandler(var PowerAutomatePrivacyNoticeTestPage: TestPage "Power Automate Privacy Notice")
    begin
        PowerAutomatePrivacyNoticeTestPage.Next.Invoke();
        PowerAutomatePrivacyNoticeTestPage.Accept.Invoke();
    end;
}

