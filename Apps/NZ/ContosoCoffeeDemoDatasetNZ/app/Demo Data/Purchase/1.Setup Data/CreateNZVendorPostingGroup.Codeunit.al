codeunit 17134 "Create NZ Vendor Posting Group"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoPostingGroup: Codeunit "Contoso Posting Group";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreatePostingGroups: Codeunit "Create Posting Groups";
    begin
        ContosoPostingGroup.InsertVendorPostingGroup(CreatePostingGroups.MiscPostingGroup(), CreateGLAccount.VendorsForeign(), CreateGLAccount.OtherCostsofOperations(), CreateGLAccount.PmtDiscReceivedDecreases(), CreateGLAccount.InvoiceRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.ApplicationRounding(), CreateGLAccount.PaymentDiscountsReceived(), CreateGLAccount.PmtTolReceivedDecreases(), CreateGLAccount.PaymentToleranceReceived(), MiscVendorsLbl, false);
    end;

    var
        MiscVendorsLbl: Label 'Vendors in EU', MaxLength = 100;
}