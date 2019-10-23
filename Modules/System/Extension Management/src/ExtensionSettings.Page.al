// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Displays settings for the selected extension, and allows users to edit them.
/// </summary>
page 2511 "Extension Settings"
{
    Extensible = false;
    DataCaptionExpression = AppNameValue;
    PageType = Card;
    SourceTable = "NAV App Setting";
    ContextSensitiveHelpPage = 'ui-extensions';

    layout
    {
        area(content)
        {
            group(Group)
            {
                field(AppId; AppIdValue)
                {
                    ApplicationArea = All;
                    Caption = 'App ID';
                    Editable = false;
                    ToolTip = 'Specifies the App ID of the extension.';
                }
                field(AppName; AppNameValue)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    Editable = false;
                    ToolTip = 'Specifies the name of the extension.';
                }
                field(AppPublisher; AppPublisherValue)
                {
                    ApplicationArea = All;
                    Caption = 'Publisher';
                    Editable = false;
                    ToolTip = 'Specifies the publisher of the extension.';
                }
                field(AllowHttpClientRequests; "Allow HttpClient Requests")
                {
                    ApplicationArea = All;
                    Caption = 'Allow HttpClient Requests';
                    Editable = HasExtensionManagementPermissions;
                    ToolTip = 'Specifies whether the runtime should allow this extension to make HTTP requests through the HttpClient data type when running in a non-production environment.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    var
        NAVApp: Record "NAV App";
    begin
        NAVApp.SetRange(ID, "App ID");

        if NAVApp.FindFirst() then begin
            AppNameValue := NAVApp.Name;
            AppPublisherValue := NAVApp.Publisher;
            AppIdValue := LowerCase(DelChr(Format(NAVApp.ID), '=', '{}'));
        end
    end;

    trigger OnOpenPage()
    var
        NAVAppObjectMetadata: Record "NAV App Object Metadata";
    begin
        if GetFilter("App ID") = '' then
            exit;

        "App ID" := GetRangeMin("App ID");
        if not FindFirst() then begin
            Init();
            Insert();
        end;

        HasExtensionManagementPermissions := NavAppObjectMetadata.ReadPermission()
    end;

    var
        AppNameValue: Text;
        AppPublisherValue: Text;
        AppIdValue: Text;
        HasExtensionManagementPermissions: Boolean;
}

