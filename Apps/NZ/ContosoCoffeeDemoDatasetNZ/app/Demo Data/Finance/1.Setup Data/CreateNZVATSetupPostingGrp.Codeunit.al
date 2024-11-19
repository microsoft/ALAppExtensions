codeunit 17123 "Create NZ VAT Setup PostingGrp"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnRun()
    begin
        CreateVatSetupPostingGrp();
        CreateVATAssistedSetupGrp();
        UpdateVatReportSetup();
    end;

    local procedure CreateVatSetupPostingGrp()
    var
        VATSetupPostingGroups: Record "VAT Setup Posting Groups";
        CreateGLAccount: Codeunit "Create G/L Account";
        CreateNZGLAccounts: Codeunit "Create NZ GL Accounts";
        CreateNZVatPostingGroup: Codeunit "Create NZ VAT Posting Group";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
    begin
        ContosoVATStatement.SetOverwriteData(true);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateNZVatPostingGroup.NoVAT(), true, 0, CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), true, VATSetupPostingGroups."Application Type"::Items, NoVatDescriptionLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateNZVatPostingGroup.VAT15(), true, 15, CreateNZGLAccounts.SalesVAT15Perc(), CreateNZGLAccounts.PurchaseVAT15Perc(), true, VATSetupPostingGroups."Application Type"::Items, Vat15DescriptionLbl);
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateNZVatPostingGroup.VAT9(), true, 9, CreateGLAccount.SalesVAT10(), CreateGLAccount.PurchaseVAT10EU(), true, VATSetupPostingGroups."Application Type"::Items, Vat9DescriptionLbl);
        ContosoVATStatement.SetOverwriteData(false);
    end;

    local procedure CreateVATAssistedSetupGrp()
    var
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
        CreateNZVATPostingGroup: Codeunit "Create NZ VAT Posting Group";
    begin
        ContosoVATStatement.InsertVATAssistedSetupBusGrp(CreateNZVATPostingGroup.MISC(), MiscPostingGroupDescriptionLbl, true, true);
    end;

    local procedure UpdateVatReportSetup()
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        VATReportSetup.Get();
        VATReportSetup.Validate("No. Series", '');
        VATReportSetup.Modify(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Assisted Setup Bus. Grp.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVATAssistedSetupBusGrp(var Rec: Record "VAT Assisted Setup Bus. Grp.")
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
    begin
        if Rec.Code = CreateVATPostingGroups.Export() then
            Rec.Validate(Description, ExportDescriptionLbl);
    end;

    var
        NoVatDescriptionLbl: Label 'Setup for MISC / NO VAT', MaxLength = 100;
        Vat15DescriptionLbl: Label 'Setup for MISC / VAT15', MaxLength = 100;
        Vat9DescriptionLbl: Label 'Setup for MISC / VAT9', MaxLength = 100;
        MiscPostingGroupDescriptionLbl: Label 'Customers and vendors in MISC', MaxLength = 100;
        ExportDescriptionLbl: Label 'Other customers and vendors (not MISC)', MaxLength = 100;
}