namespace Microsoft.Bank.Reconciliation;

codeunit 7252 "Bank Acc. Rec. AI Install"
{
    Subtype = Install;
    InherentPermissions = X;
    InherentEntitlements = X;

    trigger OnInstallAppPerDatabase()
    var
        BankRecAIMatchingImpl: Codeunit "Bank Rec. AI Matching Impl.";
    begin
        BankRecAIMatchingImpl.RegisterCapability();
    end;
}