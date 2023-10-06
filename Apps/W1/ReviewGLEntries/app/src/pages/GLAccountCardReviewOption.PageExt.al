namespace Microsoft.Finance.GeneralLedger.Review;

using Microsoft.Finance.GeneralLedger.Account;
using System.Telemetry;

pageextension 22205 "G/L Account Card Review Option" extends "G/L Account Card"
{
    layout
    {
        addlast(General)
        {
            field("Review Policy"; Rec."Review Policy")
            {
                Caption = 'Review Policy';
                ToolTip = 'Specifies the review policy for this account.';
                ApplicationArea = Basic, Suite;
                trigger OnValidate()
                var
                    FeatureTelemetry: Codeunit "Feature Telemetry";
                    Telemetry: Codeunit Telemetry;
                    Dimensions: Dictionary of [Text, Text];
                begin
                    if Rec."Review Policy" in ["Review Policy Type"::"Allow Review", "Review Policy Type"::"Allow Review and Match Balance"] then
                        FeatureTelemetry.LogUptake('0000J2X', 'Review G/L Entries', "Feature Uptake Status"::"Set up");
                    Dimensions.Add('Category', 'AL Review GL Entries');
                    Dimensions.Add('G/L Account', Format(Rec.SystemId));
                    Dimensions.Add('New Review Policy', Format(Rec."Review Policy"));
                    Telemetry.LogMessage('0000JSG', Format(Rec."Review Policy"), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, Dimensions);
                end;
            }
        }
    }
}