codeunit 4769 "Create Mfg Unit of Measures"
{
    Permissions = tabledata "Unit of Measure" = ri;

    trigger OnRun()
    begin
        InsertUnitOfMeasure(XKGTok, XKiloTok, 'KGM');
        InsertUnitOfMeasure(XGRTok, XGramTok, 'GRM');
        InsertUnitOfMeasure(XPCSTok, XPiecesTok, 'EA');
        InsertUnitOfMeasure(XLTok, XLiterTok, 'LTR');
        InsertUnitOfMeasure(XCANTok, XCanlcTok, 'CA');
        InsertUnitOfMeasure(XBOXTok, XBoxlcTok, 'BX');
        InsertUnitOfMeasure(XSETTok, XSetlcTok, 'SET');

        OnAfterDataInsert();
    end;

    var
        UnitOfMeasure: Record "Unit of Measure";
        XKGTok: Label 'KG', MaxLength = 10;
        XKiloTok: Label 'Kilo', MaxLength = 30;
        XGRTok: Label 'GR', MaxLength = 10;
        XGramTok: Label 'Gram', MaxLength = 30;
        XPCSTok: Label 'PCS', MaxLength = 10;
        XPiecesTok: Label 'Pieces', MaxLength = 30;
        XLTok: Label 'L', MaxLength = 10;
        XLiterTok: Label 'Liter', MaxLength = 30;
        XCANTok: Label 'CAN', MaxLength = 10;
        XCanlcTok: Label 'Can', MaxLength = 30;
        XBOXTok: Label 'BOX', MaxLength = 10;
        XBoxlcTok: Label 'Box', MaxLength = 30;
        XSETTok: Label 'SET', MaxLength = 10;
        XSetlcTok: Label 'Set', MaxLength = 30;

    local procedure InsertUnitOfMeasure("Code": Text[10]; Description: Text[30]; StdCode: Code[10])
    begin
        UnitOfMeasure.Validate(Code, Code);
        UnitOfMeasure.Validate(Description, Description);
        UnitOfMeasure.Validate("International Standard Code", StdCode);

        OnBeforeUnitOfMeasureInsert(UnitOfMeasure);

        if not UnitOfMeasure.Insert() then
            exit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUnitOfMeasureInsert(var UnitofMeasure: Record "Unit of Measure")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterDataInsert()
    begin
    end;
}