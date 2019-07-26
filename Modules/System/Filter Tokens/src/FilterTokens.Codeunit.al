// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality that allow users to specify pre-defined filter tokens that get converted to the correct values for various data types when filtering records.
/// </summary>
codeunit 41 "Filter Tokens"
{
    Access = Public;
    SingleInstance = true;

    var
        FilterTokensImpl: Codeunit "Filter Tokens Impl.";

        /// <summary>
        /// Turns text that represents date formats into a valid date filter expression with respect to filter tokens and date formulas.
        /// Call this function from onValidate trigger of page field that should behave similar to system filters.
        /// <param name="DateFilterText">The text from which the date filter should be extracted passed as VAR. For example: "YESTERDAY", or " 01-01-2012 ".</param>
        /// </summary>
    procedure MakeDateFilter(var DateFilterText: Text)
    begin
        FilterTokensImpl.MakeDateFilter(DateFilterText);
    end;

    /// <summary>
    /// Turns text that represents a time into a valid time filter with respect to filter tokens.
    /// Call this function from onValidate trigger of page field that should behave similar to system filters.
    /// </summary>
    /// <param name="TimeFilterText">The text from which the time filter should be extracted, passed as VAR. For example: "NOW".</param>
    procedure MakeTimeFilter(var TimeFilterText: Text)
    begin
        FilterTokensImpl.MakeTimeFilter(TimeFilterText);
    end;

    /// <summary>
    /// Turns text into a valid text filter with respect to filter tokens.
    /// Call this function from onValidate trigger of page field that should behave similar to system filters.
    /// </summary>
    /// <param name="TextFilter">The expression from which the text filter should be extracted, passed as VAR. For example: "ME".</param>
    procedure MakeTextFilter(var TextFilter: Text)
    begin
        FilterTokensImpl.MakeTextFilter(TextFilter);
    end;

    /// <summary>
    /// Turns text that represents a DateTime into a valid date and time filter with respect to filter tokens.
    /// Call this function from onValidate trigger of page field that should behave similar to system filters.
    /// </summary>
    /// <param name="DateTimeFilterText">The text from which the date and time should be extracted, passed as VAR. For example: "NOW" or "01-01-2012 11:11:11..NOW".</param>
    procedure MakeDateTimeFilter(var DateTimeFilterText: Text)
    begin
        FilterTokensImpl.MakeDateTimeFilter(DateTimeFilterText);
    end;

    /// <summary>
    /// Use this event if you want to add support for additional tokens that user will be able to use when working with date filters, for example "Christmas" or "StoneAge".
    /// Ensure that in your subscriber you check that what user entered contains your keyword, then return proper date range for your filter token.
    /// </summary>
    /// <param name="DateToken">The date token to resolve, for example: "Summer".</param>
    /// <param name="FromDate">The start date to resolve from DateToken that the filter will use, for example: "01/06/2019". Passed by reference by using VAR keywords.</param>
    /// <param name="ToDate">The end date to resolve from DateToken that the filter will use, for example: "31/08/2019". Passed by reference by using VAR keywords.</param>
    /// <param name="Handled">Stores whether the operation was successful.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnResolveDateFilterToken(DateToken: Text; var FromDate: Date; var ToDate: Date; var Handled: Boolean)
    begin
    end;

    /// <summary>
    /// Use this event if you want to add support for additional filter tokens that user will be able to use when working with text or code filters, for example "MyFilter".
    /// Ensure that in your subscriber you check that what user entered contains your token, then return properly formatted text for your filter token.
    /// </summary>
    /// <param name="TextToken">The text token to resolve.</param>
    /// <param name="TextFilter">The text to translate into a properly formatted text filter.</param>
    /// <param name="Handled">Stores whether the operation was successful.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnResolveTextFilterToken(TextToken: Text; var TextFilter: Text; var Handled: Boolean)
    begin
    end;

    /// <summary>
    /// Use this event if you want to add support for additional filter tokens that user will be able to use when working with time filters, for example "Lunch".
    /// Ensure that in your subscriber you check that what user entered contains your token, then return properly formatted time for your filter token.
    /// </summary>
    /// <param name="TimeToken">The time token to resolve, for example: "Lunch".</param>
    /// <param name="TimeFilter">The text to translate into a properly formatted time filter, for example: "12:00:00".</param>
    /// <param name="Handled">Stores whether the operation was successful.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnResolveTimeFilterToken(TimeToken: Text; var TimeFilter: Time; var Handled: Boolean)
    begin
    end;

    /// <summary>
    /// Use this event if you want to add support for additional filter tokens that user will be able to use as date in DateTime filters.
    /// Parses and translates a date token into a date filter.
    /// </summary>
    /// <param name="DateToken">The date token to resolve, for example: "Christmas".</param>
    /// <param name="DateFilter">The text to translate into a properly formatted date filter, for example: "25/12/2019".</param>
    /// <param name="Handled">Stores whether the operation was successful.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnResolveDateTokenFromDateTimeFilter(DateToken: Text; var DateFilter: Date; var Handled: Boolean)
    begin
    end;

    /// <summary>
    /// Use this event if you want to add support for additional filter tokens that user will be able to use as time in DateTime filters.
    /// Parses and translates a time token into a time filter.
    /// </summary>
    /// <param name="TimeToken">The time token to resolve, for example: "Lunch".</param>
    /// <param name="TimeFilter">The text to translate into a properly formatted time filter, for example:"12:00:00".</param>
    /// <param name="Handled">Stores whether the operation was successful.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnResolveTimeTokenFromDateTimeFilter(TimeToken: Text; var TimeFilter: Time; var Handled: Boolean)
    begin
    end;
}

