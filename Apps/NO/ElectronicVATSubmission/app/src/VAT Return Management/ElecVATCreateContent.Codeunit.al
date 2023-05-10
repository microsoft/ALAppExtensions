codeunit 10684 "Elec. VAT Create Content"
{
    TableNo = "VAT Report Header";
    Permissions = TableData "VAT Report Archive" = d;

    var
        CannotIdentifyMonthNumberErr: Label 'Cannot identify month number';
        FirstHalfMonthLbl: Label 'foerste halvdel', Locked = true;
        SecondHalfMonthLbl: Label 'andre halvdel', Locked = true;
        WeekLbl: Label 'uke', Locked = true;
        YearlyLbl: Label 'aarlig', Locked = true;

    trigger OnRun()
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
        TempVATStatementReportLine: Record "VAT Statement Report Line" temporary;
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Codeunit "Temp Blob";
        ElecVATLoggingMgt: Codeunit "Elec. VAT Logging Mgt.";
        MessageOutStream: OutStream;
    begin
        VATStatementReportLine.SetRange("VAT Report Config. Code", "VAT Report Config. Code");
        VATStatementReportLine.SetRange("VAT Report No.", "No.");
        VATStatementReportLine.FindSet();
        repeat
            TempVATStatementReportLine := VATStatementReportLine;
            TempVATStatementReportLine.Insert();
        until VATStatementReportLine.Next() = 0;
        CLEAR(TempBlob);
        TempBlob.CreateOutStream(MessageOutStream, TEXTENCODING::UTF8);
        MessageOutStream.WriteText(CreateVATReportLinesContent(TempVATStatementReportLine));
        if VATReportArchive.Get("VAT Report Config. Code", "No.") then
            VATReportArchive.Delete(true);
        VATReportArchive.ArchiveSubmissionMessage("VAT Report Config. Code", "No.", TempBlob);
        ElecVATLoggingMgt.RemoveSubmissionDocAttachments(Rec);
        ElecVATLoggingMgt.AttachXmlSubmissionToVATRepHeader(TempBlob, Rec, 'mvamelding');
        Commit();
    end;

    procedure CreateVATReportLinesContent(var TempVATStatementReportLine: Record "VAT Statement Report Line" temporary): Text
    var
        VATReportHeader: Record "VAT Report Header";
        VATCode: Record "VAT Code";
        VATSpecification: Record "VAT Specification";
        VATNote: Record "VAT Note";
        ElecVATXMLHelper: Codeunit "Elec. VAT XML Helper";
        ElecVATDataMgt: Codeunit "Elec. VAT Data Mgt.";
        OriginalVATCode: Code[10];
        IsDeductible: Boolean;
        TotalAmount: Decimal;
    begin
        VATReportHeader.Get(TempVATStatementReportLine."VAT Report Config. Code", TempVATStatementReportLine."VAT Report No.");
        ElecVATXMLHelper.Initialize('mvaMeldingDto');
        ElecVATXMLHelper.AddNewXMLNode('innsending', '');
        ElecVATXMLHelper.AppendXMLNode('regnskapssystemsreferanse', TempVATStatementReportLine."VAT Report No.");
        ElecVATXMLHelper.AddNewXMLNode('regnskapssystem', '');
        ElecVATXMLHelper.AppendXMLNode('systemnavn', 'Microsoft Dynamics 365 Business Central');
        ElecVATXMLHelper.AppendXMLNode('systemversjon', '20.0');
        ElecVATXMLHelper.FinalizeXMLNode();
        ElecVATXMLHelper.FinalizeXMLNode();

        ElecVATXMLHelper.AddNewXMLNode('skattegrunnlagOgBeregnetSkatt', '');
        ElecVATXMLHelper.AddNewXMLNode('skattleggingsperiode', '');
        ElecVATXMLHelper.AddNewXMLNode('periode', '');
        ElecVATXMLHelper.AppendXMLNode(GetPeriodTypeInNorwegian(VATReportHeader), GetPeriodTextInNorwegian(VATReportHeader));
        ElecVATXMLHelper.FinalizeXMLNode();
        ElecVATXMLHelper.AppendXMLNode('aar', format(Date2DMY(VATReportHeader."End Date", 3)));
        ElecVATXMLHelper.FinalizeXMLNode();
        TempVATStatementReportLine.FindSet();
        repeat
            GetVATCodeFromVATStatementLine(VATCode, TempVATStatementReportLine);
            if ElecVATDataMgt.IsReverseChargeVATCode(GetVATCodeOriginalNumber(VATCode)) then
                TotalAmount += TempVATStatementReportLine."Non-Deductible Amount"
            else
                TotalAmount += TempVATStatementReportLine.Amount;
        until TempVATStatementReportLine.Next() = 0;
        ElecVATXMLHelper.AppendXMLNode('fastsattMerverdiavgift', GetAmountTextRounded(TotalAmount));
        TempVATStatementReportLine.FindSet();
        repeat
            GetVATCodeFromVATStatementLine(VATCode, TempVATStatementReportLine);
            OriginalVATCode := GetVATCodeOriginalNumber(VATCode);
            IsDeductible := ElecVATDataMgt.IsReverseChargeVATCode(OriginalVATCode);
            ElecVATXMLHelper.AddNewXMLNode('mvaSpesifikasjonslinje', '');
            ElecVATXMLHelper.AppendXMLNode('mvaKode', OriginalVATCode);
            if VATCode."VAT Specification Code" <> '' then begin
                VATSpecification.Get(VATCode."VAT Specification Code");
                ElecVATXMLHelper.AppendXMLNode('spesifikasjon', VATSpecification."VAT Report Value");
            end;
            ElecVATXMLHelper.AppendXMLNode('mvaKodeRegnskapsystem', TempVATStatementReportLine.Description);
            if VATCode."Report VAT Rate" then begin
                ElecVATXMLHelper.AppendXMLNode('grunnlag', GetAmountTextRounded(TempVATStatementReportLine.Base + TempVATStatementReportLine."Non-Deductible Base"));
                ElecVATXMLHelper.AppendXMLNode('sats', Format(VATCode."VAT Rate For Reporting", 0, '<Integer><Decimals><Comma,,>'));
            end;
            ElecVATXMLHelper.AppendXMLNode('merverdiavgift', GetAmountTextRounded(TempVATStatementReportLine.Amount + TempVATStatementReportLine."Non-Deductible Amount"));
            if (VATCode."VAT Note Code" <> '') or (TempVATStatementReportLine.Note <> '') then begin
                ElecVATXMLHelper.AddNewXMLNode('merknad', '');
                if VATCode."VAT Note Code" = '' then
                    ElecVATXMLHelper.AppendXMLNode('beskrivelse', TempVATStatementReportLine.Note)
                else begin
                    VATNote.Get(VATCode."VAT Note Code");
                    ElecVATXMLHelper.AppendXMLNode('utvalgtMerknad', VATNote."VAT Report Value");
                end;
                ElecVATXMLHelper.FinalizeXMLNode();
            end;
            ElecVATXMLHelper.FinalizeXMLNode();
            if IsDeductible then begin
                ElecVATXMLHelper.AddNewXMLNode('mvaSpesifikasjonslinje', '');
                ElecVATXMLHelper.AppendXMLNode('mvaKode', OriginalVATCode);
                if VATCode."VAT Specification Code" <> '' then begin
                    VATSpecification.Get(VATCode."VAT Specification Code");
                    ElecVATXMLHelper.AppendXMLNode('spesifikasjon', VATSpecification."VAT Report Value");
                end;
                ElecVATXMLHelper.AppendXMLNode('mvaKodeRegnskapsystem', TempVATStatementReportLine.Description);
                ElecVATXMLHelper.AppendXMLNode('merverdiavgift', GetAmountTextRounded(-TempVATStatementReportLine.Amount));
                if VATCode."VAT Note Code" <> '' then begin
                    VATNote.Get(VATCode."VAT Note Code");
                    ElecVATXMLHelper.AddNewXMLNode('merknad', '');
                    ElecVATXMLHelper.AppendXMLNode('utvalgtMerknad', VATNote."VAT Report Value");
                    ElecVATXMLHelper.FinalizeXMLNode();
                end;
                ElecVATXMLHelper.FinalizeXMLNode();
            end;
        until TempVATStatementReportLine.Next() = 0;
        ElecVATXMLHelper.FinalizeXMLNode();
        ElecVATXMLHelper.AddNewXMLNode('betalingsinformasjon', '');
        if VATReportHeader.KID <> '' then
            ElecVATXMLHelper.AppendXMLNode('kundeIdentifikasjonsnummer', VATReportHeader.KID);
        ElecVATXMLHelper.FinalizeXMLNode();
        ElecVATXMLHelper.AddNewXMLNode('skattepliktig', '');
        ElecVATXMLHelper.AppendXMLNode('organisasjonsnummer', ElecVATDataMgt.GetDigitVATRegNo());
        ElecVATXMLHelper.FinalizeXMLNode();
        ElecVATXMLHelper.AppendXMLNode('meldingskategori', 'alminnelig');
        exit(ElecVATXMLHelper.GetXMLRequest());
    end;

    local procedure GetVATCodeFromVATStatementLine(var VATCode: Record "VAT Code"; VATStatementReportLine: Record "VAT Statement Report Line")
    begin
        VATCode.Get(CopyStr(VATStatementReportLine."Box No.", 1, MaxStrLen(VATCode.Code)));
    end;

    local procedure GetVATCodeOriginalNumber(VATCode: Record "VAT Code"): Code[10]
    begin
        if VATCode."SAF-T VAT Code" = '' then
            exit(VATCode.Code);
        exit(VATCode."SAF-T VAT Code");
    end;

    procedure CreateVATReturnSubmissionContent(VATReportHeader: Record "VAT Report Header"): Text
    var
        ElecVATXMLHelper: Codeunit "Elec. VAT XML Helper";
        ElecVATDataMgt: Codeunit "Elec. VAT Data Mgt.";
        TypeHelper: Codeunit "Type Helper";
        DateTimeText: Text;
        UserFullName: Text;
    begin
        ElecVATXMLHelper.InitializeNoNamespace('mvaMeldingInnsending');
        ElecVATXMLHelper.AddNewXMLNode('norskIdentifikator', '');
        ElecVATXMLHelper.AppendXMLNode('organisasjonsnummer', ElecVATDataMgt.GetDigitVATRegNo());
        ElecVATXMLHelper.FinalizeXMLNode();
        ElecVATXMLHelper.AddNewXMLNode('skattleggingsperiode', '');
        ElecVATXMLHelper.AddNewXMLNode('periode', '');
        ElecVATXMLHelper.AppendXMLNode(GetPeriodTypeInNorwegian(VATReportHeader), GetPeriodTextInNorwegian(VATReportHeader));
        ElecVATXMLHelper.FinalizeXMLNode();
        ElecVATXMLHelper.AppendXMLNode('aar', Format(Date2DMY(VATReportHeader."End Date", 3)));
        ElecVATXMLHelper.FinalizeXMLNode();
        ElecVATXMLHelper.AppendXMLNode('meldingskategori', 'alminnelig');
        ElecVATXMLHelper.AppendXMLNode('innsendingstype', 'komplett');
        ElecVATXMLHelper.AppendXMLNode('instansstatus', 'default');
        UserFullName := GetUserNameOrID();
        DateTimeText := TypeHelper.GetCurrUTCDateTimeISO8601();
        ElecVATXMLHelper.AppendXMLNode('opprettetAv', UserFullName);
        ElecVATXMLHelper.AppendXMLNode('opprettingstidspunkt', DateTimeText);
        ElecVATXMLHelper.AddNewXMLNode('vedlegg', '');
        ElecVATXMLHelper.AppendXMLNode('vedleggstype', 'mva-melding');
        ElecVATXMLHelper.AppendXMLNode('kildegruppe', 'sluttbrukersystem');
        ElecVATXMLHelper.AppendXMLNode('opprettetAv', UserFullName);
        ElecVATXMLHelper.AppendXMLNode('opprettingstidspunkt', DateTimeText);
        ElecVATXMLHelper.AddNewXMLNode('vedleggsfil', '');
        ElecVATXMLHelper.AppendXMLNode('filnavn', 'melding_xml');
        ElecVATXMLHelper.AppendXMLNode('filekstensjon', 'xml');
        ElecVATXMLHelper.AppendXMLNode('filinnhold', '-');
        ElecVATXMLHelper.FinalizeXMLNode();
        ElecVATXMLHelper.FinalizeXMLNode();
        exit(ElecVATXMLHelper.GetXMLRequest());
    end;

    local procedure GetUserNameOrID() Result: Text
    var
        User: Record User;
    begin
        User.SetRange("User Security ID", UserSecurityId());
        if not User.FindFirst() then
            exit(UserSecurityId());
        Result := User."Full Name";
        if Result = '' then
            Result := User."User Name";
        exit(Result);
    end;

    local procedure GetAmountTextRounded(Amount: Decimal): Text
    begin
        exit(Format(Round(Amount, 1, '<'), 0, '<Sign><Integer>'));
    end;

    local procedure GetPeriodTypeInNorwegian(VATReportHeader: Record "VAT Report Header"): Text
    begin
        Case VATReportHeader."Period Type" of
            VATReportHeader."Period Type"::"Bi-Monthly":
                exit('skattleggingsperiodeToMaaneder');
            VATReportHeader."Period Type"::"Half-Year":
                exit('skattleggingsperiodeSeksMaaneder');
            VATReportHeader."Period Type"::"Half-Month":
                exit('skattleggingsperiodeHalvMaaned');
            VATReportHeader."Period Type"::Quarter:
                exit('skattleggingsperiodeTreMaaneder');
            VATReportHeader."Period Type"::Month:
                exit('skattleggingsperiodeMaaned');
            VATReportHeader."Period Type"::Weekly:
                exit('skattleggingsperiodeUke');
            VATReportHeader."Period Type"::Year:
                exit('skattleggingsperiodeAar');
        End;
    end;

    local procedure GetPeriodTextInNorwegian(VATReportHeader: Record "VAT Report Header"): Text
    var
        PeriodText: Text;
    begin
        Case VATReportHeader."Period Type" of
            VATReportHeader."Period Type"::"Bi-Monthly", VATReportHeader."Period Type"::"Half-Year", VATReportHeader."Period Type"::Quarter:
                exit(
                    GetMonthNameInNorwegian(Date2DMY(VATReportHeader."Start Date", 2)) + '-' +
                    GetMonthNameInNorwegian(Date2DMY(VATReportHeader."End Date", 2)));
            VATReportHeader."Period Type"::"Half-Month":
                begin
                    if VATReportHeader."Period No." mod 2 = 0 then
                        PeriodText := SecondHalfMonthLbl
                    else
                        PeriodText := FirstHalfMonthLbl;
                    PeriodText += ' ' + GetMonthNameInNorwegian(Date2DMY(VATReportHeader."Start Date", 2));
                    exit(PeriodText);
                end;
            VATReportHeader."Period Type"::Month:
                exit(GetMonthNameInNorwegian(Date2DMY(VATReportHeader."Start Date", 2)));
            VATReportHeader."Period Type"::Weekly:
                exit(WeekLbl + ' ' + Format(VATReportHeader."Period No."));
            VATReportHeader."Period Type"::Year:
                exit(YearlyLbl);
        End;
    end;

    local procedure GetMonthNameInNorwegian(MonthNumber: Integer): Text
    begin
        case MonthNumber Of
            1:
                exit('januar');
            2:
                exit('februar');
            3:
                exit('mars');
            4:
                exit('april');
            5:
                exit('mai');
            6:
                exit('juni');
            7:
                exit('juli');
            8:
                exit('august');
            9:
                exit('september');
            10:
                exit('oktober');
            11:
                exit('november');
            12:
                exit('desember');
            else
                Error(CannotIdentifyMonthNumberErr);
        end
    end;
}
