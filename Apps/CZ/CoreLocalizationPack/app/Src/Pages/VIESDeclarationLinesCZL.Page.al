// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Utilities;

page 31141 "VIES Declaration Lines CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'VIES Declaration Lines';
    Editable = false;
    PageType = List;
    SourceTable = "VIES Declaration Line CZL";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Trade Type"; Rec."Trade Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies trade type for line of VIES declaration.';
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the country/region code.';
                }
                field("VAT Registration No."; Rec."VAT Registration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VAT Registration No. of trade partner.';
                }
                field("EU Service"; Rec."EU Service")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies, that the trade is service in EU.';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies total amounts of partner trades for selected period.';

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownAmountLCY();
                    end;
                }
                field("Trade Role Type"; Rec."Trade Role Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies for declaration line type of trade.';
                }
                field("VIES Declaration No."; Rec."VIES Declaration No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies VIES Declaration No.';
                }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action("Show Document")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Document';
                    Image = View;
                    ShortcutKey = 'Shift+F7';
                    ToolTip = 'Open the document that the selected line exists on.';

                    trigger OnAction()
                    var
                        VIESDeclartionHeaderCZL: Record "VIES Declaration Header CZL";
                        PageManagement: Codeunit "Page Management";
                    begin
                        VIESDeclartionHeaderCZL.Get(Rec."VIES Declaration No.");
                        PageManagement.PageRun(VIESDeclartionHeaderCZL);
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Show Document_Promoted"; "Show Document")
                {
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        if VIESDeclarationHeaderCZL."Corrected Declaration No." <> '' then begin
            Rec.SetRange("VIES Declaration No.", VIESDeclarationHeaderCZL."Corrected Declaration No.");
            Rec.SetRange("Line Type", Rec."Line Type"::New);
        end;
    end;

    var
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
        VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
        LastLineNo: Integer;

    procedure SetToDeclaration(NewVIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL")
    begin
        VIESDeclarationHeaderCZL := NewVIESDeclarationHeaderCZL;
        VIESDeclarationLineCZL.SetRange("VIES Declaration No.", VIESDeclarationHeaderCZL."No.");
        if VIESDeclarationLineCZL.FindLast() then
            LastLineNo := VIESDeclarationLineCZL."Line No."
        else
            LastLineNo := 0;
    end;

    procedure CopyLineToDeclaration()
    begin
        CurrPage.SetSelectionFilter(VIESDeclarationLineCZL);
        if VIESDeclarationLineCZL.FindSet() then
            repeat
                CreateLine(VIESDeclarationLineCZL."Line Type"::Cancellation);
                CreateLine(VIESDeclarationLineCZL."Line Type"::Correction);
            until VIESDeclarationLineCZL.Next() = 0;
    end;

    local procedure CreateLine(LineType: Option)
    var
        NewVIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
        IsHandled: Boolean;
    begin
        OnBeforeCreateLine(VIESDeclarationLineCZL, LineType, LastLineNo, IsHandled);
        if IsHandled then
            exit;

        LastLineNo += 10000;
        NewVIESDeclarationLineCZL.Init();
        NewVIESDeclarationLineCZL."VIES Declaration No." := VIESDeclarationHeaderCZL."No.";
        NewVIESDeclarationLineCZL."Line No." := LastLineNo;
        NewVIESDeclarationLineCZL."Line Type" := LineType;
        NewVIESDeclarationLineCZL."Trade Type" := VIESDeclarationLineCZL."Trade Type";
        NewVIESDeclarationLineCZL."Related Line No." := VIESDeclarationLineCZL."Line No.";
        NewVIESDeclarationLineCZL."Country/Region Code" := VIESDeclarationLineCZL."Country/Region Code";
        NewVIESDeclarationLineCZL."VAT Registration No." := VIESDeclarationLineCZL."VAT Registration No.";
        NewVIESDeclarationLineCZL."Amount (LCY)" := VIESDeclarationLineCZL."Amount (LCY)";
        NewVIESDeclarationLineCZL."EU 3-Party Trade" := VIESDeclarationLineCZL."EU 3-Party Trade";
        NewVIESDeclarationLineCZL."EU Service" := VIESDeclarationLineCZL."EU Service";
        NewVIESDeclarationLineCZL."EU 3-Party Intermediate Role" := VIESDeclarationLineCZL."EU 3-Party Intermediate Role";
        NewVIESDeclarationLineCZL."Trade Role Type" := VIESDeclarationLineCZL."Trade Role Type";
        NewVIESDeclarationLineCZL."Number of Supplies" := VIESDeclarationLineCZL."Number of Supplies";
        NewVIESDeclarationLineCZL."System-Created" :=
            NewVIESDeclarationLineCZL."Line Type" = NewVIESDeclarationLineCZL."Line Type"::Cancellation;
        OnBeforeInsertVIESDeclarationLine(VIESDeclarationLineCZL, NewVIESDeclarationLineCZL);
        NewVIESDeclarationLineCZL.Insert();
        OnAfterCreateLine(NewVIESDeclarationLineCZL, LastLineNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateLine(VIESDeclarationLineCZL: Record "VIES Declaration Line CZL"; LineType: Option; var LastLineNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertVIESDeclarationLine(VIESDeclarationLineCZL: Record "VIES Declaration Line CZL"; var NewVIESDeclarationLineCZL: Record "VIES Declaration Line CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateLine(NewVIESDeclarationLineCZL: Record "VIES Declaration Line CZL"; var LastLineNo: Integer)
    begin
    end;
}
