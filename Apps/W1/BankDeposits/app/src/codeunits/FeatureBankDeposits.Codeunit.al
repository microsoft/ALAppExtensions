codeunit 1698 "Feature Bank Deposits" implements "Feature Data Update"
{
    Access = Internal;

    procedure IsDataUpdateRequired(): Boolean;
    begin
        exit(false);
    end;

    procedure ReviewData();
    begin
    end;

    procedure UpdateData(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    begin
    end;

    procedure AfterUpdate(FeatureDataUpdateStatus: Record "Feature Data Update Status");
    begin
    end;

    procedure GetTaskDescription() TaskDescription: Text;
    begin
        TaskDescription := DescriptionTxt;
    end;

#if not CLEAN21
    [EventSubscriber(ObjectType::Table, Database::"Feature Data Update Status", 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterFeatureDataUpdateStatusModify(var Rec: Record "Feature Data Update Status")
    var
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
    begin
        if Rec."Feature Key" <> BankDepositFeatureMgt.GetFeatureKeyId() then
            exit;
        if Rec."Feature Status" = Rec."Feature Status"::Disabled then
            DisableFeature()
        else
            EnableFeature();
    end;

    [Obsolete('Bank Deposits feature will be enabled by default', '21.0')]
    procedure EnableFeature()
    var
        DepositsPageMgt: Codeunit "Deposits Page Mgt.";
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
    begin
        BankDepositFeatureMgt.EnableDepositActions();
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositsPage, Page::"Bank Deposits");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositPage, Page::"Bank Deposit");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositListPage, Page::"Bank Deposit List");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositReport, Report::"Bank Deposit");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::DepositTestReport, Report::"Bank Deposit Test Report");
        DepositsPageMgt.SetSetupKey(Enum::"Deposits Page Setup Key"::PostedBankDepositListPage, Page::"Posted Bank Deposit List");
        Commit();
    end;

    [Obsolete('Bank Deposits feature will be enabled by default', '21.0')]
    procedure DisableFeature()
    var
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
    begin
        BankDepositFeatureMgt.DisableDepositActions();
        Commit();
    end;

    [Obsolete('Bank Deposits feature will be enabled by default', '21.0')]
    procedure OpenPageGuard()
    var
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
    begin
        if BankDepositFeatureMgt.IsEnabled() then
            exit;
        PromptFeatureBlockingOpen();
    end;

    [Obsolete('Bank Deposits feature will be enabled by default', '21.0')]
    procedure PromptFeatureBlockingOpen()
    var
        DepositsPageMgt: Codeunit "Deposits Page Mgt.";
    begin
        if not DepositsPageMgt.PromptDepositFeature() then
            Error(FeatureDisabledErr);
        Error('');
    end;

    [Obsolete('Bank Deposits feature will be enabled by default', '21.0')]
    procedure ShouldSeePostedBankDeposits(): Boolean
    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        BankDepositFeatureMgt: Codeunit "Bank Deposit Feature Mgt.";
    begin
        exit(BankDepositFeatureMgt.IsEnabled() or (not PostedBankDepositHeader.IsEmpty()));
    end;
#endif

    var
        DescriptionTxt: Label 'Feature: Use standardized bank deposits.';
#if not CLEAN21
        FeatureDisabledErr: Label 'This page cannot be used because the Bank Deposits feature is not switched on.';
#endif
}