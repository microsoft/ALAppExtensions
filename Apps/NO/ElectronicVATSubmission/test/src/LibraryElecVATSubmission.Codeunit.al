codeunit 148130 "Library - Elec. VAT Submission"
{
    trigger OnRun()
    begin
        // [FEATURE] [Electronic VAT Submission]
    end;

    var
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        UnexpectedElementNameErr: Label 'Unexpected element name. Expected element name: %1. Actual element name: %2.', Comment = '%1=Expetced XML Element Name;%2=Actual XML Element Name';
        UnexpectedElementValueErr: Label 'Unexpected element value for element %1. Expected element value: %2. Actual element value: %3.', Comment = '%1=XML Element Name;%2=Expected XML Element Value;%3=Actual XML element Value';

    procedure SetupEnabledEnvironmentForSubmission(URL: Text)
    var
        OAuth20Setup: Record "OAuth 2.0 Setup";
        ElectronicVATInstallationCodeunit: Codeunit "Electronic VAT Installation";
        ElecVATOAuthMgt: Codeunit "Elec. VAT OAuth Mgt.";
    begin
        ElectronicVATInstallationCodeunit.InsertElectronicVATSetup();
        ElecVATOAuthMgt.InitOAuthSetup(OAuth20Setup);
        SetOAuthSetupTestTokens(OAuth20Setup);
        OAuth20Setup.Modify(true);
    end;

    procedure GetVATReportConfigurationForSubmission(var VATReportsConfiguration: Record "VAT Reports Configuration"): Boolean
    begin
        VATReportsConfiguration.SetRange("Submission Codeunit ID", codeunit::"Elec. VAT Submit Return");
        exit(VATReportsConfiguration.FindFirst());
    end;

    procedure InsertElecVATReportHeader(var VATReportHeader: Record "VAT Report Header")
    var
        VATReportsConfiguration: Record "VAT Reports Configuration";
    begin
        GetVATReportConfigurationForSubmission(VATReportsConfiguration);
        VATReportHeader."VAT Report Config. Code" := VATReportsConfiguration."VAT Report Type";
        VATReportHeader."VAT Report Version" := VATReportsConfiguration."VAT Report Version";
        VATReportHeader."No." := LibraryUtility.GenerateGUID();
        VATReportHeader.Validate(KID, LibraryUtility.GenerateGUID());
        VATReportHeader.Insert(true);
    end;

    procedure InsertVATStatementReportLineWithBoxNo(var VATStatementReportLine: Record "VAT Statement Report Line"; VATReportHeader: Record "VAT Report Header"; BoxNo: Text[30])
    var
        LineNo: Integer;
    begin
        VATStatementReportLine.Reset();
        VATStatementReportLine.SetRange("VAT Report Config. Code", VATReportHeader."VAT Report Config. Code");
        VATStatementReportLine.SetRange("VAT Report No.", VATReportHeader."No.");
        if VATStatementReportLine.FindLast() then
            LineNo := VATStatementReportLine."Line No.";
        LineNo += 10000;
        VATStatementReportLine."VAT Report Config. Code" := VATReportHeader."VAT Report Config. Code";
        VATStatementReportLine."VAT Report No." := VATReportHeader."No.";
        VATStatementReportLine."Line No." := LineNo;
        VATStatementReportLine.Description := LibraryUtility.GenerateGUID();
        VATStatementReportLine."Box No." := BoxNo;
        VATStatementReportLine.Base := LibraryRandom.RandDec(100, 2);
        VATStatementReportLine.Amount := LibraryRandom.RandDec(100, 2);
        VATStatementReportLine.Insert();
    end;

    procedure CreateSimpleVATCode(): Code[20]
    var
        VATReportingCode: Record "VAT Reporting Code";
    begin
        VATReportingCode.Code := LibraryUtility.GenerateRandomCode(VATReportingCode.FieldNo(Code), Database::"VAT Reporting Code");
        VATReportingCode.Insert(true);
        exit(VATReportingCode.Code)
    end;

    procedure SetVATSpecificationAndNoteToVATCode(VATCodeValue: Code[20])
    var
        VATReportingCode: Record "VAT Reporting Code";
    begin
        VATReportingCode.Get(VATCodeValue);
        VATReportingCode.Validate("VAT Specification Code", CreateVATSpecification());
        VATReportingCode.Validate("VAT Note Code", CreateVATNote());
        VATReportingCode.Modify(true);
    end;

    procedure SetVATCodeReportVATRate(VATCodeValue: Code[20]; VATRate: Decimal)
    var
        VATReportingCode: Record "VAT Reporting Code";
    begin
        VATReportingCode.Get(VATCodeValue);
        VATReportingCode.Validate("Report VAT Rate", true);
        VATReportingCode.Validate("VAT Rate For Reporting", VATRate);
        VATReportingCode.Modify(true);
    end;

    procedure SetReportVATNoteInVATReportSetup(NewReportVATNote: Boolean)
    var
        VATReportSetup: Record "VAT Report Setup";
    begin
        VATReportSetup.Get();
        VATReportSetup.Validate("Report VAT Note", NewReportVATNote);
        VATReportSetup.Modify(true);
    end;

    procedure FindSubmissionXmlRequestHeaderElement(var TempXMLBuffer: Record "XML Buffer" temporary)
    begin
        TempXMLBuffer.FindNodesByXPath(TempXMLBuffer, 'mvaMeldingDto');
    end;

    procedure GetAmountTextRounded(Amount: Decimal): Text
    begin
        exit(Format(Round(Amount, 1, '<'), 0, '<Sign><Integer>'));
    end;

    procedure AssertElementValue(var TempXMLBuffer: Record "XML Buffer" temporary; ElementName: Text; ElementValue: Text)
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

    procedure GetOAuthSetup(var OAuth20Setup: Record "OAuth 2.0 Setup")
    var
        ElecVATOAuthMgt: Codeunit "Elec. VAT OAuth Mgt.";
    begin
        ElecVATOAuthMgt.GetOAuthSetup(OAuth20Setup);
    end;

    local procedure SetOAuthSetupTestTokens(var OAuth20Setup: Record "OAuth 2.0 Setup")
    begin
        with OAuth20Setup do begin
            SetToken("Client ID", 'Dummy Test Client ID');
            SetToken("Client Secret", 'Dummy Test Client Secret');
            SetToken("Access Token", 'Dummy Test Access Token');
            SetToken("Refresh Token", 'Dummy Test Refresh Token');
        end;
    end;

    local procedure CreateVATSpecification(): Code[50]
    var
        VATSpecification: Record "VAT Specification";
    begin
        VATSpecification.Validate(Code, LibraryUtility.GenerateGUID());
        VATSpecification.Validate("VAT Report Value", VATSpecification.Code);
        VATSpecification.Insert();
        exit(VATSpecification.Code);
    end;

    local procedure CreateVATNote(): Code[50]
    var
        VATNote: Record "VAT Note";
    begin
        VATNote.Validate(Code, LibraryUtility.GenerateGUID());
        VATNote.Validate("VAT Report Value", VATNote.Code);
        VATNote.Insert();
        exit(VATNote.Code);
    end;
}