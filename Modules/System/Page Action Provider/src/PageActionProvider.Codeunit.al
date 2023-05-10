// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality that gets relevant page actions for a selected page.
/// This codeunit is exposed as a webservice and hence all functions are available through OData calls.
/// </summary>
codeunit 2915 "Page Action Provider"
{
    Access = Public;

    /// <summary>
    /// Gets home items for user's current role center.
    /// </summary>
    /// <param name="IncludeViews">Specifies whether views for home items should be included.</param>
    /// <returns>Text value for the home items in JSON format.</returns>
    /// <example>
    /// "version": "1.0",
    /// "roleCenterId": 9022,
    /// "items": [
    ///     {
    ///       "caption": "Customers",
    ///       "views": [
    ///         {
    ///           "caption": "balance",
    ///           "url": "https://businesscentral.dynamics.com/?company=CRONUS%20International%20Ltd.&amp;page=22&amp;view=aa49406f-6f68-4565-b857-496faa0e77aa_balance48453&amp;page=22&amp;filter=Customer.%27Balance%20(LCY)%27%20IS%20%27>200%27"
    ///         }
    ///       ],
    ///       "url": "https://businesscentral.dynamics.com/?company=CRONUS%20International%20Ltd.&amp;page=22"
    ///     },
    ///     {
    ///       "caption": "Vendors",
    ///       "url": "https://businesscentral.dynamics.com/?company=CRONUS%20International%20Ltd.&amp;page=27"
    ///     },
    ///     {
    ///       "caption": "Items",
    ///       "url": "https://businesscentral.dynamics.com/?company=CRONUS%20International%20Ltd.&amp;page=31"
    ///     },
    ///     {
    ///       "caption": "Account Schedules",
    ///       "url": "https://businesscentral.dynamics.com/?company=CRONUS%20International%20Ltd.&amp;page=103"
    ///     }
    ///  ]
    /// 
    /// In case of an error:
    /// {
    ///   "version":"1.0",
    ///   "roleCenterId": 9022,
    ///   "error":[
    ///     "code":"UnableToGetRoleCenter"
    ///     "message":"Cannot get current role center for the user."
    ///   ]
    /// }
    /// </example>
    procedure GetCurrentRoleCenterHomeItems(IncludeViews: Boolean): Text
    var
        PageActionProviderImpl: Codeunit "Page Action Provider Impl.";
    begin
        exit(PageActionProviderImpl.GetCurrentRoleCenterHomeItems(IncludeViews));
    end;

    /// <summary>
    /// Gets the current version of the Page Action Provider.
    /// </summary>
    /// <returns>Text value for the current version of Page Action Provider.</returns>
    procedure GetVersion(): Text[30]
    var
        PageActionProviderImpl: Codeunit "Page Action Provider Impl.";
    begin
        exit(PageActionProviderImpl.GetVersion());
    end;

    /// <summary>
    /// Allows changing which items are returned just before sending the response.
    /// </summary>
    /// <param name="PageId">The ID of the page for which to retrieve page action data.</param>
    /// <param name="ItemsJsonArray">Allows overriding which items are being returned.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterGetPageActions(PageId: Integer; IncludeViews: Boolean; var ItemsJsonArray: JsonArray)
    begin
    end;
}