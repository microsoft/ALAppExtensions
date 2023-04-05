codeunit 4791 "Create Whse Put Away Template"
{
    Permissions = tabledata "Put-away Template Header" = ri,
        tabledata "Put-away Template Line" = ri;

    var
        DoInsertTriggers: Boolean;
        STDTok: Label 'STD', Locked = true;
        VARTok: Label 'VAR', Locked = true;
        STDDescTok: Label 'Standard Template', MaxLength = 100;
        VARDescTok: Label 'Variable Template', MaxLength = 100;

    trigger OnRun()
    begin
        CreatePutawayTemplateLines(false);
        OnAfterCreatePutAwayTemplateLines();
    end;

    local procedure CreatePutawayTemplateHeader(
        Code: Code[10];
        Description: Text[100]
    )
    var
        PutawayTemplateHeader: Record "Put-away Template Header";
    begin
        if PutawayTemplateHeader.Get(Code) then
            exit;
        PutawayTemplateHeader.Init();
        PutawayTemplateHeader."Code" := Code;
        PutawayTemplateHeader."Description" := Description;
        PutawayTemplateHeader.Insert(DoInsertTriggers);
    end;

    local procedure CreatePutawayTemplateLine(
        PutawayTemplateCode: Code[10];
        LineNo: Integer;
        Description: Text[100];
        FindFixedBin: Boolean;
        FindFloatingBin: Boolean;
        FindSameItem: Boolean;
        FindUnitofMeasureMatch: Boolean;
        FindBinwLessthanMinQty: Boolean;
        FindEmptyBin: Boolean
    )
    var
        PutawayTemplateLine: Record "Put-away Template Line";
    begin
        if PutawayTemplateLine.Get(PutawayTemplateCode, LineNo) then
            exit;
        PutawayTemplateLine.Init();
        PutawayTemplateLine."Put-away Template Code" := PutawayTemplateCode;
        PutawayTemplateLine."Line No." := LineNo;
        PutawayTemplateLine."Description" := Description;
        PutawayTemplateLine."Find Fixed Bin" := FindFixedBin;
        PutawayTemplateLine."Find Floating Bin" := FindFloatingBin;
        PutawayTemplateLine."Find Same Item" := FindSameItem;
        PutawayTemplateLine."Find Unit of Measure Match" := FindUnitofMeasureMatch;
        PutawayTemplateLine."Find Bin w. Less than Min. Qty" := FindBinwLessthanMinQty;
        PutawayTemplateLine."Find Empty Bin" := FindEmptyBin;
        PutawayTemplateLine.Insert(DoInsertTriggers);
    end;

    local procedure CreatePutawayTemplateLines(ShouldRunInsertTriggers: Boolean)
    begin
        DoInsertTriggers := ShouldRunInsertTriggers;
        CreatePutawayTemplateHeader(STDTok, STDDescTok);
        CreatePutawayTemplateHeader(VARTok, VARDescTok);

        CreatePutawayTemplateLine(STDTok, 10000, '', true, false, true, true, true, false);
        CreatePutawayTemplateLine(STDTok, 20000, '', true, false, true, true, false, false);
        CreatePutawayTemplateLine(STDTok, 30000, '', false, true, true, true, false, false);
        CreatePutawayTemplateLine(STDTok, 40000, '', false, true, true, false, false, false);
        CreatePutawayTemplateLine(STDTok, 50000, '', false, true, false, false, false, true);
        CreatePutawayTemplateLine(STDTok, 60000, '', false, true, false, false, false, false);
        CreatePutawayTemplateLine(VARTok, 10000, '', false, true, true, true, false, false);
        CreatePutawayTemplateLine(VARTok, 20000, '', false, true, false, false, false, true);
        CreatePutawayTemplateLine(VARTok, 30000, '', false, true, false, false, false, false);

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatePutAwayTemplateLines()
    begin
    end;
}
