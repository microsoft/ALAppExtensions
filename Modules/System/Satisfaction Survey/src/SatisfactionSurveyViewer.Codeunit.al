// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1443 "Satisfaction Survey Viewer"
{
    Access = Internal;
    Permissions = tabledata "Add-in" = ri;

    var
        NameTxt: Label 'Microsoft.Dynamics.Nav.Client.SatisfactionSurvey', Locked = true;
        PublicKeyTokenTxt: Label '31bf3856ad364e35', Locked = true;
        VersionTxt: Label '', Locked = true;
        DescriptionTxt: Label 'Microsoft Satisfaction Survey control add-in', Locked = true;
        ResourceTxt: Label 'Add-ins\SatisfactionSurvey\Microsoft.Dynamics.Nav.Client.SatisfactionSurvey.zip', Locked = true;
        ResourceFileNotFoundTxt: Label 'Satisfaction Survey control add-in resource file was not found.', Locked = true;
        ControlNotRegisteredTxt: Label 'Satisfaction Survey control add-in was not registered.', Locked = true;
        ControlRegisteredTxt: Label 'Satisfaction Survey control add-in was registered.', Locked = true;
        CategoryTxt: Label 'AL SaaS Upgrade', Locked = true;

    procedure IsAddInRegistered(): Boolean
    var
        AddIn: Record "Add-in";
    begin
        exit(AddIn.Get(NameTxt, PublicKeyTokenTxt, VersionTxt));
    end;

    procedure RegisterAddIn()
    var
        AddIn: Record "Add-in";
        ResourceFilePath: Text;
    begin
        ResourceFilePath := ApplicationPath() + ResourceTxt;
        if not Exists(ResourceFilePath) then begin
            Session.LogMessage('0000A68', ResourceFileNotFoundTxt, Verbosity::Error, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTxt);
            exit;
        end;

        AddIn."Add-in Name" := CopyStr(NameTxt, 1, MaxStrLen(AddIn."Add-in Name"));
        AddIn."Public Key Token" := CopyStr(PublicKeyTokenTxt, 1, MaxStrLen(AddIn."Public Key Token"));
        AddIn.Version := CopyStr(VersionTxt, 1, MaxStrLen(AddIn.Version));
        AddIn.Category := AddIn.Category::"JavaScript Control Add-in";
        AddIn.Description := CopyStr(DescriptionTxt, 1, MaxStrLen(AddIn.Description));
        AddIn.Resource.Import(ResourceFilePath);

        if not AddIn.Insert() then begin
            Session.LogMessage('0000A69', ControlNotRegisteredTxt, Verbosity::Error, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTxt);
            exit;
        end;

        Session.LogMessage('0000A6A', ControlRegisteredTxt, Verbosity::Normal, DataClassification::CustomerContent, TelemetryScope::ExtensionPublisher, 'Category', CategoryTxt);
    end;
}