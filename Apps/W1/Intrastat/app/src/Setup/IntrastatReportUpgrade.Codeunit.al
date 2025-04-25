#pragma warning disable AA0247
codeunit 4815 "Intrastat Report Upgrade"
{
    Subtype = Upgrade;
    trigger OnUpgradePerCompany()
    var
        IntrastatReportSetup: Record "Intrastat Report Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetIntrastatDocumentVATIDUpgradeTag()) then
            exit;

        if IntrastatReportSetup.Get() then begin
            if IntrastatReportSetup."VAT No. Based On" = IntrastatReportSetup."VAT No. Based On"::"Sell-to VAT" then begin
                IntrastatReportSetup."Sales VAT No. Based On" := IntrastatReportSetup."Sales VAT No. Based On"::"Sell-to VAT";
                IntrastatReportSetup."Purchase VAT No. Based On" := IntrastatReportSetup."Purchase VAT No. Based On"::"Buy-from VAT";
                IntrastatReportSetup."Sales Intrastat Info Based On" := IntrastatReportSetup."Sales Intrastat Info Based On"::"Sell-to Customer";
                IntrastatReportSetup."Purch. Intrastat Info Based On" := IntrastatReportSetup."Purch. Intrastat Info Based On"::"Buy-from Vendor";
                IntrastatReportSetup."Project VAT No. Based On" := IntrastatReportSetup."Project VAT No. Based On"::"Sell-to Customer";
            end;
            if IntrastatReportSetup."VAT No. Based On" = IntrastatReportSetup."VAT No. Based On"::"Bill-to VAT" then begin
                IntrastatReportSetup."Sales VAT No. Based On" := IntrastatReportSetup."Sales VAT No. Based On"::"Bill-to VAT";
                IntrastatReportSetup."Purchase VAT No. Based On" := IntrastatReportSetup."Purchase VAT No. Based On"::"Pay-to VAT";
                IntrastatReportSetup."Sales Intrastat Info Based On" := IntrastatReportSetup."Sales Intrastat Info Based On"::"Bill-to Customer";
                IntrastatReportSetup."Purch. Intrastat Info Based On" := IntrastatReportSetup."Purch. Intrastat Info Based On"::"Pay-to Vendor";
                IntrastatReportSetup."Project VAT No. Based On" := IntrastatReportSetup."Project VAT No. Based On"::"Bill-to Customer";
            end;
            IntrastatReportSetup.Modify();
        end;

        UpgradeTag.SetUpgradeTag(GetIntrastatDocumentVATIDUpgradeTag());
    end;

    local procedure GetIntrastatDocumentVATIDUpgradeTag(): Code[250]
    begin
        exit('MS-548317-IntrastatDocumentVATID-20241130');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetIntrastatDocumentVATIDUpgradeTag());
    end;
}
