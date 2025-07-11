codeunit 139873 "P. & P. Permissions Tests"
{
    Subtype = Test;
    TestPermissions = Restrictive;
    
    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        Assert: Codeunit Assert;
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        PAndPqoircPermissionSetTxt: Label 'P&P-Q/O/I/R/C';

    [Test]
    [Scope('OnPrem')]
    procedure PurchaseInvoiceLineLimitedPermissionCreation()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        StandardText: Record "Standard Text";
        MyNotifications: Record "My Notifications";
        PostingSetupManagement: Codeunit PostingSetupManagement;
    begin
        // [FEATURE] [Permissions]
        // [SCENARIO 325667] Purchase Line without type is added when user has limited permissions.

        // [GIVEN] Standard text.
        LibrarySales.CreateStandardText(StandardText);
        // [GIVEN] Enabled notification about missing G/L account.
        MyNotifications.InsertDefault(PostingSetupManagement.GetPostingSetupNotificationID(), '', '', true);
        // [GIVEN] Purchase header.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, CreateVendor(''));
        // [GIVEN] Permisson to create purchase invoices.
        LibraryLowerPermissions.PushPermissionSet(PAndPqoircPermissionSetTxt);

        // [WHEN] Add Purchase Line with standard text, but without type.
        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        PurchaseLine.Validate("No.", StandardText.Code);
        PurchaseLine.Insert(true);

        // [THEN] Purchase line is created.
        Assert.RecordIsNotEmpty(PurchaseLine);
    end;

    local procedure CreateVendor(CurrencyCode: Code[10]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Currency Code", CurrencyCode);
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;
}