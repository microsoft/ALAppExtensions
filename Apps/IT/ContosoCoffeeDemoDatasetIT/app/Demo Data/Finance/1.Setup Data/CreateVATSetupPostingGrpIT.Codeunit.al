codeunit 12252 "Create VATSetupPostingGrp. IT"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"VAT Setup Posting Groups", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnBeforeInsertVatSetupPostingGroup(var Rec: Record "VAT Setup Posting Groups")
    var
        CreateVATPostingGroups: Codeunit "Create VAT Posting Groups";
        CreateITGLAccounts: Codeunit "Create IT GL Accounts";
    begin
        case Rec."VAT Prod. Posting Group" of
            CreateVATPostingGroups.FullNormal():
                Rec.Validate("VAT Prod. Posting Grp Desc.", StrSubstNo(VATOnlyInvoicesDescriptionLbl, '20'));
            CreateVATPostingGroups.ServNormal():
                Rec.Validate("VAT Prod. Posting Grp Desc.", StrSubstNo(MiscellaneousVATDescriptionLbl, '20'));
            CreateVATPostingGroups.Standard():
                ValidateRecordFields(Rec, CreateITGLAccounts.SalesVat20Perc(), CreateITGLAccounts.PurchaseVat20Perc(), 20);
            CreateVATPostingGroups.Zero():
                ValidateRecordFields(Rec, CreateITGLAccounts.SalesVat20Perc(), CreateITGLAccounts.PurchaseVat20Perc(), 0);
        end;
    end;

    local procedure ValidateRecordFields(var VATSetupPostingGroups: Record "VAT Setup Posting Groups"; SalesVATAccount: Code[20]; PurchaseVATAccount: Code[20]; VATPerc: Decimal)
    begin
        VATSetupPostingGroups.Validate("Sales VAT Account", SalesVATAccount);
        VATSetupPostingGroups.Validate("Purchase VAT Account", PurchaseVATAccount);
        VATSetupPostingGroups.Validate("VAT %", VATPerc);
    end;

    var
        VATOnlyInvoicesDescriptionLbl: Label 'VAT Only Invoices %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        MiscellaneousVATDescriptionLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
}