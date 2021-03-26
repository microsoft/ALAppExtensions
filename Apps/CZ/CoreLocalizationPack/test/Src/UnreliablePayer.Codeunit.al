#pragma warning disable AL0432
codeunit 148052 "Unreliable Payer CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
#if not CLEAN17
        ElectronicallyGovernSetup: Record "Electronically Govern. Setup";
#endif
        UnrelPayerServiceSetupCZL: Record "Unrel. Payer Service Setup CZL";
        UnreliablePayerEntryCZL: Record "Unreliable Payer Entry CZL";
        LibraryDialogHandler: Codeunit "Library - Dialog Handler";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
        isInitialized: Boolean;
        PurchaseLineType: Enum "Purchase Line Type";
        BankAccCodeNotExistQst: Label 'There is no bank account code in the document.\\Do you want to continue?';
        VendUnrVATPayerStatusNotCheckedQst: Label 'The unreliability VAT payer status has not been checked for vendor %1 (%2).\\Do you want to continue?', Comment = '%1=Vendor No.;%2=VAT Registration No.';
        VendUnrVATPayerQst: Label 'The vendor %1 (%2) is unreliable VAT payer.\\Do you want to continue?', Comment = '%1=Vendor No.;%2=VAT Registration No.';

    local procedure Initialize();
    var
        UnreliablePayerMgtCZL: Codeunit "Unreliable Payer Mgt. CZL";
    begin
        UnreliablePayerEntryCZL.Reset();
        UnreliablePayerEntryCZL.DeleteAll();
        LibraryRandom.Init();
        LibraryDialogHandler.ClearVariableStorage();
        if isInitialized then
            exit;

        UnrelPayerServiceSetupCZL.DeleteAll();
        UnrelPayerServiceSetupCZL.Init();
        UnrelPayerServiceSetupCZL.Enabled := true;
        UnrelPayerServiceSetupCZL."Unreliable Payer Web Service" := UnreliablePayerMgtCZL.GetUnreliablePayerServiceURL();
        UnrelPayerServiceSetupCZL."Public Bank Acc.Chck.Star.Date" := 20900101D;
        UnrelPayerServiceSetupCZL.Insert();

#if not CLEAN17
        if ElectronicallyGovernSetup.Get() then begin
            ElectronicallyGovernSetup.UncertaintyPayerWebService := '';
            ElectronicallyGovernSetup.Modify(false);
        end;

