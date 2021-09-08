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
    Permissions = tabledata "Nav App Setting" = rm,
                  tabledata "Published Application" = r;

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
                field(AllowHttpClientRequests; Rec."Allow HttpClient Requests")
                {
                    ApplicationArea = All;
                    Caption = 'Allow HttpClient Requests';
                    Editable = CanManageExtensions;
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
        PublishedApplication: Record "Published Application";
    begin
        PublishedApplication.SetRange(ID, "App ID");
        PublishedApplication.SetRange("Tenant Visible", true);

        if PublishedApplication.FindFirst() then begin
            AppNameValue := PublishedApplication.Name;
            AppPublisherValue := PublishedApplication.Publisher;
            AppIdValue := LowerCase(DelChr(Format(PublishedApplication.ID), '=', '{}'));
        end
    end;

    trigger OnOpenPage()
    var
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
    begin
        if GetFilter("App ID") = '' then
            exit;

        "App ID" := GetRangeMin("App ID");
        if not FindFirst() then begin
            Init();
            Insert();
        end;

        CanManageExtensions := ExtensionInstallationImpl.CanManageExtensions();
    end;

    var
        AppNameValue: Text;
        AppPublisherValue: Text;
        AppIdValue: Text;
        CanManageExtensions: Boolean;
}

