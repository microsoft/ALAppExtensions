#if not CLEAN19
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Collection of the default subscribers to system events and corresponding overridable integration events for the SmartList Designer.
/// </summary>
codeunit 2888 "SmartList Designer Subscribers"
{
    Access = Public;
    ObsoleteState = Pending;
    ObsoleteReason = 'The SmartList Designer is not supported in Business Central.';
    ObsoleteTag = '19.0';

    /// <summary>
    /// Notifies that the Default Get Enabled procedure has been invoked.
    /// Invoked once per session, this is used to indicate if the SmartList Designer and
    /// associated events are supported by the consumer.
    /// </summary>
    /// <param name="Handled">The flag which if set, would stop executing the event.</param>
    /// <param name="Enabled">A value set by subscribers to indicate if the designer supported/enabled.</param> 
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeDefaultGetEnabled(var Handled: Boolean; var Enabled: Boolean)
    begin
    end;

#if not CLEAN17
    /// <summary>
    /// Notifies that the Default On Create For Table procedure has been invoked.
    /// This should open up the designer and initialize it for creating a new SmartList
    /// using the provided TableId to identify the intended root SmartList data item.
    /// </summary>
    /// <param name="Handled">The flag which if set, would stop executing the event.</param> 
    /// <param name="TableId">The ID of the table to be used for the root data item.</param> 
    [IntegrationEvent(false, false)]
    [Obsolete('Use OnBeforeDefaultCreateNewForTableAndView instead', '17.0')]
    internal procedure OnBeforeDefaultOnCreateForTable(var Handled: Boolean; TableId: Integer)
    begin
    end;
#endif

    /// <summary>
    /// Notifies that the Default On Create For Table And View procedure has been invoked.
    /// This should open up the designer and initialize it for creating a new SmartList
    /// using the provided TableId to identify the intended root SmartList data item.
    /// </summary>
    /// <param name="Handled">The flag which if set, would stop executing the event.</param> 
    /// <param name="TableId">The ID of the table to use as the root data item.</param>
    /// <param name="ViewId">An optional view ID token that contains information about the page or view that the user was using before they opened SmartList Designer.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeDefaultCreateNewForTableAndView(var Handled: Boolean; TableId: Integer; ViewId: Text)
    begin
    end;

    /// <summary>
    /// Notifies that the Default On Edit Query procedure has been invoked.
    /// This should open up the designer and initialize it for editing an existing
    /// SmartList. The provide QueryId specifies which SmartList to edit.
    /// </summary>
    /// <param name="Handled">The flag which if set, would stop executing the event.</param>
    /// <param name="QueryId">The ID of the SmartList query that is being edited.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeDefaultOnEditQuery(var Handled: Boolean; QueryId: Text)
    begin
    end;

    /// <summary>
    /// Notiifes that the Default On Invalid Query Navigation procedure has been invoked.
    /// This occurs when a Query Navigation action has been invoked but its definition is 
    /// found to be invalid. Most commonly this would be a result of an extension that the
    /// action depended upon being uninstalled. 
    /// </summary>
    /// <param name="Handled">The flag which if set, would stop executing the event.</param>
    /// <param name="Id">The unique ID of the Query Navigation record that has become invalid.</param> 
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeDefaultOnInvalidQueryNavigation(var Handled: Boolean; Id: BigInteger)
    begin
    end;
}
#endif