page 31141 "VIES Declaration Lines CZL"
{
    Caption = 'VIES Declaration Lines';
    Editable = false;
    PageType = List;
    SourceTable = "VIES Declaration Line CZL";

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
            }
        }
    }
    trigger OnOpenPage()
    begin
        Rec.SetRange("VIES Declaration No.", VIESDeclarationHeaderCZL."Corrected Declaration No.");
        Rec.SetRange("Line Type", Rec."Line Type"::New);
    end;

    var
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
        FirstVIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
        SecondVIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
        LastLineNo: Integer;

    procedure SetToDeclaration(NewVIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL")
    begin
        VIESDeclarationHeaderCZL := NewVIESDeclarationHeaderCZL;
        FirstVIESDeclarationLineCZL.SetRange("VIES Declaration No.", VIESDeclarationHeaderCZL."No.");
        if FirstVIESDeclarationLineCZL.FindLast() then
            LastLineNo := FirstVIESDeclarationLineCZL."Line No."
        else
            LastLineNo := 0;
    end;

    procedure CopyLineToDeclaration()
    begin
        CurrPage.SetSelectionFilter(FirstVIESDeclarationLineCZL);
        if FirstVIESDeclarationLineCZL.FindSet() then
            repeat
                SecondVIESDeclarationLineCZL.Init();
                SecondVIESDeclarationLineCZL."VIES Declaration No." := VIESDeclarationHeaderCZL."No.";
                LastLineNo += 10000;
                SecondVIESDeclarationLineCZL."Line No." := LastLineNo;
                SecondVIESDeclarationLineCZL."Trade Type" := FirstVIESDeclarationLineCZL."Trade Type";
                SecondVIESDeclarationLineCZL."Line Type" := FirstVIESDeclarationLineCZL."Line Type"::Cancellation;
                SecondVIESDeclarationLineCZL."Related Line No." := FirstVIESDeclarationLineCZL."Line No.";
                SecondVIESDeclarationLineCZL."Country/Region Code" := FirstVIESDeclarationLineCZL."Country/Region Code";
                SecondVIESDeclarationLineCZL."VAT Registration No." := FirstVIESDeclarationLineCZL."VAT Registration No.";
                SecondVIESDeclarationLineCZL."Amount (LCY)" := FirstVIESDeclarationLineCZL."Amount (LCY)";
                SecondVIESDeclarationLineCZL."EU 3-Party Trade" := FirstVIESDeclarationLineCZL."EU 3-Party Trade";
                SecondVIESDeclarationLineCZL."EU Service" := FirstVIESDeclarationLineCZL."EU Service";
                SecondVIESDeclarationLineCZL."EU 3-Party Intermediate Role" := FirstVIESDeclarationLineCZL."EU 3-Party Intermediate Role";
                SecondVIESDeclarationLineCZL."Trade Role Type" := FirstVIESDeclarationLineCZL."Trade Role Type";
                SecondVIESDeclarationLineCZL."Number of Supplies" := FirstVIESDeclarationLineCZL."Number of Supplies";
                SecondVIESDeclarationLineCZL."System-Created" := true;
                SecondVIESDeclarationLineCZL.Insert();
                SecondVIESDeclarationLineCZL."Line No." := LastLineNo + 10000;
                LastLineNo += 10000;
                SecondVIESDeclarationLineCZL."Line Type" := FirstVIESDeclarationLineCZL."Line Type"::Correction;
                SecondVIESDeclarationLineCZL."System-Created" := false;
                OnBeforeVIESDeclarationLineInsert(FirstVIESDeclarationLineCZL, SecondVIESDeclarationLineCZL);
                SecondVIESDeclarationLineCZL.Insert();
                OnAfterVIESDeclarationLineInsert(SecondVIESDeclarationLineCZL, LastLineNo);
            until FirstVIESDeclarationLineCZL.Next() = 0;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeVIESDeclarationLineInsert(FirstVIESDeclarationLineCZL: Record "VIES Declaration Line CZL"; var SecondVIESDeclarationLineCZL: Record "VIES Declaration Line CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterVIESDeclarationLineInsert(SecondVIESDeclarationLineCZL: Record "VIES Declaration Line CZL"; var LastLineNo: Integer)
    begin
    end;
}