#endif
        isInitialized := true;
        Commit();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure ReleasePurchInvNewVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [FEATURE] Unreliable Payer
        Initialize();

        // [GIVEN] New Vendor created, no check performed
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."VAT Registration No." := 'CZ12345671';
        Vendor.Modify(false);

        // [GIVEN] New Purchase Invoice created
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");

        // [GIVEN] New Purchase Invoice Line created
        LibraryERM.CreateGLAccountWithPurchSetup();
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::"G/L Account",
            LibraryERM.CreateGLAccountWithPurchSetup(), LibraryRandom.RandDecInRange(1, 99, 2));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1, 100, 2));
        PurchaseLine.Modify(true);
        Commit();

        // [WHEN] Release Purchase Invoice
        SetExpectedConfirm(StrSubstNo(VendUnrVATPayerStatusNotCheckedQst, Vendor."No.", Vendor."VAT Registration No."), true);
        SetExpectedConfirm(BankAccCodeNotExistQst, true);
        ReleasePurchaseDocument.Run(PurchaseHeader);

        // [THEN] Purchase Invoice is released
        Assert.AreEqual(PurchaseHeader.Status, PurchaseHeader.Status::Released, PurchaseHeader.TableCaption());
    end;

    [Test]
    procedure ReleasePurchInvReliableVendor()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [FEATURE] Unreliable Payer
        Initialize();

        // [GIVEN] New Vendor created
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."VAT Registration No." := 'CZ12345672';
        Vendor.Modify(false);

        // [GIVEN] New Purchase Invoice created
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");

        // [GIVEN] New Purchase Invoice Line created
        LibraryERM.CreateGLAccountWithPurchSetup();
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::"G/L Account",
            LibraryERM.CreateGLAccountWithPurchSetup(), LibraryRandom.RandDecInRange(10, 99, 2));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1000, 2000, 2));
        PurchaseLine.Modify(true);
        // [GIVEN] Unreliable Payer Entry exists, Vendor is reliable
        UnreliablePayerEntryCZL.Init();
        UnreliablePayerEntryCZL."Entry No." := LibraryRandom.RandInt(1000);
        UnreliablePayerEntryCZL."Vendor No." := Vendor."No.";
        UnreliablePayerEntryCZL."Check Date" := WorkDate();
        UnreliablePayerEntryCZL."Unreliable Payer" := UnreliablePayerEntryCZL."Unreliable Payer"::NO;
        UnreliablePayerEntryCZL."Entry Type" := UnreliablePayerEntryCZL."Entry Type"::Payer;
        UnreliablePayerEntryCZL."VAT Registration No." := Vendor."VAT Registration No.";
        UnreliablePayerEntryCZL.Insert();
        Commit();

        // [WHEN] Release Purchase Invoice
        SetExpectedConfirm(BankAccCodeNotExistQst, true);
        ReleasePurchaseDocument.Run(PurchaseHeader);

        // [THEN] Purchase Invoice is released
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
        // [FEATURE] Unreliable Payer
        Initialize();

        // [GIVEN] New Vendor created
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."VAT Registration No." := 'CZ12345673';
        Vendor.Modify(false);

        // [GIVEN] New Purchase Invoice created
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");

        // [GIVEN] New Purchase Invoice Line created
        LibraryERM.CreateGLAccountWithPurchSetup();
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::"G/L Account",
            LibraryERM.CreateGLAccountWithPurchSetup(), LibraryRandom.RandDecInRange(10, 99, 2));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1000, 2000, 2));
        PurchaseLine.Modify(true);
        // [GIVEN] Unreliable Payer Entry exists, Vendor is unreliable
        UnreliablePayerEntryCZL.Init();
        UnreliablePayerEntryCZL."Entry No." := LibraryRandom.RandInt(1000);
        UnreliablePayerEntryCZL."Vendor No." := Vendor."No.";
        UnreliablePayerEntryCZL."Check Date" := WorkDate();
        UnreliablePayerEntryCZL."Unreliable Payer" := UnreliablePayerEntryCZL."Unreliable Payer"::YES;
        UnreliablePayerEntryCZL."Entry Type" := UnreliablePayerEntryCZL."Entry Type"::Payer;
        UnreliablePayerEntryCZL."VAT Registration No." := Vendor."VAT Registration No.";
        UnreliablePayerEntryCZL.Insert();
        Commit();

        // [WHEN] Release Purchase Invoice
        SetExpectedConfirm(StrSubstNo(VendUnrVATPayerQst, Vendor."No.", Vendor."VAT Registration No."), true);
        SetExpectedConfirm(BankAccCodeNotExistQst, true);
        ReleasePurchaseDocument.Run(PurchaseHeader);

        // [THEN] Purchase Invoice is released
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
        // [FEATURE] Unreliable Payer
        Initialize();

        // [GIVEN] New Vendor created
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."VAT Registration No." := 'CZ12345674';
        Vendor.Modify(false);

        // [GIVEN] New Purchase Invoice created
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");

        // [GIVEN] New Purchase Invoice Line created
        LibraryERM.CreateGLAccountWithPurchSetup();
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::"G/L Account",
            LibraryERM.CreateGLAccountWithPurchSetup(), LibraryRandom.RandDecInRange(10, 99, 2));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1000, 2000, 2));
        PurchaseLine.Modify(true);
        // [GIVEN] Unreliable Payer Entry exists, Vendor is unreliable
        UnreliablePayerEntryCZL.Init();
        UnreliablePayerEntryCZL."Entry No." := LibraryRandom.RandInt(1000);
        UnreliablePayerEntryCZL."Vendor No." := Vendor."No.";
        UnreliablePayerEntryCZL."Check Date" := WorkDate();
        UnreliablePayerEntryCZL."Unreliable Payer" := UnreliablePayerEntryCZL."Unreliable Payer"::YES;
        UnreliablePayerEntryCZL."Entry Type" := UnreliablePayerEntryCZL."Entry Type"::Payer;
        UnreliablePayerEntryCZL."VAT Registration No." := Vendor."VAT Registration No.";
        UnreliablePayerEntryCZL.Insert();
        Commit();

        // [WHEN] Cancel Release Purchase Invoice
        SetExpectedConfirm(StrSubstNo(VendUnrVATPayerQst, Vendor."No.", Vendor."VAT Registration No."), false);
        asserterror ReleasePurchaseDocument.Run(PurchaseHeader);

        // [THEN] Purchase Invoice is not released
        Assert.AreEqual(PurchaseHeader.Status, PurchaseHeader.Status::Open, PurchaseHeader.TableCaption());
    end;

    [Test]
    procedure ReleasePurchInvUnreliableVendorDisabledCheck()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        // [FEATURE] Unreliable Payer
        Initialize();

        // [GIVEN] New Vendor created, unreliability check is disabled
        LibraryPurchase.CreateVendor(Vendor);
        Vendor."VAT Registration No." := 'CZ12345675';
        Vendor."Disable Unreliab. Check CZL" := true;
        Vendor.Modify(false);

        // [GIVEN] New Purchase Invoice created
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");

        // [GIVEN] New Purchase Invoice Line created
        LibraryERM.CreateGLAccountWithPurchSetup();
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::"G/L Account",
            LibraryERM.CreateGLAccountWithPurchSetup(), LibraryRandom.RandDecInRange(10, 99, 2));
        PurchaseLine.Validate("Direct Unit Cost", LibraryRandom.RandDecInRange(1000, 2000, 2));
        PurchaseLine.Modify(true);
        // [GIVEN] Unreliable Payer Entry exists
        UnreliablePayerEntryCZL.Init();
        UnreliablePayerEntryCZL."Entry No." := LibraryRandom.RandInt(1000);
        UnreliablePayerEntryCZL."Vendor No." := Vendor."No.";
        UnreliablePayerEntryCZL."Check Date" := WorkDate();
        UnreliablePayerEntryCZL."Unreliable Payer" := UnreliablePayerEntryCZL."Unreliable Payer"::YES;
        UnreliablePayerEntryCZL."Entry Type" := UnreliablePayerEntryCZL."Entry Type"::Payer;
        UnreliablePayerEntryCZL."VAT Registration No." := Vendor."VAT Registration No.";
        UnreliablePayerEntryCZL.Insert();
        Commit();

        // [WHEN] Release Purchase Invoice
        ReleasePurchaseDocument.Run(PurchaseHeader);

        // [THEN] Purchase Invoice is released
        Assert.AreEqual(PurchaseHeader.Status, PurchaseHeader.Status::Released, PurchaseHeader.TableCaption());
    end;

    local procedure SetExpectedConfirm(Question: Text; Reply: Boolean)
    begin
        LibraryDialogHandler.SetExpectedConfirm(Question, Reply);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        LibraryDialogHandler.HandleConfirm(Question, Reply);
    end;
}
