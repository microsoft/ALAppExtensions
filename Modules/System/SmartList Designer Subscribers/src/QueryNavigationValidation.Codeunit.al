#if not CLEAN19
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Contains helper methods for performing SmartList Designer related tasks
/// </summary>
codeunit 2890 "Query Navigation Validation"
{
    Access = Public;
    ObsoleteState = Pending;
    ObsoleteReason = 'The SmartList Designer is not supported in Business Central.';
    ObsoleteTag = '19.0';

    /// <summary>
    /// Checks that the contents of the Query Navigation record is still valid.
    /// </summary>
    /// <param name="NavigationRec">The Query Navigation record to validate.</param>
    /// <param name="ValidationResult">A record containing the details about the results of the validation.</param>
    /// <returns>True if the record is valid; Otherwise false.</returns>
    procedure ValidateNavigation(NavigationRec: Record "Query Navigation"; var ValidationResult: Record "Query Navigation Validation"): Boolean
    begin
        exit(ValidateNavigation(
            NavigationRec."Source Query Object Id",
            NavigationRec."Target Page Id",
            NavigationRec."Linking Data Item Name",
            ValidationResult));
    end;

    /// <summary>
    /// Checks if the provided Query Navigation data would result in a valid Query Navigation record.
    /// </summary>
    /// <param name="SourceQueryObjectId">The ID of the query that is the source of data for the query navigation.</param>
    /// <param name="TargetPageId">The ID of the page that the query navigation opens.</param>
    /// <param name="LinkingDataItemName">
    /// The optional name of the data item within the source query that is used to generate linking filters. 
    /// This restricts the records on the target page based on the data within the selected query row when the 
    /// navigation item is selected.
    /// </param>
    /// <param name="ValidationResult">A record containing the details about the results of the validation.</param>
    /// <returns>True if the data represents a valid record; Otherwise false.</returns>
    procedure ValidateNavigation(SourceQueryObjectId: Integer; TargetPageId: Integer; LinkingDataItemName: Text; var ValidationResult: Record "Query Navigation Validation"): Boolean
    var
        QueryNavValidationImpl: Codeunit "Query Nav Validation Impl";
    begin
        exit(QueryNavValidationImpl.ValidateNavigation(
            SourceQueryObjectId,
            TargetPageId,
            LinkingDataItemName,
            ValidationResult));
    end;
}
#endif