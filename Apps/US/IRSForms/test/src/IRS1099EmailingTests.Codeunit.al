// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Purchases.Vendor;
using System.Email;
using System.TestLibraries.Email;
using System.TestLibraries.Utilities;
using System.Utilities;

codeunit 148012 "IRS 1099 Emailing Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryIRSReportingPeriod: Codeunit "Library IRS Reporting Period";
        LibraryIRS1099FormBox: Codeunit "Library IRS 1099 Form Box";
        LibraryIRS1099Document: Codeunit "Library IRS 1099 Document";
        LibraryWorkflow: Codeunit "Library - Workflow";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit "Assert";
        IsInitialized: Boolean;
        EmailSetupMissingErr: Label 'You must set up email in Business Central before you can send 1099 forms.';
        NoConsentErr: Label '%1 must be enabled on the vendor card.', Comment = '%1 - "Receiving 1099 E-Form Consent" field caption';
        EmptyEmailErr: Label '%1 must be set in the document or vendor card.', Comment = '%1 - "Vendor E-Mail" field caption';
        EnableConsentMessageTxt: Label 'You must enable the Receiving 1099 E-Form Consent field';
        SetEmailMessageTxt: Label 'Set the email in the document or in the vendor card';
        PropagateFieldToSubmittedFormDocsQst: Label 'Do you want to propagate the %1 to all submitted 1099 form documents by this vendor?', Comment = '%1 = field caption';

    [Test]
    procedure EmailFromListWhenEmailNotSetup()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocuments: TestPage "IRS 1099 Form Documents";
    begin
        // [SCENARIO 560521] Send email from 1099 form document list when email account is not set up.
        Initialize();
        DeleteEmailAccounts();

        // [GIVEN] 1099 form document for the vendor.
        MockFormDocument(IRS1099FormDocHeader, "IRS 1099 Form Doc. Status"::Released);

        // [WHEN] Press "Send Email" from the form document list.
        IRS1099FormDocuments.OpenEdit();
        IRS1099FormDocuments.Filter.SetFilter("Vendor No.", IRS1099FormDocHeader."Vendor No.");
        asserterror IRS1099FormDocuments.SendEmail.Invoke();

        // [THEN] The error "You must set up email in Business Central" is thrown.
        Assert.ExpectedError(EmailSetupMissingErr);
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure EmailFromListWhenConsentAndEmailNotSet()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocuments: TestPage "IRS 1099 Form Documents";
        ErrorMessagesPage: TestPage "Error Messages";
    begin
        // [SCENARIO 560521] Send email from 1099 form document list when email and consent are not set.
        Initialize();

        // [GIVEN] Email account.
        LibraryWorkflow.SetUpEmailAccount();

        // [GIVEN] 1099 form document without email consent and without email.
        MockFormDocument(IRS1099FormDocHeader, "IRS 1099 Form Doc. Status"::Released);
        UpdateDocumentEmailAndConsent(IRS1099FormDocHeader, '', false);

        // [WHEN] Press "Send Email" from the form document list.
        ErrorMessagesPage.Trap();
        IRS1099FormDocuments.OpenEdit();
        IRS1099FormDocuments.Filter.SetFilter("Vendor No.", IRS1099FormDocHeader."Vendor No.");
        IRS1099FormDocuments.SendEmail.Invoke();

        // [THEN] Error Messages page is shown.
        // [THEN] Error "Receiving 1099 E-Form Consent must be enabled on the vendor card." is shown on the page.
        // [THEN] Error "Vendor E-Mail must be set in the document or vendor card." is shown on the page.
        Assert.ExpectedError('');
        ErrorMessagesPage.First();
        Assert.ExpectedMessage(
            StrSubstNo(NoConsentErr, IRS1099FormDocHeader.FieldCaption("Receiving 1099 E-Form Consent")),
            ErrorMessagesPage.Description.Value);
        ErrorMessagesPage.Next();
        Assert.ExpectedMessage(
            StrSubstNo(EmptyEmailErr, IRS1099FormDocHeader.FieldCaption("Vendor E-Mail")),
            ErrorMessagesPage.Description.Value);
    end;

    [Test]
    [HandlerFunctions('SendEmailReqPageHandler')]
    procedure EmailFromListWhenConsentAndEmailSet()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        SentEmail: Record "Sent Email";
        IRS1099FormDocuments: TestPage "IRS 1099 Form Documents";
    begin
        // [SCENARIO 560521] Send email from 1099 form document list when email and emailing consent are set.
        Initialize();
        SentEmail.DeleteAll();

        // [GIVEN] Email account.
        LibraryWorkflow.SetUpEmailAccount();

        // [GIVEN] 1099 form document with email consent and email.
        MockFormDocument(IRS1099FormDocHeader, "IRS 1099 Form Doc. Status"::Released);
        UpdateDocumentEmailAndConsent(IRS1099FormDocHeader, LibraryUtility.GenerateRandomEmail(), true);

        // [WHEN] Press "Send Email" from the form document list.
        Commit();
        IRS1099FormDocuments.OpenEdit();
        IRS1099FormDocuments.Filter.SetFilter("Vendor No.", IRS1099FormDocHeader."Vendor No.");
        IRS1099FormDocuments.SendEmail.Invoke();

        // [THEN] Report "IRS 1099 Send Email" is run and one email is sent.
        // [THEN] "Copy B Sent" flag was set in 1099 form document.
        Assert.AreEqual(1, SentEmail.Count, 'One email must be sent.');
        IRS1099FormDocHeader.Get(IRS1099FormDocHeader.ID);
        Assert.IsTrue(IRS1099FormDocHeader."Copy B Sent", 'Copy B Sent must be set to true.');
    end;

    [Test]
    procedure EmailFromCardWhenEmailNotSetup()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocument: TestPage "IRS 1099 Form Document";
    begin
        // [SCENARIO 560521] Send email from 1099 form document card when email account is not set up.
        Initialize();
        DeleteEmailAccounts();

        // [GIVEN] 1099 form document for the vendor.
        MockFormDocument(IRS1099FormDocHeader, "IRS 1099 Form Doc. Status"::Released);

        // [WHEN] Press "Send Email" from the form document card.
        IRS1099FormDocument.OpenEdit();
        IRS1099FormDocument.Filter.SetFilter("Vendor No.", IRS1099FormDocHeader."Vendor No.");
        asserterror IRS1099FormDocument.SendEmail.Invoke();

        // [THEN] The error "You must set up email in Business Central" is thrown.
        Assert.ExpectedError(EmailSetupMissingErr);
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure EmailFromCardWhenConsentAndEmailNotSet()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocument: TestPage "IRS 1099 Form Document";
    begin
        // [SCENARIO 560521] Send email from 1099 form document card when email and consent are not set.
        Initialize();

        // [GIVEN] Email account.
        LibraryWorkflow.SetUpEmailAccount();

        // [GIVEN] 1099 form document without email and without consent.
        MockFormDocument(IRS1099FormDocHeader, "IRS 1099 Form Doc. Status"::Released);
        UpdateDocumentEmailAndConsent(IRS1099FormDocHeader, '', false);

        // [WHEN] Press "Send Email" from the form document card.
        IRS1099FormDocument.OpenEdit();
        IRS1099FormDocument.Filter.SetFilter("Vendor No.", IRS1099FormDocHeader."Vendor No.");
        asserterror IRS1099FormDocument.SendEmail.Invoke();

        // [THEN] Error "You must enable the Receiving 1099 E-Form Consent field" is thrown.
        Assert.ExpectedError(EnableConsentMessageTxt);
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure EmailFromCardWhenConsentSetAndEmailNotSet()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        IRS1099FormDocument: TestPage "IRS 1099 Form Document";
    begin
        // [SCENARIO 560521] Send email from 1099 form document card when email is set and consent is not set.
        Initialize();

        // [GIVEN] Email account.
        LibraryWorkflow.SetUpEmailAccount();

        // [GIVEN] 1099 form document without email and with consent.
        MockFormDocument(IRS1099FormDocHeader, "IRS 1099 Form Doc. Status"::Released);
        UpdateDocumentEmailAndConsent(IRS1099FormDocHeader, '', true);

        // [WHEN] Press "Send Email" from the form document card.
        IRS1099FormDocument.OpenEdit();
        IRS1099FormDocument.Filter.SetFilter("Vendor No.", IRS1099FormDocHeader."Vendor No.");
        asserterror IRS1099FormDocument.SendEmail.Invoke();

        // [THEN] Error "Set the email in the document or in the vendor card" is thrown.
        Assert.ExpectedError(SetEmailMessageTxt);
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    [HandlerFunctions('SendEmailReqPageHandler')]
    procedure EmailFromCardWhenConsentAndEmailSet()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        SentEmail: Record "Sent Email";
        IRS1099FormDocument: TestPage "IRS 1099 Form Document";
    begin
        // [SCENARIO 560521] Send email from 1099 form document card when email and emailing consent are set.
        Initialize();
        SentEmail.DeleteAll();

        // [GIVEN] Email account.
        LibraryWorkflow.SetUpEmailAccount();

        // [GIVEN] 1099 form document with email and consent.
        MockFormDocument(IRS1099FormDocHeader, "IRS 1099 Form Doc. Status"::Released);
        UpdateDocumentEmailAndConsent(IRS1099FormDocHeader, LibraryUtility.GenerateRandomEmail(), true);

        // [WHEN] Press "Send Email" from the form document card.
        Commit();
        IRS1099FormDocument.OpenEdit();
        IRS1099FormDocument.Filter.SetFilter("Vendor No.", IRS1099FormDocHeader."Vendor No.");
        IRS1099FormDocument.SendEmail.Invoke();

        // [THEN] Report "IRS 1099 Send Email" is run and one email is sent.
        // [THEN] "Copy B Sent" flag was set in 1099 form document.
        Assert.AreEqual(1, SentEmail.Count, 'One email must be sent.');
        IRS1099FormDocHeader.Get(IRS1099FormDocHeader.ID);
        Assert.IsTrue(IRS1099FormDocHeader."Copy B Sent", 'Copy B Sent must be set to true.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure PropagateConsentToSubmittedDocument()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        DummyVendor: Record Vendor;
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        VendorCard: TestPage "Vendor Card";
        ConfirmQuestion: Text;
    begin
        // [SCENARIO 560521] Propagate email consent from vendor to submitted 1099 form document.
        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif

        // [GIVEN] Submitted 1099 form document without email and without consent.
        MockFormDocument(IRS1099FormDocHeader, "IRS 1099 Form Doc. Status"::Submitted);
        UpdateDocumentEmailAndConsent(IRS1099FormDocHeader, '', false);

        // [GIVEN] Vendor with email and without consent.
        UpdateVendorEmailAndConsent(IRS1099FormDocHeader."Vendor No.", LibraryUtility.GenerateRandomEmail(), false);

        // [WHEN] Open the vendor card and set the email consent.
        VendorCard.OpenEdit();
        VendorCard.Filter.SetFilter("No.", IRS1099FormDocHeader."Vendor No.");
        VendorCard."Receive Elec. IRS Forms".SetValue(true);

        // [THEN] Confirm dialog with question "Do you want to propagate consent to submitted documents" is shown. Reply Yes.
        ConfirmQuestion := LibraryVariableStorage.DequeueText();
        Assert.AreEqual(
            StrSubstNo(PropagateFieldToSubmittedFormDocsQst, DummyVendor.FieldCaption("Receiving 1099 E-Form Consent")),
            ConfirmQuestion, 'Confirm dialog with question must be shown.');

        // [THEN] Consent was propagated to the 1099 form document.
        IRS1099FormDocHeader.Get(IRS1099FormDocHeader.ID);
        Assert.IsTrue(IRS1099FormDocHeader."Receiving 1099 E-Form Consent", 'Receiving 1099 E-Form Consent must be set to true.');
        Assert.AreEqual('', IRS1099FormDocHeader."Vendor E-Mail", 'Vendor E-Mail must be empty.');

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure PropagateEmailToSubmittedDocument()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
        DummyVendor: Record Vendor;
#if not CLEAN25
#pragma warning disable AL0432
        IRSFormsEnableFeature: Codeunit "IRS Forms Enable Feature";
#pragma warning restore AL0432
#endif
        VendorCard: TestPage "Vendor Card";
        ConfirmQuestion: Text;
        VendorEmail: Text[80];
    begin
        // [SCENARIO 560521] Propagate email from vendor to submitted 1099 form document.
        Initialize();
#if not CLEAN25
        BindSubscription(IRSFormsEnableFeature);
#endif

        // [GIVEN] Submitted 1099 form document without email and with consent.
        MockFormDocument(IRS1099FormDocHeader, "IRS 1099 Form Doc. Status"::Submitted);
        UpdateDocumentEmailAndConsent(IRS1099FormDocHeader, '', true);

        // [GIVEN] Vendor without email and with consent.
        UpdateVendorEmailAndConsent(IRS1099FormDocHeader."Vendor No.", '', true);

        // [WHEN] Open the vendor card and set the email.
        VendorEmail := LibraryUtility.GenerateRandomEmail();
        VendorCard.OpenEdit();
        VendorCard.Filter.SetFilter("No.", IRS1099FormDocHeader."Vendor No.");
        VendorCard."E-Mail".SetValue(VendorEmail);

        // [THEN] Confirm dialog with question "Do you want to propagate email to submitted documents" is shown. Reply Yes.
        ConfirmQuestion := LibraryVariableStorage.DequeueText();
        Assert.AreEqual(
            StrSubstNo(PropagateFieldToSubmittedFormDocsQst, DummyVendor.FieldCaption("E-Mail")),
            ConfirmQuestion, 'Confirm dialog with question must be shown.');

        // [THEN] Consent was propagated to the 1099 form document.
        IRS1099FormDocHeader.Get(IRS1099FormDocHeader.ID);
        Assert.IsTrue(IRS1099FormDocHeader."Receiving 1099 E-Form Consent", 'Receiving 1099 E-Form Consent must be set to true.');
        Assert.AreEqual(VendorEmail, IRS1099FormDocHeader."Vendor E-Mail", 'Vendor E-Mail must be specified.');

#if not CLEAN25
        UnbindSubscription(IRSFormsEnableFeature);
#endif
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure Initialize()
    var
        IRSReportingPeriod: Record "IRS Reporting Period";
    begin
        DeleteFormDocuments();
        IRSReportingPeriod.DeleteAll(true);

        if IsInitialized then
            exit;

        IsInitialized := true;
    end;

    local procedure DeleteFormDocuments()
    var
        IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header";
    begin
        IRS1099FormDocHeader.ModifyAll(Status, IRS1099FormDocHeader.Status::Open);
        IRS1099FormDocHeader.DeleteAll(true);
    end;

    local procedure DeleteEmailAccounts()
    var
        EmailAccount: Record "Email Account";
        TestEmailAccount: Record "Test Email Account";
        EmailScenarioMock: Codeunit "Email Scenario Mock";
    begin
        EmailScenarioMock.DeleteAllMappings();
        EmailAccount.DeleteAll(true);
        TestEmailAccount.DeleteAll(true);
    end;

    local procedure MockFormDocument(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; Status: Enum "IRS 1099 Form Doc. Status")
    var
        PeriodNo, FormNo, VendorNo, FormBoxNo : Code[20];
        DocID: Integer;
    begin
        PeriodNo := LibraryIRSReportingPeriod.CreateOneDayReportingPeriod(WorkDate());
        FormNo := LibraryIRS1099FormBox.CreateSingleFormInReportingPeriod(WorkDate());
        FormBoxNo := LibraryIRS1099FormBox.CreateSingleFormBoxInReportingPeriod(WorkDate(), FormNo);
        VendorNo := LibraryIRS1099FormBox.CreateVendorNoWithFormBox(WorkDate(), FormNo, FormBoxNo);
        LibraryIRS1099FormBox.CreateSingleFormStatementLine(WorkDate(), FormNo, FormBoxNo);
        DocID := LibraryIRS1099Document.MockFormDocumentForVendor(PeriodNo, VendorNo, FormNo, Status);
        LibraryIRS1099Document.MockFormDocumentLineForVendor(DocID, PeriodNo, VendorNo, FormNo, FormBoxNo);
        IRS1099FormDocHeader.Get(DocID);
    end;

    local procedure UpdateDocumentEmailAndConsent(var IRS1099FormDocHeader: Record "IRS 1099 Form Doc. Header"; EmailAddress: Text[80]; EmailConsent: Boolean)
    begin
        IRS1099FormDocHeader."Vendor E-Mail" := EmailAddress;
        IRS1099FormDocHeader."Receiving 1099 E-Form Consent" := EmailConsent;
        IRS1099FormDocHeader.Modify();
    end;

    local procedure UpdateVendorEmailAndConsent(VendorNo: Code[20]; EmailAddress: Text[80]; EmailConsent: Boolean)
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(VendorNo);
        Vendor."E-Mail" := EmailAddress;
        Vendor."Receiving 1099 E-Form Consent" := EmailConsent;
        Vendor.Modify();
    end;

    [RequestPageHandler]
    procedure SendEmailReqPageHandler(var IRS1099SendEmail: TestRequestPage "IRS 1099 Send Email")
    begin
        IRS1099SendEmail.ReportTypeField.SetValue(Enum::"IRS 1099 Email Report Type"::"Copy B");
        IRS1099SendEmail.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryVariableStorage.Enqueue(Question);
        Reply := true;
    end;
}