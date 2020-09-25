// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Implements functionality to get summary data for a given object.
/// </summary>
codeunit 2717 "Page Summary Provider Impl."
{
    Access = Internal;

    procedure GetPageSummary(PageId: Integer; Bookmark: Text): Text
    var
        PageSummaryProvider: Codeunit "Page Summary Provider";
        RecId: RecordID;
        ResultJsonObject: JsonObject;
        FieldsJsonArray: JsonArray;
        SummaryType: Enum "Summary Type";
        Handled: Boolean;
    begin
        // Add header
        AddPageSummaryHeader(PageId, ResultJsonObject);

        // Initialize variables
        EvaluateRecordId(RecId, Bookmark);

        // Allow partner to override returned fields and summary type
        PageSummaryProvider.OnBeforeGetPageSummary(PageId, RecId, FieldsJsonArray, Handled);
        if Handled then begin // Partner overrode fields
            Session.LogMessage('0000D73', StrSubstNo(PartnerHandledOnBeforeGetPageSummaryTxt, PageId), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PageSummaryCategoryLbl);
            ResultJsonObject.Add('summaryType', GetSummaryName(SummaryType));
            ResultJsonObject.Add('fields', FieldsJsonArray);
            exit(Format(ResultJsonObject));
        end;

        // Get summary fields
        AddPageSummaryFields(PageId, RecId, Bookmark, ResultJsonObject);

        exit(Format(ResultJsonObject));
    end;

    local procedure EvaluateRecordId(var RecId: RecordId; Bookmark: Text)
    begin
        // 10 is identifier for bookmark format
        if not Evaluate(RecId, Bookmark, 10) then
            Error(InvalidBookmarkErr);
    end;

    local procedure AddPageSummaryHeader(PageId: Integer; var ResultJsonObject: JsonObject)
    var
        PageMetadata: Record "Page Metadata";
        PageCaption: Text;
    begin
        if PageMetadata.Get(PageId) then
            PageCaption := PageMetadata.Caption
        else
            PageCaption := StrSubstNo(PageTxt, PageId);
        ResultJsonObject.Add('version', GetVersion());
        ResultJsonObject.Add('pageCaption', PageCaption);
        ResultJsonObject.Add('pageType', format(PageMetadata.PageType));
    end;

    local procedure AddPageSummaryFields(PageId: Integer; RecId: RecordId; Bookmark: Text; var ResultJsonObject: JsonObject)
    var
        PageSummaryProvider: Codeunit "Page Summary Provider";
        NavPageSummaryALFunctions: DotNet NavPageSummaryALFunctions;
        GenericList: DotNet GenericList1;
        NavPageSummaryALResponse: DotNet NavPageSummaryALResponse;
        NavPageSummaryALField: DotNet NavPageSummaryALField;
        FieldsJsonArray: JsonArray;
        PageSummaryFieldList: List of [Integer];
        SummaryType: Enum "Summary Type";
        PageSummaryField: Integer;
        ErrorMessage: Text;
    begin
        GenericList := NavPageSummaryALFunctions.GetSummaryFields(PageId);
        if IsNull(GenericList) then
            exit;
        if GenericList.Count() > 0 then
            SummaryType := SummaryType::Brick
        else
            SummaryType := SummaryType::Caption;

        foreach PageSummaryField in GenericList do
            PageSummaryFieldList.Add(PageSummaryField);
        CorrectFieldOrderingOfBrick(PageSummaryFieldList);

        // Allow partners to override fields to be shown + order
        PageSummaryProvider.OnAfterGetSummaryFields(PageId, RecId, PageSummaryFieldList);
        ResultJsonObject.Add('summaryType', GetSummaryName(SummaryType));
        GenericList.Clear();
        foreach PageSummaryField in PageSummaryFieldList do
            GenericList.Add(PageSummaryField);

        if (GenericList.Count() > 0) then begin
            NavPageSummaryALResponse := NavPageSummaryALFunctions.GetSummary(PageId, Bookmark, GenericList);

            if not NavPageSummaryALResponse.Success then begin
                Session.LogMessage('0000DGV', StrSubstNo(SummaryFailureTelemetryTxt, PageId), Verbosity::Error, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', PageSummaryCategoryLbl);
                ErrorMessage := NavPageSummaryALResponse.ErrorMessage;
                Error(ErrorMessage);
            end;
            // Get field values
            foreach NavPageSummaryALField in NavPageSummaryALResponse.SummaryFields do
                AddPageSummaryFieldToJsonArray(NavPageSummaryALField, FieldsJsonArray);
        end;

        // Allow partner to finally override field names and values
        PageSummaryProvider.OnAfterGetPageSummary(PageId, RecId, FieldsJsonArray);
        ResultJsonObject.Add('fields', FieldsJsonArray);
    end;

    local procedure GetSummaryName(SummaryType: Enum "Summary Type"): Text;
    var
        Index: Integer;
    begin
        Index := SummaryType.Ordinals.IndexOf(SummaryType.AsInteger());
        exit(SummaryType.Names().Get(Index));
    end;

    local procedure CorrectFieldOrderingOfBrick(var PageSummaryFieldList: List of [Integer])
    var
        TempValue: Integer;
    begin
        // Currently we just want to swap first and second field if there is more than one
        if PageSummaryFieldList.Count() <= 1 then
            exit;

        TempValue := PageSummaryFieldList.Get(1);
        PageSummaryFieldList.RemoveAt(1);
        PageSummaryFieldList.Insert(2, TempValue);
    end;

    local procedure AddPageSummaryFieldToJsonArray(NavPageSummaryALField: DotNet NavPageSummaryALField; var FieldsJsonArray: JsonArray)
    var
        FieldsJsonObject: JsonObject;
        FieldValue: Text;
        FieldType: Text;
        MimeType: Text;
    begin
        if NavPageSummaryALField.FieldType = 33794 then // 33794 == Blob
            exit;
        FieldValue := NavPageSummaryALField.Value.ToString();
        FieldType := NavPageSummaryALField.FieldType.ToString();

        // Handle pictures - 26209 == MediaSet, 26208 == Media
        if NavPageSummaryALField.FieldType = 26208 then
            ExtractPictureFromMedia(NavPageSummaryALField.Value.ToString(), FieldValue, MimeType, FieldType);
        if NavPageSummaryALField.FieldType = 26209 then
            ExtractPictureFromMediaSet(NavPageSummaryALField.Value.ToString(), FieldValue, MimeType, FieldType);

        // Add the actual field
        FieldsJsonObject.Add('caption', NavPageSummaryALField.Caption);
        if NavPageSummaryALField.ExtendedType <> NavPageSummaryALField.ExtendedType::Undefined then
            FieldsJsonObject.Add('extendedType', NavPageSummaryALField.ExtendedType.ToString());
        FieldsJsonObject.Add('fieldValue', FieldValue);
        FieldsJsonObject.Add('fieldType', FieldType);
        if MimeType <> '' then
            FieldsJsonObject.Add('mimeType', MimeType);
        FieldsJsonArray.Add(FieldsJsonObject);
    end;

    local procedure ExtractPictureFromMedia(ImageGuid: Guid; var FieldValue: Text; var MimeType: Text; var FieldType: Text)
    var
        TenantMediaThumbnails: Record "Tenant Media Thumbnails";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
    begin
        FieldType := 'Media';
        // Filter on large image thumbnail
        // Whenever an image is stored, we also store a large image thumbnail in dimensions 240 x 240 (used in grid view)
        TenantMediaThumbnails.SetRange("Media Id", ImageGuid);
        TenantMediaThumbnails.SetRange("Height", 240);
        TenantMediaThumbnails.SetRange("Width", 240);
        if not TenantMediaThumbnails.FindFirst() then begin
            Clear(FieldValue);
            Clear(MimeType);
            exit;
        end;

        TenantMediaThumbnails.CalcFields(Content);
        TenantMediaThumbnails.Content.CreateInStream(InStr);
        FieldValue := Base64Convert.ToBase64(InStr);
        MimeType := TenantMediaThumbnails."Mime Type";
    end;

    local procedure ExtractPictureFromMediaSet(ImageGuid: Guid; var FieldValue: Text; var MimeType: Text; var FieldType: Text)
    var
        TenantMediaSet: Record "Tenant Media Set";
    begin
        TenantMediaSet.SetRange(Id, ImageGuid);
        if TenantMediaSet.FindFirst() then;
        ExtractPictureFromMedia(TenantMediaSet."Media ID".MediaId, FieldValue, MimeType, FieldType);
    end;

    procedure GetVersion(): Text[30]
    begin
        exit('1.0');
    end;

    var
        PageTxt: Label 'Page %1', Comment = '%1 is a whole number, ex. 10';
        PageSummaryCategoryLbl: Label 'Page Summary Provider', Locked = true;
        PartnerHandledOnBeforeGetPageSummaryTxt: Label 'Partner handled OnBeforeGetPageSummary for page %1.', Locked = true;
        InvalidBookmarkErr: Label 'The bookmark format is not valid';
        SummaryFailureTelemetryTxt: Label 'Failure to get summary for page %1.', Locked = true;
}