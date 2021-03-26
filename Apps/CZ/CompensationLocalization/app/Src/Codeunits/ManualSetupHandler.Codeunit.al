codeunit 31275 "Manual Setup Handler CZC"
{
    var
        Info: ModuleInfo;
        ManualSetupCategory: Enum "Manual Setup Category";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Manual Setup", 'OnRegisterManualSetup', '', false, false)]
    local procedure OnRegisterManualSetup(var Sender: Codeunit "Manual Setup")
    begin
        RegisterCmpensationsSetup(Sender);
    end;

    local procedure RegisterCmpensationsSetup(var ManualSetup: Codeunit "Manual Setup")
    var
        CompensationsSetupNameTxt: Label 'Compensations Setup';
        CompensationsSetupDescriptionTxt: Label 'Set up method, numbering and posting compensation of receivables and payables.';
        CompensationsSetupKeywordsTxt: Label 'Compensations, Credits, Receivables, Payables';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(CompensationsSetupNameTxt, CompensationsSetupDescriptionTxt,
          CompensationsSetupKeywordsTxt, Page::"Compensations Setup CZC",
          Info.Id(), ManualSetupCategory::Finance);
    end;
}
