// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

page 20350 "Connectivity Apps"
{
    PageType = List;
    ApplicationArea = All;
    Caption = 'Connectivity Apps';
    UsageCategory = Lists;
    SourceTable = "Connectivity App";
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    Extensible = false;
    AboutTitle = 'Connect your business';
    AboutText = 'These apps can connect your business to external services that increase productivity by automating processes. For example, you can connect to your banks and automatically import bank transactions. These apps are easy to install and set up, which you can do directly from this page. Choose an app to learn more about its features and pricing.';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    Caption = 'Name';
                    ToolTip = 'Specifies the name of the app.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the app.';
                }
                field(Publisher; Rec.Publisher)
                {
                    ApplicationArea = All;
                    Caption = 'Publisher';
                    ToolTip = 'Specifies the publisher of the app.';
                }
                field(Logo; Rec.Logo)
                {
                    ApplicationArea = All;
                    Caption = 'Logo';
                    ToolTip = 'Specifies the logo of the app.';
                }
                field(SupportedCountry; Rec."Country/Region")
                {
                    ApplicationArea = All;
                    Caption = 'Supported Country';
                    ToolTip = 'Specifies the code of the country in which the app is supported.';
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
                    FeatureTelemetry.LogUptake('0000I4Q', 'Connectivity Apps', Enum::"Feature Uptake Status"::Used);
                    ConnectivityAppsImpl.LogFeatureTelemetry(Rec."App Id", Rec.Name, Rec.Publisher);
                end;
            }
            action(OpenCard)
            {
                ApplicationArea = All;
                ToolTip = 'Open Card';
                Image = Edit;
                Visible = false;
                ShortcutKey = return;

                trigger OnAction();
                begin
                    Page.Run(Page::"Connectivity App", Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        CompanyInformation: Record "Company Information";
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        if Rec.IsEmpty() then
            ConnectivityApps.Load(Rec);

        ConnectivityApps.LoadImages(Rec);

        CompanyInformation.Get();
        Rec.SetRange("Country/Region", CompanyInformation."Country/Region Code");

        FeatureTelemetry.LogUptake('0000I4R', 'Connectivity Apps', Enum::"Feature Uptake Status"::Discovered);
    end;

    var
        ConnectivityApps: Codeunit "Connectivity Apps";
}
