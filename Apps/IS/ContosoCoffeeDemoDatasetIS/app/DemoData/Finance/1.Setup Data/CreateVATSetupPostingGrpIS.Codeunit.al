codeunit 14632 "Create VAT Setup PostingGrpIS"
{
    SingleInstance = true;
    EventSubscriberInstance = Manual;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Table, Database::"VAT Setup Posting Groups", 'OnBeforeInsertEvent', '', false, false)]
    local procedure OnbeforeInsertVatReportingSetup(var Rec: Record "VAT Setup Posting Groups")
    var
        CreateVatPostingGroup: Codeunit "Create VAT Posting Groups";
    begin
        case Rec."VAT Prod. Posting Group" of
            CreateVatPostingGroup.FullNormal():
                Rec.Validate("VAT Prod. Posting Grp Desc.", StrSubstNo(VATOnlyInvoicesDescriptionLbl, '24'));
            CreateVatPostingGroup.ServNormal():
                Rec.Validate("VAT Prod. Posting Grp Desc.", StrSubstNo(MiscellaneousVATDescriptionLbl, '24'));
            CreateVatPostingGroup.Standard():
                Rec.Validate("VAT %", 24);
        end;
    end;

    var
        VATOnlyInvoicesDescriptionLbl: Label 'VAT Only Invoices %1%', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
        MiscellaneousVATDescriptionLbl: Label 'Miscellaneous %1 VAT', Comment = '%1=a number specifying the VAT percentage', MaxLength = 100;
}