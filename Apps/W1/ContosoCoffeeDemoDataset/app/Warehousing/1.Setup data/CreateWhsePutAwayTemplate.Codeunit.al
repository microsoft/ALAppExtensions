codeunit 4791 "Create Whse Put Away Template"
{
    Permissions = tabledata "Put-away Template Header" = rim,
        tabledata "Put-away Template Line" = rim;

    var
        DoInsertTriggers: Boolean;
        XSTDTok: Label 'STD', Locked = true;
        XVARTok: Label 'VAR', Locked = true;
        XSTDDescTok: Label 'Standard Template', MaxLength = 100;
        XVARDescTok: Label 'Variable Template', MaxLength = 100;

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
        CreatePutawayTemplateHeader(XSTDTok, XSTDDescTok);
        CreatePutawayTemplateHeader(XVARTok, XVARDescTok);

        CreatePutawayTemplateLine(XSTDTok, 10000, '', true, false, true, true, true, false);
        CreatePutawayTemplateLine(XSTDTok, 20000, '', true, false, true, true, false, false);
        CreatePutawayTemplateLine(XSTDTok, 30000, '', false, true, true, true, false, false);
        CreatePutawayTemplateLine(XSTDTok, 40000, '', false, true, true, false, false, false);
        CreatePutawayTemplateLine(XSTDTok, 50000, '', false, true, false, false, false, true);
        CreatePutawayTemplateLine(XSTDTok, 60000, '', false, true, false, false, false, false);
        CreatePutawayTemplateLine(XVARTok, 10000, '', false, true, true, true, false, false);
        CreatePutawayTemplateLine(XVARTok, 20000, '', false, true, false, false, false, true);
        CreatePutawayTemplateLine(XVARTok, 30000, '', false, true, false, false, false, false);

    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreatePutAwayTemplateLines()
    begin
    end;
}
