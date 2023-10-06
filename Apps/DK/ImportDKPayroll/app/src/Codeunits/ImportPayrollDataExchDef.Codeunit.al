// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Payroll;

using Microsoft.Finance.GeneralLedger.Setup;
using System.Environment.Configuration;
using System.IO;
using System.Utilities;

codeunit 13640 ImportPayrollDataExchDef
{
    var
        DanloenExchDefTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root>  <DataExchDef Code="DANLOEN" Name="DANLOEN" Type="2" ReadingWritingXMLport="1220" ExternalDataHandlingCodeunit="1240" HeaderLines="1" ColumnSeparator="2" FileType="1">    <DataExchLineDef Code="DANLOEN" Name="DANLOEN" ColumnCount="0">      <DataExchColumnDef ColumnNo="1" Name="CVR-Nr." Show="false" DataType="0" />      <DataExchColumnDef ColumnNo="2" Name="Transaktions Dato" Show="true" DataType="1" DataFormat="yyyy-MM-dd" DataFormattingCulture="da-dk" />      <DataExchColumnDef ColumnNo="3" Name="UKENDT" Show="false" DataType="0" />      <DataExchColumnDef ColumnNo="4" Name="Konto Nr." Show="true" DataType="2" DataFormattingCulture="da-DK" />      <DataExchColumnDef ColumnNo="5" Name="CPR-Nr." Show="false" DataType="2" DataFormattingCulture="da-DK" />      <DataExchColumnDef ColumnNo="6" Name="Beløb" Show="true" DataType="2" DataFormattingCulture="da-DK" />      <DataExchColumnDef ColumnNo="7" Name="Lønart" Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="8" Name="Periode" Show="true" DataType="0" />      <DataExchMapping TableId="81" Name="Danløn Til Finanskladdelinje" MappingCodeunit="1247" DataExchNoFieldID="1220" DataExchLineFieldID="1223">        <DataExchFieldMapping ColumnNo="2" FieldID="5" />        <DataExchFieldMapping ColumnNo="4" FieldID="4" />        <DataExchFieldMapping ColumnNo="5" FieldID="1222" Optional="true" />        <DataExchFieldMapping ColumnNo="6" FieldID="13" />        <DataExchFieldMapping ColumnNo="7" FieldID="8" />        <DataExchFieldMapping ColumnNo="8" FieldID="1222" Optional="true" />      </DataExchMapping>    </DataExchLineDef>  </DataExchDef></root>', Locked = true;
        DataloenExchDefTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root>  <DataExchDef Code="DATALOEN" Name="DATALOEN" Type="2" ReadingWritingXMLport="1220" ExternalDataHandlingCodeunit="1240" ColumnSeparator="1" FileType="1">    <DataExchLineDef Code="DATALOEN" Name="DATALOEN" ColumnCount="0">      <DataExchColumnDef ColumnNo="1" Name="Dato" Show="true" DataType="1" DataFormat="dd.MM.yyyy" DataFormattingCulture="da-DK" />      <DataExchColumnDef ColumnNo="2" Name="KontoNr." Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="3" Name="Beløb" Show="true" DataType="2" DataFormattingCulture="da-DK" />      <DataExchColumnDef ColumnNo="4" Name="Tekst" Show="true" DataType="0" />      <DataExchMapping TableId="81" Name="Dataløn Til Finanskladdelinje" MappingCodeunit="1247" DataExchNoFieldID="1220" DataExchLineFieldID="1223">        <DataExchFieldMapping ColumnNo="1" FieldID="5" />        <DataExchFieldMapping ColumnNo="2" FieldID="4" />        <DataExchFieldMapping ColumnNo="3" FieldID="13" />        <DataExchFieldMapping ColumnNo="4" FieldID="8" />      </DataExchMapping>    </DataExchLineDef>  </DataExchDef></root>', Locked = true;
        LoenserviceExchDefTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root>  <DataExchDef Code="LOENSERVICE" Name="LOENSERVICE" Type="2" ReadingWritingXMLport="1220" ExternalDataHandlingCodeunit="1240" ColumnSeparator="2" FileType="1">    <DataExchLineDef Code="LOENSERVICE" Name="LOENSERVICE" ColumnCount="0">      <DataExchColumnDef ColumnNo="1" Name="Dato" Show="true" DataType="1" DataFormat="dd.MM.yyyy" DataFormattingCulture="da-DK" />      <DataExchColumnDef ColumnNo="2" Name="KontoNr." Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="3" Name="Beløb" Show="true" DataType="2" DataFormattingCulture="da-DK" />      <DataExchColumnDef ColumnNo="4" Name="Tekst" Show="true" DataType="0" />      <DataExchMapping TableId="81" Name="Lønservice Til Finanskladdelinje" MappingCodeunit="1247" DataExchNoFieldID="1220" DataExchLineFieldID="1223">        <DataExchFieldMapping ColumnNo="1" FieldID="5" />        <DataExchFieldMapping ColumnNo="2" FieldID="4" />        <DataExchFieldMapping ColumnNo="3" FieldID="13" />        <DataExchFieldMapping ColumnNo="4" FieldID="8" />      </DataExchMapping>    </DataExchLineDef>  </DataExchDef></root>', Locked = true;
        MultiloenExchDefTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root>  <DataExchDef Code="MULTILOEN" Name="MULTILOEN" Type="2" ReadingWritingXMLport="1220" ExternalDataHandlingCodeunit="1240" HeaderLines="1" ColumnSeparator="2" FileType="1">    <DataExchLineDef Code="MULTILOEN" Name="MULTILOEN" ColumnCount="0">      <DataExchColumnDef ColumnNo="1" Name="Arbejdsgiver" Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="2" Name="Kørselsnummer" Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="3" Name="Kørselstext" Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="4" Name="Kontotekst" Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="5" Name="Afdeling" Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="6" Name="Kontonr" Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="7" Name="Debet" Show="true" DataType="2" DataFormattingCulture="da-DK" />      <DataExchColumnDef ColumnNo="8" Name="Kredit" Show="true" DataType="2" DataFormattingCulture="da-DK" />      <DataExchMapping TableId="81" Name="Multiløn Til Finanskladdelinje" MappingCodeunit="1247" DataExchNoFieldID="1220" DataExchLineFieldID="1223">        <DataExchFieldMapping ColumnNo="2" FieldID="1222" />        <DataExchFieldMapping ColumnNo="3" FieldID="1222" />        <DataExchFieldMapping ColumnNo="4" FieldID="8" />        <DataExchFieldMapping ColumnNo="6" FieldID="4" />        <DataExchFieldMapping ColumnNo="7" FieldID="14" Optional="true" />        <DataExchFieldMapping ColumnNo="8" FieldID="15" Optional="true" />      </DataExchMapping>    </DataExchLineDef>  </DataExchDef></root>', Locked = true;
        ProloenExchDefTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root>  <DataExchDef Code="PROLOEN" Name="PROLOEN" Type="2" ReadingWritingXMLport="13600" ExternalDataHandlingCodeunit="1240" HeaderLines="1" ColumnSeparator="2" FileType="1">    <DataExchLineDef Code="PROLOEN" Name="PROLOEN" ColumnCount="0">      <DataExchColumnDef ColumnNo="1" Name="LINJENR-1" Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="2" Name="LINJENR-2" Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="3" Name="AFDELING" Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="4" Name="LØNART" Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="5" Name="BELØB" Show="true" DataType="2" DataFormattingCulture="da-DK" />      <DataExchColumnDef ColumnNo="6" Name="D/K" Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="7" Name="PERIODE" Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="8" Name="LINJETEKST" Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="9" Name="AFDELINGSSTEKST" Show="true" DataType="0" />      <DataExchColumnDef ColumnNo="10" Name="LØNARTSTEKST" Show="true" DataType="0" />      <DataExchMapping TableId="81" Name="Proløn Til Finanskladdelinje" MappingCodeunit="1247" DataExchNoFieldID="1220" DataExchLineFieldID="1223">        <DataExchFieldMapping ColumnNo="2" FieldID="4" />        <DataExchFieldMapping ColumnNo="5" FieldID="13" />        <DataExchFieldMapping ColumnNo="7" FieldID="1222" />        <DataExchFieldMapping ColumnNo="8" FieldID="8" />        <DataExchFieldMapping ColumnNo="9" FieldID="1222" Optional="true" />        <DataExchFieldMapping ColumnNo="10" FieldID="1222" Optional="true" />      </DataExchMapping>    </DataExchLineDef>  </DataExchDef></root>', Locked = true;
        SetupDKPayrollServiceTitleTxt: Label 'Ready for Danish payroll';
        SetupDKPayrollServiceShortTitleTxt: Label 'Payroll Definitions';
        SetupDKPayrollServiceDescriptionTxt: Label 'Set up your Business Central to be able to import payroll data from Danish service providers such as Danloen, Dataloen, Loenservice, Multiloen, and Proloen.';

    trigger OnRun();
    begin
        ImportPayrollDataExchDef();
    end;

    [EventSubscriber(ObjectType::Page, Page::"General Ledger Setup", 'OnOpenPageEvent', '', true, true)]
    local procedure OnSetupPageOpen(var Rec: Record "General Ledger Setup");
    begin
        ImportPayrollDataExchDef();
    end;

    local procedure ImportPayrollDataExchDef();
    begin
        if not IsImported('DANLOEN') then
            ImportDataExchDefFromText(DanloenExchDefTxt);
        if not IsImported('DATALOEN') then
            ImportDataExchDefFromText(DataloenExchDefTxt);
        if not IsImported('LOENSERVICE') then
            ImportDataExchDefFromText(LoenserviceExchDefTxt);
        if not IsImported('MULTILOEN') then
            ImportDataExchDefFromText(MultiloenExchDefTxt);
        if not IsImported('PROLOEN') then
            ImportDataExchDefFromText(ProloenExchDefTxt);
    end;

    local procedure IsImported(DataExchDefCode: Code[20]): Boolean;
    var
        DataExchDef: record "Data Exch. Def";
    begin
        DataExchDef.SetRange(Type, DataExchDef.Type::"Payroll Import");
        DataExchDef.SetRange(Code, DataExchDefCode);
        exit(NOT DataExchDef.IsEmpty());
    end;

    local procedure ImportDataExchDefFromText(DataExchDefData: Text);
    var
        TempBlob: Codeunit "Temp Blob";
        FileDataOutStream: OutStream;
        DataExchDefinStream: InStream;
    begin
        TempBlob.CreateOutStream(FileDataOutStream, TextEncoding::UTF8);
        TempBlob.CreateInStream(DataExchDefinStream, TextEncoding::UTF8);

        FileDataOutStream.WriteText(DataExchDefData);
        CopyStream(FileDataOutStream, DataExchDefinStream);

        Xmlport.Import(Xmlport::"Imp / Exp Data Exch Def & Map", DataExchDefinStream);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterManualSetup', '', true, true)]
    local procedure InsertIntoMAnualSetupOnRegisterManualSetup()
    var
        GuidedExperience: Codeunit "Guided Experience";
    begin
        GuidedExperience.InsertManualSetup(SetupDKPayrollServiceTitleTxt, SetupDKPayrollServiceShortTitleTxt, SetupDKPayrollServiceDescriptionTxt, 5, ObjectType::Page, Page::"Setup DK Payroll Service", "Manual Setup Category"::Finance, '', true);
    end;
}
