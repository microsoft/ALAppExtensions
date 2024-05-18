// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

table 11021 "Sales VAT Advance Notif."
{
    DataCaptionFields = "No.", Description;
    LookupPageID = 11017;

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NoSeries: Codeunit "No. Series";
            begin
                if "No." <> xRec."No." then begin
                    ElecVATDeclSetup.Get();
                    NoSeries.TestManual(ElecVATDeclSetup."Sales VAT Adv. Notif. Nos.");
                    "No. Series" := '';
                end;
            end;
        }
        field(2; Description; Text[30])
        {
            DataClassification = CustomerContent;
        }
        field(4; "XML Submission Document"; Blob)
        {
            DataClassification = CustomerContent;
        }
        field(5; "Starting Date"; Date)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckEditable();
                if "Starting Date" <> 0D then
                    CheckDate("Starting Date");
            end;
        }
        field(6; Period; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = Month,Quarter;
            OptionCaption = 'Month,Quarter';

            trigger OnValidate()
            begin
                CheckEditable();
                if "Starting Date" <> 0D then
                    CheckDate("Starting Date");
            end;
        }
        field(7; "XML-File Creation Date"; Date)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "No. Series";
        }
        field(9; "XSL-Filename"; Text[250])
        {
            DataClassification = CustomerContent;
            ObsoleteTag = '23.0';
            ObsoleteState = Removed;
            ObsoleteReason = 'This functionality is not in use and not supported';
        }
        field(10; "XSD-Filename"; Text[250])
        {
            DataClassification = CustomerContent;
            ObsoleteTag = '23.0';
            ObsoleteState = Removed;
            ObsoleteReason = 'This functionality is not in use and not supported';
        }

        field(11; "Statement Template Name"; Code[10])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "VAT Statement Template";

            trigger OnValidate()
            begin
                CheckEditable();
            end;
        }
        field(12; "Statement Name"; Code[10])
        {
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "VAT Statement Name".Name where("Statement Template Name" = field("Statement Template Name"));

            trigger OnValidate()
            begin
                CheckEditable();
            end;
        }
        field(13; "Incl. VAT Entries (Closing)"; Enum "VAT Statement Report Selection")
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckEditable();
            end;
        }
        field(14; "Incl. VAT Entries (Period)"; Enum "VAT Statement Report Period Selection")
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckEditable();
            end;
        }
        field(15; "Corrected Notification"; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckEditable();
            end;
        }
        field(16; "Offset Amount of Refund"; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckEditable();
            end;
        }
        field(17; "Cancel Order for Direct Debit"; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckEditable();
            end;
        }
        field(19; "Amounts in Add. Rep. Currency"; Boolean)
        {
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(20; Testversion; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckEditable();
            end;
        }
        field(24; "Additional Information"; Text[250])
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckEditable();
            end;
        }
        field(25; "Contact for Tax Office"; Text[30])
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckEditable();
            end;
        }
        field(26; "Contact Phone No."; Text[20])
        {
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;

            trigger OnValidate()
            begin
                CheckEditable();
            end;
        }
        field(27; "Contact E-Mail"; Text[70])
        {
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;

            trigger OnValidate()
            begin
                CheckEditable();
            end;
        }
        field(30; "Documents Submitted Separately"; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckEditable();
            end;
        }
        field(31; "Use Authentication"; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CheckEditable();
            end;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; "Starting Date")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "No.", Description)
        {
        }
    }

    trigger OnInsert()
    var
        CompanyInformation: Record "Company Information";
        NoSeries: Codeunit "No. Series";
#if not CLEAN24
        NoSeriesManagement: Codeunit NoSeriesManagement;
        IsHandled: Boolean;
#endif
    begin
        FeatureTelemetry.LogUptake('0001Q0G', ElecVATAdvanceNotTok, Enum::"Feature Uptake Status"::"Used");
        if xRec.FindLast() then;
        Period := xRec.Period;
        "Contact for Tax Office" := xRec."Contact for Tax Office";
        if "Contact for Tax Office" = '' then begin
            CompanyInformation.Get();
            "Contact for Tax Office" := CopyStr(CompanyInformation."VAT Representative", 1, MaxStrLen("Contact for Tax Office"));
        end;

        if "No." = '' then begin
            ElecVATDeclSetup.Get();
            ElecVATDeclSetup.TestField("Sales VAT Adv. Notif. Nos.");
