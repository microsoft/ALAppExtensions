codeunit 31244 "Manual Setup Handler CZF"
{
    var
        Info: ModuleInfo;
        ManualSetupCategory: Enum "Manual Setup Category";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Manual Setup", 'OnRegisterManualSetup', '', false, false)]
    local procedure OnRegisterManualSetup(var Sender: Codeunit "Manual Setup")
    begin
        RegisterDepreciationGroup(Sender);
        RegisterClassificationCode(Sender);
    end;

    local procedure RegisterDepreciationGroup(var ManualSetup: Codeunit "Manual Setup")
    var
        DepreciationGroupNameTxt: Label 'Tax Depreciation Groups';
        DepreciationGroupDescriptionTxt: Label 'Set up Tax Depreciation Groups for Fixes Assets. These groups determine minimal depreciation periods and parameters used for calculating tax depreciation.';
        DepreciationGroupKeywordsTxt: Label 'FA, Fixed Assets, Tax Depreciations';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(DepreciationGroupNameTxt, DepreciationGroupDescriptionTxt,
          DepreciationGroupKeywordsTxt, Page::"Tax Depreciation Groups CZF",
          Info.Id(), ManualSetupCategory::"Fixed Assets");
    end;

    local procedure RegisterClassificationCode(var ManualSetup: Codeunit "Manual Setup")
    var
        ClassificationCodeNameTxt: Label 'Classification Codes';
        ClassificationCodeDescriptionTxt: Label 'Set up Classification Codes for Fixed Assets. Production Classification marked CZ-CPA, Classification building operations marked CZ-CC else DNM).';
        ClassificationCodeKeywordsTxt: Label 'FA, Fixed Assets, Classification';
    begin
        NavApp.GetCurrentModuleInfo(Info);
        ManualSetup.Insert(ClassificationCodeNameTxt, ClassificationCodeDescriptionTxt,
          ClassificationCodeKeywordsTxt, Page::"Classification Codes CZF",
          Info.Id(), ManualSetupCategory::"Fixed Assets");
    end;
}
