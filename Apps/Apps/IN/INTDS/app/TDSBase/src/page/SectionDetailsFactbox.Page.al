// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSBase;

page 18689 "Section Details Factbox"
{
    PageType = CardPart;
    SourceTable = "TDS Section";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            field(Detail; SectionDetail)
            {
                ApplicationArea = Basic, Suite;
                ShowCaption = false;
                Caption = 'Section Details';
                Style = StandardAccent;
                ToolTip = 'Specify additional details for the TDS section.';


                trigger OnDrillDown()
                var
                    SectionDetail: Page "Section Detail";
                begin
                    SectionDetail.SetRecord(rec);
                    SectionDetail.Run();
                end;
            }
        }
    }


    trigger OnAfterGetrecord()
    begin
        formatline();
    end;

    trigger OnAfterGetCurrrecord()
    begin
        formatline();
    end;

    var
        SectionDetail: Text;

    local procedure formatline()
    var
        TDSEntityManagement: Codeunit "TDS Entity Management";
    begin
        SectionDetail := TDSEntityManagement.GetDetailTxt(Rec);
    end;
}
