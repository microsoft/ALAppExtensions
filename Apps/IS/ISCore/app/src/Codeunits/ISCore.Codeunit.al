
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using Microsoft.Finance.GeneralLedger.IRS;
using Microsoft.Sales.Setup;
using Microsoft.Utilities;

codeunit 14600 "IS Core"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Data Class. Eval. Data Country", OnAfterClassifyCountrySpecificTables, '', false, false)]
    local procedure OnAfterClassifyCountrySpecificTables()
    begin
        ClassifyTablesToNormal();
    end;

#if not CLEAN24
    [Obsolete('The table used to enable IS Core App.', '24.0')]
    [EventSubscriber(ObjectType::Table, Database::"IS Core App Setup", 'OnAfterValidateEvent', 'Enabled', false, false)]
    local procedure OnAfterValidateEnabledISCoreApp(var Rec: Record "IS Core App Setup")
    begin
        if Rec.Enabled then
            Page.Run(PAGE::"IS Core App Setup Wizard");
    end;
#endif

    [EventSubscriber(ObjectType::Table, Database::"Sales & Receivables Setup", 'OnAfterValidateEvent', 'Electronic Invoicing Reminder', false, false)]
    local procedure OnAfterValidateElectronicInvoicing(var Rec: Record "Sales & Receivables Setup")
    var
#if not CLEAN24
        [Obsolete('The table used to enable IS Core App.', '24.0')]
        ISCoreAppSetup: Record "IS Core App Setup";
#endif
    begin
#if not CLEAN24
        if ISCoreAppSetup.Enabled then begin
#endif
            if Rec."Electronic Invoicing Reminder" then
                Message(ReminderMsg);
            Rec.Modify();
#if not CLEAN24
        end;
#endif
    end;

    local procedure ClassifyTablesToNormal()
    var
        DataClassificationEvalData: Codeunit "Data Classification Eval. Data";
    begin
        DataClassificationEvalData.SetTableFieldsToNormal(DATABASE::"IS IRS Numbers");
        DataClassificationEvalData.SetTableFieldsToNormal(DATABASE::"IS IRS Groups");
        DataClassificationEvalData.SetTableFieldsToNormal(DATABASE::"IS IRS Types");
    end;

    internal procedure BlockDeletingPostedDocument(PostingDate: Date)
    var
        ISPostedDocumentDeletion: codeunit "IS Docs Retention Period";
    begin
        ISPostedDocumentDeletion.CheckDocumentDeletionAllowedByLaw(PostingDate);
    end;

    var
        ReminderMsg: Label 'Reminder to read legal restrictions on form and print/send statement';
}