// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using Microsoft.Foundation.Address;
using Microsoft.Foundation.Attachment;
using Microsoft.Foundation.Company;
using Microsoft.Foundation.NoSeries;
using Microsoft.HumanResources.Employee;
using System.IO;
using System.Utilities;

#pragma warning disable AA0232
table 31075 "VIES Declaration Header CZL"
{
    Caption = 'VIES Declaration Header';
    DataCaptionFields = "No.";
    DrillDownPageId = "VIES Declarations CZL";
    LookupPageId = "VIES Declarations CZL";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                NoSeriesMgt: Codeunit NoSeriesManagement;
            begin
                if "No." <> xRec."No." then begin
                    NoSeriesMgt.TestManual(GetNoSeriesCode());
                    "No. Series" := '';
                end;
            end;
        }
        field(2; "VAT Registration No."; Text[20])
        {
            Caption = 'VAT Registration No.';
            NotBlank = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(3; "Trade Type"; Option)
        {
            Caption = 'Trade Type';
            InitValue = Both;
            OptionCaption = 'Purchase,Sales,Both';
            OptionMembers = Purchase,Sales,Both;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
                if LineExists() then
                    Error(LineExistErr, FieldCaption("Trade Type"));
                CheckPeriod();
            end;
        }
        field(4; "Period No."; Integer)
        {
            Caption = 'Period No.';
            BlankZero = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
                if "Period No." <> xRec."Period No." then begin
                    if LineExists() then
                        Error(LineExistErr, FieldCaption("Period No."));
                    SetPeriod();
                end;
            end;
        }
        field(5; Year; Integer)
        {
            Caption = 'Year';
            MaxValue = 9999;
            MinValue = 2000;
            BlankZero = true;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
                if Year <> xRec.Year then begin
                    if LineExists() then
                        Error(LineExistErr, FieldCaption(Year));
                    SetPeriod();
                end;
            end;
        }
        field(6; "Start Date"; Date)
        {
            Caption = 'Start Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(7; "End Date"; Date)
        {
            Caption = 'End Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(8; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(9; "Name 2"; Text[50])
        {
            Caption = 'Name 2';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(10; "Country/Region Name"; Text[50])
        {
            Caption = 'Country/Region Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(11; County; Text[30])
        {
            Caption = 'County';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(12; "Municipality No."; Text[30])
        {
            Caption = 'Municipality No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(13; Street; Text[50])
        {
            Caption = 'Street';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(14; "House No."; Text[30])
        {
            Caption = 'House No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(15; "Apartment No."; Text[30])
        {
            Caption = 'Apartment No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(16; City; Text[30])
        {
            Caption = 'City';
            TableRelation = "Post Code".City;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CountryCode: Code[10];
            begin
                Testfield(Status, Status::Open);
                PostCode.ValidateCity(City, "Post Code", County, CountryCode, (CurrFieldNo <> 0) and GuiAllowed());
            end;
        }
        field(17; "Post Code"; Code[20])
        {
            Caption = 'Post Code';
            TableRelation = "Post Code";
            ValidateTableRelation = false;
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                CountryCode: Code[10];
            begin
                Testfield(Status, Status::Open);
                PostCode.ValidatePostCode(City, "Post Code", County, CountryCode, (CurrFieldNo <> 0) and GuiAllowed());
            end;
        }
        field(18; "Tax Office Number"; Code[20])
        {
            Caption = 'Tax Office Number';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(19; "Declaration Period"; Option)
        {
            Caption = 'Declaration Period';
            OptionCaption = 'Quarter,Month';
            OptionMembers = Quarter,Month;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
                if "Declaration Period" <> xRec."Declaration Period" then begin
                    if LineExists() then
                        Error(LineExistErr, FieldCaption("Declaration Period"));
                    SetPeriod();
                end;
            end;
        }
        field(20; "Declaration Type"; Option)
        {
            Caption = 'Declaration Type';
            OptionCaption = 'Normal,Corrective,Corrective-Supplementary (Obsolete)';
            OptionMembers = Normal,Corrective,"Corrective-Supplementary";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
                if "Declaration Type" <> xRec."Declaration Type" then begin
                    if LineExists() then
                        Error(LineExistErr, FieldCaption("Declaration Type"));
                    if "Declaration Type" = "Declaration Type"::Normal then
                        "Corrected Declaration No." := '';
                    if "Declaration Type" = "Declaration Type"::"Corrective-Supplementary" then
                        Error(NoLongerSupportedErr);
                end;
            end;
        }
        field(21; "Corrected Declaration No."; Code[20])
        {
            Caption = 'Corrected Declaration No.';
            TableRelation = "VIES Declaration Header CZL" where("Corrected Declaration No." = filter(''),
                                                             Status = const(Released));
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
                if "Corrected Declaration No." <> xRec."Corrected Declaration No." then begin
                    if "Declaration Type" = "Declaration Type"::Normal then
                        FieldError("Declaration Type");
                    if "No." = "Corrected Declaration No." then
                        FieldError("Corrected Declaration No.");
                    if LineExists() then
                        Error(LineExistErr, FieldCaption("Corrected Declaration No."));

                    CopyCorrDeclaration();
                end;
            end;
        }
        field(24; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(25; "Number of Pages"; Integer)
        {
            CalcFormula = max("VIES Declaration Line CZL"."Report Page Number" where("VIES Declaration No." = field("No.")));
            Caption = 'Number of Pages';
            Editable = false;
            BlankZero = true;
            FieldClass = FlowField;
        }
        field(26; "Number of Lines"; Integer)
        {
            CalcFormula = count("VIES Declaration Line CZL" where("VIES Declaration No." = field("No.")));
            Caption = 'Number of Lines';
            BlankZero = true;
            Editable = false;
            FieldClass = FlowField;
        }
        field(27; "Sign-off Place"; Text[30])
        {
            Caption = 'Sign-off Place';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(28; "Sign-off Date"; Date)
        {
            Caption = 'Sign-off Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(29; "EU Goods/Services"; Option)
        {
            Caption = 'EU Goods/Services';
            OptionCaption = 'Both,Goods,Services';
            OptionMembers = Both,Goods,Services;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if LineExists() then
                    Error(LineExistErr, FieldCaption("EU Goods/Services"));
            end;
        }
        field(30; "Purchase Amount (LCY)"; Decimal)
        {
            CalcFormula = sum("VIES Declaration Line CZL"."Amount (LCY)" where("VIES Declaration No." = field("No."),
                                                                            "Trade Type" = const(Purchase)));
            Caption = 'Purchase Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(31; "Sales Amount (LCY)"; Decimal)
        {
            CalcFormula = sum("VIES Declaration Line CZL"."Amount (LCY)" where("VIES Declaration No." = field("No."),
                                                                            "Trade Type" = const(Sales)));
            Caption = 'Sales Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(32; "Amount (LCY)"; Decimal)
        {
            CalcFormula = sum("VIES Declaration Line CZL"."Amount (LCY)" where("VIES Declaration No." = field("No.")));
            Caption = 'Amount (LCY)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(33; "Number of Supplies"; Decimal)
        {
            CalcFormula = sum("VIES Declaration Line CZL"."Number of Supplies" where("VIES Declaration No." = field("No.")));
            Caption = 'Number of Supplies';
            DecimalPlaces = 0 : 0;
            Editable = false;
            FieldClass = FlowField;
        }
        field(50; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Open,Released';
            OptionMembers = Open,Released;
            DataClassification = CustomerContent;
        }
        field(51; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = CustomerContent;
        }
        field(70; "Authorized Employee No."; Code[20])
        {
            Caption = 'Authorized Employee No.';
            TableRelation = "Company Official CZL";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(71; "Filled by Employee No."; Code[20])
        {
            Caption = 'Filled by Employee No.';
            TableRelation = "Company Official CZL";
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(90; "Individual First Name"; Text[30])
        {
            Caption = 'Individual First Name';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(91; "Individual Surname"; Text[30])
        {
            Caption = 'Individual Surname';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(92; "Individual Title"; Text[30])
        {
            Caption = 'Individual Title';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(93; "Company Type"; Option)
        {
            Caption = 'Company Type';
            OptionCaption = ' ,Individual,Corporate';
            OptionMembers = " ",Individual,Corporate;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
                if "Company Type" = xRec."Company Type" then
                    exit;

                CompanyInformation.Get();
                StatutoryReportingSetupCZL.Get();

                case "Company Type" of
                    "Company Type"::Individual:
                        begin
                            Name := '';
                            "Name 2" := '';
                            "Company Trade Name Appendix" := '';
                            "Individual First Name" := StatutoryReportingSetupCZL."Individual First Name";
                            "Individual Surname" := StatutoryReportingSetupCZL."Individual Surname";
                            "Individual Title" := StatutoryReportingSetupCZL."Individual Title";
                        end;
                    "Company Type"::Corporate:
                        begin
                            Name := StatutoryReportingSetupCZL."Company Trade Name";
                            "Name 2" := '';
                            "Company Trade Name Appendix" := StatutoryReportingSetupCZL."Company Trade Name Appendix";
                            "Individual First Name" := '';
                            "Individual Surname" := '';
                            "Individual Title" := '';
                        end;
                end;
            end;
        }
        field(95; "Individual Employee No."; Code[20])
        {
            Caption = 'Individual Employee No.';
            TableRelation = Employee;
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(96; "Company Trade Name Appendix"; Text[11])
        {
            Caption = 'Company Trade Name Appendix';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Testfield(Status, Status::Open);
            end;
        }
        field(100; "Tax Office Region Number"; Code[20])
        {
            Caption = 'Tax Office Region Number';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "Start Date", "End Date")
        {
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; "EU Goods/Services", "Period No.", Year)
        {
        }
    }

    trigger OnDelete()
    var
        VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
    begin
        Testfield(Status, Status::Open);
        VIESDeclarationLineCZL.SetRange("VIES Declaration No.", "No.");
        VIESDeclarationLineCZL.DeleteAll();
    end;

    trigger OnInsert()
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if "No." = '' then
            NoSeriesManagement.InitSeries(GetNoSeriesCode(), xRec."No. Series", WorkDate(), "No.", "No. Series");

        InitRecord();
    end;

    trigger OnRename()
    begin
        Error(RenameErr, TableCaption);
    end;

    var
        StatutoryReportingSetupCZL: Record "Statutory Reporting Setup CZL";
        PostCode: Record "Post Code";
        CountryRegion: Record "Country/Region";
        CompanyInformation: Record "Company Information";
        FileManagement: Codeunit "File Management";
        PeriodExistsErr: Label 'Period from %1 till %2 already exists on %3 %4.', Comment = '%1 = start date; %2 = end date; %3 = VIES declaration tablecaption; %4 = VIES declaration number';
        EarlierDateErr: Label '%1 should be earlier than %2.', Comment = '%1 = starting date fieldcaption; %2 = end date fieldcaption';
        RenameErr: Label 'You cannot rename a %1.', Comment = '%1 = tablecaption';
        LineExistErr: Label 'You cannot change %1 because you already have declaration lines.', Comment = '%1 = fieldcaption';
        PeriodNumberErr: Label 'The permitted values for %1 are from 1 to %2.', Comment = '%1 = period number fieldcaption; %2 = max periodnumber';
        NoLongerSupportedErr: Label 'The Corrective-Supplementary type is no longer supported.';

    procedure InitRecord()
    begin
        CompanyInformation.Get();
        StatutoryReportingSetupCZL.Get();
        "VAT Registration No." := CompanyInformation."VAT Registration No.";
        "Document Date" := WorkDate();
        Name := StatutoryReportingSetupCZL."Company Trade Name";
        "Name 2" := '';
        if CountryRegion.Get(CompanyInformation."Country/Region Code") then
            "Country/Region Name" := CountryRegion.Name;
        County := CompanyInformation.County;
        City := StatutoryReportingSetupCZL.City;
        Street := StatutoryReportingSetupCZL.Street;
        "House No." := StatutoryReportingSetupCZL."House No.";
        "Apartment No." := StatutoryReportingSetupCZL."Apartment No.";
        "Municipality No." := StatutoryReportingSetupCZL."Municipality No.";
        "Post Code" := CompanyInformation."Post Code";
        "Tax Office Number" := StatutoryReportingSetupCZL."Tax Office Number";
        "Tax Office Region Number" := StatutoryReportingSetupCZL."Tax Office Region Number";
        "Company Type" := StatutoryReportingSetupCZL."Company Type";
        "Company Trade Name Appendix" := StatutoryReportingSetupCZL."Company Trade Name Appendix";
        "Individual Employee No." := StatutoryReportingSetupCZL."Individual Employee No.";
        "Authorized Employee No." := StatutoryReportingSetupCZL."VIES Decl. Auth. Employee No.";
        "Filled by Employee No." := StatutoryReportingSetupCZL."VIES Decl. Filled Employee No.";
    end;

    procedure AssistEdit(OldVIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL"): Boolean
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if NoSeriesManagement.SelectSeries(GetNoSeriesCode(), OldVIESDeclarationHeaderCZL."No. Series", "No. Series") then begin
            NoSeriesManagement.SetSeries("No.");
            exit(true);
        end;
    end;

    local procedure GetNoSeriesCode(): Code[20]
    begin
        StatutoryReportingSetupCZL.Get();
        StatutoryReportingSetupCZL.Testfield("VIES Declaration Nos.");
        exit(StatutoryReportingSetupCZL."VIES Declaration Nos.");
    end;

    local procedure CheckPeriodNo()
    var
        MaxPeriodNo: Integer;
    begin
        if "Declaration Period" = "Declaration Period"::Month then
            MaxPeriodNo := 12
        else
            MaxPeriodNo := 4;
        if not ("Period No." in [1 .. MaxPeriodNo]) then
            Error(PeriodNumberErr, FieldCaption("Period No."), MaxPeriodNo);
    end;

    local procedure SetPeriod()
    begin
        if "Period No." <> 0 then
            CheckPeriodNo();
        if ("Period No." = 0) or (Year = 0) then begin
            "Start Date" := 0D;
            "End Date" := 0D;
        end else
            if "Declaration Period" = "Declaration Period"::Month then begin
                "Start Date" := DMY2Date(1, "Period No.", Year);
                "End Date" := CalcDate('<CM>', "Start Date");
            end else begin
                "Start Date" := DMY2Date(1, "Period No." * 3 - 2, Year);
                "End Date" := CalcDate('<CQ>', "Start Date");
            end;
        CheckPeriod();
    end;

    local procedure CheckPeriod()
    var
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
    begin
        if ("Start Date" = 0D) or ("End Date" = 0D) then
            exit;
        if "Start Date" >= "End Date" then
            Error(EarlierDateErr, FieldCaption("Start Date"), FieldCaption("End Date"));

        if "Corrected Declaration No." = '' then begin
            VIESDeclarationHeaderCZL.SetCurrentKey("Start Date", "End Date");
            VIESDeclarationHeaderCZL.SetRange("Start Date", "Start Date");
            VIESDeclarationHeaderCZL.SetRange("End Date", "End Date");
            VIESDeclarationHeaderCZL.SetRange("Corrected Declaration No.", '');
            VIESDeclarationHeaderCZL.SetRange("VAT Registration No.", "VAT Registration No.");
            VIESDeclarationHeaderCZL.SetRange("Declaration Type", "Declaration Type");
            VIESDeclarationHeaderCZL.SetRange("Trade Type", "Trade Type");
            VIESDeclarationHeaderCZL.SetFilter("No.", '<>%1', "No.");
            OnCheckPeriodOnAfterSetFilters(Rec, VIESDeclarationHeaderCZL);
            if VIESDeclarationHeaderCZL.FindFirst() then
                Error(PeriodExistsErr, "Start Date", "End Date", VIESDeclarationHeaderCZL.TableCaption(), VIESDeclarationHeaderCZL."No.");
        end;
    end;

    procedure GetVATRegNo(): Code[20]
    var
        VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
    begin
        CompanyInformation.Get();
        VIESDeclarationLineCZL."VAT Registration No." := "VAT Registration No.";
        VIESDeclarationLineCZL."Country/Region Code" := CompanyInformation."Country/Region Code";
        exit(VIESDeclarationLineCZL.GetVATRegNo());
    end;

    procedure PrintTestReport()
    var
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
    begin
        VIESDeclarationHeaderCZL := Rec;
        VIESDeclarationHeaderCZL.SetRecFilter();
        Report.Run(Report::"VIES Declaration - Test CZL", true, false, VIESDeclarationHeaderCZL);
    end;

    procedure Print()
    var
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
        IsHandled: Boolean;
    begin
        OnBeforePrint(Rec, IsHandled);
        if IsHandled then
            exit;

        Testfield(Status, Status::Released);
        StatutoryReportingSetupCZL.Get();
        StatutoryReportingSetupCZL.Testfield("VIES Declaration Report No.");

        VIESDeclarationHeaderCZL := Rec;
        VIESDeclarationHeaderCZL.SetRecFilter();
        Report.Run(StatutoryReportingSetupCZL."VIES Declaration Report No.", true, false, VIESDeclarationHeaderCZL);
    end;

    procedure Export()
    var
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
        VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
        TempVIESDeclarationLineCZL: Record "VIES Declaration Line CZL" temporary;
        TempBlob: Codeunit "Temp Blob";
        VIESDeclarationCZL: XmlPort "VIES Declaration CZL";
        OutStream: OutStream;
        FileNameTok: Label '%1.xml', Locked = true;
    begin
        Testfield(Status, Status::Released);
        CheckDeclarationType();
        StatutoryReportingSetupCZL.Get();
        StatutoryReportingSetupCZL.Testfield("VIES Declaration Export No.");

        VIESDeclarationHeaderCZL := Rec;
        VIESDeclarationHeaderCZL.SetRecFilter();
        VIESDeclarationLineCZL.SetRange("VIES Declaration No.", "No.");
        if VIESDeclarationLineCZL.FindSet() then
            repeat
                TempVIESDeclarationLineCZL := VIESDeclarationLineCZL;
                TempVIESDeclarationLineCZL.Insert();
            until VIESDeclarationLineCZL.Next() = 0;

        TempBlob.CreateOutStream(OutStream);
        VIESDeclarationCZL.SetHeader(VIESDeclarationHeaderCZL);
        VIESDeclarationCZL.SetLines(TempVIESDeclarationLineCZL);
        VIESDeclarationCZL.SetDestination(OutStream);
        VIESDeclarationCZL.Export();
        FileManagement.BLOBExport(TempBlob, StrSubstNo(FileNameTok, "No."), true);
    end;

    local procedure CheckDeclarationType()
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckDeclarationType(Rec, IsHandled);
        if IsHandled then
            exit;

        if "Declaration Type" = "Declaration Type"::"Corrective-Supplementary" then
            Error(NoLongerSupportedErr);
    end;

    procedure PrintToDocumentAttachment()
    var
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentMgmt: Codeunit "Document Attachment Mgmt";
        TempBlob: Codeunit "Temp Blob";
        RecordRef: RecordRef;
        DummyInStream: InStream;
        ReportOutStream: OutStream;
        DocumentInStream: InStream;
        FileName: Text[250];
        DocumentAttachmentFileNameLbl: Label 'VIES Declaration %1', Comment = '%1 = VIES Declaration No.';
    begin
        VIESDeclarationHeaderCZL := Rec;
        VIESDeclarationHeaderCZL.SetRecFilter();
        RecordRef.GetTable(VIESDeclarationHeaderCZL);
        if not RecordRef.FindFirst() then
            exit;

        StatutoryReportingSetupCZL.Get();
        StatutoryReportingSetupCZL.Testfield("VIES Declaration Report No.");
        if not Report.RdlcLayout(StatutoryReportingSetupCZL."VIES Declaration Report No.", DummyInStream) then
            exit;

        TempBlob.CreateOutStream(ReportOutStream);
        Report.SaveAs(StatutoryReportingSetupCZL."VIES Declaration Report No.", '',
                      ReportFormat::Pdf, ReportOutStream, RecordRef);

        DocumentAttachment.InitFieldsFromRecRef(RecordRef);
        FileName := DocumentAttachment.FindUniqueFileName(
                    StrSubstNo(DocumentAttachmentFileNameLbl, VIESDeclarationHeaderCZL."No."), 'pdf');
        TempBlob.CreateInStream(DocumentInStream);
        DocumentAttachment.SaveAttachmentFromStream(DocumentInStream, RecordRef, FileName);
        DocumentAttachmentMgmt.ShowNotification(RecordRef, 1, true);
    end;

    local procedure LineExists(): Boolean
    var
        VIESDeclarationLineCZL: Record "VIES Declaration Line CZL";
    begin
        VIESDeclarationLineCZL.SetRange("VIES Declaration No.", "No.");
        exit(not VIESDeclarationLineCZL.IsEmpty());
    end;

    local procedure CopyCorrDeclaration()
    var
        SavedVIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
        VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL";
    begin
        Testfield("Corrected Declaration No.");
        VIESDeclarationHeaderCZL.Get("Corrected Declaration No.");
        SavedVIESDeclarationHeaderCZL.TransferFields(Rec);
        TransferFields(VIESDeclarationHeaderCZL, false);
        Modify();
        "No." := SavedVIESDeclarationHeaderCZL."No.";
        Status := SavedVIESDeclarationHeaderCZL.Status::Open;
        "Document Date" := SavedVIESDeclarationHeaderCZL."Document Date";
        "Declaration Type" := SavedVIESDeclarationHeaderCZL."Declaration Type";
        "Corrected Declaration No." := SavedVIESDeclarationHeaderCZL."Corrected Declaration No.";
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCheckPeriodOnAfterSetFilters(VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL"; var FilteredVIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeCheckDeclarationType(VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforePrint(var VIESDeclarationHeaderCZL: Record "VIES Declaration Header CZL"; var IsHandled: Boolean)
    begin
    end;
}
