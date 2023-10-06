// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AutomaticAccounts;

page 4850 "Automatic Account Header"
{
    Caption = 'Automatic Account Groups';
    PageType = ListPlus;
    SourceTable = "Automatic Account Header";
    ApplicationArea = Basic, Suite;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the automatic account group number in this field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an appropriate description of the automatic account group in this field.';
                }
            }
            part(AccLines; "Automatic Account Line")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "Automatic Acc. No." = FIELD("No.");
            }
        }
    }

    actions
    {
    }

#if not CLEAN22
    trigger OnInit()
    var
        AutoAccCodesPageMgt: Codeunit "Auto. Acc. Codes Page Mgt.";
        AutoAccCodesFeatureMgt: Codeunit "Auto. Acc. Codes Feature Mgt.";
    begin
        if not AutoAccCodesFeatureMgt.IsEnabled() then begin
            AutoAccCodesPageMgt.OpenAutoAccGroupListPage();
            Error('');
        end;
    end;
#endif
}

