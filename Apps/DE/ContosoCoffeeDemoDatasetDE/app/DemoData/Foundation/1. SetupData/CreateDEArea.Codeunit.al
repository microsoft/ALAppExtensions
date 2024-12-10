codeunit 11118 "Create DE Area"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoArea: Codeunit "Contoso Receiver/Dispatcher DE";
    begin
        ContosoArea.InsertAreaData(AreaCode1(), AreaCode1Lbl);
        ContosoArea.InsertAreaData(AreaCode2(), AreaCode2Lbl);
        ContosoArea.InsertAreaData(AreaCode3(), AreaCode3Lbl);
        ContosoArea.InsertAreaData(AreaCode4(), AreaCode4Lbl);
        ContosoArea.InsertAreaData(AreaCode5(), AreaCode5Lbl);
        ContosoArea.InsertAreaData(AreaCode6(), AreaCode6Lbl);
        ContosoArea.InsertAreaData(AreaCode7(), AreaCode7Lbl);
        ContosoArea.InsertAreaData(AreaCode8(), AreaCode8Lbl);
        ContosoArea.InsertAreaData(AreaCode9(), AreaCode9Lbl);
        ContosoArea.InsertAreaData(AreaCode10(), AreaCode10Lbl);
        ContosoArea.InsertAreaData(AreaCode11(), AreaCode11Lbl);
        ContosoArea.InsertAreaData(AreaCode12(), AreaCode12Lbl);
        ContosoArea.InsertAreaData(AreaCode13(), AreaCode13Lbl);
        ContosoArea.InsertAreaData(AreaCode14(), AreaCode14Lbl);
        ContosoArea.InsertAreaData(AreaCode15(), AreaCode15Lbl);
        ContosoArea.InsertAreaData(AreaCode16(), AreaCode16Lbl);
        ContosoArea.InsertAreaData(AreaCode25(), AreaCode25Lbl);
        ContosoArea.InsertAreaData(AreaCode99(), AreaCode99Lbl);
    end;

    procedure AreaCode1(): Code[10]
    begin
        exit('01');
    end;

    procedure AreaCode2(): Code[10]
    begin
        exit('02');
    end;

    procedure AreaCode3(): Code[10]
    begin
        exit('03');
    end;

    procedure AreaCode4(): Code[10]
    begin
        exit('04');
    end;

    procedure AreaCode5(): Code[10]
    begin
        exit('05');
    end;

    procedure AreaCode6(): Code[10]
    begin
        exit('06');
    end;

    procedure AreaCode7(): Code[10]
    begin
        exit('07');
    end;

    procedure AreaCode8(): Code[10]
    begin
        exit('08');
    end;

    procedure AreaCode9(): Code[10]
    begin
        exit('09');
    end;

    procedure AreaCode10(): Code[10]
    begin
        exit('10');
    end;

    procedure AreaCode11(): Code[10]
    begin
        exit('11');
    end;

    procedure AreaCode12(): Code[10]
    begin
        exit('12');
    end;

    procedure AreaCode13(): Code[10]
    begin
        exit('13');
    end;

    procedure AreaCode14(): Code[10]
    begin
        exit('14');
    end;

    procedure AreaCode15(): Code[10]
    begin
        exit('15');
    end;

    procedure AreaCode16(): Code[10]
    begin
        exit('16');
    end;

    procedure AreaCode25(): Code[10]
    begin
        exit('25');
    end;

    procedure AreaCode99(): Code[10]
    begin
        exit('99');
    end;

    var
        AreaCode1Lbl: Label 'Schleswig-Holstein', MaxLength = 250;
        AreaCode2Lbl: Label 'Hamburg', MaxLength = 250;
        AreaCode3Lbl: Label 'Niedersachsen', MaxLength = 250;
        AreaCode4Lbl: Label 'Bremen', MaxLength = 250;
        AreaCode5Lbl: Label 'Nordrhein-Westfalen', MaxLength = 250;
        AreaCode6Lbl: Label 'Hessen', MaxLength = 250;
        AreaCode7Lbl: Label 'Rheinland-Pfalz', MaxLength = 250;
        AreaCode8Lbl: Label 'Baden-Württemberg', MaxLength = 250;
        AreaCode9Lbl: Label 'Bayern', MaxLength = 250;
        AreaCode10Lbl: Label 'Saarland', MaxLength = 250;
        AreaCode11Lbl: Label 'Berlin', MaxLength = 250;
        AreaCode12Lbl: Label 'Brandenburg', MaxLength = 250;
        AreaCode13Lbl: Label 'Mecklenburg-Vorpommern', MaxLength = 250;
        AreaCode14Lbl: Label 'Sachsen', MaxLength = 250;
        AreaCode15Lbl: Label 'Sachsen-Anhalt', MaxLength = 250;
        AreaCode16Lbl: Label 'Thüringen', MaxLength = 250;
        AreaCode25Lbl: Label 'Ausland (Eingang)', MaxLength = 250;
        AreaCode99Lbl: Label 'Ausland (Versendung)', MaxLength = 250;
}