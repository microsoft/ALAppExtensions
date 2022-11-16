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
#if not CLEAN21
#pragma warning disable AL0432
        if NewVIESDeclarationLineCZL."Line Type" = NewVIESDeclarationLineCZL."Line Type"::Correction then
            OnBeforeVIESDeclarationLineInsert(VIESDeclarationLineCZL, NewVIESDeclarationLineCZL);
#pragma warning restore AL0432
#endif
        OnBeforeInsertVIESDeclarationLine(VIESDeclarationLineCZL, NewVIESDeclarationLineCZL);
        NewVIESDeclarationLineCZL.Insert();
#if not CLEAN21
#pragma warning disable AL0432
        if NewVIESDeclarationLineCZL."Line Type" = NewVIESDeclarationLineCZL."Line Type"::Correction then
            OnAfterVIESDeclarationLineInsert(NewVIESDeclarationLineCZL, LastLineNo);
#pragma warning restore AL0432
#endif
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
#if not CLEAN21
    [Obsolete('Replaced by OnBeforeInsertVIESDeclarationLine function.', '21.0')]
    [IntegrationEvent(false, false)]
    local procedure OnBeforeVIESDeclarationLineInsert(FirstVIESDeclarationLineCZL: Record "VIES Declaration Line CZL"; var SecondVIESDeclarationLineCZL: Record "VIES Declaration Line CZL")
    begin
    end;

    [Obsolete('Replaced by OnAfterCreateLine function.', '21.0')]
    [IntegrationEvent(false, false)]
    local procedure OnAfterVIESDeclarationLineInsert(SecondVIESDeclarationLineCZL: Record "VIES Declaration Line CZL"; var LastLineNo: Integer)
    begin
    end;
#endif
}
