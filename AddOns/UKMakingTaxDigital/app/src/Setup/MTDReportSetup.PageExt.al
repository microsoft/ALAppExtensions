// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

pageextension 10539 "MTD Report Setup" extends "VAT Report Setup"
{
    layout
    {
        addlast("Return Period")
        {
            field(MTDDisableFPHeaders; "MTD Disable FraudPrev. Headers")
            {
                Caption = 'Disable Fraud Prevention Headers';
                ToolTip = 'Specifies if fraud prevention headers are disabled. Choose the field if you do not want to include fraud prevention headers in the HTTP requests that are sent to HMRC.';
                ApplicationArea = Basic, Suite;
                Importance = Additional;
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
}
