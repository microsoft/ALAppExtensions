codeunit 148052 "Unreliable Payer CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [Unreliable Payer]
        isInitialized := false;
    end;

    var
        UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
        LibraryDialogHandler: Codeunit "Library - Dialog Handler";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
        EntryNo: Integer;
        isInitialized: Boolean;
        VendorBankAccountCode: Code[20];
        VendorBankAccountName: Text[100];
        PurchaseLineType: Enum "Purchase Line Type";
        BankAccCodeNotExistQst: Label 'There is no bank account code in the document.\\Do you want to continue?';
        VendUnrVATPayerStatusNotCheckedQst: Label 'The unreliability VAT payer status has not been checked for vendor %1 (%2).\\Do you want to continue?', Comment = '%1=Vendor No.;%2=VAT Registration No.';
        VendUnrVATPayerQst: Label 'The vendor %1 (%2) is unreliable VAT payer.\\Do you want to continue?', Comment = '%1=Vendor No.;%2=VAT Registration No.';

    local procedure Initialize();
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Unreliable Payer CZL");
        UnreliablePayerEntryCZL.Reset();
        UnreliablePayerEntryCZL.DeleteAll();
        LibraryRandom.Init();
        LibraryDialogHandler.ClearVariableStorage();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Unreliable Payer CZL");

        UnrelPayerServiceSetupCZL.DeleteAll();
        UnrelPayerServiceSetupCZL.Init();
        UnrelPayerServiceSetupCZL.Enabled := true;
        UnreliablePayerMgtCZL.SetDefaultUnreliablePayerServiceURL(UnrelPayerServiceSetupCZL);
        UnrelPayerServiceSetupCZL."Public Bank Acc.Chck.Star.Date" := 20900101D;
        UnrelPayerServiceSetupCZL.Insert();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Unreliable Payer CZL");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ReleasePurchInvNewVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] Release Purchase Invoce to new Vendor
        Initialize();

        // [GIVEN] New Vendor has been created
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."VAT Registration No." := 'CZ12345671';
        Vendor.Modify(false);

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::"G/L Account",
            LibraryERM.CreateGLAccountWithPurchSetup(), 1);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1000, 2000, 2));
        PurchaseLine.Modify(true);
        Commit();

        // [WHEN] Release Purchase Invoice
        SetExpectedConfirm(StrSubstNo(VendUnrVATPayerStatusNotCheckedQst, Vendor."No.", Vendor."VAT Registration No."), true);
        SetExpectedConfirm(BankAccCodeNotExistQst, true);
        ReleasePurchaseDocument.Run(PurchaseHeader);

        // [THEN] Purchase Invoice will be released
        Assert.AreEqual(PurchaseHeader.Status, PurchaseHeader.Status::Released, PurchaseHeader.TableCaption());
    end;

    [Test]
    procedure ReleasePurchInvReliableVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] Release Purchase Invoce to reliable Vendor
        Initialize();

        // [GIVEN] New Vendor has been created
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."VAT Registration No." := 'CZ12345672';
        Vendor.Modify(false);

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::"G/L Account",
            LibraryERM.CreateGLAccountWithPurchSetup(), 1);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1000, 2000, 2));
        PurchaseLine.Modify(true);

        // [GIVEN] Unreliable Payer Entry has been created, Vendor is reliable
        CreateUnreliablePayerEntry(Vendor, UnreliablePayerEntryCZL."Unreliable Payer"::NO, UnreliablePayerEntryCZL."Entry Type"::Payer);
        Commit();

        // [WHEN] Release Purchase Invoice
        SetExpectedConfirm(BankAccCodeNotExistQst, true);
        ReleasePurchaseDocument.Run(PurchaseHeader);

        // [THEN] Purchase Invoice will be released
        Assert.AreEqual(PurchaseHeader.Status, PurchaseHeader.Status::Released, PurchaseHeader.TableCaption());
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ReleasePurchInvUnreliableVendorConfirmed()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] Release Purchase Invoice to unreliable Vendor with confirmation
        Initialize();

        // [GIVEN] New Vendor has been created
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."VAT Registration No." := 'CZ12345673';
        Vendor.Modify(false);

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::"G/L Account",
            LibraryERM.CreateGLAccountWithPurchSetup(), 1);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1000, 2000, 2));
        PurchaseLine.Modify(true);

        // [GIVEN] Unreliable Payer Entry has been created, Vendor is unreliable
        CreateUnreliablePayerEntry(Vendor, UnreliablePayerEntryCZL."Unreliable Payer"::YES, UnreliablePayerEntryCZL."Entry Type"::Payer);
        Commit();

        // [WHEN] Release Purchase Invoice
        SetExpectedConfirm(StrSubstNo(VendUnrVATPayerQst, Vendor."No.", Vendor."VAT Registration No."), true);
        SetExpectedConfirm(BankAccCodeNotExistQst, true);
        ReleasePurchaseDocument.Run(PurchaseHeader);

        // [THEN] Purchase Invoice will be released
        Assert.AreEqual(PurchaseHeader.Status, PurchaseHeader.Status::Released, PurchaseHeader.TableCaption());
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ReleasePurchInvUnreliableVendorNotConfirmed()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] Release Purchace Invoice to unreliable Vendor not confirmed
        Initialize();

        // [GIVEN] New Vendor has been created
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."VAT Registration No." := 'CZ12345674';
        Vendor.Modify(false);

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::"G/L Account",
            LibraryERM.CreateGLAccountWithPurchSetup(), LibraryRandom.RandDecInRange(10, 99, 2));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1000, 2000, 2));
        PurchaseLine.Modify(true);

        // [GIVEN] Unreliable Payer Entry has been created, Vendor is unreliable
        CreateUnreliablePayerEntry(Vendor, UnreliablePayerEntryCZL."Unreliable Payer"::YES, UnreliablePayerEntryCZL."Entry Type"::Payer);
        Commit();

        // [WHEN] Release Purchase Invoice
        SetExpectedConfirm(StrSubstNo(VendUnrVATPayerQst, Vendor."No.", Vendor."VAT Registration No."), false);
        asserterror ReleasePurchaseDocument.Run(PurchaseHeader);

        // [THEN] Purchase Invoice will be opened
        Assert.AreEqual(PurchaseHeader.Status, PurchaseHeader.Status::Open, PurchaseHeader.TableCaption());
    end;

    local procedure SetExpectedConfirm(Question: Text; Reply: Boolean)
    begin
        LibraryDialogHandler.SetExpectedConfirm(Question, Reply);
    end;

    [Test]
    procedure ReleasePurchInvUnreliableVendorDisabledCheck()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [SCENARIO] Release Purchase Invoice to unreliable Vendor with disabled check
        Initialize();

        // [GIVEN] New Vendor created, unreliability check is disabled
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."VAT Registration No." := 'CZ12345675';
        Vendor."Disable Unreliab. Check CZL" := true;
        Vendor.Modify(false);

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::"G/L Account",
            LibraryERM.CreateGLAccountWithPurchSetup(), 1);
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1000, 2000, 2));
        PurchaseLine.Modify(true);

        // [GIVEN] Unreliable Payer Entry has been created, Vendor is unreliable
        CreateUnreliablePayerEntry(Vendor, UnreliablePayerEntryCZL."Unreliable Payer"::YES, UnreliablePayerEntryCZL."Entry Type"::Payer);
        Commit();

        // [WHEN] Release Purchase Invoice
        ReleasePurchaseDocument.Run(PurchaseHeader);

        // [THEN] Purchase Invoice will be released
        Assert.AreEqual(PurchaseHeader.Status, PurchaseHeader.Status::Released, PurchaseHeader.TableCaption());
    end;

    [Test]
    [HandlerFunctions('GetVendBankAccCodeModalPageHandler')]
    procedure CreateBankAccountWithUnreliablePayerEntry()
    var
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        // [SCENARIO] Create Vendor Bank Account from Unreliable Payer Entry
        Initialize();

        // [GIVEN] New Vendor has been created with Country Code CZ
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."VAT Registration No." := 'CZ123456789';
        Vendor."Country/Region Code" := 'CZ';
        Vendor.Modify(false);

        // [GIVEN] Unreliable Payer Entry has been created for Payer
        CreateUnreliablePayerEntry(Vendor, UnreliablePayerEntryCZL."Unreliable Payer"::NO, UnreliablePayerEntryCZL."Entry Type"::Payer);
        Commit();

        // [GIVEN] Unreliable Payer Entry has been created for Bank Acount
        UnreliablePayerEntryCZL.Init();
        UnreliablePayerEntryCZL."Entry No." := GetNextEntryNo();
        UnreliablePayerEntryCZL."Vendor No." := Vendor."No.";
        UnreliablePayerEntryCZL."Check Date" := WorkDate();
        UnreliablePayerEntryCZL."Entry Type" := UnreliablePayerEntryCZL."Entry Type"::"Bank Account";
        UnreliablePayerEntryCZL."VAT Registration No." := Vendor."VAT Registration No.";
        UnreliablePayerEntryCZL."Public Date" := 20140401D;
        UnreliablePayerEntryCZL."Full Bank Account No." := '123/0100';
        UnreliablePayerEntryCZL."Bank Account No. Type" := UnreliablePayerEntryCZL."Bank Account No. Type"::Standard;
        UnreliablePayerEntryCZL.Insert();
        Commit();

        // [WHEN] Create Vendor Bank Account from Unreliable Payer Entry
        UnreliablePayerEntryCZL.CreateVendorBankAccountCZL(Vendor."No.");

        // [THEN] Vendor Bank Account will be created
        VendorBankAccount.Get(Vendor."No.", VendorBankAccountCode);

        // [THEN] Vendor Bank Account will have Bank Account No. from Unreliable Payer Entry
        Assert.AreEqual(UnreliablePayerEntryCZL."Full Bank Account No.", VendorBankAccount."Bank Account No.", VendorBankAccount.FieldCaption("Bank Account No."));

        // [THEN] Vendor Bank Account will be public
        Assert.AreEqual(true, VendorBankAccount.IsPublicBankAccountCZL(), 'Vendor Bank Account is not Public');
    end;

    [Test]
    procedure CreateBankAccountWithoutUnreliablePayerEntry()
    var
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        // [SCENARIO] Create Vendor Bank Account without Unreliable Payer Entry
        Initialize();

        // [GIVEN] New Vendor has been created with Country Code CZ
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."VAT Registration No." := 'CZ111111111';
        Vendor."Country/Region Code" := 'CZ';
        Vendor.Modify(false);

        // [GIVEN] Unreliable Payer Entry has been created, Vendor is reliable
        CreateUnreliablePayerEntry(Vendor, UnreliablePayerEntryCZL."Unreliable Payer"::NO, UnreliablePayerEntryCZL."Entry Type"::Payer);
        Commit();

        // [GIVEN] Unreliable Payer Entry has been created for Bank Acount
        UnreliablePayerEntryCZL.Init();
        UnreliablePayerEntryCZL."Entry No." := GetNextEntryNo();
        UnreliablePayerEntryCZL."Vendor No." := Vendor."No.";
        UnreliablePayerEntryCZL."Check Date" := WorkDate();
        UnreliablePayerEntryCZL."Entry Type" := UnreliablePayerEntryCZL."Entry Type"::"Bank Account";
        UnreliablePayerEntryCZL."VAT Registration No." := Vendor."VAT Registration No.";
        UnreliablePayerEntryCZL."Public Date" := 20140401D;
        UnreliablePayerEntryCZL."Full Bank Account No." := '245/0100';
        UnreliablePayerEntryCZL."Bank Account No. Type" := UnreliablePayerEntryCZL."Bank Account No. Type"::Standard;
        UnreliablePayerEntryCZL.Insert();
        Commit();

        // [WHEN] Vendor Bank Account is created
        VendorBankAccount.Init();
        VendorBankAccount."Vendor No." := Vendor."No.";
        VendorBankAccount.Code := CopyStr(LibraryRandom.RandText(2), 1, 2);
        VendorBankAccount.Name := CopyStr(LibraryRandom.RandText(20), 1, 20);
        VendorBankAccount."Bank Account No." := '245/0100';
        VendorBankAccount.Insert();

        // [THEN] Vendor Bank Account will be public
        Assert.AreEqual(true, VendorBankAccount.IsPublicBankAccountCZL(), 'Vendor Bank Account is not Public');
    end;

    local procedure CreateUnreliablePayerEntry(Vendor: Record Vendor; UnreliablePayer: Option; EntryType: Option)
    begin
        UnreliablePayerEntryCZL.Init();
        UnreliablePayerEntryCZL."Entry No." := GetNextEntryNo();
        UnreliablePayerEntryCZL."Vendor No." := Vendor."No.";
        UnreliablePayerEntryCZL."Check Date" := WorkDate();
        UnreliablePayerEntryCZL."Unreliable Payer" := UnreliablePayer;
        UnreliablePayerEntryCZL."Entry Type" := EntryType;
        UnreliablePayerEntryCZL."VAT Registration No." := Vendor."VAT Registration No.";
        UnreliablePayerEntryCZL.Insert();
    end;

    local procedure GetNextEntryNo(): Integer
    begin
        EntryNo += 1;
        exit(EntryNo);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryDialogHandler.HandleConfirm(Question, Reply);
    end;

    [ModalPageHandler]
    procedure GetVendBankAccCodeModalPageHandler(var GetVendBankAccCodeCZL: TestPage "Get Vend. Bank Acc. Code CZL")
    begin
        VendorBankAccountCode := CopyStr(LibraryRandom.RandText(2), 1, 2);
        VendorBankAccountName := CopyStr(LibraryRandom.RandText(20), 1, 20);
        GetVendBankAccCodeCZL.VendorBankAccCode.Value := VendorBankAccountCode;
        GetVendBankAccCodeCZL.VendorBankAccName.Value := VendorBankAccountName;
        GetVendBankAccCodeCZL.OK().Invoke();
    end;
}
