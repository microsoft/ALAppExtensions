codeunit 148016 "Digital Vouchers Tests DK"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;
    TestPermissions = Disabled;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        NotAllowedToChangeWhenEnforcedErr: Label 'You are not allowed to change make this change when the feature is enforced.';
        CannotChangeEnforcedAppErr: Label 'You cannot perform this action because the Digital Voucher functionality is enforced in your application.';

    trigger OnRun()
    begin

    end;

    [Test]
    procedure AssistedSetupDoesNotExistForEnforcedDigitalVoucherFeature()
    var
        GuidedExperience: Codeunit "Guided Experience";
        DigVouchersEnableEnforce: Codeunit "Dig. Vouchers Enable Enforce";
        AssistedSetupPage: TestPage "Assisted Setup";
        GuidedExperienceType: Enum "Guided Experience Type";
    begin
        // [SCENARIO 475787] Digital voucher feature does not exist in the assisted setup when it is enforced

        Initialize();
        // [GIVEN] Enforce digital voucher feature
        BindSubscription(DigVouchersEnableEnforce);
        // [WHEN] Open Assisted Setup page
        AssistedSetupPage.OpenView();
        AssistedSetupPage.Close();
        // [THEN] Digital voucher feature is not available for the setup
        Assert.IsFalse(GuidedExperience.Exists(GuidedExperienceType::"Assisted Setup", ObjectType::Page, Page::"Digital Voucher Guide"), 'Aassisted setup for digital voucher feature found');

        UnbindSubscription(DigVouchersEnableEnforce);
    end;

    [Test]
    procedure DefaultDigitalVoucherEntrySetupList()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
    begin
        // [SCENARIO 475787] Digital Voucher Setup record created when Stan open the Digital Voucher Setup page

        Initialize();
        // [GIVEN] There are 5 Digital Voucher Entry Setup records
        Assert.RecordCount(DigitalVoucherEntrySetup, 5);
        // [GIVEN] For purchase document, sales document, general journal, purchase journal and sales journal
        DigitalVoucherEntrySetup.Get(DigitalVoucherEntrySetup."Entry Type"::"Purchase Document");
        DigitalVoucherEntrySetup.TestField("Check Type", DigitalVoucherEntrySetup."Check Type"::Attachment);
        DigitalVoucherEntrySetup.Get(DigitalVoucherEntrySetup."Entry Type"::"Sales Document");
        DigitalVoucherEntrySetup.TestField("Check Type", DigitalVoucherEntrySetup."Check Type"::Attachment);
        DigitalVoucherEntrySetup.Get(DigitalVoucherEntrySetup."Entry Type"::"General Journal");
        DigitalVoucherEntrySetup.TestField("Check Type", DigitalVoucherEntrySetup."Check Type"::"No Check");
        DigitalVoucherEntrySetup.Get(DigitalVoucherEntrySetup."Entry Type"::"Purchase Journal");
        DigitalVoucherEntrySetup.TestField("Check Type", DigitalVoucherEntrySetup."Check Type"::Attachment);
        DigitalVoucherEntrySetup.Get(DigitalVoucherEntrySetup."Entry Type"::"Sales Journal");
        DigitalVoucherEntrySetup.TestField("Check Type", DigitalVoucherEntrySetup."Check Type"::"No Check");
    end;

    [Test]
    procedure CannotDisableDigitalVoucherSetup()
    var
        DigitalVoucherSetup: Record "Digital Voucher Setup";
        DigVouchersEnableEnforce: Codeunit "Dig. Vouchers Enable Enforce";
    begin
        // [SCENARIO 475787] Stan cannot disable enforced the digital voucher feature

        Initialize();
        // [GIVEN] Enforce digital voucher feature
        BindSubscription(DigVouchersEnableEnforce);
        DigitalVoucherSetup.InitSetup();
        DigitalVoucherSetup.Validate(Enabled, false);
        // [WHEN] Disable feature from the Digital Voucher Setup        
        asserterror DigitalVoucherSetup.Modify(true);
        // [THEN] Error message "You cannot perform this action because feature is enforced" is shown
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(CannotChangeEnforcedAppErr);
        UnbindSubscription(DigVouchersEnableEnforce);
    end;

    [Test]
    procedure CannotDeleteDigitalVoucherSetup()
    var
        DigitalVoucherSetup: Record "Digital Voucher Setup";
        DigVouchersEnableEnforce: Codeunit "Dig. Vouchers Enable Enforce";
    begin
        // [SCENARIO 475787] Stan cannot delete digital voucher setup for enforced feature

        Initialize();
        // [GIVEN] Enforce digital voucher feature
        BindSubscription(DigVouchersEnableEnforce);
        // [WHEN] Delete digital voucher setup
        asserterror DigitalVoucherSetup.Delete(true);
        // [THEN] Error message "You cannot perform this action because feature is enforced" is shown
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(CannotChangeEnforcedAppErr);
        UnbindSubscription(DigVouchersEnableEnforce);
    end;

    [Test]
    procedure ChangeCheckTypeForGeneralJournalWhenEnforced()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        DigVouchersEnableEnforce: Codeunit "Dig. Vouchers Enable Enforce";
        DigitalVoucherEntrySetupPage: TestPage "Digital Voucher Entry Setup";
    begin
        // [SCENARIO 493264] Stan can change the check type for general journal when the feature is enforced

        Initialize();
        BindSubscription(DigVouchersEnableEnforce);
        DigitalVoucherEntrySetupPage.OpenEdit();
        DigitalVoucherEntrySetupPage.Filter.SetFilter("Entry Type", Format(DigitalVoucherEntrySetup."Entry Type"::"General Journal"));
        DigitalVoucherEntrySetupPage."Check Type".SetValue(Format(DigitalVoucherEntrySetup."Check Type"::"No Check"));
        DigitalVoucherEntrySetupPage.Close();
        DigitalVoucherEntrySetup.Get(DigitalVoucherEntrySetup."Entry Type"::"General Journal");
        DigitalVoucherEntrySetup.TestField("Check Type", DigitalVoucherEntrySetup."Check Type"::"No Check");
        UnbindSubscription(DigVouchersEnableEnforce);
    end;

    [Test]
    procedure ChangeCheckTypeForSalesJournalWhenEnforced()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        DigVouchersEnableEnforce: Codeunit "Dig. Vouchers Enable Enforce";
        DigitalVoucherEntrySetupPage: TestPage "Digital Voucher Entry Setup";
    begin
        // [SCENARIO 493264] Stan can change the check type for sales journal when the feature is enforced

        Initialize();
        BindSubscription(DigVouchersEnableEnforce);
        DigitalVoucherEntrySetupPage.OpenEdit();
        DigitalVoucherEntrySetupPage.Filter.SetFilter("Entry Type", Format(DigitalVoucherEntrySetup."Entry Type"::"Sales Journal"));
        DigitalVoucherEntrySetupPage."Check Type".SetValue(Format(DigitalVoucherEntrySetup."Check Type"::"No Check"));
        DigitalVoucherEntrySetupPage.Close();
        DigitalVoucherEntrySetup.Get(DigitalVoucherEntrySetup."Entry Type"::"Sales Journal");
        DigitalVoucherEntrySetup.TestField("Check Type", DigitalVoucherEntrySetup."Check Type"::"No Check");
        UnbindSubscription(DigVouchersEnableEnforce);
    end;

    [Test]
    procedure CannotChangeCheckTypeForPurchaseJournalWhenEnforced()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        DigVouchersEnableEnforce: Codeunit "Dig. Vouchers Enable Enforce";
        DigitalVoucherEntrySetupPage: TestPage "Digital Voucher Entry Setup";
    begin
        // [SCENARIO 493264] Stan cannot change the check type for purchase journal when the feature is enforced

        Initialize();
        BindSubscription(DigVouchersEnableEnforce);
        DigitalVoucherEntrySetupPage.OpenEdit();
        DigitalVoucherEntrySetupPage.Filter.SetFilter("Entry Type", Format(DigitalVoucherEntrySetup."Entry Type"::"Purchase Journal"));
        DigitalVoucherEntrySetupPage."Check Type".SetValue(Format(DigitalVoucherEntrySetup."Check Type"::"No Check"));
        asserterror DigitalVoucherEntrySetupPage.Close();
        Assert.ExpectedError(NotAllowedToChangeWhenEnforcedErr);
        UnbindSubscription(DigVouchersEnableEnforce);
    end;

    [Test]
    procedure CannotChangeCheckTypeForPurchaseDocumentWhenEnforced()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        DigVouchersEnableEnforce: Codeunit "Dig. Vouchers Enable Enforce";
        DigitalVoucherEntrySetupPage: TestPage "Digital Voucher Entry Setup";
    begin
        // [SCENARIO 493264] Stan cannot change the check type for purchase document when the feature is enforced

        Initialize();
        BindSubscription(DigVouchersEnableEnforce);
        DigitalVoucherEntrySetupPage.OpenEdit();
        DigitalVoucherEntrySetupPage.Filter.SetFilter("Entry Type", Format(DigitalVoucherEntrySetup."Entry Type"::"Purchase Document"));
        DigitalVoucherEntrySetupPage."Check Type".SetValue(Format(DigitalVoucherEntrySetup."Check Type"::"No Check"));
        asserterror DigitalVoucherEntrySetupPage.Close();
        Assert.ExpectedError(NotAllowedToChangeWhenEnforcedErr);
        UnbindSubscription(DigVouchersEnableEnforce);
    end;

    [Test]
    procedure CannotChangeCheckTypeForSalesDocumentWhenEnforced()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        DigVouchersEnableEnforce: Codeunit "Dig. Vouchers Enable Enforce";
        DigitalVoucherEntrySetupPage: TestPage "Digital Voucher Entry Setup";
    begin
        // [SCENARIO 493264] Stan cannot change the check type for sales document when the feature is enforced

        Initialize();
        BindSubscription(DigVouchersEnableEnforce);
        DigitalVoucherEntrySetupPage.OpenEdit();
        DigitalVoucherEntrySetupPage.Filter.SetFilter("Entry Type", Format(DigitalVoucherEntrySetup."Entry Type"::"Sales Document"));
        DigitalVoucherEntrySetupPage."Check Type".SetValue(Format(DigitalVoucherEntrySetup."Check Type"::"No Check"));
        asserterror DigitalVoucherEntrySetupPage.Close();
        Assert.ExpectedError(NotAllowedToChangeWhenEnforcedErr);
        UnbindSubscription(DigVouchersEnableEnforce);
    end;

    [Test]
    procedure CannotChangeGenerateAutomaticallyForPurchaseJournalWhenEnforced()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        DigVouchersEnableEnforce: Codeunit "Dig. Vouchers Enable Enforce";
        DigitalVoucherEntrySetupPage: TestPage "Digital Voucher Entry Setup";
    begin
        // [SCENARIO 493264] Stan cannot change the generate automatically option for purchase journal when the feature is enforced

        Initialize();
        BindSubscription(DigVouchersEnableEnforce);
        DigitalVoucherEntrySetupPage.OpenEdit();
        DigitalVoucherEntrySetupPage.Filter.SetFilter("Entry Type", Format(DigitalVoucherEntrySetup."Entry Type"::"Purchase Journal"));
        DigitalVoucherEntrySetupPage."Generate Automatically".SetValue(true);
        asserterror DigitalVoucherEntrySetupPage.Close();
        Assert.ExpectedError(NotAllowedToChangeWhenEnforcedErr);
        UnbindSubscription(DigVouchersEnableEnforce);
    end;

    [Test]
    procedure CannotChangeGenerateAutomaticallyForPurchaseDocumentWhenEnforced()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        DigVouchersEnableEnforce: Codeunit "Dig. Vouchers Enable Enforce";
        DigitalVoucherEntrySetupPage: TestPage "Digital Voucher Entry Setup";
    begin
        // [SCENARIO 493264] Stan cannot change the generate automatically option for purchase document when the feature is enforced

        Initialize();
        BindSubscription(DigVouchersEnableEnforce);
        DigitalVoucherEntrySetupPage.OpenEdit();
        DigitalVoucherEntrySetupPage.Filter.SetFilter("Entry Type", Format(DigitalVoucherEntrySetup."Entry Type"::"Purchase Document"));
        DigitalVoucherEntrySetupPage."Generate Automatically".SetValue(true);
        asserterror DigitalVoucherEntrySetupPage.Close();
        Assert.ExpectedError(NotAllowedToChangeWhenEnforcedErr);
        UnbindSubscription(DigVouchersEnableEnforce);
    end;

    [Test]
    procedure ChangeGenerateAutomaticallyForSalesDocumentWhenEnforced()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        DigVouchersEnableEnforce: Codeunit "Dig. Vouchers Enable Enforce";
        DigitalVoucherEntrySetupPage: TestPage "Digital Voucher Entry Setup";
    begin
        // [SCENARIO 493264] Stan can change the generate automatically option for sales document when the feature is enforced

        Initialize();
        BindSubscription(DigVouchersEnableEnforce);
        DigitalVoucherEntrySetupPage.OpenEdit();
        DigitalVoucherEntrySetupPage.Filter.SetFilter("Entry Type", Format(DigitalVoucherEntrySetup."Entry Type"::"Sales Document"));
        DigitalVoucherEntrySetupPage."Generate Automatically".SetValue(true);
        DigitalVoucherEntrySetupPage.Close();
        DigitalVoucherEntrySetup.Get(DigitalVoucherEntrySetup."Entry Type"::"Sales Document");
        DigitalVoucherEntrySetup.TestField("Generate Automatically", true);
        UnbindSubscription(DigVouchersEnableEnforce);
    end;

    [Test]
    procedure ChangeGenerateAutomaticallyForSalesJournalWhenEnforced()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        DigVouchersEnableEnforce: Codeunit "Dig. Vouchers Enable Enforce";
        DigitalVoucherEntrySetupPage: TestPage "Digital Voucher Entry Setup";
    begin
        // [SCENARIO 493264] Stan can change the generate automatically option for sales journal when the feature is enforced

        Initialize();
        BindSubscription(DigVouchersEnableEnforce);
        DigitalVoucherEntrySetupPage.OpenEdit();
        DigitalVoucherEntrySetupPage.Filter.SetFilter("Entry Type", Format(DigitalVoucherEntrySetup."Entry Type"::"Sales Journal"));
        DigitalVoucherEntrySetupPage."Generate Automatically".SetValue(true);
        DigitalVoucherEntrySetupPage.Close();
        DigitalVoucherEntrySetup.Get(DigitalVoucherEntrySetup."Entry Type"::"Sales Journal");
        DigitalVoucherEntrySetup.TestField("Generate Automatically", true);
        UnbindSubscription(DigVouchersEnableEnforce);
    end;

    [Test]
    procedure ChangeGenerateAutomaticallyForGeneralJournalWhenEnforced()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        DigVouchersEnableEnforce: Codeunit "Dig. Vouchers Enable Enforce";
        DigitalVoucherEntrySetupPage: TestPage "Digital Voucher Entry Setup";
    begin
        // [SCENARIO 493264] Stan can change the generate automatically option for general journal when the feature is enforced

        Initialize();
        BindSubscription(DigVouchersEnableEnforce);
        DigitalVoucherEntrySetupPage.OpenEdit();
        DigitalVoucherEntrySetupPage.Filter.SetFilter("Entry Type", Format(DigitalVoucherEntrySetup."Entry Type"::"General Journal"));
        DigitalVoucherEntrySetupPage."Generate Automatically".SetValue(true);
        DigitalVoucherEntrySetupPage.Close();
        DigitalVoucherEntrySetup.Get(DigitalVoucherEntrySetup."Entry Type"::"General Journal");
        DigitalVoucherEntrySetup.TestField("Generate Automatically", true);
        UnbindSubscription(DigVouchersEnableEnforce);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Digital Vouchers Tests DK");
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Digital Vouchers Tests DK");

        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Digital Vouchers Tests DK");
    end;
}