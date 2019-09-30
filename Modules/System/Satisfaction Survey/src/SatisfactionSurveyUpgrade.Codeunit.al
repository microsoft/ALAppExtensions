// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1435 "Satisfaction Survey Upgrade"
{
    Subtype = Upgrade;
    Access = Internal;

    var
        ControlNotRegisteredErr: Label 'Satisfaction Survey control add-in was not registered.', Locked = true;

    trigger OnUpgradePerDatabase()
    var
        UpgradeTag: Codeunit "Upgrade Tag";
        SatisfactionSurveyUpgradeTag: Codeunit "Satisfaction Survey Upgr. Tag";
        SatisfactionSurveyViewer: Codeunit "Satisfaction Survey Viewer";
    begin
        if UpgradeTag.HasUpgradeTag(SatisfactionSurveyUpgradeTag.GetRegisterControlAddInTag()) then
            exit;

        if not SatisfactionSurveyViewer.IsAddInRegistered() then
            SatisfactionSurveyViewer.RegisterAddIn();

        UpgradeTag.SetUpgradeTag(SatisfactionSurveyUpgradeTag.GetRegisterControlAddInTag());
    end;

    trigger OnValidateUpgradePerDatabase()
    var
        SatisfactionSurveyViewer: Codeunit "Satisfaction Survey Viewer";
    begin
        if not SatisfactionSurveyViewer.IsAddInRegistered() then
            Error(ControlNotRegisteredErr);
    end;
}