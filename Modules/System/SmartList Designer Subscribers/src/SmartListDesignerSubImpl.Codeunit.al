// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 2889 "SmartList Designer Sub Impl."
{
    Access = Internal;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SmartList Designer Triggers", 'GetEnabled', '', false, false)]
    local procedure DefaultGetEnabled(var Enabled: Boolean)
    var
        SmartListDesignerSubscribers: Codeunit "SmartList Designer Subscribers";
        Handled: Boolean;
    begin
        SmartListDesignerSubscribers.OnBeforeDefaultGetEnabled(Handled, Enabled);
        if not Handled then
            Enabled := false;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SmartList Designer Triggers", 'OnCreateNewForTableAndView', '', false, false)]
    local procedure DefaultOnCreateNewForTableAndView(TableId: Integer; ViewId: Text)
    var
        SmartListDesignerSubscribers: Codeunit "SmartList Designer Subscribers";
        Handled: Boolean;
    begin
        SmartListDesignerSubscribers.OnBeforeDefaultCreateNewForTableAndView(Handled, TableId, ViewId);

        // Fallback to old implementation for backwards compat
        if not Handled then
            SmartListDesignerSubscribers.OnBeforeDefaultOnCreateForTable(Handled, TableId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SmartList Designer Triggers", 'OnEditQuery', '', false, false)]
    local procedure DefaultOnEditQuery(QueryId: Text)
    var
        SmartListDesignerSubscribers: Codeunit "SmartList Designer Subscribers";
        Handled: Boolean;
    begin
        SmartListDesignerSubscribers.OnBeforeDefaultOnEditQuery(Handled, QueryId);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SmartList Designer Triggers", 'OnInvalidQueryNavigation', '', false, false)]
    local procedure DefaultOnInvalidQueryNavigation(Id: BigInteger)
    var
        QueryNavigationRec: Record "Query Navigation";
        ValidationResult: Record "Query Navigation Validation";
        SmartListDesignerSubscribers: Codeunit "SmartList Designer Subscribers";
        QueryNavigationValidation: Codeunit "Query Navigation Validation";
        Handled: Boolean;
    begin
        SmartListDesignerSubscribers.OnBeforeDefaultOnInvalidQueryNavigation(Handled, Id);

        // If not handled, find the record and emit an error message with the reason it is not valid
        if not Handled then begin
            QueryNavigationRec.SetRange(Id, Id);
            if QueryNavigationRec.FindFirst() and
               (not QueryNavigationValidation.ValidateNavigation(QueryNavigationRec, ValidationResult)) then
                Error(ValidationResult.Reason);
        end;
    end;
}