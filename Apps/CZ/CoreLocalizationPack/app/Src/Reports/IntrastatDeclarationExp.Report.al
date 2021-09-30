report 31107 "Intrastat Declaration Exp. CZL"
{
    Caption = 'Intrastat Declaration Export';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Intrastat Jnl. Batch"; "Intrastat Jnl. Batch")
        {
            DataItemTableView = sorting("Journal Template Name", Name);
            dataitem("Intrastat Jnl. Line"; "Intrastat Jnl. Line")
            {
                DataItemLink = "Journal Template Name" = field("Journal Template Name"), "Journal Batch Name" = field(Name);
                DataItemTableView = sorting("Journal Template Name", "Journal Batch Name", "Line No.");
            }
        }
    }

    trigger OnPreReport()
    begin
        GetOneIntrastatJnlBatch();
        IntrastatJnlBatch.TestField(Reported, false);
        InitExport();
        MainLoop();
        FinishExport();
        CurrReport.Quit();
    end;

    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        IntrastatJnlBatch: Record "Intrastat Jnl. Batch";
        IntrastatJnlLine: Record "Intrastat Jnl. Line";
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        DataTypeManagement: Codeunit "Data Type Management";
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        OutStream: OutStream;
        Direction: Text[1];
        Month: Text[2];
        VATRegNo: Text[10];
        Year: Text[4];
        LengthExceededErr: Label 'The formatted value %1 = %2 has exceeded the maximum length of %3 characters in %4', Comment = '%1=caption of a field, %2=text value, %3=integer, %4=key of record';
        NullSatementWithLinesErr: Label 'There must not be any Intrastat Jnl. Lines if you choose Null Statement!';

    local procedure GetOneIntrastatJnlBatch()
    begin
        IntrastatJnlBatch.Copy("Intrastat Jnl. Batch");
        if IntrastatJnlBatch.GetFilters() = '' then begin
            IntrastatJnlLine.Copy("Intrastat Jnl. Line");
            if IntrastatJnlLine.GetFilters() = '' then
                "Intrastat Jnl. Line".FilterGroup := 2;
            if IntrastatJnlBatch.GetFilter("Journal Template Name") = '' then
                "Intrastat Jnl. Line".CopyFilter("Journal Template Name", IntrastatJnlBatch."Journal Template Name");
            if IntrastatJnlBatch.GetFilter(Name) = '' then
                "Intrastat Jnl. Line".CopyFilter("Journal Batch Name", IntrastatJnlBatch.Name);
            "Intrastat Jnl. Line".FilterGroup := 0;
        end;
        IntrastatJnlBatch.FindFirst();
    end;

    local procedure InitExport()
    begin
        GeneralLedgerSetup.Get();
        CompanyInformation.Get();
        StatutoryReportingSetupCZL.Get();
        GetRoundingDirection();

        Month := CopyStr(IntrastatJnlBatch."Statistics Period", 3, 2);
        Year := '20' + CopyStr(IntrastatJnlBatch."Statistics Period", 1, 2);
        if CopyStr(CompanyInformation."VAT Registration No.", 1, 2) = CompanyInformation."Country/Region Code" then
            VATRegNo := CopyStr(CompanyInformation."VAT Registration No.", 3, 10)
        else
            VATRegNo := CopyStr(CompanyInformation."VAT Registration No.", 1, 10);

        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
    end;

    local procedure MainLoop()
    var
        FieldValue: array[20] of Text;
        IsHandled: Boolean;
    begin
        IntrastatJnlLine.Reset();
        IntrastatJnlLine.SetRange("Journal Template Name", IntrastatJnlBatch."Journal Template Name");
        IntrastatJnlLine.SetRange("Journal Batch Name", IntrastatJnlBatch.Name);
        if not IntrastatJnlLine.FindSet() then
            exit;
        if IntrastatJnlBatch."Statement Type CZL" = IntrastatJnlBatch."Statement Type CZL"::Null then
            error(NullSatementWithLinesErr);
        repeat
            IsHandled := false;
            OnBeforeFormatIntrastatJnlLineValues(IntrastatJnlLine, FieldValue, IsHandled);
            if not IsHandled then
                FormatIntrastatJnlLineValues(FieldValue);
            OnAfterFormatIntrastatJnlLineValues(IntrastatJnlLine, FieldValue);
            OutStream.WriteText(BuildCSVRow(FieldValue, 20));
            OutStream.WriteText();
        until IntrastatJnlLine.Next() = 0;
    end;

    local procedure FinishExport()
    var
        IsHandled: Boolean;
    begin
        if not TempBlob.HasValue() then
            exit;

        IsHandled := false;
        OnBeforeDownloadExport(TempBlob, IsHandled);
        if not IsHandled then
            FileManagement.BLOBExport(TempBlob, '*.csv', true);

        IntrastatJnlBatch.Reported := true;
        OnBeforeModifyIntrastatJnlBatch(IntrastatJnlBatch);
        IntrastatJnlBatch.Modify();
        Commit();
    end;

    local procedure FormatIntrastatJnlLineValues(var FieldValue: array[20] of Text)
    begin
        FieldValue[1] := Month; //Month of declaration
        FieldValue[2] := Year; //Year of declaration
        FieldValue[3] := VATRegNo; //VAT registration number (DIC) without prefix CZ
        FieldValue[4] := Format(IntrastatJnlLine.Type + 1); //Arrival / Dispatch
        FieldValue[5] := CopyStr(IntrastatJnlLine."Country/Region Code", 1, 2); //Country of dispatch / arrival
        FieldValue[6] := GetIntrastatJnlLineShipmentArea(); //Region of dispatch / arrival
        FieldValue[7] := GetIntrastatJnlLineShipmentCountryRegionofOrigin(); //Country of origin
        FieldValue[8] := CopyStr(IntrastatJnlLine."Transaction Type", 1, 2); //Nature of transaction
        FieldValue[9] := CopyStr(IntrastatJnlLine."Transport Method", 1, 1); //Nature of transport
        FieldValue[10] := CopyStr(GetDeliveryGroupCode(), 1, 1); //Delivery terms
        FieldValue[11] := GetDeclarationTypeCode(); //Code of movement (special)
        FieldValue[12] := CopyStr(DelChr(IntrastatJnlLine."Tariff No.", '=', ' '), 1, 8); //Combined nomenclature CN8
        FieldValue[13] := CopyStr(IntrastatJnlLine."Statistic Indication CZL", 1, 2); //Statistical sign (additional code)
        FieldValue[14] := CopyStr(IntrastatJnlLine."Item Description", 1, 80); //Description of goods
        FieldValue[15] := FormatWeight(); //Net mass
        FieldValue[16] := FormatQuantity(); //Quantity in supplementary units
        FieldValue[17] := FormatAmount(); //Invoiced value
        FieldValue[18] := ''; //Statistical value. It is not filled out.
        FieldValue[19] := ''; //Internal note 1. Maximal length 40.
        FieldValue[20] := ''; //Internal note 2. Maximal length 40.
    end;

    local procedure BuildCSVRow(FieldValue: array[20] of Text; NoOfFields: Integer) Result: Text
    var
        i: Integer;
        DelimeterTok: Label '"', Locked = true;
        SeparatorTok: Label ';', Locked = true;
    begin
        for i := 1 to NoOfFields do
            Result += SeparatorTok + DelimeterTok + FieldValue[i] + DelimeterTok;
        Result := CopyStr(Result, 2);
    end;

    local procedure GetIntrastatJnlLineShipmentArea(): Text[2]
    begin
        if IntrastatJnlLine.Type = IntrastatJnlLine.Type::Shipment then
            exit(CopyStr(IntrastatJnlLine."Area", 1, 2));
    end;

    local procedure GetIntrastatJnlLineShipmentCountryRegionofOrigin(): Text[2]
    begin
        if (IntrastatJnlLine.Type <> IntrastatJnlLine.Type::Shipment) then
            exit(CopyStr(IntrastatJnlLine."Country/Region of Origin Code", 1, 2));
    end;

    local procedure GetRoundingDirection()
    begin
        case StatutoryReportingSetupCZL."Intrastat Rounding Type" of
            StatutoryReportingSetupCZL."Intrastat Rounding Type"::Nearest:
                Direction := '=';
            StatutoryReportingSetupCZL."Intrastat Rounding Type"::Up:
                Direction := '>';
            StatutoryReportingSetupCZL."Intrastat Rounding Type"::Down:
                Direction := '<';
        end;
    end;

    local procedure GetDeclarationTypeCode(): Text[2]
    var
        NnTok: Label 'NN', Locked = true;
        StTok: Label 'ST', Locked = true;
    begin
        if IntrastatJnlBatch."Statement Type CZL" <> IntrastatJnlBatch."Statement Type CZL"::Null then begin
            if IntrastatJnlLine."Specific Movement CZL" <> '' then
                exit(CopyStr(IntrastatJnlLine."Specific Movement CZL", 1, 2));
            exit(StTok); //ST - standard declaration
        end;
        exit(NnTok); //NN - nil (negative) declaration
    end;

    local procedure GetDeliveryGroupCode(): Code[10]
    var
        ShipmentMethod: Record "Shipment Method";
    begin
        ShipmentMethod.Get(IntrastatJnlLine."Shpt. Method Code");
        exit(ShipmentMethod."Intrastat Deliv. Grp. Code CZL");
    end;

    local procedure FormatWeight() FormattedValue: Text
    begin
        if IntrastatJnlLine."Total Weight" <= 1 then
            exit(Format(IntrastatJnlLine."Total Weight", 0, PrecisionFormat()));
        FormattedValue := Format(Round(IntrastatJnlLine."Total Weight", 1, '>'), 0, PrecisionFormat());
        TestMaxLength(IntrastatJnlLine, IntrastatJnlLine.FieldNo("Total Weight"), FormattedValue, 14);
    end;

    local procedure FormatQuantity() FormattedValue: Text
    var
        TariffNumber: Record "Tariff Number";
    begin
        TariffNumber.Get(IntrastatJnlLine."Tariff No.");
