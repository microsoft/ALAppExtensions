// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Finance.VAT.Reporting;

pageextension 10525 "VAT Reports Configuration" extends "VAT Reports Configuration"
{
    layout
    {
#if not CLEAN27
        modify("Validate Codeunit Caption")
        {
            Visible = false;
        }
#endif
        addafter("Validate Codeunit Caption")
        {
            field("Content Max Lines GB"; Rec."Content Max Lines GB")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Max. No. of Lines';
                ToolTip = 'Specifies the maximum number of lines in each message.';
#if not CLEAN27
                Visible = FeatureEnabled;
#endif

                trigger OnValidate()
                begin
                    if
                       (Rec."VAT Report Type" = Rec."VAT Report Type"::"VAT Return") and
                       (Rec."Content Max Lines GB" <> 0)
                    then
                        Error(NotApplicableErr);

                    if Rec."Content Max Lines GB" < 0 then
                        Error(MinValueErr);
                end;
            }
        }
    }

#if not CLEAN27
    trigger OnOpenPage()
    var
        GovTalk: Codeunit GovTalk;
    begin
        FeatureEnabled := GovTalk.IsEnabled();
    end;
#endif

    var
#if not CLEAN27
        FeatureEnabled: Boolean;
#endif
        NotApplicableErr: Label 'This value is only applicable for EC Sales list report.';
        MinValueErr: Label 'The value of Max. No. of Lines must be bigger than zero.';
}