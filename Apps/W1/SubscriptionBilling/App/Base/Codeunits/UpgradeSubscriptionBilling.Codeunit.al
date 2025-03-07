#if not CLEAN26
namespace Microsoft.SubscriptionBilling;

using System.Upgrade;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 8032 "Upgrade Subscription Billing"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerDatabase()
    begin
    end;

    trigger OnUpgradePerCompany()
    begin
        UpdateClosedFlagForServiceCommitments();
        UpdateSourceNoForServiceObjects();
        UpdateTypeNoForContractLines();
        UpdateSourceNoForContractAnalysisEntries();
        UpdateDefaultPeriodsInServiceContractSetup();
        MoveCustContrDimensionToServiceContractSetup();
    end;

    local procedure UpdateClosedFlagForServiceCommitments()
    var
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        VendorContractLine: Record "Vend. Sub. Contract Line";
        ServiceCommitment: Record "Subscription Line";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetClosedFlagUpgradeTag()) then
            exit;

        CustomerContractLine.SetLoadFields(Closed, "Subscription Line Entry No.");
        CustomerContractLine.SetRange(Closed, true);
        if CustomerContractLine.FindSet() then
            repeat
                if ServiceCommitment.Get(CustomerContractLine."Subscription Line Entry No.") then begin
                    ServiceCommitment.Closed := CustomerContractLine.Closed;
                    ServiceCommitment.Modify(false);
                end;
            until CustomerContractLine.Next() = 0;

        VendorContractLine.SetLoadFields(Closed, "Subscription Line Entry No.");
        VendorContractLine.SetRange(Closed, true);
        if VendorContractLine.FindSet() then
            repeat
                if ServiceCommitment.Get(VendorContractLine."Subscription Line Entry No.") then begin
                    ServiceCommitment.Closed := VendorContractLine.Closed;
                    ServiceCommitment.Modify(false);
                end;
            until VendorContractLine.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetClosedFlagUpgradeTag());
    end;

    internal procedure GetClosedFlagUpgradeTag(): Code[250]
    begin
        exit('MS-XXXXXX-ClosedFlagUpgradeTag-20241110');
    end;

    local procedure UpdateSourceNoForServiceObjects()
    var
        ServiceObject: Record "Subscription Header";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetSourceNoForServiceObjectsUpgradeTag()) then
            exit;

        if ServiceObject.FindSet() then
            repeat
                ServiceObject.Type := ServiceObject.Type::Item;
                ServiceObject."Source No." := ServiceObject."Item No.";
                ServiceObject.Modify();
            until ServiceObject.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetSourceNoForServiceObjectsUpgradeTag());
    end;

    internal procedure GetSourceNoForServiceObjectsUpgradeTag(): Code[250]
    begin
        exit('MS-565334-SourceNoForServiceObjectsUpgradeTag-20250205');
    end;

    local procedure UpdateTypeNoForContractLines()
    var
        CustomerContractLine: Record "Cust. Sub. Contract Line";
        VendorContractLine: Record "Vend. Sub. Contract Line";
        ServiceObject: Record "Subscription Header";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetTypeNoForContractLinesUpgradeTag()) then
            exit;

        CustomerContractLine.SetRange("Contract Line Type", CustomerContractLine."Contract Line Type"::"Service Commitment");
        if CustomerContractLine.FindSet() then
            repeat
                if ServiceObject.Get(CustomerContractLine."Subscription Header No.") then begin
                    CustomerContractLine."Contract Line Type" := CustomerContractLine."Contract Line Type"::Item;
                    CustomerContractLine."No." := ServiceObject."Source No.";
                    CustomerContractLine.Modify();
                end;
            until CustomerContractLine.Next() = 0;

        VendorContractLine.SetRange("Contract Line Type", VendorContractLine."Contract Line Type"::"Service Commitment");
        if VendorContractLine.FindSet() then
            repeat
                if ServiceObject.Get(VendorContractLine."Subscription Header No.") then begin
                    VendorContractLine."Contract Line Type" := VendorContractLine."Contract Line Type"::Item;
                    VendorContractLine."No." := ServiceObject."Source No.";
                    VendorContractLine.Modify();
                end;
            until VendorContractLine.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetTypeNoForContractLinesUpgradeTag());
    end;

    internal procedure GetTypeNoForContractLinesUpgradeTag(): Code[250]
    begin
        exit('MS-565334-TypeNoForContractLinessUpgradeTag-20250205');
    end;

    local procedure UpdateSourceNoForContractAnalysisEntries()
    var
        ContractAnalysisEntry: Record "Sub. Contr. Analysis Entry";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetSourceNoForContractAnalysisEntriesUpgradeTag()) then
            exit;

        if ContractAnalysisEntry.FindSet() then
            repeat
                ContractAnalysisEntry."Sub. Header Source Type" := ContractAnalysisEntry."Sub. Header Source Type"::Item;
                ContractAnalysisEntry."Sub. Header Source No." := ContractAnalysisEntry."Service Object Item No.";
                ContractAnalysisEntry.Modify();
            until ContractAnalysisEntry.Next() = 0;

        UpgradeTag.SetUpgradeTag(GetSourceNoForContractAnalysisEntriesUpgradeTag());
    end;

    internal procedure GetSourceNoForContractAnalysisEntriesUpgradeTag(): Code[250]
    begin
        exit('MS-565334-SourceNoForContractAnalysisEntriesTag-20250205');
    end;

    local procedure UpdateDefaultPeriodsInServiceContractSetup()
    var
        ServiceContractSetup: Record "Subscription Contract Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetUpdateDefaultPeriodsInServiceContractSetupUpgradeTag()) then
            exit;

        if ServiceContractSetup.Get() then begin
            Evaluate(ServiceContractSetup."Default Billing Base Period", '<1M>');
            Evaluate(ServiceContractSetup."Default Billing Rhythm", '<1M>');
            ServiceContractSetup.Modify();
        end;

        UpgradeTag.SetUpgradeTag(GetUpdateDefaultPeriodsInServiceContractSetupUpgradeTag());
    end;

    internal procedure GetUpdateDefaultPeriodsInServiceContractSetupUpgradeTag(): Code[250]
    begin
        exit('MS-565334-DefaultPeriodsInServiceContractSetupsTag-20250205');
    end;

    local procedure MoveCustContrDimensionToServiceContractSetup()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ServiceContractSetup: Record "Subscription Contract Setup";
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetMoveCustContrDimensionUpgradeTag()) then
            exit;

        if not GeneralLedgerSetup.Get() then
            exit;

        if ServiceContractSetup.Get() then begin
            ServiceContractSetup."Dimension Code Cust. Contr." := GeneralLedgerSetup."Dimension Code Cust. Contr.";
            ServiceContractSetup.Modify(false);
        end;

        UpgradeTag.SetUpgradeTag(GetMoveCustContrDimensionUpgradeTag());
    end;

    internal procedure GetMoveCustContrDimensionUpgradeTag(): Code[250]
    begin
        exit('MS-565334-MoveCustContrDimension-20250205');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetClosedFlagUpgradeTag());
        PerCompanyUpgradeTags.Add(GetSourceNoForServiceObjectsUpgradeTag());
        PerCompanyUpgradeTags.Add(GetTypeNoForContractLinesUpgradeTag());
        PerCompanyUpgradeTags.Add(GetSourceNoForContractAnalysisEntriesUpgradeTag());
        PerCompanyUpgradeTags.Add(GetUpdateDefaultPeriodsInServiceContractSetupUpgradeTag());
        PerCompanyUpgradeTags.Add(GetMoveCustContrDimensionUpgradeTag());
    end;
}
#endif