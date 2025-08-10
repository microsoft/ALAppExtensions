codeunit 144080 "Serv. Decl. FR Export Tests"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Service Declaration] [Export]
    end;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        UnexpectedElementNameErr: Label 'Unexpected element name. Expected element name: %1. Actual element name: %2.', Comment = '%1=Expetced XML Element Name;%2=Actual XML Element Name';
        UnexpectedElementValueErr: Label 'Unexpected element value for element %1. Expected element value: %2. Actual element value: %3.', Comment = '%1=XML Element Name;%2=Expected XML Element Value;%3=Actual XML element Value';

    [Test]
    procedure BasicXMLFileStructure()
    var
        ServDeclSetup: Record "Service Declaration Setup";
        ServDeclHeader: Record "Service Declaration Header";
        ServDeclLine: Record "Service Declaration Line";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchTableFilter: Record "Data Exch. Table Filter";
        TempXMLBuffer: Record "XML Buffer" temporary;
        CompanyInformation: Record "Company Information";
        ServDeclMgt: Codeunit "Service Declaration Mgt.";
        OutStr: OutStream;
        InStr: InStream;
    begin
        // [SCENARIO 437878] The structure of the service declaration XML for basic scenario with two lines is correct

        Initialize();
        // [GIVEN] "VAT Registration No." in the Company Information is "X"
        ServDeclMgt.InsertSetup(ServDeclSetup);
        // [GIVEN] Service declaration with "No." = "SERVDECL-0001", "Starting Date" = "01.02.2022", "Ending Date" = "28.02.2022"            
        ServDeclHeader."Starting Date" := WorkDate();
        ServDeclHeader."Ending Date" := CalcDate('<CM>', WorkDate());
        ServDeclHeader.Insert(true);
        // [GIVEN] Two service declaration lines - for sales and purchase
        // [GIVEN] Sales line has "VAT Registration No." = "ES123456789" and "Sales Amount (LCY)" = 100
        ServDeclLine."Service Declaration No." := ServDeclHeader."No.";
        ServDeclLine."Line No." := 10000;
        ServDeclLine."VAT Reg. No." := LibraryUtility.GenerateGUID();
        ServDeclLine."Sales Amount (LCY)" := LibraryRandom.RandDec(100, 2);
        ServDeclLine.Insert();
        ServDeclLine.Init();
        // [GIVEN] Purchase line has "VAT Registration No." = "DE987654321" and "Purchase Amount (LCY)" = 200
        ServDeclLine."Service Declaration No." := ServDeclHeader."No.";
        ServDeclLine."Line No." := 20000;
        ServDeclLine."VAT Reg. No." := LibraryUtility.GenerateGUID();
        ServDeclLine."Purchase Amount (LCY)" := LibraryRandom.RandDec(100, 2);
        ServDeclLine.Insert();

        // [GIVEN] Data exchange definition setup that mimics the setup codeuinit id
        DataExchDef.Get(ServDeclSetup."Data Exch. Def. Code");
        DataExchMapping.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchMapping.SetRange("Table ID", DATABASE::"Service Declaration Line");
        DataExchMapping.FindFirst();
        DataExch.Init();
        DataExch."Data Exch. Def Code" := DataExchMapping."Data Exch. Def Code";
        DataExch."Data Exch. Line Def Code" := DataExchMapping."Data Exch. Line Def Code";
        DataExch."Table Filters".CreateOutStream(OutStr);
        ServDeclLine.SetRange("Service Declaration No.", ServDeclLine."Service Declaration No.");
        OutStr.WriteText(ServDeclLine.GetView(false));
        DataExch.Insert(true);
        DataExchTableFilter.Init();
        DataExchTableFilter."Data Exch. No." := DataExch."Entry No.";
        DataExchTableFilter."Table ID" := Database::"Service Declaration Header";
        DataExchTableFilter."Table Filters".CreateOutStream(OutStr);
        ServDeclHeader.SetRecFilter();
        OutStr.WriteText(ServDeclHeader.GetView(false));
        DataExchTableFilter.Insert();
        DataExchTableFilter.Init();
        DataExchTableFilter."Data Exch. No." := DataExch."Entry No.";
        DataExchTableFilter."Table ID" := Database::"Company Information";
        DataExchTableFilter."Table Filters".CreateOutStream(OutStr);
        CompanyInformation.FindFirst();
        CompanyInformation.SetRecFilter();
        OutStr.WriteText(CompanyInformation.GetView(false));
        DataExchTableFilter.Insert();
        Codeunit.Run(Codeunit::"Export Mapping", DataExch);

        // [WHEN] Generate XML by the given data exchange definition
        Codeunit.Run(Codeunit::"Export Generic XML", DataExch);

        // [THEN] The structure of the XML file is correct
        DataExch.CalcFields("File Content");
        DataExch.TestField("File Content");
        DataExch."File Content".CreateInStream(InStr);
        TempXMLBuffer.Reset();
        TempXMLBuffer.DeleteAll();
        TempXMLBuffer.LoadFromStream(InStr);
        // [THEN] The file starts with "fichier_des" xml root element
        TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, '/fichier_des');
        // [THEN] the header contains 4 elements: "num_des" = "SERVDECL-0001", "an_des" = "2" (February), "mois_des" = 2022 and "num_tvaFr" = "X"
        AssertElementValue(TempXMLBuffer, 'num_des', ServDeclHeader."No.");
        AssertElementValue(TempXMLBuffer, 'an_des', Format(Date2DMY(ServDeclHeader."Starting Date", 2)));
        AssertElementValue(TempXMLBuffer, 'mois_des', Format(Date2DMY(ServDeclHeader."Starting Date", 3)));
        CompanyInformation.Get();
        AssertElementValue(TempXMLBuffer, 'num_tvaFr', CompanyInformation."VAT Registration No.");
        // [THEN] Each line exports to the "ligne_des" xml node
        ServDeclLine.FindSet();
        // [THEN] Sales "ligne_des" xml node contains 3 elements: "numlin_des" = 10000, "partner_des" = "ES123456789", "valeur" = 100
        CheckServDeclLineXML(TempXMLBuffer, ServDeclLine, ServDeclLine."Sales Amount (LCY)");
        ServDeclLine.Next();
        // [THEN] Purchase "ligne_des" xml node contains 3 elements: "numlin_des" = 20000, "partner_des" = "DE987654321", "valeur" = 200
        CheckServDeclLineXML(TempXMLBuffer, ServDeclLine, ServDeclLine."Purchase Amount (LCY)");
    end;

    local procedure CheckServDeclLineXML(var TempXMLBuffer: Record "XML Buffer" temporary; ServDeclLine: Record "Service Declaration Line"; Amount: Decimal)
    begin
        AssertElementName(TempXMLBuffer, 'ligne_des');
        AssertElementValue(TempXMLBuffer, 'numlin_des', Format(ServDeclLine."Line No."));
        AssertElementValue(TempXMLBuffer, 'partner_des', ServDeclLine."VAT Reg. No.");
        AssertElementValue(TempXMLBuffer, 'valeur', Format(Amount));
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Serv. Decl. FR Export Tests");
        LibrarySetupStorage.Restore();
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Serv. Decl. FR Export Tests");
        LibrarySetupStorage.Save(Database::"Service Declaration Setup");
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Serv. Decl. FR Export Tests");
    end;

    local procedure AssertElementValue(var TempXMLBuffer: Record "XML Buffer" temporary; ElementName: Text; ElementValue: Text)
    begin
        FindNextElement(TempXMLBuffer);
        AssertCurrentElementValue(TempXMLBuffer, ElementName, ElementValue);
    end;

    procedure FindNextElement(var TempXMLBuffer: Record "XML Buffer" temporary)
    begin
        if TempXMLBuffer.HasChildNodes() then
            TempXMLBuffer.FindChildElements(TempXMLBuffer)
        else
            if not (TempXMLBuffer.Next() > 0) then begin
                TempXMLBuffer.GetParent();
                TempXMLBuffer.SetRange("Parent Entry No.", TempXMLBuffer."Parent Entry No.");
                if not (TempXMLBuffer.Next() > 0) then
                    repeat
                        TempXMLBuffer.GetParent();
                        TempXMLBuffer.SetRange("Parent Entry No.", TempXMLBuffer."Parent Entry No.");
                    until TempXMLBuffer.Next() > 0;
            end;
    end;

    procedure AssertCurrentElementValue(var TempXMLBuffer: Record "XML Buffer" temporary; ElementName: Text; ElementValue: Text)
    begin
        Assert.AreEqual(ElementName, TempXMLBuffer.GetElementName(),
            StrSubstNo(UnexpectedElementNameErr, ElementName, TempXMLBuffer.GetElementName()));
        Assert.AreEqual(ElementValue, TempXMLBuffer.Value,
            StrSubstNo(UnexpectedElementValueErr, ElementName, ElementValue, TempXMLBuffer.Value));
    end;

    procedure AssertElementName(var TempXMLBuffer: Record "XML Buffer" temporary; ElementName: Text)
    begin
        FindNextElement(TempXMLBuffer);
        AssertCurrentElementName(TempXMLBuffer, ElementName);
    end;

    procedure AssertCurrentElementName(var TempXMLBuffer: Record "XML Buffer" temporary; ElementName: Text)
    begin
        Assert.AreEqual(ElementName, TempXMLBuffer.GetElementName(),
            StrSubstNo(UnexpectedElementNameErr, ElementName, TempXMLBuffer.GetElementName()));
    end;
}
