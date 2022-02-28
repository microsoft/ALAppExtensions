/// <summary>
/// This code unit supports the 'Report Layouts' page and provides implementations for adding/deleting/editing user and extension defined report layouts.
/// </summary>
codeunit 9660 "Report Layouts Impl."
{
    Access = Internal;
    Permissions = tabledata "Tenant Report Layout" = rimd,
                  tabledata "Tenant Report Layout Selection" = rimd;

    var
        TenantReportLayoutSelection: Record "Tenant Report Layout Selection";
        SelectedCompany: Text[30];
        EmptyGuid: Guid;
        ImportWordTxt: Label 'Choose Word layout file';
        ImportRdlcTxt: Label 'Choose RDLC layout file';
        ImportExcelTxt: Label 'Choose Excel layout file';
        ImportExternalTxt: Label 'Choose External layout file';
        DefaultLayoutSetTxt: Label '"%1" has been set as the default layout for Report "%2"', Comment = '%1 = Layout Name, %2 = Report Name';
        FileFilterWordTxt: Label 'Word Files (*.docx)|*.docx', Comment = '{Split=r''\|''}{Locked=s''1''}';
        FileFilterRdlcTxt: Label 'SQL Report Builder (*.rdl;*.rdlc)|*.rdl;*.rdlc', Comment = '{Split=r''\|''}{Locked=s''1''}';
        FileFilterExcelTxt: Label 'Excel Files (*.xlsx)|*.xlsx', Comment = '{Split=r''\|''}{Locked=s''1''}';
        FileFilterExternalTxt: Label 'All Files (*.*)|*.*', Comment = '{Split=r''\|''}{Locked=s''1''}';
        EmptyLayoutNameTxt: Label 'A layout name must be specified.';
        LayoutAlreadyExistsErr: Label 'A layout named "%1" already exists.', Comment = '%1 = Layout Name';

    internal procedure SetSelectedCompany(CompanyName: Text[30])
    begin
        SelectedCompany := CompanyName;
    end;

    internal procedure RunCustomReport(SelectedReportLayoutList: Record "Report Layout List")
    begin
        if SelectedReportLayoutList."Report ID" = 0 then
            exit;

        AddLayoutSelection(SelectedReportLayoutList, UserSecurityId());
        Commit(); // End current transaction to allow running the report modally.
        if TryRunCustomReport(SelectedReportLayoutList) then
            RemoveLayoutSelection(SelectedReportLayoutList)
        else begin
            RemoveLayoutSelection(SelectedReportLayoutList);
            Error(GetLastErrorText());
        end;
    end;

    [TryFunction]
    local procedure TryRunCustomReport(SelectedReportLayoutList: Record "Report Layout List")
    begin
        Report.RunModal(SelectedReportLayoutList."Report ID");
    end;

    local procedure AddLayoutSelection(SelectedReportLayoutList: Record "Report Layout List"; UserId: Guid): Boolean
    begin
        TenantReportLayoutSelection.Init();
        TenantReportLayoutSelection."App ID" := SelectedReportLayoutList."Application ID";
        TenantReportLayoutSelection."Company Name" := SelectedCompany;
        TenantReportLayoutSelection."Layout Name" := SelectedReportLayoutList."Name";
        TenantReportLayoutSelection."Report ID" := SelectedReportLayoutList."Report ID";
        TenantReportLayoutSelection."User ID" := UserId;

        if not TenantReportLayoutSelection.Insert(true) then
            TenantReportLayoutSelection.Modify(true);
    end;

    local procedure RemoveLayoutSelection(SelectedReportLayoutList: Record "Report Layout List")
    begin
        if TenantReportLayoutSelection.Get(SelectedReportLayoutList."Report ID", SelectedCompany, UserSecurityId()) then
            TenantReportLayoutSelection.Delete(true);
    end;

    internal procedure CreateNewReportLayout(SelectedReportLayoutList: Record "Report Layout List"; var ReturnReportID: Integer; var ReturnLayoutName: Text)
    var
        ReportLayoutNewDialog: Page "Report Layout New Dialog";
    begin
        ReportLayoutNewDialog.SetReportID(SelectedReportLayoutList."Report ID");
        if ReportLayoutNewDialog.RunModal() = Action::OK then
            case true of
                ReportLayoutNewDialog.SelectedAddCustomLayout():
                    UploadNewLayout(
                    ReportLayoutNewDialog.SelectedReportID(), ReportLayoutNewDialog.SelectedLayoutName(),
                    ReportLayoutNewDialog.SelectedLayoutDescription(), SelectedReportLayoutList."Layout Format"::Custom,
                    ReturnReportID, ReturnLayoutName);

                ReportLayoutNewDialog.SelectedAddWordLayout():
                    UploadNewLayout(
                    ReportLayoutNewDialog.SelectedReportID(), ReportLayoutNewDialog.SelectedLayoutName(),
                    ReportLayoutNewDialog.SelectedLayoutDescription(), SelectedReportLayoutList."Layout Format"::Word,
                    ReturnReportID, ReturnLayoutName);

                ReportLayoutNewDialog.SelectedAddRDLCLayout():
                    UploadNewLayout(
                    ReportLayoutNewDialog.SelectedReportID(), ReportLayoutNewDialog.SelectedLayoutName(),
                    ReportLayoutNewDialog.SelectedLayoutDescription(), SelectedReportLayoutList."Layout Format"::RDLC,
                    ReturnReportID, ReturnLayoutName);

                ReportLayoutNewDialog.SelectedAddExcelLayout():
                    UploadNewLayout(
                    ReportLayoutNewDialog.SelectedReportID(), ReportLayoutNewDialog.SelectedLayoutName(),
                    ReportLayoutNewDialog.SelectedLayoutDescription(), SelectedReportLayoutList."Layout Format"::Excel,
                    ReturnReportID, ReturnLayoutName);
            end;
    end;

    internal procedure SetDefaultReportLayoutSelection(SelectedReportLayoutList: Record "Report Layout List")
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        // Add to TenantReportLayoutSelection table with an Empty Guid.
        AddLayoutSelection(SelectedReportLayoutList, EmptyGuid);

        // Add to the report layout selection table
        if ReportLayoutSelection.get(SelectedReportLayoutList."Report ID", SelectedCompany) then begin
            ReportLayoutSelection.Type := GetReportLayoutSelectionCorrespondingEnum(SelectedReportLayoutList);
            ReportLayoutSelection.Modify();
        end else begin
            ReportLayoutSelection."Report ID" := SelectedReportLayoutList."Report ID";
            ReportLayoutSelection."Report Name" := SelectedReportLayoutList."Report Name";
            ReportLayoutSelection."Company Name" := SelectedCompany;
            ReportLayoutSelection."Custom Report Layout Code" := '';
            ReportLayoutSelection.Type := GetReportLayoutSelectionCorrespondingEnum(SelectedReportLayoutList);
            ReportLayoutSelection.Insert(true);
        end;
        Message(DefaultLayoutSetTxt, SelectedReportLayoutList."Name", SelectedReportLayoutList."Report Name");
    end;

    local procedure GetReportLayoutSelectionCorrespondingEnum(SelectedReportLayoutList: Record "Report Layout List"): Integer
    begin
        case SelectedReportLayoutList."Layout Format" of

            SelectedReportLayoutList."Layout Format"::RDLC:
                exit(0);
            SelectedReportLayoutList."Layout Format"::Word:
                exit(1);
            SelectedReportLayoutList."Layout Format"::Excel:
                exit(3);
            SelectedReportLayoutList."Layout Format"::Custom:
                exit(4);
        end
    end;

    internal procedure UploadNewLayout(ReportID: Integer; LayoutName: Text[250]; LayoutDescription: Text[250]; LayoutFormat: Option; var ReturnReportID: Integer; var ReturnLayoutName: Text)
    var
        TenantReportLayout: Record "Tenant Report Layout";
        FileManagement: Codeunit "File Management";
        FileFilterTxt: Text;
        DialogCaption: Text;
        NVInStream: InStream;
        UploadResult: Boolean;
        UploadFileName: Text;
        ErrorMessage: Text;
    begin
        if ReportID = 0 then
            exit;

        if LayoutName = '' then begin
            Message(EmptyLayoutNameTxt);
            exit;
        end;

        TenantReportLayout.Init();
        TenantReportLayout."Report ID" := ReportID;
        TenantReportLayout."Name" := LayoutName;
        TenantReportLayout."Company Name" := SelectedCompany;
        TenantReportLayout."Layout Format" := LayoutFormat;
        TenantReportLayout."Description" := LayoutDescription;

        case TenantReportLayout."Layout Format" of
            TenantReportLayout."Layout Format"::Word:
                begin
                    DialogCaption := ImportWordTxt;
                    FileFilterTxt := FileFilterWordTxt;
                end;
            TenantReportLayout."Layout Format"::RDLC:
                begin
                    DialogCaption := ImportRdlcTxt;
                    FileFilterTxt := FileFilterRdlcTxt;
                end;
            TenantReportLayout."Layout Format"::Excel:
                begin
                    DialogCaption := ImportExcelTxt;
                    FileFilterTxt := FileFilterExcelTxt;
                end;
            TenantReportLayout."Layout Format"::Custom:
                begin
                    DialogCaption := ImportExternalTxt;
                    FileFilterTxt := FileFilterExternalTxt;
                end;
        end;

        UploadFileName := TenantReportLayout."Name";
        ClearLastError();
        UploadResult := UploadIntoStream(DialogCaption, '', FileFilterTxt, UploadFileName, NVInStream);

        if not UploadResult then begin
            ErrorMessage := GetLastErrorText();
            //When upload is cancelled by user, don't emit an error.
            if ErrorMessage <> '' then
                Error(ErrorMessage);
            exit;
        end;

        // Custom layouts files are treated as unknown streams and don't need validation.
        if TenantReportLayout."Layout Format" <> TenantReportLayout."Layout Format"::Custom then
            FileManagement.ValidateFileExtension(UploadFileName, FileFilterTxt);

        if TenantReportLayout.Get(TenantReportLayout."Report ID", TenantReportLayout."Name", TenantReportLayout."App ID") then
            TenantReportLayout.Delete(true);

        TenantReportLayout."Layout".ImportStream(NVInStream, TenantReportLayout."Description");
        TenantReportLayout."MIME Type" := CreateLayoutMime(UploadFileName);
        TenantReportLayout.Insert(true);

        ReturnReportID := TenantReportLayout."Report ID";
        ReturnLayoutName := TenantReportLayout."Name";
    end;

    local procedure CreateLayoutMime(FileNameWithExtension: Text) MimeType: Text[255]
    var
        FileManagement: Codeunit "File Management";
        FileExtension: Text;
    begin
        FileExtension := FileManagement.GetExtension(FileNameWithExtension);
        MimeType := 'reportlayout/' + FileExtension;
    end;

    internal procedure EditReportLayout(SelectedReportLayoutList: Record "Report Layout List"; var NewEditedLayoutName: Text)
    var
        TenantReportLayout: Record "Tenant Report Layout";
        TempBlob: Codeunit "Temp Blob";
        ReportLayoutEditDialog: Page "Report Layout Edit Dialog";
        NewDescription: Text[250];
        NewLayoutName: Text[250];
        CreateCopy: Boolean;
        ForceCopy: Boolean;
        NewLayoutInStream: InStream;
        SourceLayoutOutStream: OutStream;
    begin
        ForceCopy := false; // Default behavior is not to create a copy.
        if not SelectedReportLayoutList."User Defined" then
            ForceCopy := true;
        ReportLayoutEditDialog.SetupDialog(SelectedReportLayoutList, ForceCopy);
        if ReportLayoutEditDialog.RunModal() = Action::OK then begin

            NewDescription := ReportLayoutEditDialog.SelectedLayoutDescription();
            NewLayoutName := ReportLayoutEditDialog.SelectedLayoutName();
            CreateCopy := ReportLayoutEditDialog.CopyOperationEnabled();

            // Check if a layout having NewLayoutName already exists
            if TenantReportLayout.Get(SelectedReportLayoutList."Report ID", NewLayoutName, EmptyGuid) then
                Error(LayoutAlreadyExistsErr, NewLayoutName);

            if CreateCopy then begin
                TenantReportLayout.Init();
                TenantReportLayout.Name := NewLayoutName;
                TenantReportLayout.Description := NewDescription;
                TenantReportLayout."Report ID" := SelectedReportLayoutList."Report ID";
                TenantReportLayout."Company Name" := SelectedCompany;

                // Copy media stream
                TempBlob.CreateOutStream(SourceLayoutOutStream);
                SelectedReportLayoutList."Layout".ExportStream(SourceLayoutOutStream);
                TempBlob.CreateInStream(NewLayoutInStream);
                TenantReportLayout."Layout".ImportStream(NewLayoutInStream, NewDescription);

                TenantReportLayout."Layout Format" := SelectedReportLayoutList."Layout Format";
                TenantReportLayout.Insert(true);
            end else begin
                TenantReportLayout.Get(SelectedReportLayoutList."Report ID", SelectedReportLayoutList."Name", EmptyGuid);
                TenantReportLayout.Rename(SelectedReportLayoutList."Report ID", NewLayoutName, EmptyGuid);
                TenantReportLayout.Description := NewDescription;
                TenantReportLayout.Modify(true);
            end;
            NewEditedLayoutName := NewLayoutName;
        end;
    end;

    internal procedure ExportReportLayout(SelectedReportLayoutList: Record "Report Layout List"): Text
    var
        TempBlob: Codeunit "Temp Blob";
        FileManagement: Codeunit "File Management";
        FileName: Text;
        MediaOutStream: OutStream;
    begin
        TempBlob.CreateOutStream(MediaOutStream);
        SelectedReportLayoutList."Layout".ExportStream(MediaOutStream);
        FileName := GetFileName(SelectedReportLayoutList);
        exit(FileManagement.BLOBExport(TempBlob, FileName, true));
    end;

    local procedure GetFileName(SelectedReportLayoutList: Record "Report Layout List"): Text
    var
        CurrentExt: Text;
        CurrentLayoutName: Text;
    begin
        CurrentLayoutName := SelectedReportLayoutList."Name";
        CurrentExt := GetFileExtension(SelectedReportLayoutList);
        if StrPos(CurrentLayoutName, '.' + CurrentExt) = 0 then
            exit(CurrentLayoutName + '.' + CurrentExt);
        exit(CurrentLayoutName);
    end;

    local procedure GetFileExtension(SelectedReportLayoutList: Record "Report Layout List") FileExt: Text
    begin
        // If MIME Type is present, use that to create file-extension.
        if (SelectedReportLayoutList."MIME Type" <> '') and SelectedReportLayoutList."MIME Type".ToLower().Contains('reportlayout/') then begin
            FileExt := SelectedReportLayoutList."MIME Type".Split('/').Get(2);
            exit;
        end;

        case SelectedReportLayoutList."Layout Format" of
            SelectedReportLayoutList."Layout Format"::Word:
                FileExt := 'docx';
            SelectedReportLayoutList."Layout Format"::RDLC:
                FileExt := 'rdlc';
            SelectedReportLayoutList."Layout Format"::Excel:
                FileExt := 'xlsx';
            SelectedReportLayoutList."Layout Format"::Custom:
                FileExt := '';
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Report Layout Selection", 'OnSelectReportLayout', '', false, false)]
    local procedure SelectReportLayout(var ReportLayoutList: Record "Report Layout List"; var Handled: Boolean)
    begin
        if Page.RunModal(Page::"Report Layouts", ReportLayoutList) = ACTION::LookupOK then
            Handled := true;
    end;
}