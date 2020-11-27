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
        VIESDeclarationLineCZL1: Record "VIES Declaration Line CZL";
        VIESDeclarationLineCZL2: Record "VIES Declaration Line CZL";
        LastLineNo: Integer;

    procedure SetToDeclaration(VIESDeclarationHeaderCZLNew: Record "VIES Declaration Header CZL")
    begin
        VIESDeclarationHeaderCZL := VIESDeclarationHeaderCZLNew;
        VIESDeclarationLineCZL1.SetRange("VIES Declaration No.", VIESDeclarationHeaderCZL."No.");
        if VIESDeclarationLineCZL1.FindLast() then
            LastLineNo := VIESDeclarationLineCZL1."Line No."
        else
            LastLineNo := 0;
    end;

    procedure CopyLineToDeclaration()
    begin
        CurrPage.SetSelectionFilter(VIESDeclarationLineCZL1);
        if VIESDeclarationLineCZL1.FindSet() then
            repeat
                VIESDeclarationLineCZL2.Init();
                VIESDeclarationLineCZL2."VIES Declaration No." := VIESDeclarationHeaderCZL."No.";
                LastLineNo += 10000;
                VIESDeclarationLineCZL2."Line No." := LastLineNo;
                VIESDeclarationLineCZL2."Trade Type" := VIESDeclarationLineCZL1."Trade Type";
                VIESDeclarationLineCZL2."Line Type" := VIESDeclarationLineCZL1."Line Type"::Cancellation;
                VIESDeclarationLineCZL2."Related Line No." := VIESDeclarationLineCZL1."Line No.";
                VIESDeclarationLineCZL2."Country/Region Code" := VIESDeclarationLineCZL1."Country/Region Code";
                VIESDeclarationLineCZL2."VAT Registration No." := VIESDeclarationLineCZL1."VAT Registration No.";
                VIESDeclarationLineCZL2."Amount (LCY)" := VIESDeclarationLineCZL1."Amount (LCY)";
                VIESDeclarationLineCZL2."EU 3-Party Trade" := VIESDeclarationLineCZL1."EU 3-Party Trade";
                VIESDeclarationLineCZL2."EU Service" := VIESDeclarationLineCZL1."EU Service";
                VIESDeclarationLineCZL2."EU 3-Party Intermediate Role" := VIESDeclarationLineCZL1."EU 3-Party Intermediate Role";
                VIESDeclarationLineCZL2."Trade Role Type" := VIESDeclarationLineCZL1."Trade Role Type";
                VIESDeclarationLineCZL2."Number of Supplies" := VIESDeclarationLineCZL1."Number of Supplies";
                VIESDeclarationLineCZL2."System-Created" := true;
                VIESDeclarationLineCZL2.Insert();
                VIESDeclarationLineCZL2."Line No." := LastLineNo + 10000;
                LastLineNo += 10000;
                VIESDeclarationLineCZL2."Line Type" := VIESDeclarationLineCZL1."Line Type"::Correction;
                VIESDeclarationLineCZL2."System-Created" := false;
                VIESDeclarationLineCZL2.Insert();
            until VIESDeclarationLineCZL1.Next() = 0;
    end;
}