#if not CLEAN24
            IsHandled := false;
            NoSeriesManagement.RaiseObsoleteOnBeforeInitSeries(ElecVATDeclSetup."Sales VAT Adv. Notif. Nos.", xRec."No. Series", WorkDate(), "No.", "No. Series", IsHandled);
            if not IsHandled then begin
#endif
                "No. Series" := ElecVATDeclSetup."Sales VAT Adv. Notif. Nos.";
                if NoSeries.AreRelated("No. Series", xRec."No. Series") then
                    "No. Series" := xRec."No. Series";
                "No." := NoSeries.GetNextNo("No. Series");
#if not CLEAN24
                NoSeriesManagement.RaiseObsoleteOnAfterInitSeries("No. Series", ElecVATDeclSetup."Sales VAT Adv. Notif. Nos.", WorkDate(), "No.");
            end;
#endif
        end;
        FeatureTelemetry.LogUsage('0001Q0H', ElecVATAdvanceNotTok, 'Elec. VAT advance notif generated');
    end;

    trigger OnRename()
    begin
        CheckEditable();
    end;

    trigger OnDelete()
    begin
        CheckEditable();
    end;

    var
        ElecVATDeclSetup: Record "Elec. VAT Decl. Setup";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        ElecVATAdvanceNotTok: Label 'DE Elec. VAT Advance Notifications', Locked = true;
        WrongPlaceErr: Label 'Places of %1 in area %2 must be %3.', Comment = '%1 = Registration No. Field Caption; %2 = Tax Office Area; %3 = VAT No.';
        MustSpecStartingDateErr: Label 'You must specify a beginning of a month as starting date of the statement period.';
        StartingDateErr: Label 'The starting date is not the first date of a quarter.';
        DeleteXMLFileQst: Label 'Do you want to delete the XML-File for the %1?', Comment = '%1 = Sales VAT Advance Notif. Table Caption';
        CreateXMLBeforeShowErr: Label 'You must create the XML-File before it can be shown.';
        CannotChangeXMLFileErr: Label 'You cannot change the value of this field anymore after the XML-File for the %1 has been created.', Comment = '%1 = Sales VAT Advance Notif. Table Caption';
        XmlFilterTxt: Label 'XML File(*.xml)|*.xml', Locked = true;
        ElsterTok: Label 'ElsterTelemetryCategoryTok', Locked = true;
        DeleteXMLFileMsg: Label 'Deleting XML file', Locked = true;
        DeleteXMLFileSuccessMsg: Label 'XML file deleted successfully', Locked = true;
        XMLFileNameTxt: Label '%1_%2.xml', Locked = true;
        TotalAmount: Decimal;
        TotalBase: Decimal;
        TotalUnrealizedAmount: Decimal;
        TotalUnrealizedBase: Decimal;
        Amount: Decimal;
        StartDate: Date;
        EndDate: Date;
        Selection: Enum "VAT Statement Report Selection";
        PeriodSelection: Enum "VAT Statement Report Period Selection";

    procedure AssistEdit(OldSalesVATAdvNotif: Record "Sales VAT Advance Notif."): Boolean
    var
        SalesVATAdvNotif: Record "Sales VAT Advance Notif.";
        NoSeries: Codeunit "No. Series";
    begin
        SalesVATAdvNotif := Rec;
        ElecVATDeclSetup.Get();
        ElecVATDeclSetup.TestField("Sales VAT Adv. Notif. Nos.");
        if NoSeries.LookupRelatedNoSeries(ElecVATDeclSetup."Sales VAT Adv. Notif. Nos.", OldSalesVATAdvNotif."No. Series", SalesVATAdvNotif."No. Series") then begin
            SalesVATAdvNotif."No." := NoSeries.GetNextNo(SalesVATAdvNotif."No. Series");
            Rec := SalesVATAdvNotif;
            exit(true);
        end;
    end;

    procedure Export()
    var
        XmlDoc: XmlDocument;
        XmlInStream: InStream;
    begin
        if "XML-File Creation Date" = 0D then
            Error(CreateXMLBeforeShowErr);
        CalcFields("XML Submission Document");
        "XML Submission Document".CreateInStream(XMLInStream);
        XmlDocument.ReadFrom(XmlInStream, XmlDoc);
        ExportXMLDocument(XmlDoc);
    end;

    local procedure ExportXMLDocument(XmlDoc: XmlDocument)
    var
        SalesVATAdvNotif2: Record "Sales VAT Advance Notif.";
        FileManagement: Codeunit "File Management";
        XmlElem: XmlElement;
        XmlOutStream: OutStream;
        XmlInStream: InStream;
        FileOutStream: OutStream;
        XmlFile: File;
        FileName: Text;
        TextLine: Text;
    begin
        FileName := FileManagement.ServerTempFileName('xml');

        XmlDoc.GetRoot(XmlElem);
        SalesVATAdvNotif2."XML Submission Document".CreateOutStream(XmlOutStream);
        XmlDoc.WriteTo(XmlOutStream);
        SalesVATAdvNotif2."XML Submission Document".CreateInStream(XmlInStream);
        XmlFile.Create(FileName);
        XmlFile.CreateOutStream(FileOutStream);
        while not XmlInStream.EOS() do begin
            XmlInStream.ReadText(TextLine);
            FileOutStream.WriteText(TextLine);
        end;
        XmlFile.Close();

        ExportXMLFile(FileName);
    end;

    local procedure ExportXMLFile(SourceFile: Text)
    var
        FileName: Text;
    begin
        ElecVATDeclSetup.Get();

        FileName := StrSubstNo(XMLFileNameTxt, ElecVATDeclSetup."XML File Default Name", Description);

        Download(SourceFile, '', ElecVATDeclSetup."Sales VAT Adv. Notif. Path", XmlFilterTxt, FileName);
    end;

    procedure CheckDate(StartDate2: Date)
    begin
        if Date2DMY(StartDate2, 1) <> 1 then
            Error(MustSpecStartingDateErr);
        if (Period = Period::Quarter) and (((Date2DMY(StartDate2, 2) + 2) / 3) <> Round((Date2DMY(StartDate2, 2) + 2) / 3)) then
            Error(StartingDateErr);
    end;

    procedure CalcEndDate(StartDate2: Date): Date
    var
        DateFormula: DateFormula;
    begin
        case Period of
            Period::Quarter:
                Evaluate(DateFormula, '<+3M-1D>');
            else
                Evaluate(DateFormula, '<+1M-1D>');
        end;
        exit(CalcDate(DateFormula, StartDate2));
    end;

    local procedure CheckEditable()
    begin
        if "XML-File Creation Date" <> 0D then
            Error(CannotChangeXMLFileErr, TableCaption());
    end;

    procedure DeleteXMLSubDoc()
    begin
        if not Confirm(DeleteXMLFileQst, false, TableCaption()) then
            exit;

        Session.LogMessage('0000C9U', DeleteXMLFileMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ElsterTok);

        Clear("XML Submission Document");
        "XML-File Creation Date" := 0D;
        "Statement Template Name" := '';
        "Statement Name" := '';
        Modify();

        Session.LogMessage('0000C9V', DeleteXMLFileSuccessMsg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', ElsterTok);
    end;

    procedure CheckVATNo(var PosTaxoffice: Integer; var NumberTaxOffice: Integer; var PosArea: Integer; var NumberArea: Integer; var PosDistinction: Integer; var NumberDistinction: Integer) VATNo: Text[30]
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.Get();
        CompanyInfo.TestField("Tax Office Area");
        CompanyInfo.TestField("Registration No.");

        VATNo := CopyStr(DelChr(CompanyInfo."Registration No."), 1, MaxStrLen(VATNo));
        VATNo := CopyStr(DelChr(VATNo, '=', '/'), 1, MaxStrLen(VATNo));

        case CompanyInfo."Tax Office Area" of
            8, 4, 2, 3, 7, 1, 16:               // resedually old areas
                begin
                    PosTaxoffice := 9;
                    NumberTaxOffice := 2;       // Tax Office No.
                    PosArea := 12;
                    NumberArea := 3;            // Area No.
                    PosDistinction := 16;
                    NumberDistinction := 4;     // Distinction No.
                end;
            6, 9, 10, 11, 12, 13, 14, 15:            // Bavaria, Saarland and new areas
                begin
                    PosTaxoffice := 8;
                    NumberTaxOffice := 3;
                    PosArea := 12;
                    NumberArea := 3;
                    PosDistinction := 16;
                    NumberDistinction := 4;
                end;
            5:                              // Nordrhein-Westfalen
                begin
                    PosTaxoffice := 8;
                    NumberTaxOffice := 3;
                    PosArea := 12;
                    NumberArea := 4;
                    PosDistinction := 17;
                    NumberDistinction := 3;
                end;
        end;

        if StrLen(VATNo) <> NumberTaxOffice + NumberArea + NumberDistinction + 1 then
            Error(
              WrongPlaceErr,
              CompanyInfo.FieldCaption("Registration No."),
              CompanyInfo."Tax Office Area", NumberTaxOffice + NumberArea + NumberDistinction + 1);
    end;

    procedure CalcTaxFigures(VATStmtName: Record "VAT Statement Name"; var TaxAmount: array[100] of Decimal; var TaxBase: array[100] of Decimal; var TaxUnrealizedAmount: array[100] of Decimal; var TaxUnrealizedBase: array[100] of Decimal; var Continued: Decimal; var TotalLine1: Decimal; var TotalLine2: Decimal; var TotalLine3: Decimal)
    var
        VATStmtLine: Record "VAT Statement Line";
        KeyFigure: Integer;
        i: Integer;
    begin
        VATStmtLine.SetRange("Statement Template Name", VATStmtName."Statement Template Name");
        VATStmtLine.SetRange("Statement Name", VATStmtName.Name);
        if VATStmtLine.FindSet() then
            repeat
                if not Evaluate(KeyFigure, VATStmtLine."Row No.") then
                    KeyFigure := 0;
                if (KeyFigure > 0) and (KeyFigure <= 100) then begin
                    TotalAmount := 0;
                    TotalBase := 0;
                    TotalUnrealizedAmount := 0;
                    TotalUnrealizedBase := 0;
                    CalcLineTotal(VATStmtLine, 0);
                    if VATStmtLine."Print with" = VATStmtLine."Print with"::"Opposite Sign" then begin
                        TaxAmount[KeyFigure] := TaxAmount[KeyFigure] - TotalAmount;
                        TaxBase[KeyFigure] := TaxBase[KeyFigure] - TotalBase;
                        TaxUnrealizedAmount[KeyFigure] := TaxUnrealizedAmount[KeyFigure] - TotalUnrealizedAmount;
                        TaxUnrealizedBase[KeyFigure] := TaxUnrealizedBase[KeyFigure] - TotalUnrealizedBase;
                    end else begin
                        TaxAmount[KeyFigure] := TaxAmount[KeyFigure] + TotalAmount;
                        TaxBase[KeyFigure] := TaxBase[KeyFigure] + TotalBase;
                        TaxUnrealizedAmount[KeyFigure] := TaxUnrealizedAmount[KeyFigure] + TotalUnrealizedAmount;
                        TaxUnrealizedBase[KeyFigure] := TaxUnrealizedBase[KeyFigure] + TotalUnrealizedBase;
                    end;
                    case KeyFigure of
                        51, 86, 36, 80, 97, 93, 98, 96:
                            Continued := Continued - TotalAmount;
                        47, 53, 74, 85, 65:
                            TotalLine1 := TotalLine1 - TotalAmount;
                        66, 61, 62, 67, 63, 64, 59:
                            TotalLine2 := TotalLine2 + TotalAmount;
                        69, 39:
                            TotalLine3 := TotalLine3 - TotalAmount;
                    end;
                end;
            until VATStmtLine.Next() = 0;
        for i := 21 to 100 do begin
            if ABS(TaxBase[i]) < 1 then
                case i of
                    35:
                        TaxAmount[36] := 0;
                    76:
                        TaxAmount[80] := 0;
                    95:
                        TaxAmount[98] := 0;
                    94:
                        TaxAmount[96] := 0;
                    52:
                        TaxAmount[53] := 0;
                    73:
                        TaxAmount[74] := 0;
                    84:
                        TaxAmount[85] := 0;
                    57:
                        TaxAmount[58] := 0;
                    46:
                        TaxAmount[47] := 0;
                    78:
                        TaxAmount[79] := 0;
                end;
            TaxBase[i] := Round(TaxBase[i], 1, '<');
            TaxUnrealizedBase[i] := ROUND(TaxUnrealizedBase[i], 1, '<');
        end;
    end;

    local procedure CalcLineTotal(VATStmtLine2: Record "VAT Statement Line"; Level: Integer) Result: Boolean
    var
        GLAcc: Record "G/L Account";
        VATEntry: Record "VAT Entry";
        i: Integer;
        ErrorText: Text[80];
        LineNo: array[6] of Code[10];
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcLineTotal(Rec, VATStmtLine2, Level, IsHandled, Result);
        if IsHandled then
            exit(Result);

        case VATStmtLine2.Type of
            VATStmtLine2.Type::"Account Totaling":
                if VATStmtLine2."Account Totaling" <> '' then begin
                    GLAcc.SetFilter("No.", VATStmtLine2."Account Totaling");
                    GLAcc.SetRange("VAT Reporting Date Filter", StartDate, EndDate);
                    if GLAcc.FindSet() then begin
                        Amount := 0;
                        repeat
                            GLAcc.CalcFields("Net Change", "Additional-Currency Net Change");
                            Amount := ConditionalAdd(Amount, GLAcc."Net Change", GLAcc."Additional-Currency Net Change");
                        until GLAcc.Next() = 0;
                        CalcTotalAmount(VATStmtLine2);
                    end;
                end;
            VATStmtLine2.Type::"VAT Entry Totaling":
                begin
                    VATEntry.SetCurrentKey(Type, Closed, "VAT Bus. Posting Group", "VAT Prod. Posting Group",
                      "Tax Jurisdiction Code", "Use Tax", "VAT Reporting Date");
                    VATEntry.SetRange(Type, VATStmtLine2."Gen. Posting Type");
                    case Selection of
                        Selection::Open:
                            VATEntry.SetRange(Closed, false);
                        Selection::Closed:
                            VATEntry.SetRange(Closed, true);
                    end;
                    VATEntry.SetRange("VAT Bus. Posting Group", VATStmtLine2."VAT Bus. Posting Group");
                    VATEntry.SetRange("VAT Prod. Posting Group", VATStmtLine2."VAT Prod. Posting Group");

                    if PeriodSelection = PeriodSelection::"Before and Within Period" then
                        VATEntry.SetRange("VAT Reporting Date", 0D, EndDate)
                    else
                        VATEntry.SetRange("VAT Reporting Date", StartDate, EndDate);

                    Amount := 0;
                    case VATStmtLine2."Amount Type" of
                        VATStmtLine2."Amount Type"::Amount:
                            begin
                                VATEntry.CalcSums(Amount, "Additional-Currency Amount");
                                Amount := ConditionalAdd(0, VATEntry.Amount, VATEntry."Additional-Currency Amount");
                            end;
                        VATStmtLine2."Amount Type"::Base:
                            begin
                                VATEntry.CalcSums(Base, "Additional-Currency Base");
                                Amount := ConditionalAdd(0, VATEntry.Base, VATEntry."Additional-Currency Base");
                            end;
                        VATStmtLine2."Amount Type"::"Unrealized Amount":
                            begin
                                VATEntry.CalcSums("Unrealized Amount", "Add.-Currency Unrealized Amt.");
                                Amount := ConditionalAdd(0, VATEntry."Unrealized Amount", VATEntry."Add.-Currency Unrealized Amt.");
                            end;
                        VATStmtLine2."Amount Type"::"Unrealized Base":
                            begin
                                VATEntry.CalcSums("Unrealized Base", "Add.-Currency Unrealized Base");
                                Amount := ConditionalAdd(0, VATEntry."Unrealized Base", VATEntry."Add.-Currency Unrealized Base");
                            end;
                        else
                            VATStmtLine2.TestField("Amount Type");
                    end;
                    OnCalcLineTotalOnBeforeCalcTotalAmountVATEntryTotaling(VATStmtLine2, VATEntry, Amount);
                    CalcTotalAmount(VATStmtLine2);
                end;
            VATStmtLine2.Type::"Row Totaling":
                begin
                    if Level >= ArrayLen(LineNo) then
                        exit(false);
                    Level := Level + 1;
                    LineNo[Level] := VATStmtLine2."Row No.";

                    if VATStmtLine2."Row Totaling" = '' then
                        exit(true);
                    VATStmtLine2.SetRange("Statement Template Name", VATStmtLine2."Statement Template Name");
                    VATStmtLine2.SetRange("Statement Name", VATStmtLine2."Statement Name");
                    VATStmtLine2.SetFilter("Row No.", VATStmtLine2."Row Totaling");
                    if VATStmtLine2.FindSet() then
                        repeat
                            if not CalcLineTotal(VATStmtLine2, Level) then begin
                                if Level > 1 then
                                    exit(FALSE);
                                for i := 1 to ArrayLen(LineNo) do
                                    ErrorText := ErrorText + LineNo[i] + ' => ';
                                ErrorText := CopyStr(ErrorText + '...', 1, MaxStrLen(ErrorText));
                                VATStmtLine2.FieldError("Row No.", ErrorText);
                            end;
                        until VATStmtLine2.Next() = 0;
                end;
            VATStmtLine2.Type::Description:
                ;
        end;

        exit(TRUE);
    end;

    local procedure CalcTotalAmount(VATStmtLine: Record "VAT Statement Line")
    begin
        if VATStmtLine."Calculate with" = VATStmtLine."Calculate with"::"Opposite Sign" then
            Amount := -Amount;
        case VATStmtLine."Amount Type" of
            VATStmtLine."Amount Type"::Amount:
                TotalAmount := TotalAmount + Amount;
            VATStmtLine."Amount Type"::Base:
                TotalBase := TotalBase + Amount;
            VATStmtLine."Amount Type"::"Unrealized Amount":
                TotalUnrealizedAmount := TotalUnrealizedAmount + Amount;
            VATStmtLine."Amount Type"::"Unrealized Base":
                TotalUnrealizedBase := TotalUnrealizedBase + Amount;
        end;
    end;

    local procedure ConditionalAdd(Amount2: Decimal; AmountToAdd: Decimal; AddCurrAmountToAdd: Decimal): Decimal
    begin
        if "Amounts in Add. Rep. Currency" then
            exit(Amount2 + AddCurrAmountToAdd);

        exit(Amount2 + AmountToAdd);
    end;

    procedure SetCalcParameters(StartDate2: Date; EndDate2: Date; Selection2: Enum "VAT Statement Report Selection"; PeriodSelection2: Enum "VAT Statement Report Period Selection"; UseAmtsInAddCurr2: Boolean)
    begin
        StartDate := StartDate2;
        EndDate := EndDate2;
        Selection := Selection2;
        PeriodSelection := PeriodSelection2;
        "Amounts in Add. Rep. Currency" := UseAmtsInAddCurr2;
    end;

    procedure GetDateFilter() ResultedDateFilter: Text[30]
    begin
        if "Starting Date" = 0D then
            exit('');
        exit(Format("Starting Date") + '..' + Format(CalcEndDate("Starting Date")));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcLineTotal(SalesVATAdvanceNotif: Record "Sales VAT Advance Notif."; VATStmtLine2: Record "VAT Statement Line"; Level: Integer; var IsHandled: Boolean; var Result: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCalcLineTotalOnBeforeCalcTotalAmountVATEntryTotaling(VATStmtLine: Record "VAT Statement Line"; var VATEntry: Record "VAT Entry"; var Amount: Decimal)
    begin
    end;
}

