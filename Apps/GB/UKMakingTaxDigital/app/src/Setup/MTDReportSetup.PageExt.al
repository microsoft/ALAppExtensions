// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#pragma warning disable AA0247

pageextension 10539 "MTD Report Setup" extends "VAT Report Setup"
{
    layout
    {
        modify("Return Period")
        {
            Caption = 'Making Tax Digital';
        }
        modify("Auto Update Job")
        {
            Visible = false;
        }
        addfirst("Return Period")
        {
            field(Enabled; Rec."MTD Enabled")
            {
                Caption = 'Enabled';
                ToolTip = 'Specifies if the Making Tax Digital feature is enabled.';
                ApplicationArea = Basic, Suite;
            }
        }
        addlast("Return Period")
        {
            field(MTDFPPublicIPServiceURL; Rec."MTD FP Public IP Service URL")
            {
                ToolTip = 'Specifies the endpoint of an IP address lookup service that will return the IP address of the user who submits the report. The IP address of the user is included with Fraud Prevention Headers when Business Central communicates with HMRC.';
                ApplicationArea = Basic, Suite;

                trigger OnAssistEdit()
                var
                    MTDFraudPreventionMgt: Codeunit "MTD Fraud Prevention Mgt.";
                begin
                    MTDFraudPreventionMgt.TestPublicIPServiceURL(Rec."MTD FP Public IP Service URL");
                end;

                trigger OnValidate()
                var
                    MTDFraudPreventionMgt: Codeunit "MTD Fraud Prevention Mgt.";
                begin
                    MTDFraudPreventionMgt.TestPublicIPServiceURL(Rec."MTD FP Public IP Service URL");
                end;
            }
            group(Connection)
            {
                Visible = false; // only developer mode

                field("MTD OAuth Setup Option"; "MTD OAuth Setup Option")
                {
                    Caption = 'OAuth Setup';
                    ToolTip = 'Specifies the OAuth 2.0 setup for the HMRC connection.';
                    ApplicationArea = Basic, Suite;
                }
                group("Gov Test Scenario Group")
                {
                    ShowCaption = false;
                    Visible = "MTD OAuth Setup Option" = "MTD OAuth Setup Option"::Sandbox;
                    field("MTD Gov Test Scenario"; "MTD Gov Test Scenario")
                    {
                        Caption = 'Gov Test Scenario';
                        ToolTip = 'Specifies the "Gov Test Scenario" flag for the HMRC sandbox connection.';
                        ApplicationArea = Basic, Suite;
                    }
                }
            }
        }
    }
    actions
    {
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        UKMakingTaxTok: Label 'UK Making Tax Digital', Locked = true;
    begin
        FeatureTelemetry.LogUptake('0000HFU', UKMakingTaxTok, Enum::"Feature Uptake Status"::Discovered);
    end;
}
