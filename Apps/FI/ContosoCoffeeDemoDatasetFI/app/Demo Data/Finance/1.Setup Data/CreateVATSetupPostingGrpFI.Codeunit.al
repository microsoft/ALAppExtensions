codeunit 13449 "Create VATSetupPostingGrp. FI"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        VatSetupPostingGroup: Record "VAT Setup Posting Groups";
        ContosoVATStatement: Codeunit "Contoso VAT Statement";
        CreateVatPostingGroupsFI: Codeunit "Create Vat Posting Groups FI";
        CreateFIGLAccounts: Codeunit "Create FI GL Accounts";
    begin
        ContosoVATStatement.InsertVatSetupPostingGrp(CreateVatPostingGroupsFI.VAT8(), true, 8, CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3(), true, VatSetupPostingGroup."Application Type"::Items, Vat8DescriptionLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Setup Posting Groups", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVatSetupPostingGroup(var Rec: Record "VAT Setup Posting Groups")
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateFIGLAccounts: Codeunit "Create FI GL Accounts";
    begin
        case Rec."VAT Prod. Posting Group" of
            CreateVATPostingGroups.FullNormal():
                Rec.Validate("VAT Prod. Posting Grp Desc.", StrSubstNo(VATOnlyInvoicesDescriptionLbl, '24'));
            CreateVATPostingGroups.FullRed():
                Rec.Validate("VAT Prod. Posting Grp Desc.", StrSubstNo(VATOnlyInvoicesDescriptionLbl, '17'));
            CreateVATPostingGroups.ServNormal():
                Rec.Validate("VAT Prod. Posting Grp Desc.", StrSubstNo(MiscellaneousVATDescriptionLbl, '24'));
            CreateVATPostingGroups.ServRed():
                Rec.Validate("VAT Prod. Posting Grp Desc.", StrSubstNo(MiscellaneousVATDescriptionLbl, '17'));
            CreateVATPostingGroups.Reduced():
                ValidateRecordFields(Rec, 17, CreateFIGLAccounts.Deferredtaxliability10(), CreateFIGLAccounts.Deferredtaxreceivables3());
            CreateVATPostingGroups.Standard():
                ValidateRecordFields(Rec, 24, CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1());
            CreateVATPostingGroups.Zero():
                ValidateRecordFields(Rec, 0, CreateFIGLAccounts.Deferredtaxliability8(), CreateFIGLAccounts.Deferredtaxreceivables1());
        end;
    end;

    local procedure ValidateRecordFields(var VATSetupPostingGroups: Record "VAT Setup Posting Groups"; VatPercent: Decimal; SalesVatAccount: Code[20]; PurchaseVatAccount: Code[20])
    begin
        VATSetupPostingGroups.Validate("VAT %", VatPercent);
        VATSetupPostingGroups.Validate("Sales VAT Account", SalesVatAccount);
        VATSetupPostingGroups.Validate("Purchase VAT Account", PurchaseVatAccount);
    end;

    var
        VATOnlyInvoicesDescriptionLbl: Label 'VAT Only Invoices %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        MiscellaneousVATDescriptionLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        Vat8DescriptionLbl: Label 'Setup for EXPORT / VAT8', MaxLength = 100;
}