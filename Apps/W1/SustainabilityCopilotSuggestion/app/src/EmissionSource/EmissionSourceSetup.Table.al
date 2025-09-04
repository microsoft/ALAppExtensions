// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.Copilot;

using Microsoft.Foundation.Address;
using System.Utilities;
using System.IO;

table 6291 "Emission Source Setup"
{
    Caption = 'Emission Source Setup';
    DataClassification = CustomerContent;
    InherentPermissions = X;
    InherentEntitlements = X;

    Access = Internal;
    fields
    {
        field(1; Id; BigInteger)
        {
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Country/Region Code"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Country/Region";
            ToolTip = 'Specifies the country/region code';
            Caption = 'Country/Region Code';

            trigger OnValidate()
            var
                SourceCO2Emission: Record "Source CO2 Emission";
            begin
                if xRec."Country/Region Code" = "Country/Region Code" then
                    exit;

                SourceCO2Emission.SetRange("Emission Source ID", Id);
                if not SourceCO2Emission.IsEmpty() then
                    Error(UploadedDataErr, FieldCaption("Country/Region Code"));
            end;
        }
        field(3; "Country Name"; Text[50])
        {
            ToolTip = 'Specifies the country name';
            Caption = 'Country Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Country/Region".Name where(Code = field("Country/Region Code")));
        }
        field(4; Description; Text[250])
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the source description';
            Caption = 'Source Description';

            trigger OnValidate()
            var
                SourceCO2Emission: Record "Source CO2 Emission";
            begin
                if xRec.Description = Description then
                    exit;

                SourceCO2Emission.SetRange("Emission Source ID", Id);
                if not SourceCO2Emission.IsEmpty() then
                    Error(UploadedDataErr, FieldCaption(Description));
            end;
        }
        field(5; "Source File"; Blob)
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the source file';
            Caption = 'Source File';
        }
        field(6; "Starting Date"; Date)
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the starting date for the emission source';
            Caption = 'Starting Date';

            trigger OnValidate()
            begin
                HandleStartingEndingDateUpdate();
            end;
        }
        field(7; "Ending Date"; Date)
        {
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the ending date for the emission source';
            Caption = 'Ending Date';

            trigger OnValidate()
            begin
                HandleStartingEndingDateUpdate();
            end;
        }

    }

    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    var
        DuplicateDescriptionLbl: Label 'The description %1 already exist for country %2 for this period. Check the content of the file or adjust the starting and ending dates.', Comment = '%1 = description, %2 = country';

    trigger OnDelete()
    var
        SourceCO2Emission: Record "Source CO2 Emission";
    begin
        SourceCO2Emission.SetRange("Emission Source ID", Id);
        if SourceCO2Emission.IsEmpty() then
            exit;

        SourceCO2Emission.DeleteAll();
    end;

    procedure AddFile()
    var
        InStr: InStream;
    begin
        ClearLastError();
        if UploadFileToBlob(InStr) then
            ImportExcelSheet(InStr);
    end;

    procedure UploadFileToBlob(var InStr: InStream): Boolean
    var
        SourceCO2Emission: Record "Source CO2 Emission";
        TempBlob: Codeunit "Temp Blob";
        ConfirmMgt: Codeunit "Confirm Management";
        FileName: Text;
        OutStr: OutStream;
        AddeFileMsg: Label 'Upload file to selected country';
        AddFileQst: Label 'The existing file will be replaced. Do you want to continue?';
    begin
        FileName := Description;
        CalcFields("Source File");
        if "Source File".HasValue() then
            if ConfirmMgt.GetResponse(AddFileQst, false) then begin
                SourceCO2Emission.SetRange("Emission Source ID", Id);
                SourceCO2Emission.DeleteAll();
            end else
                exit;

        if not UploadIntoStream(AddeFileMsg, '', '', FileName, InStr) then
            Error(GetLastErrorText());

        if Description = '' then
            Description := CopyStr(FileName, 1, 250);

        TempBlob.CreateOutStream(OutStr);
        CopyStream(OutStr, InStr);
        SetContentFromBlob(TempBlob);
        if Id = 0 then
            Insert(true)
        else
            Modify();
        exit(true);
    end;

    procedure SetContentFromBlob(TempBlob: Codeunit "Temp Blob")
    var
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(Rec);
        TempBlob.ToRecordRef(RecordRef, FieldNo("Source File"));
        RecordRef.SetTable(Rec);
    end;

    procedure DownloadFile()
    var
        ConfirmMgt: Codeunit "Confirm Management";
        FileInStream: InStream;
        FileName: Text;
        FileNameLbl: Label '%1.xlsx', Comment = '%1 = File name';
        DownloadFileMsg: Label 'Do you want to download the file?';
        NoFileErr: Label 'No file to download';
    begin
        ClearLastError();

        CalcFields("Source File");
        if not "Source File".HasValue then
            Error(NoFileErr);

        if not ConfirmMgt.GetResponse(DownloadFileMsg, false) then
            exit;

        FileName := Description;
        if StrPos(FileName, '.xlsx') = 0 then
            FileName := StrSubstNo(FileNameLbl, Description);

        "Source File".CreateInStream(FileInStream);
        DownloadFromStream(FileInStream, '', '', '', FileName);
    end;

    internal procedure ImportExcelSheet(var InStr: InStream)
    var
        SourceCO2Emission: Record "Source CO2 Emission";
        SheetName: Text[250];
        LastRowNo: Integer;
        LastColumnNo: Integer;
        RowNo: Integer;
    begin
        if InStr.Length = 0 then
            exit;
        TempExcelBuffer.Reset();
        TempExcelBuffer.DeleteAll();
        SheetName := TempExcelBuffer.SelectSheetsNameStream(InStr);
        TempExcelBuffer.OpenBookStream(InStr, SheetName);
        TempExcelBuffer.ReadSheet();
        if not TempExcelBuffer.FindLast() then
            exit;
        LastRowNo := TempExcelBuffer."Row No.";
        LastColumnNo := TempExcelBuffer."Column No.";

        for RowNo := 2 to LastRowNo do begin
            SourceCO2Emission.Init();
            AddDescription(SourceCO2Emission, RowNo, LastColumnNo);
            SourceCO2Emission."Country/Region Code" := "Country/Region Code";
            SourceCO2Emission.Id := 0;
            Evaluate(SourceCO2Emission."Emission Factor CO2", GetCellValue(Rowno, LastColumnNo));
            SourceCO2Emission."Emission Source ID" := Id;
            SourceCO2Emission."Source Description" := Description;
            SourceCO2Emission."Starting Date" := "Starting Date";
            SourceCO2Emission."Ending Date" := "Ending Date";
            CheckSourceCO2EmissionExist(SourceCO2Emission);
            SourceCO2Emission.Insert(true);
        end;
        TempExcelBuffer.CloseBook();
    end;

    local procedure GetCellValue(RowNo: Integer; ColNo: Integer): Text
    begin
        if TempExcelBuffer.Get(RowNo, ColNo) then
            exit(TempExcelBuffer."Cell Value as Text");

        exit('');
    end;

    local procedure AddDescription(var SourceCO2Emission: Record "Source CO2 Emission"; RowNo: Integer; LastColumnNo: Integer)
    var
        AccountDescription: Text;
        ColNo: Integer;
    begin
        if LastColumnNo = 2 then
            AccountDescription := GetCellValue(Rowno, 1)
        else
            for ColNo := 1 to (LastColumnNo - 1) do
                if AccountDescription = '' then
                    AccountDescription := GetCellValue(RowNo, ColNo)
                else
                    AccountDescription += ' ' + GetCellValue(RowNo, ColNo);
        SourceCO2Emission.Description := CopyStr(AccountDescription, 1, MaxStrLen(SourceCO2Emission.Description));
    end;

    local procedure CheckSourceCO2EmissionExist(var SourceCO2Emission: Record "Source CO2 Emission"): Boolean
    var
        ExistingSourceCO2Emission: Record "Source CO2 Emission";
    begin
        ExistingSourceCO2Emission.SetLoadFields("Starting Date", "Ending Date");
        ExistingSourceCO2Emission.SetCurrentKey("Description", "Country/Region Code");
        ExistingSourceCO2Emission.SetRange(Description, SourceCO2Emission.Description);
        ExistingSourceCO2Emission.SetRange("Country/Region Code", SourceCO2Emission."Country/Region Code");
        if not ExistingSourceCO2Emission.FindFirst() then
            exit;
        CheckTwoPeriodsOfSourceCO2EmissionAreNotOverlapping(ExistingSourceCO2Emission, SourceCO2Emission);
    end;

    local procedure CheckSourceCO2EmissionExist()
    var
        OtherSourceCO2Emission, CurrentSourceCO2Emission : Record "Source CO2 Emission";
    begin
        CurrentSourceCO2Emission.SetRange("Emission Source ID", Rec.Id);
        if not CurrentSourceCO2Emission.FindSet() then
            exit;
        repeat
            OtherSourceCO2Emission.SetFilter("Emission Source ID", '<>%1', Rec.Id);
            OtherSourceCO2Emission.SetRange(Description, CurrentSourceCO2Emission.Description);
            OtherSourceCO2Emission.SetRange("Country/Region Code", "Country/Region Code");
            if OtherSourceCO2Emission.FindSet() then
                repeat
                    CheckTwoPeriodsOfSourceCO2EmissionAreNotOverlapping(OtherSourceCO2Emission, CurrentSourceCO2Emission, Rec."Starting Date", Rec."Ending Date");
                until OtherSourceCO2Emission.Next() = 0;
        until CurrentSourceCO2Emission.Next() = 0;
    end;

    local procedure CheckTwoPeriodsOfSourceCO2EmissionAreNotOverlapping(ExistingSourceCO2Emission: Record "Source CO2 Emission"; CurrentSourceCO2Emission: Record "Source CO2 Emission")
    begin
        CheckTwoPeriodsOfSourceCO2EmissionAreNotOverlapping(ExistingSourceCO2Emission, CurrentSourceCO2Emission, CurrentSourceCO2Emission."Starting Date", CurrentSourceCO2Emission."Ending Date");
    end;

    local procedure CheckTwoPeriodsOfSourceCO2EmissionAreNotOverlapping(ExistingSourceCO2Emission: Record "Source CO2 Emission"; CurrentSourceCO2Emission: Record "Source CO2 Emission"; StartingDate: Date; EndingDate: Date)
    var
        ExistingStartingDate, ExistingEndingDate, CurrentStartingDate, CurrentEndingDate : Date;
    begin
        ExistingStartingDate := ExistingSourceCO2Emission."Starting Date";
        ExistingEndingDate := ExistingSourceCO2Emission."Ending Date";
        if ExistingEndingDate = 0D then
            ExistingEndingDate := DMY2Date(31, 12, 9999);
        CurrentStartingDate := StartingDate;
        CurrentEndingDate := EndingDate;
        if CurrentEndingDate = 0D then
            CurrentEndingDate := DMY2Date(31, 12, 9999);
        if (ExistingStartingDate <= CurrentEndingDate) and (ExistingEndingDate >= CurrentStartingDate) then
            Error(DuplicateDescriptionLbl, CurrentSourceCO2Emission.Description, CurrentSourceCO2Emission."Country/Region Code");
    end;

    local procedure HandleStartingEndingDateUpdate()
    var
        SourceCO2Emission: Record "Source CO2 Emission";
        StartingDateEmptyErr: Label 'The starting date must be specified.';
        StartingDateLaterEndingDateErr: Label 'The starting date cannot be later than the ending date.';
    begin
        if "Starting Date" = 0D then
            Error(StartingDateEmptyErr);
        if ("Ending Date" <> 0D) and ("Starting Date" > "Ending Date") then
            Error(StartingDateLaterEndingDateErr);
        CheckSourceCO2EmissionExist();
        SourceCO2Emission.SetRange("Emission Source ID", Id);
        SourceCO2Emission.ModifyAll("Starting Date", "Starting Date");
        SourceCO2Emission.ModifyAll("Ending Date", "Ending Date");
    end;

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        UploadedDataErr: Label 'You cannot change the %1 after the file has been uploaded. Please delete the file before changes.', Comment = '%1 = field caption';
}
