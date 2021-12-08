codeunit 10684 "Elec. VAT Create Content"
{
    TableNo = "VAT Report Header";

    var
        CannotIdentifyMonthNumberErr: Label 'Cannot identify month number';

    trigger OnRun()
    var
        VATStatementReportLine: Record "VAT Statement Report Line";
        TempVATStatementReportLine: Record "VAT Statement Report Line" temporary;
        VATReportArchive: Record "VAT Report Archive";
        TempBlob: Codeunit "Temp Blob";
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
        MessageOutStream.Write(CreateVATReportLinesContent(TempVATStatementReportLine));
        if VATReportArchive.Get("VAT Report Config. Code", "No.") then
            VATReportArchive.Delete(true);
        VATReportArchive.ArchiveSubmissionMessage("VAT Report Config. Code", "No.", TempBlob);
        Commit();
    end;

    procedure CreateVATReportLinesContent(var TempVATStatementReportLine: Record "VAT Statement Report Line" temporary): Text
    var
        VATReportHeader: Record "VAT Report Header";
        CompanyInformation: Record "Company Information";
        VATCode: Record "VAT Code";
        ElecVATXMLHelper: Codeunit "Elec. VAT XML Helper";
        ElecVATDataMgt: Codeunit "Elec. VAT Data Mgt.";
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
        ElecVATXMLHelper.AppendXMLNode('skattleggingsperiodeToMaaneder', GetPeriodTextInNorwegian(VATReportHeader));
        ElecVATXMLHelper.FinalizeXMLNode();
        ElecVATXMLHelper.AppendXMLNode('aar', format(Date2DMY(VATReportHeader."End Date", 3)));
        ElecVATXMLHelper.FinalizeXMLNode();
        TempVATStatementReportLine.FindSet();
        repeat
            if not ElecVATDataMgt.IsReverseChargeVATCode(CopyStr(TempVATStatementReportLine."Box No.", 1, MaxStrLen(VATCode.Code))) then
                TotalAmount += TempVATStatementReportLine.Amount;
        until TempVATStatementReportLine.Next() = 0;
        ElecVATXMLHelper.AppendXMLNode('fastsattMerverdiavgift', GetAmountTextRounded(TotalAmount));
        TempVATStatementReportLine.FindSet();
        repeat
            IsDeductible := ElecVATDataMgt.IsReverseChargeVATCode(CopyStr(TempVATStatementReportLine."Box No.", 1, MaxStrLen(VATCode.Code)));
            ElecVATXMLHelper.AddNewXMLNode('mvaSpesifikasjonslinje', '');
            ElecVATXMLHelper.AppendXMLNode('mvaKode', TempVATStatementReportLine."Box No.");
            ElecVATXMLHelper.AppendXMLNode('mvaKodeRegnskapsystem', TempVATStatementReportLine.Description);
            VATCode.Get(CopyStr(TempVATStatementReportLine."Box No.", 1, MaxStrLen(VATCode.Code)));
            if VATCode."Report VAT Rate" then begin
                ElecVATXMLHelper.AppendXMLNode('grunnlag', GetAmountTextRounded(TempVATStatementReportLine.Base));
                ElecVATXMLHelper.AppendXMLNode('sats', Format(VATCode."VAT Rate For Reporting", 0, '<Integer><Decimals><Comma,,>'));
            end;
            ElecVATXMLHelper.AppendXMLNode('merverdiavgift', GetAmountTextRounded(TempVATStatementReportLine.Amount));
            ElecVATXMLHelper.FinalizeXMLNode();
            if IsDeductible then begin
                ElecVATXMLHelper.AddNewXMLNode('mvaSpesifikasjonslinje', '');
                ElecVATXMLHelper.AppendXMLNode('mvaKode', TempVATStatementReportLine."Box No.");
                ElecVATXMLHelper.AppendXMLNode('mvaKodeRegnskapsystem', TempVATStatementReportLine.Description);
                ElecVATXMLHelper.AppendXMLNode('merverdiavgift', GetAmountTextRounded(-TempVATStatementReportLine.Amount));
                ElecVATXMLHelper.FinalizeXMLNode();
            end;
        until TempVATStatementReportLine.Next() = 0;
        ElecVATXMLHelper.FinalizeXMLNode();
        ElecVATXMLHelper.AddNewXMLNode('betalingsinformasjon', '');
        if VATReportHeader.KID <> '' then
            ElecVATXMLHelper.AppendXMLNode('kundeIdentifikasjonsnummer', VATReportHeader.KID);
        ElecVATXMLHelper.FinalizeXMLNode();
        ElecVATXMLHelper.AddNewXMLNode('skattepliktig', '');
        CompanyInformation.Get();
        ElecVATXMLHelper.AppendXMLNode('organisasjonsnummer', CompanyInformation."VAT Registration No.");
        ElecVATXMLHelper.FinalizeXMLNode();
        ElecVATXMLHelper.AppendXMLNode('meldingskategori', 'alminnelig');
        exit(ElecVATXMLHelper.GetXMLRequest());
    end;

    procedure CreateVATReturnSubmissionContent(VATReportHeader: Record "VAT Report Header"): Text
    var
        CompanyInformation: Record "Company Information";
        ElecVATXMLHelper: Codeunit "Elec. VAT XML Helper";
        TypeHelper: Codeunit "Type Helper";
        DateTimeText: Text;
        UserFullName: Text;
    begin
        CompanyInformation.Get();
        ElecVATXMLHelper.InitializeNoNamespace('mvaMeldingInnsending');
        ElecVATXMLHelper.AddNewXMLNode('norskIdentifikator', '');
        ElecVATXMLHelper.AppendXMLNode('organisasjonsnummer', CompanyInformation."VAT Registration No.");
        ElecVATXMLHelper.FinalizeXMLNode();
        ElecVATXMLHelper.AddNewXMLNode('skattleggingsperiode', '');
        ElecVATXMLHelper.AddNewXMLNode('periode', '');
        ElecVATXMLHelper.AppendXMLNode('skattleggingsperiodeToMaaneder', GetPeriodTextInNorwegian(VATReportHeader));
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

    local procedure GetPeriodTextInNorwegian(VATReportHeader: Record "VAT Report Header"): Text
    begin
        exit(
            GetMonthNameInNorwegian(Date2DMY(VATReportHeader."Start Date", 2)) + '-' +
            GetMonthNameInNorwegian(Date2DMY(VATReportHeader."End Date" + 1, 2)))
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
