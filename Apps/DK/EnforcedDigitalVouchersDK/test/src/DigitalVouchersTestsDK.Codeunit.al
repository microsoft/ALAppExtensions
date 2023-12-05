codeunit 148016 "Digital Vouchers Tests DK"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;
    TestPermissions = Disabled;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        NotAllowedToChangeDigitalVoucherEntrySetupErr: Label 'You are not allowed to change the Digital Voucher Entry Setup for this entry type.';
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
        DigitalVoucherEntrySetup.TestField("Check Type", DigitalVoucherEntrySetup."Check Type"::Attachment);
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
    procedure EditDigitalVoucherEntrySetup()
    var
        DigitalVoucherEntrySetup: Record "Digital Voucher Entry Setup";
        DigVouchersEnableEnforce: Codeunit "Dig. Vouchers Enable Enforce";
    begin
        // [SCENARIO 475787] Stan can either edit or not edit certain digital voucher entry setup

        Initialize();
        BindSubscription(DigVouchersEnableEnforce);

        DigitalVoucherEntrySetup.Get(DigitalVoucherEntrySetup."Entry Type"::"General Journal");
        DigitalVoucherEntrySetup.Validate("Check Type", DigitalVoucherEntrySetup."Check Type"::"No Check");
        DigitalVoucherEntrySetup.TestField("Check Type", DigitalVoucherEntrySetup."Check Type"::"No Check");

        DigitalVoucherEntrySetup.Get(DigitalVoucherEntrySetup."Entry Type"::"Sales Journal");
        DigitalVoucherEntrySetup.Validate("Check Type", DigitalVoucherEntrySetup."Check Type"::"No Check");
        DigitalVoucherEntrySetup.TestField("Check Type", DigitalVoucherEntrySetup."Check Type"::"No Check");

        DigitalVoucherEntrySetup.Get(DigitalVoucherEntrySetup."Entry Type"::"Purchase Journal");
        DigitalVoucherEntrySetup.Validate("Check Type", DigitalVoucherEntrySetup."Check Type"::"No Check");
        asserterror DigitalVoucherEntrySetup.Modify(true);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(NotAllowedToChangeDigitalVoucherEntrySetupErr);

        DigitalVoucherEntrySetup.Get(DigitalVoucherEntrySetup."Entry Type"::"Sales Document");
        DigitalVoucherEntrySetup.Validate("Check Type", DigitalVoucherEntrySetup."Check Type"::"No Check");
        asserterror DigitalVoucherEntrySetup.Modify(true);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(NotAllowedToChangeDigitalVoucherEntrySetupErr);

        DigitalVoucherEntrySetup.Get(DigitalVoucherEntrySetup."Entry Type"::"Purchase Document");
        DigitalVoucherEntrySetup.Validate("Check Type", DigitalVoucherEntrySetup."Check Type"::"No Check");
        asserterror DigitalVoucherEntrySetup.Modify(true);
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(NotAllowedToChangeDigitalVoucherEntrySetupErr);

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