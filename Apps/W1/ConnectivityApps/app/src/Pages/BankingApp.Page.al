// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

page 20352 "Banking App"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Banking App';
    DataCaptionExpression = Rec.Name;
    SourceTable = "Connectivity App";
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;
    AboutTitle = 'Banking app details';
    AboutText = 'This page provides details about the app. The description outlines its purpose, and you can visit AppSource to learn more. These apps may have a cost of usage. You will find that information on AppSource or on the app publisher''s web site linked to on this page.';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the app.';
                }
                field(Publisher; Rec.Publisher)
                {
                    ApplicationArea = All;
                    Caption = 'Publisher';
                    ToolTip = 'Specifies the publisher of the app.';
                }
                field(SupportedCountry; Rec."Country/Region")
                {
                    ApplicationArea = All;
                    Caption = 'Supported Country';
                    ToolTip = 'Specifies the code for the country in which the app is supported.';
                }
                field("AppSourceURL"; AppSourceURLLbl)
                {
                    ApplicationArea = All;
                    Caption = 'AppSource URL';
                    ShowCaption = false;
                    ToolTip = 'Specifies the URL for the app on AppSource.';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(Rec."AppSource URL");
                    end;
                }
                field("ProviderSupportURL"; ProvideSupportURLLbl)
                {
                    ApplicationArea = All;
                    Caption = 'Provide Support URL';
                    ShowCaption = false;
                    ToolTip = 'Specifies the URL to support from the app provider.';
                    AboutTitle = 'Supported banks';
                    AboutText = 'This is a link to the app publisher''s web site where you can find more information about which banks are supported and in which countries.';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(Rec."Provider Support URL");
                    end;
                }
            }
            group(Desc)
            {
                ShowCaption = false;
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ShowCaption = false;
                    ToolTip = 'Specifies the description of the app.';
                    MultiLine = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Install)
            {
                ApplicationArea = All;
                ToolTip = 'Install';
                Image = NewRow;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Enabled = Rec.Name <> '';

                trigger OnAction();
                var
                    ConnectivityAppsImpl: Codeunit "Connectivity Apps Impl.";
                    ExtensionManagement: Codeunit "Extension Management";
                    FeatureTelemetry: Codeunit "Feature Telemetry";
                begin
                    if IsNullGuid(Rec."App Id") then
                        exit;
                    ExtensionManagement.InstallMarketplaceExtension(Rec."App Id");
                    FeatureTelemetry.LogUptake('0000I4K', 'Connectivity Apps', Enum::"Feature Uptake Status"::Used);
                    ConnectivityAppsImpl.LogFeatureTelemetry(Rec."App Id", Rec.Name, Rec.Publisher);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000I4L', 'Connectivity Apps', Enum::"Feature Uptake Status"::Used);
    end;

    var
        AppSourceURLLbl: Label 'View in AppSource';
        ProvideSupportURLLbl: Label 'View supported banks';
}
