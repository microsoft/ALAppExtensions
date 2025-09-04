// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.GovTalk;

using Microsoft.Foundation.Company;

pageextension 10526 "Company Information" extends "Company Information"
{
    layout
    {
#if not CLEAN27
#pragma warning disable AL0432
        modify("Branch Number")
        {
            Visible = not FeatureEnabled;
        }
#pragma warning restore AL0432        
#endif
        addafter(Shipping)
        {
            group(Statutory_)
            {
                Caption = 'Statutory';
                field("Branch Number GB"; Rec."Branch Number GB")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the three-digit numeric branch number.';
#if not CLEAN27
                    Visible = FeatureEnabled;
#endif
                }
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

    var
        FeatureEnabled: Boolean;
#endif
}