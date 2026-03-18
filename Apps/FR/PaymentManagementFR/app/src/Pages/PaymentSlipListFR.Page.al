// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;

using System.Telemetry;

page 10846 "Payment Slip List FR"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Payment Slips';
    CardPageID = "Payment Slip FR";
    Editable = false;
    PageType = List;
    SourceTable = "Payment Header FR";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the payment header.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the currency code to be used on the payment lines.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date when the payment slip should be posted.';
                }
                field("Payment Class"; Rec."Payment Class")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the payment class used when creating this payment slip.';
                }
                field("Status Name"; Rec."Status Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the status the payment is in.';
                }
            }
        }
    }

    actions
    {
        area(creation)
        {
            action("Create Payment Slip")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Create Payment Slip';
                Image = NewDocument;
                RunObject = Codeunit "Payment Management FR";
                ToolTip = 'Manage information about customer and vendor payments.';
            }
        }
    }

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FRPaymentSlipTok: Label 'FR Create Payment Slips', Locked = true;
    begin
        FeatureTelemetry.LogUptake('1000HP0', FRPaymentSlipTok, Enum::"Feature Uptake Status"::Discovered);
    end;
}

