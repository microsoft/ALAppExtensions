namespace Microsoft.PowerBIReports;
using System.Upgrade;
codeunit 36957 "PowerBI Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        TransferDimensionSetEntries();
    end;

    local procedure TransferDimensionSetEntries()
    var
        FlatDimensionSetEntry: Record "PowerBI Flat Dim. Set Entry";
        UpgradeTag: Codeunit "Upgrade Tag";
        DataTransfer: DataTransfer;
        FieldNo: Integer;
    begin
        if UpgradeTag.HasUpgradeTag(TransferDimensionSetEntriesUpgradeTag()) then
            exit;

        FlatDimensionSetEntry.DeleteAll(false);
        DataTransfer.SetTables(Database::"Dimension Set Entry", Database::"PowerBI Flat Dim. Set Entry");
        for FieldNo := 1 to 18 do
            DataTransfer.AddFieldValue(FieldNo, FieldNo);
        DataTransfer.CopyRows();

        UpgradeTag.SetUpgradeTag(TransferDimensionSetEntriesUpgradeTag());
    end;

    local procedure TransferDimensionSetEntriesUpgradeTag(): Code[250]
    begin
        exit('MS-561310-POWERBI-TRANSFER-DIMENSION-SET-ENTRIES-20250110');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(TransferDimensionSetEntriesUpgradeTag());
    end;

}