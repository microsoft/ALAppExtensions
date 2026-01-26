// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

pageextension 20354 "Headline RC Accountant Ext." extends "Headline RC Accountant"
{
    layout
    {
        addafter(DocumentationText)
        {
            group(Control3)
            {
                ShowCaption = false;
                Visible = IsConnectivityAppsAvailable and IsEvaluationCompany;

                field(BankingAppsText; GetBankingAppsText())
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Banking apps headline';
                    ToolTip = 'Banking apps headline';
                    DrillDown = true;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"Banking Apps");
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        Company: Record Company;
    begin
        IsConnectivityAppsAvailable := ConnectivityApps.IsConnectivityAppsAvailableForGeoAndCategory(ConnectivityAppsCategory::Banking);
        Company.Get(CompanyName());
        IsEvaluationCompany := Company."Evaluation Company";
    end;

    var
        ConnectivityApps: Codeunit "Connectivity Apps";
        ConnectivityAppsCategory: Enum "Connectivity Apps Category";
        IsConnectivityAppsAvailable: Boolean;
        IsEvaluationCompany: Boolean;
        BankingAppsTxt: Label 'Connect to banks to import bank feeds.';

    procedure GetBankingAppsText(): Text
    begin
        exit(BankingAppsTxt);
    end;
}
