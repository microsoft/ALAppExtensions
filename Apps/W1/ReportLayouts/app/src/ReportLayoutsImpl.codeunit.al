// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Shared.Report;

using Microsoft.EServices.EDocument;
using Microsoft.Foundation.Reporting;
using System.Environment.Configuration;
using System.Reflection;
using System.IO;
using System.Utilities;
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
        DefaultLayoutDeleteTxt: Label 'You are about to delete the currently selected default layout "%1", for report "%2". Do you want to continue? A new default layout must be selected manually from the Report Layout Selection page.', Comment = '%1 = Layout Name, %2 = Report Name';
        DefaultLayoutSetTxt: Label '"%1" has been set as the default layout for Report "%2"', Comment = '%1 = Layout Name, %2 = Report Name';
        FileFilterWordTxt: Label 'Word Files (*.docx)|*.docx', Comment = '{Split=r''\|''}{Locked=s''1''}';
        FileFilterRdlcTxt: Label 'SQL Report Builder (*.rdl;*.rdlc)|*.rdl;*.rdlc', Comment = '{Split=r''\|''}{Locked=s''1''}';
        FileFilterExcelTxt: Label 'Excel Files (*.xlsx)|*.xlsx', Comment = '{Split=r''\|''}{Locked=s''1''}';
        FileFilterExternalTxt: Label 'All Files (*.*)|*.*', Comment = '{Split=r''\|''}{Locked=s''1''}';
        EmptyLayoutNameTxt: Label 'A layout name must be specified.';
        LayoutAlreadyExistsErr: Label 'A layout named "%1" already exists.', Comment = '%1 = Layout Name';

    internal procedure SetSelectedCompany(NewCompanyName: Text)
    begin
        SelectedCompany := CopyStr(NewCompanyName, 1, MaxStrLen(SelectedCompany));
    end;

    internal procedure RunCustomReport(SelectedReportLayoutList: Record "Report Layout List")
    var
        DesignTimeReportSelection: codeunit "Design-time Report Selection";
    begin
        if SelectedReportLayoutList."Report ID" = 0 then
            exit;

        DesignTimeReportSelection.SetSelectedLayout(SelectedReportLayoutList.Name, SelectedReportLayoutList."Application ID");
        Commit(); // Since we run the report modally, we cannot have any active transactions.
        if TryRunCustomReport(SelectedReportLayoutList) then
            DesignTimeReportSelection.ClearLayoutSelection()
        else begin
            DesignTimeReportSelection.ClearLayoutSelection();
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

    internal procedure CreateNewReportLayout(SelectedReportLayoutList: Record "Report Layout List"; var ReturnReportID: Integer; var ReturnLayoutName: Text)
    var
        ReportLayoutNewDialog: Page "Report Layout New Dialog";
    begin
        ReportLayoutNewDialog.SetReportID(SelectedReportLayoutList."Report ID");
        if ReportLayoutNewDialog.RunModal() = Action::OK then
            case true of
                ReportLayoutNewDialog.SelectedAddCustomLayout():
                    InsertNewLayout(
                    ReportLayoutNewDialog.SelectedReportID(), ReportLayoutNewDialog.SelectedLayoutName(),
                    ReportLayoutNewDialog.SelectedLayoutDescription(), SelectedReportLayoutList."Layout Format"::Custom,
                    ReportLayoutNewDialog.SelectedLayoutIsGlobal(), ReturnReportID, ReturnLayoutName);

                ReportLayoutNewDialog.SelectedAddWordLayout():
                    InsertNewLayout(
                    ReportLayoutNewDialog.SelectedReportID(), ReportLayoutNewDialog.SelectedLayoutName(),
                    ReportLayoutNewDialog.SelectedLayoutDescription(), SelectedReportLayoutList."Layout Format"::Word,
                    ReportLayoutNewDialog.SelectedLayoutIsGlobal(), ReturnReportID, ReturnLayoutName);

                ReportLayoutNewDialog.SelectedAddRDLCLayout():
                    InsertNewLayout(
                    ReportLayoutNewDialog.SelectedReportID(), ReportLayoutNewDialog.SelectedLayoutName(),
                    ReportLayoutNewDialog.SelectedLayoutDescription(), SelectedReportLayoutList."Layout Format"::RDLC,
                    ReportLayoutNewDialog.SelectedLayoutIsGlobal(), ReturnReportID, ReturnLayoutName);

                ReportLayoutNewDialog.SelectedAddExcelLayout():
                    InsertNewLayout(
                    ReportLayoutNewDialog.SelectedReportID(), ReportLayoutNewDialog.SelectedLayoutName(),
                    ReportLayoutNewDialog.SelectedLayoutDescription(), SelectedReportLayoutList."Layout Format"::Excel,
                    ReportLayoutNewDialog.SelectedLayoutIsGlobal(), ReturnReportID, ReturnLayoutName);
            end;
    end;

    internal procedure SetDefaultReportLayoutSelection(SelectedReportLayoutList: Record "Report Layout List"; ShowMessage: Boolean)
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        // Add to TenantReportLayoutSelection table with an Empty Guid.
        AddLayoutSelection(SelectedReportLayoutList, EmptyGuid);

        // Add to the report layout selection table
        if ReportLayoutSelection.get(SelectedReportLayoutList."Report ID", SelectedCompany) then begin
            ReportLayoutSelection.Type := GetReportLayoutSelectionCorrespondingEnum(SelectedReportLayoutList);
            ReportLayoutSelection.Modify(true);
        end else begin
            ReportLayoutSelection."Report ID" := SelectedReportLayoutList."Report ID";
            ReportLayoutSelection."Company Name" := SelectedCompany;
            ReportLayoutSelection."Custom Report Layout Code" := '';
            ReportLayoutSelection.Type := GetReportLayoutSelectionCorrespondingEnum(SelectedReportLayoutList);
            ReportLayoutSelection.Insert(true);
        end;

        if ShowMessage then
            Message(DefaultLayoutSetTxt, SelectedReportLayoutList."Caption", SelectedReportLayoutList."Report Name");
    end;

    internal procedure GetDefaultReportLayoutSelection(ReportId: Integer; var DefaultReportLayoutList: Record "Report Layout List"): Boolean
    var
        ReportMetadata: Record "Report Metadata";
    begin
        TenantReportLayoutSelection.Init();
        DefaultReportLayoutList.Init();

        if TenantReportLayoutSelection.Get(ReportId, SelectedCompany, EmptyGuid) then begin
            // Filter Default Report Layout List by the layout name and application id and report id
            DefaultReportLayoutList.SetRange("Name", TenantReportLayoutSelection."Layout Name");
            DefaultReportLayoutList.SetRange("Application ID", TenantReportLayoutSelection."App ID");
            DefaultReportLayoutList.SetRange("Report ID", ReportId);

            // Retrive the record based on filters
            if DefaultReportLayoutList.FindFirst() then
                exit(true);
        end else
            if ReportMetadata.Get(ReportId) then begin
                DefaultReportLayoutList.SetRange("Name", ReportMetadata."DefaultLayoutName");
                DefaultReportLayoutList.SetFilter("Application ID", '<>%1', EmptyGuid);
                DefaultReportLayoutList.SetRange("Report ID", ReportId);

                if DefaultReportLayoutList.FindFirst() then
                    exit(true);
            end;

        exit(false);
    end;

    internal procedure UpdateDefaultLayoutSelectionName(SelectedReportLayoutList: Record "Report Layout List"; NewLayoutName: Text[250]): Boolean
    begin
        if TenantReportLayoutSelection.Get(SelectedReportLayoutList."Report ID", SelectedCompany, EmptyGuid) then
            if TenantReportLayoutSelection."Layout Name" = SelectedReportLayoutList."Name" then begin
                TenantReportLayoutSelection."Layout Name" := NewLayoutName;
                TenantReportLayoutSelection.Modify(true);
            end;
    end;

    internal procedure ConfirmDeleteDefaultLayoutSelection(SelectedReportLayoutList: Record "Report Layout List"; TenantReportLayoutSelection: Record "Tenant Report Layout Selection"): Boolean
    var
        ReportLayoutSelection: Record "Report Layout Selection";
    begin
        if Dialog.Confirm(StrSubstNo(DefaultLayoutDeleteTxt, SelectedReportLayoutList.Caption, SelectedReportLayoutList."Report Name"), false) then begin

            // Clear the selection from the Tenant Report Layout Selection table.
            if (TenantReportLayoutSelection."Layout Name" = SelectedReportLayoutList."Name") then
                TenantReportLayoutSelection.Delete(true);

            // Clear the selection from Report Layout Selection table and let platform set the new default layout for this report.
            if ReportLayoutSelection.get(SelectedReportLayoutList."Report ID", SelectedCompany) then
                ReportLayoutSelection.Delete(true);
            exit(true);
        end;
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

    internal procedure InsertNewLayout(ReportID: Integer; LayoutName: Text[250]; LayoutDescription: Text[250]; LayoutFormat: Option; LayoutIsGlobal: Boolean; var ReturnReportID: Integer; var ReturnLayoutName: Text)
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

        if LayoutIsGlobal then
            TenantReportLayout."Company Name" := ''
        else
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
        OnBeforeUpload(UploadResult, UploadFileName, NVInStream);

        if (not UploadResult) then begin
            ClearLastError();
            UploadResult := UploadIntoStream(DialogCaption, '', FileFilterTxt, UploadFileName, NVInStream);
        end;

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

        // If the current layout is being replaced using the ReplaceLayout action
        if TenantReportLayout.Get(TenantReportLayout."Report ID", TenantReportLayout."Name", TenantReportLayout."App ID") then
            TenantReportLayout.Delete(true);

        TenantReportLayout."Layout".ImportStream(NVInStream, TenantReportLayout."Description");
        TenantReportLayout."MIME Type" := CreateLayoutMime(UploadFileName);
        TenantReportLayout.Insert(true);

        ReturnReportID := TenantReportLayout."Report ID";
        ReturnLayoutName := TenantReportLayout."Name";
    end;

    internal procedure ReplaceLayout(ReportID: Integer; LayoutName: Text[250]; LayoutDescription: Text[250]; LayoutFormat: Option; var ReturnReportID: Integer; var ReturnLayoutName: Text)
    var
        TenantReportLayout: Record "Tenant Report Layout";
    begin
        TenantReportLayout."Report ID" := ReportID;
        TenantReportLayout."Name" := LayoutName;

        if TenantReportLayout.Get(ReportID, LayoutName, TenantReportLayout."App ID") then
            InsertNewLayout(ReportID, LayoutName, LayoutDescription, LayoutFormat, TenantReportLayout."Company Name" = '', ReturnReportID, ReturnLayoutName);
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
        CompanyName: Text[30];
        CreateCopy: Boolean;
        NewLayoutInStream: InStream;
        SourceLayoutOutStream: OutStream;
        AllCompaniesTxt: Label '';
        AvailableInAllCompanies: Boolean;
    begin
        if SelectedReportLayoutList."User Defined" then begin
            if TenantReportLayout.Get(SelectedReportLayoutList."Report ID", SelectedReportLayoutList.Name, EmptyGuid) then
                CompanyName := TenantReportLayout."Company Name";
        end else
            CompanyName := SelectedCompany;

        ReportLayoutEditDialog.SetupDialog(SelectedReportLayoutList, SelectedCompany);
        if ReportLayoutEditDialog.RunModal() = Action::OK then begin

            NewDescription := ReportLayoutEditDialog.SelectedLayoutDescription();
            NewLayoutName := ReportLayoutEditDialog.SelectedLayoutName();
            CreateCopy := ReportLayoutEditDialog.CopyOperationEnabled();
            AvailableInAllCompanies := ReportLayoutEditDialog.SelectedAvailableInAllCompanies();

            // Check if a layout having NewLayoutName already exists
            if TenantReportLayout.Get(SelectedReportLayoutList."Report ID", NewLayoutName, EmptyGuid) then
                if CreateCopy or (SelectedReportLayoutList.Name <> NewLayoutName) then
                    Error(LayoutAlreadyExistsErr, NewLayoutName);

            // Check if the layout should be made available for all companies
            if AvailableInAllCompanies then
                CompanyName := AllCompaniesTxt;

            if CreateCopy then begin
                // If create-copy is used to create a layout bound to the current company
                if SelectedReportLayoutList."User Defined" and (not AvailableInAllCompanies) and (CompanyName = '') then
                    CompanyName := SelectedCompany;

                TenantReportLayout.Init();
                TenantReportLayout.Name := NewLayoutName;
                TenantReportLayout.Description := NewDescription;
                TenantReportLayout."Report ID" := SelectedReportLayoutList."Report ID";
                TenantReportLayout."Company Name" := CompanyName;

                // Copy media stream
                TempBlob.CreateOutStream(SourceLayoutOutStream);
                SelectedReportLayoutList."Layout".ExportStream(SourceLayoutOutStream);
                TempBlob.CreateInStream(NewLayoutInStream);
                TenantReportLayout."Layout".ImportStream(NewLayoutInStream, NewDescription);

                TenantReportLayout."Layout Format" := SelectedReportLayoutList."Layout Format";
                TenantReportLayout."MIME Type" := SelectedReportLayoutList."MIME Type";
                TenantReportLayout.Insert(true);
            end else begin
                TenantReportLayout.Get(SelectedReportLayoutList."Report ID", SelectedReportLayoutList."Name", EmptyGuid);
                TenantReportLayout."Company Name" := CompanyName;
                TenantReportLayout.Rename(SelectedReportLayoutList."Report ID", NewLayoutName, EmptyGuid);
                TenantReportLayout.Description := NewDescription;

                TenantReportLayout.Modify(true);
            end;
            NewEditedLayoutName := NewLayoutName;

            // If the layout name was updated, we check if this layout is the default layout
            // and update its reference in the tenant report layout selection table. 
            if not CreateCopy then
                if (SelectedReportLayoutList.Name <> NewLayoutName) then
                    UpdateDefaultLayoutSelectionName(SelectedReportLayoutList, NewLayoutName);
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

    internal procedure OpenInOneDrive(SelectedReportLayoutList: Record "Report Layout List")
    var
        TenantReportLayout: Record "Tenant Report Layout";
        DocumentServiceMgt: Codeunit "Document Service Management";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        FileExtension: Text;
        MediaInStream: InStream;
        MediaOutStream: OutStream;
    begin
        if not TenantReportLayout.Get(SelectedReportLayoutList."Report ID", SelectedReportLayoutList."Name", EmptyGuid) then
            exit;

        FileName := GetFileName(SelectedReportLayoutList);
        FileExtension := GetFileExtension(SelectedReportLayoutList);

        TempBlob.CreateOutStream(MediaOutStream);
        TenantReportLayout."Layout".ExportStream(MediaOutStream);

        MediaInStream := TempBlob.CreateInStream();
        DocumentServiceMgt.OpenInOneDrive(FileName, FileExtension, MediaInStream);
    end;

    internal procedure ShareWithOneDrive(SelectedReportLayoutList: Record "Report Layout List")
    var
        TenantReportLayout: Record "Tenant Report Layout";
        DocumentServiceMgt: Codeunit "Document Service Management";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        FileExtension: Text;
        MediaInStream: InStream;
        MediaOutStream: OutStream;
    begin
        if not TenantReportLayout.Get(SelectedReportLayoutList."Report ID", SelectedReportLayoutList."Name", EmptyGuid) then
            exit;

        FileName := GetFileName(SelectedReportLayoutList);
        FileExtension := GetFileExtension(SelectedReportLayoutList);

        TempBlob.CreateOutStream(MediaOutStream);
        TenantReportLayout."Layout".ExportStream(MediaOutStream);

        MediaInStream := TempBlob.CreateInStream();
        DocumentServiceMgt.ShareWithOneDrive(FileName, FileExtension, MediaInStream);
    end;

    internal procedure EditInOneDrive(SelectedReportLayoutList: Record "Report Layout List")
    var
        TenantReportLayout: Record "Tenant Report Layout";
        DocumentServiceMgt: Codeunit "Document Service Management";
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
        FileExtension: Text;
        MediaInStream: InStream;
        MediaOutStream: OutStream;
    begin
        if not TenantReportLayout.Get(SelectedReportLayoutList."Report ID", SelectedReportLayoutList."Name", EmptyGuid) then
            exit;

        FileName := GetFileName(SelectedReportLayoutList);
        FileExtension := GetFileExtension(SelectedReportLayoutList);

        TempBlob.CreateOutStream(MediaOutStream);
        TenantReportLayout."Layout".ExportStream(MediaOutStream);

        if DocumentServiceMgt.EditInOneDrive(FileName, FileExtension, TempBlob) then begin

            MediaInStream := TempBlob.CreateInStream();
            TenantReportLayout."Layout".ImportStream(MediaInStream, TenantReportLayout."Description");

            if not TenantReportLayout.Insert(true) then
                TenantReportLayout.Modify(true);
        end;
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
                FileExt := 'rdl';
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnSelectReportLayout', '', false, false)]
    local procedure SelectReportLayoutUI(var ReportLayoutList: Record "Report Layout List"; var Handled: Boolean)
    begin
        if Page.RunModal(Page::"Report Layouts", ReportLayoutList) = ACTION::LookupOK then
            Handled := true;
    end;

    [InternalEvent(false, false)]
    local procedure OnBeforeUpload(var AlreadyUploaded: Boolean; var UploadFileName: Text; var FileInStream: InStream)
    begin
    end;
}