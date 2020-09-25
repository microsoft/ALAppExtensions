codeunit 10609 "Payroll Integration (NO)"
{

    trigger OnRun()
    begin
    end;

    var
        ExchDefinitionTxt: Label '<?xml version="1.0" encoding="UTF-8" standalone="no"?><root><DataExchDef Code="HULDT-LILLEVIK" Name="" Type="2" ReadingWritingXMLport="1220" ExternalDataHandlingCodeunit="1240" ColumnSeparator="2" FileType="1"><DataExchLineDef LineType="0" Code="HULDT-LILLEVIK" Name="HULDT-LILLEVIK" ColumnCount="17"><DataExchColumnDef ColumnNo="1" Name="AccountNo" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" /><DataExchColumnDef ColumnNo="2" Name="VATCode" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" /><DataExchColumnDef ColumnNo="3" Name="Department" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" /><DataExchColumnDef ColumnNo="4" Name="Project" Show="false" DataType="0" TextPaddingRequired="false" Justification="0" /><DataExchColumnDef ColumnNo="12" Name="PostingDate" Show="false" DataType="1" DataFormat="ddmmyyyy" DataFormattingCulture="nb-NO" TextPaddingRequired="false" Justification="0" /><DataExchColumnDef ColumnNo="15" Name="Quantity" Show="false" DataType="2" DataFormat="F" DataFormattingCulture="nb-NO" TextPaddingRequired="false" Justification="0" /><DataExchColumnDef ColumnNo="17" Name="Amount" Show="false" DataType="2" DataFormat="F" DataFormattingCulture="nb-NO" TextPaddingRequired="false" Justification="0" /><DataExchMapping TableId="81" Name="" MappingCodeunit="1247"><DataExchFieldMapping ColumnNo="1" FieldID="4" TransformationRule="EVAL_TXT_TO_INT"></DataExchFieldMapping><DataExchFieldMapping ColumnNo="3" FieldID="24" Optional="true" TransformationRule="BLANK_DIM_CODE"/><DataExchFieldMapping ColumnNo="4" FieldID="25" Optional="true" TransformationRule="BLANK_DIM_CODE"/><DataExchFieldMapping ColumnNo="12" FieldID="5"/><DataExchFieldMapping ColumnNo="15" FieldID="43" Optional="true" TransformationRule="AMOUNT_IN_CENTS"/><DataExchFieldMapping ColumnNo="17" FieldID="13" TransformationRule="AMOUNT_IN_CENTS"/></DataExchMapping></DataExchLineDef></DataExchDef></root>', Locked = true;
        HuldtAndLillevikTok: Label 'HULDT-LILLEVIK', Locked = true;
        HuldtAndLillevikTxt: Label 'Huldt & Lillevik Payroll - transactions import.';
        AmountInCentsTok: Label 'AMOUNT_IN_CENTS', locked = true;
        AmountInCentsTxt: label 'Transform amounts with leading zeros to decimal amounts.';
        EvaluateTextToIntegerTok: Label 'EVAL_TXT_TO_INT', locked = true;
        EvaluateTextToIntegerTxt: label 'Transform numeric strings with leading zeroes to integers.';
        BlankDimCodeTok: Label 'BLANK_DIM_CODE', locked = true;
        BlankDimCodeTxt: label 'Blank value if your company does not want to import dimension codes.';

    [EventSubscriber(ObjectType::Page, Page::"General Ledger Setup", 'OnOpenPageEvent', '', true, true)]
    local procedure OnSetupPageOpen(var Rec: Record "General Ledger Setup");
    begin
        CreateTransformationRules();
        ImportPayrollDataExchDef();
    end;

    local procedure CreateTransformationRules()
    begin
        CreateTransformationRule(AmountInCentsTok, AmountInCentsTxt);
        CreateTransformationRule(BlankDimCodeTok, BlankDimCodeTxt);
        CreateTransformationRule(EvaluateTextToIntegerTok, EvaluateTextToIntegerTxt);
    end;

    local procedure CreateTransformationRule(RuleCode: text; RuleDescription: text)
    var
        TransformationRule: Record "Transformation Rule";
    begin
        with TransformationRule do
            if not get(RuleCode) then begin
                Init();
                Code := CopyStr(RuleCode, 1, MaxStrLen(Code));
                Description := CopyStr(RuleDescription, 1, MaxStrLen(Description));
                "Transformation Type" := "Transformation Type"::Custom;
                Insert();
            end;
    end;

    local procedure ImportPayrollDataExchDef()
    var
        DataExchDef: record "Data Exch. Def";
    begin
        if not DataExchDef.get(HuldtAndLillevikTok) then begin
            ImportDataExchDefFromText(ExchDefinitionTxt);
            SetTranslatableNameForDataExchDef();
        end
    end;

    local procedure SetTranslatableNameForDataExchDef()
    var
        DataExchDef: record "Data Exch. Def";
    begin
        if DataExchDef.get(HuldtAndLillevikTok) then begin
            DataExchDef.Name := CopyStr(HuldtAndLillevikTxt, 1, MaxStrLen(DataExchDef.Name));
            DataExchDef.Modify();
        end;
    end;

    local procedure ImportDataExchDefFromText(DataExchDefData: Text)
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

    [EventSubscriber(ObjectType::Table, 1237, 'OnTransformation', '', false, false)]
    local procedure OnTransformation(TransformationCode: code[20]; InputText: text; var OutputText: text)
    var
        TypeHelper: Codeunit "Type Helper";
        Int: Integer;
    begin
        case TransformationCode of
            BlankDimCodeTok:
                if KeepTextBlank(InputText) then
                    OutputText := ''
                else
                    OutputText := InputText;
            AmountInCentsTok, EvaluateTextToIntegerTok:
                if Evaluate(Int, InputText) then
                    case TransformationCode of
                        AmountInCentsTok:
                            OutputText := TypeHelper.FormatDecimal(Int / 100, '', 'nn');
                        EvaluateTextToIntegerTok:
                            OutputText := TypeHelper.FormatDecimal(Int, '', 'nn')
                    end
                else
                    OutputText := InputText;
        end;
    end;

    local procedure KeepTextBlank(InputText: Text): Boolean
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        
        if not GeneralLedgerSetup."Import Dimension Codes" then
            exit(true);

        If not GeneralLedgerSetup."Ignore Zeros-Only Values" then
            exit(false);

        exit(StrLen(DelChr(InputText, '<>', '0')) = 0);
    end;

}

