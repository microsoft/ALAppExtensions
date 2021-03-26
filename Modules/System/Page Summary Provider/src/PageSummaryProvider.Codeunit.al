// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality that gets page summary for a selected page.
/// This codeunit is exposed as a webservice and hence all functions are available through OData calls.
/// </summary>
codeunit 2718 "Page Summary Provider"
{
    Access = Public;

    /// <summary>
    /// Gets page summary for a given Page ID and bookmark.
    /// </summary>
    //  <param name="PageId">The ID of the page for which to retrieve page summary.</param>
    //  <param name="Bookmark">The Bookmark of the page for which to retrieve page summary.</param>
    /// <returns>Text value for the page summary in JSON format.</returns>
    /// <example>
    /// {
    ///   "version":"1.1",
    ///   "pageCaption":"Customer Card",
    ///   "pageType":"Card",
    ///   "summaryType":"Brick",
    ///   "fields":[
    ///      {"caption":"No.","fieldValue":"01445544","type":"Code"},
    ///      {"caption":"Name","fieldValue":"Progressive Home Furnishings","type":"Text"},
    ///      {"caption":"Contact","fieldValue":"Mr. Scott Mitchell","type":"Text"},
    ///      {"caption":"Balance Due (LCY)","fieldValue":"1.499,03","type":"Decimal"}]
    ///   }
    /// }
    /// 
    /// In case of an error:
    /// {
    ///   "version":"1.1",
    ///   "pageCaption":"Customer Card",
    ///   "pageType":"Card",
    ///   "summaryType":"Caption",
    ///   "error":[
    ///     "code":"InvalidBookmark"
    ///     "message":"The bookmark is invalid."
    ///   ]
    /// }
    /// </example>
    procedure GetPageSummary(PageId: Integer; Bookmark: Text): Text
    var
        SummaryProviderImpl: Codeunit "Page Summary Provider Impl.";
    begin
        exit(SummaryProviderImpl.GetPageSummary(PageID, Bookmark));
    end;

    /// <summary>
    /// Gets page summary for a given Page ID and System ID.
    /// </summary>
    //  <param name="PageId">The ID of the page for which to retrieve page summary.</param>
    //  <param name="SystemId">The system ID of the record in the page for which to retrieve page summary.
    //  Following GUID formats are supported:
    //  1. 32 digits seperated by hyphens.
    //  2. 32 digits seperated by hyphens and enclosed in braces.
    //  </param>
    /// <returns>Text value for the page summary in JSON format.</returns>
    /// <example>
    /// {
    ///   "version":"1.1",
    ///   "pageCaption":"Customer Card",
    ///   "pageType":"Card",
    ///   "summaryType":"Brick",
    ///   "url":"https://businesscentral.dynamics.com/?company=CRONUS%20International%20Ltd.&amp;page=22&amp;bookmark=27%3bEgAAAAJ7CDAAMQA5ADAANQA4ADkAMw%3d%3",
    ///   "fields":[
    ///      {"caption":"No.","fieldValue":"01445544","type":"Code"},
    ///      {"caption":"Name","fieldValue":"Progressive Home Furnishings","type":"Text"},
    ///      {"caption":"Contact","fieldValue":"Mr. Scott Mitchell","type":"Text"},
    ///      {"caption":"Balance Due (LCY)","fieldValue":"1.499,03","type":"Decimal"}]
    ///   }
    /// }
    /// 
    /// In case of an error:
    /// {
    ///   "version":"1.1",
    ///   "pageCaption":"Customer Card",
    ///   "pageType":"Card",
    ///   "summaryType":"Caption",
    ///   "error":[
    ///     "code":"InvalidSystemId"
    ///     "message":"The system id is invalid."
    ///   ]
    /// }
    /// </example>
    procedure GetPageSummaryBySystemID(PageId: Integer; SystemId: Guid): Text
    var
        SummaryProviderImpl: Codeunit "Page Summary Provider Impl.";
    begin
        exit(SummaryProviderImpl.GetPageSummary(PageID, SystemId));
    end;

    /// <summary>
    /// Gets page information such as page caption and and page type.
    /// </summary>
    //  <param name="PageId">The ID of the page for which to retrieve page summary.</param>
    /// <returns>Text value for the page summary in JSON format.</returns>
    /// <example>
    /// {
    ///   "version":"1.1",
    ///   "pageCaption":"Customer Card",
    ///   "pageType":"Card",
    ///   "summaryType":"Caption",
    /// }
    /// 
    /// In case of error:
    /// {
    ///   "version":"1.1",
    ///   "pageCaption":"Customer Card",
    ///   "pageType":"Card",
    ///   "summaryType":"Caption",
    ///   "error":[
    ///     "code":"error code"
    ///     "message":"error message"
    ///   ]
    /// }
    /// </example>
    procedure GetPageSummary(PageId: Integer): Text
    var
        SummaryProviderImpl: Codeunit "Page Summary Provider Impl.";
    begin
        exit(SummaryProviderImpl.GetPageSummary(PageID, ''));
    end;

    /// <summary>
    /// Gets the current version of the Page Summary Provider.
    /// </summary>
    /// <returns>Text value for the current version of Page Summary Provider.</returns>
    procedure GetVersion(): Text[30]
    var
        SummaryProviderImpl: Codeunit "Page Summary Provider Impl.";
    begin
        exit(SummaryProviderImpl.GetVersion());
    end;

    /// <summary>
    /// Allows changing which fields and values are returned when fetching page summary.
    /// </summary>
    //  <param name="PageId">The ID of the page for which to retrieve page summary.</param>
    //  <param name="RecId">The underlying record id of the source table for the page we are retrieving, based on the bookmark.</param>
    //  <param name="FieldsJsonArray">The Json array that will be used to summarize fields if the event is handled.</param>
    //  <param name="Handled">Specifies whether the event has been handled and no further execution should occur.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetPageSummary(PageId: Integer; RecId: RecordId; var FieldsJsonArray: JsonArray; var Handled: Boolean)
    begin
    end;

    /// <summary>
    /// Allows changing which fields are shown when fetching page summary, including their order.
    /// </summary>
    //  <param name="PageId">The ID of the page for which we are retrieving page summary.</param>
    //  <param name="RecId">The underlying record id of the source table for the page we are retrieving.</param>
    //  <param name="FieldList">The List of fields that will be returned.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterGetSummaryFields(PageId: Integer; RecId: RecordId; var FieldList: List of [Integer])
    begin
    end;

    /// <summary>
    /// Allows changing which fields and values are returned just before sending the response.
    /// </summary>
    //  <param name="PageId">The ID of the page for which to retrieve page summary.</param>
    //  <param name="RecId">The underlying record id of the source table for the page we are retrieving.</param>
    //  <param name="FieldsJsonArray">Allows overriding which fields and values are being returned.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterGetPageSummary(PageId: Integer; RecId: RecordId; var FieldsJsonArray: JsonArray)
    begin
    end;
}