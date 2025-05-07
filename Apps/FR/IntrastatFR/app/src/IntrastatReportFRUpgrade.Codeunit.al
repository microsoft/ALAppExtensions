#pragma warning disable AA0247
codeunit 10857 IntrastatReportFRUpgrade
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpdateLinesType();
        UpdateColumnsDataExchangeDef();
    end;

    local procedure UpdateLinesType()
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetIntrastatTypeUpdateTag()) then
            exit;

        DataExchColumnDef.SetRange("Data Exch. Def Code", 'INTRA-2022-FR');
        DataExchColumnDef.SetFilter("Column No.", '8|9|10');
        if DataExchColumnDef.FindSet() then
            repeat
                if DataExchColumnDef."Data Type" = DataExchColumnDef."Data Type"::Decimal then begin
                    DataExchColumnDef.Validate("Data Type", DataExchColumnDef."Data Type"::Text);
                    DataExchColumnDef.Modify(true);
                end;
            until DataExchColumnDef.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetIntrastatTypeUpdateTag());
    end;

    local procedure UpdateColumnsDataExchangeDef()
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        //Set "Export If Not Blank" = true for partyType and partyRole columns
        if UpgradeTag.HasUpgradeTag(GetUpdateColumnsDataExchangeDefTag()) then
            exit;

        DataExchColumnDef.SetRange("Data Exch. Def Code", 'INTRA-2022-FR');
        DataExchColumnDef.SetRange("Data Exch. Line Def Code", '2-SENDER');
        DataExchColumnDef.SetFilter(Path, '%1|%2', '/Party[@partyType]', '/Party[@partyRole]');
        if DataExchColumnDef.IsEmpty() then
            exit;

        DataExchColumnDef.ModifyAll("Export If Not Blank", true);

        UpgradeTag.SetUpgradeTag(GetUpdateColumnsDataExchangeDefTag());
    end;

    internal procedure GetIntrastatTypeUpdateTag(): Code[250]
    begin
        exit('MS-481518-IntrastatTypeUpdateFR-20230818');
    end;

    internal procedure GetUpdateColumnsDataExchangeDefTag(): Code[250]
    begin
        exit('MS-527324-UpdateColumnsDataExchangeDef-20240522');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetUpdateColumnsDataExchangeDefTag());
    end;

}
