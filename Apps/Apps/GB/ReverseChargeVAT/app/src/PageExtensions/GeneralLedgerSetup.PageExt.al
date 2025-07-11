// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using Microsoft.Finance.GeneralLedger.Setup;

pageextension 10549 "General Ledger Setup" extends "General Ledger Setup"
{
    layout
    {
#if not CLEAN27
#pragma warning disable AL0432
        modify("Reverse Charge")
#pragma warning restore AL0432
        {
            Visible = not IsNewFeatureEnabled;
        }
#pragma warning disable AL0432
        modify("Threshold applies")
#pragma warning restore AL0432
        {
            Visible = not IsNewFeatureEnabled;
        }
#pragma warning disable AL0432
        modify(ThresholdAmount)
#pragma warning restore AL0432
        {
            Visible = not IsNewFeatureEnabled;
        }
#endif
        addafter(Application)
        {
            group("Reverse Charge GB")
            {
                Caption = 'Reverse Charge';
#if not CLEAN27
                Visible = IsNewFeatureEnabled;
                Enabled = IsNewFeatureEnabled;
#endif

                field("Threshold applies GB"; Rec."Threshold applies GB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether or not the program is setup to process Reverse Charge invoices.';
#if not CLEAN27
                    Visible = IsNewFeatureEnabled;
                    Enabled = IsNewFeatureEnabled;
#endif

                    trigger OnValidate()
                    begin
                        if Rec."Threshold applies GB" then
                            ThresholdAmountEnable := true
                        else
                            ThresholdAmountEnable := false;
                    end;
                }
                field("Threshold Amount"; Rec."Threshold Amount GB")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Threshold Amount';
                    Enabled = ThresholdAmountEnable;
                    ToolTip = 'Specifies the de minimis rule amount determined by the tax authorities.';
#if not CLEAN27
                    Visible = IsNewFeatureEnabled;
#endif
                }
            }
        }
    }

    var
#if not CLEAN27
        IsNewFeatureEnabled: Boolean;
#endif
        ThresholdAmountEnable: Boolean;

    trigger OnOpenPage()
    var
#if not CLEAN27
        ReverseChargeVAT: Codeunit "Reverse Charge VAT GB";
#endif
    begin
#if not CLEAN27
        IsNewFeatureEnabled := ReverseChargeVAT.IsEnabled();
        ThresholdAmountEnable := Rec."Threshold applies GB" and IsNewFeatureEnabled;
#endif
        ThresholdAmountEnable := Rec."Threshold applies GB";
    end;
}