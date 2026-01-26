// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

page 31129 "VAT Attribute Codes CZL"
{
    Caption = 'VAT Attribute Codes';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "VAT Attribute Code CZL";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                }
                field("XML Code"; Rec."XML Code")
                {
                    ApplicationArea = Basic, Suite;
                }
                field("VAT Report Amount Type"; Rec."VAT Report Amount Type")
                {
                    ApplicationArea = Basic, Suite;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }
    trigger OnOpenPage()
    var
        VATAttributeCodeMgtCZL: Codeunit "VAT Attribute Code Mgt. CZL";
        TemplateSelected: Boolean;
    begin
        if Rec.GetFilter("VAT Statement Template Name") = '' then begin
            VATAttributeCodeMgtCZL.VATStatementTemplateSelection(Rec, TemplateSelected);
            if not TemplateSelected then
                Error('');
        end;
    end;
}