#if not CLEAN18
        TariffNumber.CalcFields("Supplementary Units");
#endif
        if not TariffNumber."Supplementary Units" then
            exit(Format(0.0, 0, PrecisionFormat()));
        FormattedValue := Format(IntrastatJnlLine."Supplem. UoM Quantity CZL", 0, PrecisionFormat());
        TestMaxLength(IntrastatJnlLine, IntrastatJnlLine.FieldNo("Supplem. UoM Quantity CZL"), FormattedValue, 14);
    end;

    local procedure FormatAmount() FormattedValue: Text
    begin
        FormattedValue := Format(Round(IntrastatJnlLine.Amount, 1, Direction), 0, 9);
        TestMaxLength(IntrastatJnlLine, IntrastatJnlLine.FieldNo(Amount), FormattedValue, 14);
    end;

    local procedure PrecisionFormat(): Text
    begin
        exit('<Precision,3:3><Standard Format,9>');
    end;

    local procedure TestMaxLength(RecRelatedVariant: Variant; FieldNumber: Integer; FormattedValue: Text; MaxLength: Integer)
    var
        FieldRef: FieldRef;
        RecordRef: RecordRef;
    begin
        if StrLen(FormattedValue) <= MaxLength then
            exit;
        if not DataTypeManagement.GetRecordRefAndFieldRef(RecRelatedVariant, FieldNumber, RecordRef, FieldRef) then
            exit;
        error(LengthExceededErr, FieldRef.Caption, FormattedValue, MaxLength, Format(RecordRef.RecordId));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeFormatIntrastatJnlLineValues(var IntrastatJnlLine: Record "Intrastat Jnl. Line"; var FieldValue: array[20] of Text; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFormatIntrastatJnlLineValues(var IntrastatJnlLine: Record "Intrastat Jnl. Line"; var FieldValue: array[20] of Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDownloadExport(var TempBlob: Codeunit "Temp Blob"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeModifyIntrastatJnlBatch(var IntrastatJnlBatch: Record "Intrastat Jnl. Batch")
    begin
    end;

}
