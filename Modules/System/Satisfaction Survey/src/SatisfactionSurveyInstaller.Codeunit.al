// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1434 "Satisfaction Survey Installer"
{
    Subtype = Install;
    Access = Internal;

    trigger OnInstallAppPerDatabase()
    var
        SatisfactionSurveyViewer: Codeunit "Satisfaction Survey Viewer";
    begin
        if SatisfactionSurveyViewer.IsAddInRegistered() then
            exit;

        SatisfactionSurveyViewer.RegisterAddIn();
    end;
}